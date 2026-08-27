import sys
import os
import warnings

warnings.filterwarnings("ignore")

import numpy as np
import pandas as pd
import joblib
import tensorflow as tf

from sklearn.metrics import (
    mean_absolute_error,
    mean_squared_error,
    r2_score
)

# ============================================================
# CONFIGURATION
# ============================================================

MODEL_PATH = "../Models/Electricity/House/resnet_model.keras"
SCALER_PATH = "../Models/Electricity/House/scaler.pkl"

OUTPUT_PATH = "resnet_predictions.csv"

WINDOW_SIZE = 60

FEATURE_COLS = [
    "hour",
    "day_of_week",
    "day",
    "month",
    "quarter",
    "is_weekend",
    "lag_1",
    "lag_60",
    "lag_1440"
]

TARGET = "consumption"

# ============================================================
# LOAD MODEL + SCALER
# ============================================================

def load_model_and_scaler():
    print("Loading ResNet model...")

    if not os.path.exists(MODEL_PATH):
        raise FileNotFoundError(
            f"Model not found: {MODEL_PATH}"
        )

    if not os.path.exists(SCALER_PATH):
        raise FileNotFoundError(
            f"Scaler not found: {SCALER_PATH}"
        )

    model = tf.keras.models.load_model(MODEL_PATH)
    scaler = joblib.load(SCALER_PATH)

    print("Model loaded successfully.")
    print("Scaler loaded successfully.")

    return model, scaler

# ============================================================
# PREPROCESSING
# ============================================================

def preprocess_data(csv_path):
    print("\nReading CSV...")
    df = pd.read_csv(csv_path)
    print("Original shape:", df.shape)

    # --------------------------------------------------------
    # Replace ? with NaN
    # --------------------------------------------------------
    df = df.replace("?", np.nan)

    # --------------------------------------------------------
    # Convert numeric columns
    # --------------------------------------------------------
    numeric_columns = [
        "consumption",
        "Global_active_power",
        "Global_reactive_power",
        "Voltage",
        "Global_intensity",
        "Sub_metering_1",
        "Sub_metering_2",
        "Sub_metering_3"
    ]

    for col in numeric_columns:
        if col in df.columns:
            df[col] = pd.to_numeric(
                df[col],
                errors="coerce"
            )

    # --------------------------------------------------------
    # Check target
    # --------------------------------------------------------
    if TARGET not in df.columns:
        raise ValueError(
            f"CSV must contain '{TARGET}' "
            "to calculate MAE, RMSE and R²."
        )

    # --------------------------------------------------------
    # Create timestamp
    # --------------------------------------------------------
    if "Datetime" in df.columns:
        df["timestamp"] = pd.to_datetime(
            df["Datetime"],
            dayfirst=True,
            errors="coerce"
        )
    elif "Date" in df.columns and "Time" in df.columns:
        df["timestamp"] = pd.to_datetime(
            df["Date"] + " " + df["Time"],
            dayfirst=True,
            errors="coerce"
        )
    else:
        raise ValueError(
            "CSV must contain either 'Datetime' OR both 'Date' and 'Time'."
        )

    df = df.dropna(
        subset=["timestamp"]
    )

    # --------------------------------------------------------
    # Sort
    # --------------------------------------------------------
    df = df.sort_values("timestamp")

    # --------------------------------------------------------
    # Remove duplicate timestamps
    # --------------------------------------------------------
    df = df.drop_duplicates(
        subset=["timestamp"],
        keep="first"
    )

    # --------------------------------------------------------
    # Set timestamp
    # --------------------------------------------------------
    df = df.set_index("timestamp")

    # --------------------------------------------------------
    # Interpolate missing values
    # --------------------------------------------------------
    available_numeric = [
        col for col in numeric_columns
        if col in df.columns
    ]

    df[available_numeric] = (
        df[available_numeric]
        .interpolate(method="time")
        .ffill()
        .bfill()
    )

    # ========================================================
    # FEATURE ENGINEERING
    # ========================================================
    print("Creating features...")

    df["hour"] = df.index.hour
    df["day_of_week"] = df.index.dayofweek
    df["day"] = df.index.day
    df["month"] = df.index.month
    df["quarter"] = df.index.quarter
    df["is_weekend"] = (
        df["day_of_week"] >= 5
    ).astype(int)

    # --------------------------------------------------------
    # Lag features
    # --------------------------------------------------------
    df["lag_1"] = df[TARGET].shift(1)
    df["lag_60"] = df[TARGET].shift(60)
    df["lag_1440"] = df[TARGET].shift(1440)

    # --------------------------------------------------------
    # Remove NaN
    # --------------------------------------------------------
    df = df.dropna()

    print(
        "Shape after preprocessing:",
        df.shape
    )

    X = df[FEATURE_COLS].copy()
    y = df[TARGET].copy()

    return df, X, y

