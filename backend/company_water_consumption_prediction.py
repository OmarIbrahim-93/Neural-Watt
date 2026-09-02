import os
import joblib
import numpy as np
import pandas as pd
from pathlib import Path

# ============================================================
# HELPER FUNCTIONS (From AQUAGUARD AI)
# ============================================================

def safe_mape(y_true, y_pred):
    y_true = np.asarray(y_true)
    y_pred = np.asarray(y_pred)
    mask = np.abs(y_true) > 1e-9
    if mask.sum() == 0:
        return np.nan
    return np.mean(np.abs((y_true[mask] - y_pred[mask]) / y_true[mask])) * 100


def create_time_features(df):
    df = df.copy()
    df["year"] = df["period"].dt.year
    df["month"] = df["period"].dt.month
    df["quarter"] = df["period"].dt.quarter
    df["weekofyear"] = df["period"].dt.isocalendar().week.astype(int)
    df["dayofyear"] = df["period"].dt.dayofyear
    df["dayofmonth"] = df["period"].dt.day
    df["days_in_month"] = df["period"].dt.days_in_month
    df["month_sin"] = np.sin(2 * np.pi * df["month"] / 12)
    df["month_cos"] = np.cos(2 * np.pi * df["month"] / 12)
    df["quarter_sin"] = np.sin(2 * np.pi * df["quarter"] / 4)
    df["quarter_cos"] = np.cos(2 * np.pi * df["quarter"] / 4)
    df["week_sin"] = np.sin(2 * np.pi * df["weekofyear"] / 52)
    df["week_cos"] = np.cos(2 * np.pi * df["weekofyear"] / 52)
    return df


