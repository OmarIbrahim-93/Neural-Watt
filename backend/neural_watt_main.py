import os
import json
import tempfile
import uvicorn
import pandas as pd
from fastapi import FastAPI, File, UploadFile, Form, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from house_water_consumption_prediction import HouseWaterConsumptionPredictor

# ============================================================
# FASTAPI APP
# ============================================================
app = FastAPI(
    title="NeuralWatt Main API",
    description="Main backend service for NeuralWatt",
    version="1.0.0"
)

# ============================================================
# CORS CONFIGURATION
# ============================================================
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ============================================================
# DATA PROCESSING
# ============================================================
def convert_to_daily_data(csv_file_path: str, duration_months: int, missing_values: list = None):

    """
    Convert cumulative meter readings into daily consumption
    and add missing calendar days.

    Parameters
    ----------
    csv_file_path : str
        Path to the input CSV.

    duration_months : int
        Number of calendar months to include.

    missing_values : list, optional
        User-provided values for missing days.
        Format: [{"date": "2025-01-15", "meter_value": "42.5"}, ...]
        If a missing day has a matching entry, its consumption
        is set to the provided meter_value. Otherwise defaults to 0.

    Process
    -------
        CSV
        ↓
        Sort by timestamp
        ↓
        Calculate interval consumption
        ↓
        Remove negative/reset values
        ↓
        Calculate daily consumption
        ↓
        Create complete calendar date range
        ↓
        Apply user-provided missing values, fill rest with 0
        ↓
        Return complete daily dataset
    """

    # ========================================================
    # 1. VALIDATE DURATION
    # ========================================================

    if not isinstance(
        duration_months,
        int
    ):
        raise ValueError(
            "duration_months must be an integer."
        )

    if duration_months <= 0:
        raise ValueError(
            "duration_months must be greater than 0."
        )


    # ========================================================
    # 2. CHECK FILE
    # ========================================================

    if not os.path.exists(
        csv_file_path
    ):
        raise FileNotFoundError(
            f"CSV file not found: {csv_file_path}"
        )


    # ========================================================
    # 3. READ CSV
    # ========================================================

    df = pd.read_csv(
        csv_file_path
    )

    if df.empty:
        raise ValueError(
            "The CSV file is empty."
        )


    # ========================================================
    # 4. CHECK COLUMNS
    # ========================================================

    if len(df.columns) < 2:
        raise ValueError(
            "CSV must contain at least two columns: "
            "timestamp and meter value."
        )


    # ========================================================
    # 5. IDENTIFY COLUMNS
    # ========================================================

    timestamp_column = df.columns[0]

    meter_column = df.columns[1]


    # ========================================================
    # 6. CONVERT DATA TYPES
    # ========================================================

    df["timestamp"] = pd.to_datetime(
        df[timestamp_column],
        errors="coerce"
    )

    df["meter_value"] = pd.to_numeric(
        df[meter_column],
        errors="coerce"
    )


    # ========================================================
    # 7. REMOVE INVALID DATA
    # ========================================================

    df = df.dropna(
        subset=[
            "timestamp",
            "meter_value"
        ]
    ).copy()


    if df.empty:
        raise ValueError(
            "The CSV does not contain valid timestamp "
            "and meter values."
        )


    # ========================================================
    # 8. SORT CHRONOLOGICALLY
    # ========================================================

    df = (
        df.sort_values(
            "timestamp"
        )
        .reset_index(drop=True)
    )


    # ========================================================
    # 9. CALCULATE INTERVAL CONSUMPTION
    # ========================================================

    df["consumption"] = (
        df["meter_value"].diff()
    )


    # ========================================================
    # 10. REMOVE FIRST READING
    # ========================================================

    df = df.dropna(
        subset=["consumption"]
    ).copy()


    # ========================================================
    # 11. REMOVE NEGATIVE CONSUMPTION
    # ========================================================

    df = df[
        df["consumption"] >= 0
    ].copy()


    if df.empty:
        raise ValueError(
            "No valid consumption values were calculated."
        )


    # ========================================================
    # 12. CREATE CALENDAR DATE
    # ========================================================

    df["date"] = (
        df["timestamp"].dt.normalize()
    )


    # ========================================================
    # 13. CALCULATE DAILY CONSUMPTION
    # ========================================================

    daily_csv = (
        df.groupby(
            "date",
            as_index=False
        )
        .agg(
            consumption=(
                "consumption",
                "sum"
            )
        )
    )


    # ========================================================
    # 14. GET START DATE
    # ========================================================

    start_date = (
        daily_csv["date"].min()
    )


    # ========================================================
    # 15. CALCULATE END DATE
    #
    # Example:
    #
    # start = 2026-01-15
    # months = 6
    #
    # end = 2026-07-15
    #
    # The expected range is:
    #
    # 2026-01-15 → 2026-07-14
    # ========================================================

    end_date = (
        start_date
        + pd.DateOffset(
            months=duration_months
        )
        - pd.Timedelta(days=1)
    )


    # ========================================================
    # 16. CREATE COMPLETE CALENDAR
    # ========================================================

    complete_dates = pd.date_range(
        start=start_date,
        end=end_date,
        freq="D"
    )


    # ========================================================
    # 17. REINDEX DATASET
    #
    # Missing dates will automatically become NaN.
    # ========================================================

    daily_csv = (
        daily_csv
        .set_index("date")
        .reindex(complete_dates)
    )


    # ========================================================
    # 18. RENAME DATE INDEX
    # ========================================================

    daily_csv.index.name = "date"


    # ========================================================
    # 19. APPLY USER-PROVIDED MISSING VALUES, FILL REST WITH 0
    # ========================================================

    if missing_values:
        for entry in missing_values:
            try:
                date_key = entry.get("date", "")
                val_str = entry.get("meter_value", "")
                dt = pd.to_datetime(date_key, dayfirst=True).normalize()
                mask = daily_csv["date"] == dt
                if mask.any():
                    daily_csv.loc[mask, "consumption"] = float(val_str)
            except:
                pass

    # Any remaining missing days (NaN) default to 0
    daily_csv["consumption"] = (
        daily_csv["consumption"]
        .fillna(0)
    )


    # ========================================================
    # 20. RESET INDEX
    # ========================================================

    daily_csv = (
        daily_csv
        .reset_index()
    )


    # ========================================================
    # 21. ADD MISSING-DAY FLAG
    # ========================================================

    # 1 = day originally missing
    # 0 = day originally existed

    original_dates = set(
        pd.to_datetime(
            df["date"]
        ).dt.normalize()
    )

    daily_csv["is_missing_day"] = (
        ~daily_csv["date"].isin(
            original_dates
        )
    ).astype(int)


    # ========================================================
    # 22. SORT
    # ========================================================

    daily_csv = (
        daily_csv
        .sort_values("date")
        .reset_index(drop=True)
    )


    # ========================================================
    # 23. RETURN
    # ========================================================

    return daily_csv

