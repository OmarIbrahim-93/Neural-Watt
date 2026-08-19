import os
import tempfile
import pandas as pd

from fastapi import FastAPI, UploadFile, File, Form, HTTPException
from fastapi.middleware.cors import CORSMiddleware


# ============================================================
# FASTAPI APP
# ============================================================

app = FastAPI(title="NeuralWatt Consumption API")


# ============================================================
# CORS
# ============================================================

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ============================================================
# CONVERT ANY FREQUENCY DATA TO DAILY DATA
# ============================================================

def convert_to_daily_data(csv_file_path: str):

    """
    Convert CSV data from any time frequency to daily data.

    Supported examples:

        1 minute
        5 minutes
        15 minutes
        30 minutes
        1 hour
        etc.

    Expected CSV structure:

        Column 1 -> timestamp/date
        Column 2 -> meter/consumption value

    Example:

        timestamp              meter_value
        2026-01-01 00:00:00    10
        2026-01-01 00:05:00    12
        2026-01-01 00:10:00    8

    Result:

        date          meter_value
        2026-01-01    30
    """

    # --------------------------------------------------------
    # Check file
    # --------------------------------------------------------

    if not os.path.exists(csv_file_path):
        raise FileNotFoundError(
            f"CSV file not found: {csv_file_path}"
        )

    # --------------------------------------------------------
    # Read CSV
    # --------------------------------------------------------

    df = pd.read_csv(csv_file_path)

    if df.empty:
        raise ValueError("The CSV file is empty.")

    # --------------------------------------------------------
    # Check columns
    # --------------------------------------------------------

    if len(df.columns) < 2:
        raise ValueError(
            "CSV must contain at least two columns: "
            "timestamp and meter value."
        )

    # --------------------------------------------------------
    # First column = timestamp
    # Second column = meter value
    # --------------------------------------------------------

    timestamp_column = df.columns[0]
    meter_column = df.columns[1]

    # --------------------------------------------------------
    # Convert timestamp
    # --------------------------------------------------------

    df["timestamp"] = pd.to_datetime(
        df[timestamp_column],
        errors="coerce"
    )

    # --------------------------------------------------------
    # Remove invalid timestamps
    # --------------------------------------------------------

    df = df.dropna(
        subset=["timestamp"]
    ).copy()

    if df.empty:
        raise ValueError(
            "The CSV does not contain valid timestamp data."
        )

    # --------------------------------------------------------
    # Convert meter value to numeric
    # --------------------------------------------------------

    df["meter_value"] = pd.to_numeric(
        df[meter_column],
        errors="coerce"
    )

    # --------------------------------------------------------
    # Remove invalid meter values
    # --------------------------------------------------------

    df = df.dropna(
        subset=["meter_value"]
    ).copy()

    if df.empty:
        raise ValueError(
            "The CSV does not contain valid meter values."
        )

    # --------------------------------------------------------
    # Sort by timestamp
    # --------------------------------------------------------

    df = df.sort_values(
        by="timestamp"
    ).reset_index(drop=True)

    # --------------------------------------------------------
    # Convert timestamp → calendar date
    # --------------------------------------------------------

    df["date"] = df["timestamp"].dt.normalize()

    # --------------------------------------------------------
    # GROUP BY DAY
    #
    # Sum all meter/consumption values belonging
    # to the same calendar day.
    # --------------------------------------------------------

    daily_df = (
        df.groupby("date", as_index=False)
        .agg(
            meter_value=("meter_value", "sum")
        )
    )

    # --------------------------------------------------------
    # Sort daily data
    # --------------------------------------------------------

    daily_df = daily_df.sort_values(
        by="date"
    ).reset_index(drop=True)

    return daily_df


# ============================================================
# FIND MISSING DAYS
# ============================================================

