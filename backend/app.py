import os
import tempfile
import pandas as pd
from fastapi import FastAPI, UploadFile, File, Form, HTTPException
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="NeuralWatt Consumption API")

# Enable CORS for Flutter web / desktop / mobile local connections
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def find_missing_consumption_hours(csv_file_path: str, duration_months: int):
    """
    Find missing hourly consumption records.
    Input CSV can use ('date' or 'timestamp') and ('consumption' or 'consumption_kwh').
    """
    if not isinstance(duration_months, int):
        raise ValueError("duration_months must be an integer.")

    if duration_months < 2 or duration_months > 12:
        raise ValueError("duration_months must be between 2 and 12.")

    if not os.path.exists(csv_file_path):
        raise FileNotFoundError(f"CSV file not found: {csv_file_path}")

    df = pd.read_csv(csv_file_path)

    # Normalize column names for flexibility
    col_map = {}
    for col in df.columns:
        c_lower = col.strip().lower()
        if c_lower in ["date", "timestamp", "time"]:
            col_map[col] = "date"
        elif c_lower in ["consumption", "consumption_kwh", "kwh", "usage", "value"]:
            col_map[col] = "consumption"

    df = df.rename(columns=col_map)

    required_columns = ["date", "consumption"]
    missing_columns = [col for col in required_columns if col not in df.columns]
    if missing_columns:
        raise ValueError(f"Missing required columns: {missing_columns}. Found columns: {list(df.columns)}")

    df["date"] = pd.to_datetime(df["date"], errors="coerce")
    df = df.dropna(subset=["date"]).copy()
    df = df.sort_values(by="date").reset_index(drop=True)

    if len(df) == 0:
        raise ValueError("The CSV does not contain valid timestamp data.")

    start_date = df.loc[0, "date"]
    end_date = start_date + pd.DateOffset(months=duration_months)

    df_period = df[(df["date"] >= start_date) & (df["date"] < end_date)].copy()

    expected_hours = pd.date_range(
        start=start_date,
        end=end_date - pd.Timedelta(hours=1),
        freq="h"
    )

    existing_hours = pd.DatetimeIndex(df_period["date"].drop_duplicates())
    missing_hours = expected_hours.difference(existing_hours)

    missing_hours_df = pd.DataFrame({"date": missing_hours})
    if len(missing_hours_df) > 0:
        missing_hours_df["day"] = missing_hours_df["date"].dt.date
        missing_hours_df["hour"] = missing_hours_df["date"].dt.hour
        missing_hours_df = missing_hours_df.sort_values("date").reset_index(drop=True)

        missing_days_df = (
            missing_hours_df.groupby("day")
            .agg(
                missing_hours=("date", "count"),
                first_missing_hour=("date", "min"),
                last_missing_hour=("date", "max"),
            )
            .reset_index()
        )

        missing_days_df["day_status"] = missing_days_df["missing_hours"].apply(
            lambda x: "FULL DAY MISSING" if x == 24 else "PARTIALLY MISSING"
        )
    else:
        missing_days_df = pd.DataFrame(
            columns=["day", "missing_hours", "first_missing_hour", "last_missing_hour", "day_status"]
        )

    expected_hours_count = len(expected_hours)
    existing_hours_count = len(existing_hours)
    missing_hours_count = len(missing_hours_df)
    missing_days_count = len(missing_days_df)
    
    total_expected_days = (end_date - start_date).days
    total_missing_days = missing_days_count
    total_available_days = total_expected_days - total_missing_days
    
    completeness_percentage = round((existing_hours_count / expected_hours_count * 100), 1) if expected_hours_count > 0 else 100.0

    # Format output JSON
    missing_hours_list = []
    if len(missing_hours_df) > 0:
        for _, row in missing_hours_df.iterrows():
            missing_hours_list.append({
                "date": row["date"].strftime("%Y-%m-%d %H:%M:%S"),
                "day": str(row["day"]),
                "hour": int(row["hour"]),
            })

    missing_days_list = []
    if len(missing_days_df) > 0:
        for _, row in missing_days_df.iterrows():
            missing_days_list.append({
                "day": str(row["day"]),
                "missing_hours": int(row["missing_hours"]),
                "first_missing_hour": pd.to_datetime(row["first_missing_hour"]).strftime("%Y-%m-%d %H:%M:%S"),
                "last_missing_hour": pd.to_datetime(row["last_missing_hour"]).strftime("%Y-%m-%d %H:%M:%S"),
                "day_status": str(row["day_status"]),
            })

    return {
        "success": True,
        "duration_months": duration_months,
        "start_date": start_date.strftime("%Y-%m-%d %H:%M:%S"),
        "end_date": end_date.strftime("%Y-%m-%d %H:%M:%S"),
        "expected_hours_count": expected_hours_count,
        "existing_hours_count": existing_hours_count,
        "missing_hours_count": missing_hours_count,
        "expected_days_count": total_expected_days,
        "available_days_count": total_available_days,
        "missing_days_count": total_missing_days,
        "completeness_percentage": completeness_percentage,
        "missing_hours": missing_hours_list,
        "missing_days": missing_days_list,
    }


@app.get("/health")
def health_check():
    return {"status": "ok", "service": "NeuralWatt Backend API"}


@app.post("/api/analyze-consumption")
async def analyze_consumption(
    file: UploadFile = File(...),
    duration_months: int = Form(6),
):
    try:
        # Save temporary CSV file to disk
        contents = await file.read()
        with tempfile.NamedTemporaryFile(delete=False, suffix=".csv") as tmp:
            tmp.write(contents)
            tmp_path = tmp.name

        try:
            result = find_missing_consumption_hours(tmp_path, duration_months)
            return result
        finally:
            if os.path.exists(tmp_path):
                os.remove(tmp_path)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)