# ============================================================
# ENDPOINTS
# ============================================================
@app.post("/api/predict")
async def predict_consumption(
    resource_type: str = Form(...),
    environment_type: str = Form(...),
    facility_subtype: str = Form(...),
    holiday_usage: str = Form(...),
    holiday_days: str = Form(""),
    duration_months: int = Form(...),
    has_missing_days: str = Form(...),
    data_handling_method: str = Form(...),
    missing_values: str = Form(None),
    file: UploadFile = File(...)
):
    try:
        # 1. Save uploaded file to a temporary file
        with tempfile.NamedTemporaryFile(delete=False, suffix=".csv") as tmp:
            content = await file.read()
            tmp.write(content)
            tmp_path = tmp.name

        # 2. Parse missing values from the user (if any)
        # Expected format: [{"date": "2025-01-15", "meter_value": "42.5"}, ...]
        parsed_missing = []
        if missing_values:
            try:
                parsed_missing = json.loads(missing_values)
            except:
                pass

        # 3. Convert to daily data — missing values are applied inside
        daily_csv = convert_to_daily_data(tmp_path, duration_months, missing_values=parsed_missing)

        # 3.5 Perform Analytics
        from Analytics import Analytics
        analytics_results, _ = Analytics(daily_csv, resource_type, environment_type, facility_subtype)

        # Clean up temp file
        os.remove(tmp_path)

        # 4. Route to the appropriate resource logic
        resource_type_lower = resource_type.lower()
        if resource_type_lower == "water":
            from water_consumption import process_water_consumption
            prediction_result = process_water_consumption(
                daily_csv, environment_type, facility_subtype, holiday_usage, holiday_days, duration_months, data_handling_method
            )
        elif resource_type_lower == "electricity":
            from electricity_consumption import process_electricity_consumption
            prediction_result = process_electricity_consumption(
                daily_csv, environment_type, facility_subtype, holiday_usage, holiday_days, duration_months, data_handling_method
            )
        elif resource_type_lower == "gas":
            from gas_consumption import process_gas_consumption
            prediction_result = process_gas_consumption(
                daily_csv, environment_type, facility_subtype, holiday_usage, holiday_days, duration_months, data_handling_method
            )
        else:
            raise ValueError(f"Unknown resource type: {resource_type}")

        if not isinstance(prediction_result, dict):
            prediction_result = {}
            
        actual_val = analytics_results.get("last_1_months", {}).get("total_consumption", round(float(daily_csv["consumption"].sum()), 2))
        waste_amt = prediction_result.get("waste", {}).get("waste_month", "N/A")
        
        facility_data = {
            "name": "User Facility",
            "type": environment_type,
            "location": "Local",
            resource_type_lower: {
                "actual": actual_val,
                "baseline": "N/A",
                "waste": waste_amt,
                "current_tier": "N/A",
                "current_rate": "N/A",
                "target_limit": "N/A",
                "target_rate": "N/A",
                "notes": f"Occupants/Units: {facility_subtype}"
            }
        }
        
        from LLM_Advices import generate_energy_advice
        llm_advices = generate_energy_advice(facility_data)

        return {
            "status": "success",
            "message": "Prediction processed successfully.",
            "total_days": len(daily_csv),
            "total_consumption": round(float(daily_csv["consumption"].sum()), 2),
            "next_day_prediction": prediction_result.get("next_day"),
            "next_week_prediction": prediction_result.get("next_week"),
            "next_month_prediction": prediction_result.get("next_month"),
            "next_quarter_prediction": prediction_result.get("next_quarter"),
            "waste": prediction_result.get("waste"),
            "analytics": analytics_results,
            "llm_advices": llm_advices,
            "parameters": {
                "resource_type": resource_type,
                "environment_type": environment_type,
                "facility_subtype": facility_subtype,
                "holiday_usage": holiday_usage,
                "holiday_days": holiday_days,
                "data_handling_method": data_handling_method
            }
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/")
def root():
    return {"message": "Welcome to NeuralWatt Main API"}

@app.get("/health")
def health_check():
    return {
        "status": "ok", 
        "service": "NeuralWatt Main Backend"
    }

# ============================================================
# RUN SERVER
# ============================================================
if __name__ == "__main__":
    # Running on port 8005 so it doesn't conflict with app.py which runs on 8000
    uvicorn.run(
        "neural_watt_main:app",
        host="127.0.0.1",
        port=8005,
        reload=True
    )