def find_missing_consumption_days(csv_file_path: str,duration_months: int):

    """
    Complete pipeline:

        CSV
        ↓
        Detect timestamp
        ↓
        Convert timestamp → date
        ↓
        Group by calendar day
        ↓
        Sum meter values
        ↓
        Create one row per day
        ↓
        Check missing days
        ↓
        Return results
    """

    # --------------------------------------------------------
    # Validate duration
    # --------------------------------------------------------

    if not isinstance(duration_months, int):
        raise ValueError(
            "duration_months must be an integer."
        )

    if duration_months < 2 or duration_months > 12:
        raise ValueError(
            "duration_months must be between 2 and 12."
        )

    # --------------------------------------------------------
    # Convert source data to daily data
    # --------------------------------------------------------

    daily_df = convert_to_daily_data(csv_file_path)

    if daily_df.empty:
        raise ValueError("No valid daily data was created.")

    # --------------------------------------------------------
    # First available date
    # --------------------------------------------------------

    start_date = daily_df["date"].min()

    # --------------------------------------------------------
    # Calculate end date
    #
    # Uses calendar months.
    #
    # Example:
    #
    # Jan 1 + 6 months = July 1
    # --------------------------------------------------------

    end_date = (start_date + pd.DateOffset(months=duration_months))

    # --------------------------------------------------------
    # Create expected calendar days
    # --------------------------------------------------------

    expected_days = pd.date_range(
        start=start_date,
        end=end_date - pd.Timedelta(days=1),
        freq="D"
    )

    # --------------------------------------------------------
    # Available days
    # --------------------------------------------------------

    available_days = pd.DatetimeIndex(
        daily_df["date"].drop_duplicates()
    )

    # --------------------------------------------------------
    # Find missing days
    # --------------------------------------------------------

    missing_days = expected_days.difference(
        available_days
    )

    # --------------------------------------------------------
    # Calculate statistics
    # --------------------------------------------------------

    total_expected_days = len(
        expected_days
    )

    total_available_days = len(
        expected_days.intersection(
            available_days
        )
    )

    total_missing_days = len(
        missing_days
    )

    # --------------------------------------------------------
    # Completeness
    # --------------------------------------------------------

    if total_expected_days > 0:

        completeness_percentage = round((total_available_days/ total_expected_days) * 100,2)

    else:

        completeness_percentage = 100.0

    # --------------------------------------------------------
    # Format missing days
    # --------------------------------------------------------

    missing_days_list = [
        {
            "day": day.strftime("%Y-%m-%d"),
            "missing_hours": 24,
            "first_missing_hour": f"{day.strftime('%Y-%m-%d')} 00:00:00",
            "last_missing_hour": f"{day.strftime('%Y-%m-%d')} 23:00:00",
            "day_status": "Missing"
        }
        for day in missing_days
    ]

    # --------------------------------------------------------
    # Return results
    # --------------------------------------------------------

    return {
        "success": True,
        "duration_months": duration_months,
        "start_date": start_date.strftime("%Y-%m-%d %H:%M:%S") if pd.notnull(start_date) else None,
        "end_date": end_date.strftime("%Y-%m-%d %H:%M:%S") if pd.notnull(end_date) else None,
        "expected_hours_count": total_expected_days * 24,
        "existing_hours_count": total_available_days * 24,
        "missing_hours_count": total_missing_days * 24,
        "expected_days_count": total_expected_days,
        "available_days_count": total_available_days,
        "missing_days_count": total_missing_days,
        "completeness_percentage": completeness_percentage,
        "missing_hours": [],
        "missing_days": missing_days_list
    }


# ============================================================
# HEALTH CHECK
# ============================================================

@app.get("/health")
def health_check():

    return {
        "status": "ok",
        "service": "NeuralWatt Backend API"
    }


# ============================================================
# ANALYZE CONSUMPTION
# ============================================================

@app.post("/api/analyze-consumption")
async def analyze_consumption(
    file: UploadFile = File(...),

    duration_months: int = Form(6)
):

    try:

        # ----------------------------------------------------
        # Read uploaded CSV
        # ----------------------------------------------------

        contents = await file.read()

        # ----------------------------------------------------
        # Save temporary CSV
        # ----------------------------------------------------

        with tempfile.NamedTemporaryFile(
            delete=False,
            suffix=".csv"
        ) as tmp:

            tmp.write(contents)

            tmp_path = tmp.name

        try:

            # ------------------------------------------------
            # Run analysis
            # ------------------------------------------------

            result = find_missing_consumption_days(
                tmp_path,
                duration_months
            )

            return result

        finally:

            # ------------------------------------------------
            # Delete temporary file
            # ------------------------------------------------

            if os.path.exists(tmp_path):

                os.remove(tmp_path)

    except Exception as e:

        raise HTTPException(
            status_code=400,
            detail=str(e)
        )


# ============================================================
# RUN SERVER
# ============================================================

if __name__ == "__main__":

    import uvicorn

    uvicorn.run(
        app,
        host="127.0.0.1",
        port=8000
    )