# ============================================================
# CREATE SEQUENCES
# ============================================================

def create_sequences(X, y, window_size):
    X_seq = []
    y_seq = []

    for i in range(window_size, len(X)):
        X_seq.append(
            X[i - window_size:i]
        )
        y_seq.append(
            y[i]
        )

    return (
        np.array(X_seq),
        np.array(y_seq)
    )

# ============================================================
# TEST MODEL
# ============================================================

def test_model(model, scaler, X, y):
    print("\nScaling data...")

    X_scaled = scaler.transform(
        X.astype(np.float32)
    )

    print("Creating sequences...")

    X_sequences, y_actual = create_sequences(
        X_scaled,
        y.values,
        WINDOW_SIZE
    )

    print("X shape:", X_sequences.shape)
    print("Y shape:", y_actual.shape)

    print("\nRunning prediction...")

    y_pred = model.predict(
        X_sequences,
        verbose=0
    ).flatten()

    mae = mean_absolute_error(y_actual, y_pred)
    rmse = np.sqrt(mean_squared_error(y_actual, y_pred))
    r2 = r2_score(y_actual, y_pred)

    print("\n")
    print("=" * 60)
    print("       RESNET MODEL PERFORMANCE")
    print("=" * 60)
    print(f"MAE  : {mae:.4f}")
    print(f"RMSE : {rmse:.4f}")
    print(f"R²   : {r2:.4f}")
    print("=" * 60)

    return y_actual, y_pred, mae, rmse, r2


def process_house_electricity(df, facility_subtype, holiday_usage, holiday_days, duration_months, data_handling_method, csv_path=None):
    """
    Processes house electricity consumption data and returns day, week, month, and quarter predictions.
    """
    result_dict = {}
    
    if csv_path and os.path.exists(csv_path):
        try:
            model, scaler = load_model_and_scaler()
            processed_df, X, y = preprocess_data(csv_path)
            y_actual, y_pred, mae, rmse, r2 = test_model(model, scaler, X, y)
            
            # Match timestamps with predictions
            result = processed_df.iloc[WINDOW_SIZE:].copy()
            result = result.reset_index()
            result["Actual"] = y_actual
            result["Predicted"] = y_pred
            
            df_agg = result.set_index("timestamp")
            
            # 1. Next Day
            daily_agg = df_agg[["Predicted"]].resample("D").sum().dropna()
            if len(daily_agg) > 0:
                result_dict["next_day"] = int(daily_agg["Predicted"].iloc[-1])
                
            # 2. Next Week
            weekly_agg = df_agg[["Predicted"]].resample("W").sum().dropna()
            if len(weekly_agg) > 0:
                result_dict["next_week"] = int(weekly_agg["Predicted"].iloc[-1])
                
            # 3. Next Month
            try:
                monthly_agg = df_agg[["Predicted"]].resample("ME").sum().dropna()
            except Exception:
                monthly_agg = df_agg[["Predicted"]].resample("M").sum().dropna()
            if len(monthly_agg) > 0:
                result_dict["next_month"] = int(monthly_agg["Predicted"].iloc[-1])
                
            # 4. Next Quarter
            try:
                quarterly_agg = df_agg[["Predicted"]].resample("QE").sum().dropna()
            except Exception:
                quarterly_agg = df_agg[["Predicted"]].resample("Q").sum().dropna()
            if len(quarterly_agg) > 0:
                result_dict["next_quarter"] = int(quarterly_agg["Predicted"].iloc[-1])
                
        except Exception as e:
            print(f"Warning: Failed to run house electricity resnet model: {e}")
            
    return result_dict