def create_lag_features(df, lags, rolling_windows):
    df = df.copy()
    grouped = df.groupby("building_id")["consumption"]

    for lag in lags:
        df[f"lag_{lag}"] = grouped.shift(lag)

    for window in rolling_windows:
        df[f"rolling_mean_{window}"] = grouped.transform(
            lambda x: x.shift(1).rolling(window=window, min_periods=max(1, window // 2)).mean()
        )
        df[f"rolling_std_{window}"] = grouped.transform(
            lambda x: x.shift(1).rolling(window=window, min_periods=max(2, window // 2)).std()
        )
        df[f"rolling_max_{window}"] = grouped.transform(
            lambda x: x.shift(1).rolling(window=window, min_periods=max(1, window // 2)).max()
        )
        df[f"rolling_min_{window}"] = grouped.transform(
            lambda x: x.shift(1).rolling(window=window, min_periods=max(1, window // 2)).min()
        )
    return df


def load_and_preprocess(data_path, config):
    df = pd.read_csv(data_path)

    timestamp_candidates = ["timestamp", "datetime", "date_time", "date", "time", "DateTime", "Timestamp"]
    timestamp_col = next((c for c in timestamp_candidates if c in df.columns), None)
    if timestamp_col is None:
        timestamp_col = next((c for c in df.columns if "time" in c.lower() or "date" in c.lower()), None)
    if timestamp_col is None:
        raise ValueError("Could not detect timestamp column in dataset.")

    df.rename(columns={timestamp_col: "timestamp"}, inplace=True)
    df["timestamp"] = pd.to_datetime(df["timestamp"], errors="coerce")
    df = df.dropna(subset=["timestamp"]).drop_duplicates(subset=["timestamp"]).sort_values("timestamp").reset_index(drop=True)

    if "building_id" in df.columns and "consumption" in df.columns:
        long_df = df[["timestamp", "building_id", "consumption"]].copy()
    else:
        building_cols = [c for c in df.columns if c != "timestamp"]
        for c in building_cols:
            df[c] = pd.to_numeric(df[c], errors="coerce")
            df.loc[df[c] < 0, c] = np.nan
        long_df = df.melt(id_vars=["timestamp"], value_vars=building_cols, var_name="building_id", value_name="consumption")

    long_df["consumption"] = pd.to_numeric(long_df["consumption"], errors="coerce")
    
    aggregated = (
        long_df.set_index("timestamp")
        .groupby("building_id")["consumption"]
        .resample(config["rule"])
        .sum()
        .reset_index()
        .rename(columns={"timestamp": "period"})
    )
    aggregated = aggregated.dropna(subset=["consumption"]).sort_values(["building_id", "period"]).reset_index(drop=True)
    return aggregated

# ============================================================
# MAIN FORECASTING FUNCTION
# ============================================================

def forecast_universal_water(csv_path, sample_building_id=None):
    """
    Forecasting using AQUAGUARD AI logic for Day, Week, Month, Quarter
    """
    print("=" * 75)
    print("      AQUAGUARD AI - WATER INFERENCE ENGINE (MULTI-HORIZON)      ")
    print("=" * 75)
    
    # Model Paths
    BASE_DIR = os.path.dirname(os.path.abspath(__file__))
    MODELS = {
        "Target_Next_Day": os.path.join(BASE_DIR, "..", "Models", "Water", "Company", "daily_final_xgboost_model.pkl"),
        "Target_Next_Week": os.path.join(BASE_DIR, "..", "Models", "Water", "Company", "weekly_final_xgboost_model.pkl"),
        "Target_Next_Month": os.path.join(BASE_DIR, "..", "Models", "Water", "Company", "monthly_final_xgboost_model.pkl"),
        "Target_Next_Quarter": os.path.join(BASE_DIR, "..", "Models", "Water", "Company", "quarterly_final_xgboost_model.pkl")
    }

    forecast_results = {}

    for target_key, model_path in MODELS.items():
        if not os.path.exists(model_path):
            print(f"⚠️ Model path {model_path} not found. Skipping {target_key}.")
            forecast_results[target_key] = 0.0
            continue

        try:
            bundle = joblib.load(model_path)
            model = bundle["model"]
            feature_cols = bundle["feature_columns"]
            config = bundle["config"]
            building_mapping = bundle["building_mapping"]
            site_mapping = bundle["site_mapping"]
            type_mapping = bundle["type_mapping"]
            building_stats = bundle["building_stats"]
            
            # 1. Load and resample
            aggregated = load_and_preprocess(csv_path, config)
            history = aggregated.copy().sort_values(["building_id", "period"]).reset_index(drop=True)
            
            if sample_building_id:
                history = history[history["building_id"] == sample_building_id].copy()

            if len(history) == 0:
                print(f"⚠️ No data for {sample_building_id} in {target_key}. Skipping.")
                forecast_results[target_key] = 0.0
                continue

            last_period = history["period"].max()

            # Date Increment
            if config["rule"] == "D":
                next_period = last_period + pd.Timedelta(days=1)
            elif "W" in config["rule"]:
                next_period = last_period + pd.Timedelta(weeks=1)
            elif "MS" in config["rule"] or "M" in config["rule"]:
                next_period = last_period + pd.offsets.MonthBegin(1)
            elif "QS" in config["rule"] or "Q" in config["rule"]:
                next_period = last_period + pd.offsets.QuarterBegin(1)
            else:
                next_period = last_period + pd.Timedelta(days=1)

            current_step = history.sort_values("period").groupby("building_id").tail(1).copy()
            current_step["period"] = next_period

            current_step["site"] = current_step["building_id"].apply(lambda x: x.split("_")[0] if "_" in x else "Unknown")
            current_step["building_type"] = current_step["building_id"].apply(lambda x: x.split("_")[1] if len(x.split("_")) > 1 else "Unknown")
            current_step["building_encoded"] = current_step["building_id"].map(building_mapping).fillna(-1).astype("int32")
            current_step["site_encoded"] = current_step["site"].map(site_mapping).fillna(-1).astype("int32")
            current_step["building_type_encoded"] = current_step["building_type"].map(type_mapping).fillna(-1).astype("int32")

            current_step = create_time_features(current_step)

            for col in ["building_mean", "building_std", "building_median", "building_min", "building_max"]:
                if col not in current_step.columns:
                    current_step = current_step.merge(building_stats[["building_id", col]], on="building_id", how="left")

            # Compute Lags
            for lag in config["lags"]:
                current_step[f"lag_{lag}"] = history.groupby("building_id")["consumption"].nth(-lag).values

            # Compute Rolling Statistics
            for w in config["rolling"]:
                tail_slice = history.groupby("building_id")["consumption"].apply(lambda s: s.iloc[-w:])
                current_step[f"rolling_mean_{w}"] = tail_slice.groupby("building_id").mean().values
                current_step[f"rolling_std_{w}"] = tail_slice.groupby("building_id").std().fillna(0).values
                current_step[f"rolling_max_{w}"] = tail_slice.groupby("building_id").max().values
                current_step[f"rolling_min_{w}"] = tail_slice.groupby("building_id").min().values

            X_step = current_step[feature_cols].replace([np.inf, -np.inf], np.nan).fillna(0)
            
            # Predict and sum across all building_ids (if sample_building_id was not provided, we sum the totals)
            predictions = model.predict(X_step).clip(min=0)
            total_pred = float(np.sum(predictions))
            
            forecast_results[target_key] = max(0.0, total_pred)
            print(f"🔮 {target_key:<20} | {total_pred:>10,.2f} m3")

        except Exception as e:
            print(f"⚠️ Error running {target_key}: {e}")
            forecast_results[target_key] = 0.0

    print("=" * 75)
    return forecast_results


def process_company_water(df, facility_subtype, holiday_usage, holiday_days, duration_months, data_handling_method, facility_size="small"):
    """
    Processes company water consumption data.
    """
    csv_path = "Actual_daily_consumption.csv"
    if not os.path.exists(csv_path):
        df.to_csv(csv_path, index=False)
            
    try:
        forecast = forecast_universal_water(csv_path)
    except Exception as e:
        print(f"Error in utility pipeline: {e}")
        forecast = {}

    def calc_waste(pred, factor=1.0):
        if not pred: return 0.0, 0.0
        # Since water thresholds weren't provided differently, we use the same electricity ones as agreed
        water_thresholds = {
            'Bakery': {'small': 5000, 'medium': 20000, 'large': 60000},
            'Office': {'small': 2500, 'medium': 10000, 'large': 30000},
            'Hotel': {'small': 10000, 'medium': 40000, 'large': 120000},
            'Restaurant': {'small': 8000, 'medium': 30000, 'large': 100000},
            'School': {'small': 3000, 'medium': 12000, 'large': 35000},
            'SuperMarket': {'small': 10000, 'medium': 50000, 'large': 150000},
        }
        base_threshold = 2500
        if facility_subtype in water_thresholds:
            size = facility_size.lower() if facility_size else 'small'
            if size not in water_thresholds[facility_subtype]:
                size = 'small'
            base_threshold = water_thresholds[facility_subtype][size]
        
        limit = base_threshold * factor
        if pred > limit:
            waste_amt = pred - limit
            waste_pct = (waste_amt / limit) * 100
            return round(waste_amt, 2), round(waste_pct, 2)
        return 0.0, 0.0

    day_amt, day_pct = calc_waste(forecast.get("Target_Next_Day"), factor=1/30)
    week_amt, week_pct = calc_waste(forecast.get("Target_Next_Week"), factor=1/4)
    month_amt, month_pct = calc_waste(forecast.get("Target_Next_Month"), factor=1.0)
    quarter_amt, quarter_pct = calc_waste(forecast.get("Target_Next_Quarter"), factor=3.0)

    waste_dict = {
        "waste_day": day_amt,
        "waste_day_pct": day_pct,
        "waste_week": week_amt,
        "waste_week_pct": week_pct,
        "waste_month": month_amt,
        "waste_month_pct": month_pct,
        "waste_quarter": quarter_amt,
        "waste_quarter_pct": quarter_pct,
    }

    prediction_result = {
        "next_day": forecast.get("Target_Next_Day"),
        "next_week": forecast.get("Target_Next_Week"),
        "next_month": forecast.get("Target_Next_Month"),
        "next_quarter": forecast.get("Target_Next_Quarter"),
        "next_semi_annual": forecast.get("Target_Next_SemiAnnual", 0.0),
        "next_annual": forecast.get("Target_Next_Annual", 0.0),
        "waste": waste_dict
    }
    
    return prediction_result
