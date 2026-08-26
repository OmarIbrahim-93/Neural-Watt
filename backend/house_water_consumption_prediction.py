import os
import pickle
import pandas as pd
import numpy as np
import joblib
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score

# ============================================================
# CONSTANTS
# ============================================================

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
XGBOOST_DIR = os.path.join(BASE_DIR, "Models", "Water", "House", "XGBoost")
LIGHTGBM_DIR = os.path.join(BASE_DIR, "Models", "Water", "House", "LightGBM")

XGBOOST_MODELS = {
    "day": os.path.join(XGBOOST_DIR, "xgboost_next_day_water_model.pkl"),
    "week": os.path.join(XGBOOST_DIR, "xgboost_next_week_water_model.pkl"),
    "month": os.path.join(XGBOOST_DIR, "xgboost_next_month_water_model.pkl"),
    "quarter": os.path.join(XGBOOST_DIR, "xgboost_next_quarter_water_model.pkl")
}

LIGHTGBM_MODELS = {
    "day": os.path.join(LIGHTGBM_DIR, "lightgbm_next_day_water_model.pkl"),
    "week": os.path.join(LIGHTGBM_DIR, "lightgbm_next_week_water_model.pkl"),
    "month": os.path.join(LIGHTGBM_DIR, "lightgbm_next_month_water_model.pkl"),
    "quarter": os.path.join(LIGHTGBM_DIR, "lightgbm_next_quarter_water_model.pkl")
}

TARGET_COLUMN = "consumption"

FEATURE_COLUMNS = [
    "house_id", "day_of_week", "day_of_month", "week_of_year", "month", "quarter", "day_of_year", "days_since_start",
    "current_consumption", "lag_1", "lag_2", "lag_3", "lag_7", "lag_14", "lag_21", "lag_28", "lag_30", "lag_45", "lag_60", "lag_90"
]

LAGS = [1, 2, 3, 7, 14, 21, 28, 30, 45, 60, 90]

class HouseWaterConsumptionPredictor:
    def __init__(self, model_path="house_water_model.pkl"):
        """
        Initialize the predictor and load the model from a .pkl file.
        """
        self.model_path = model_path
        self.model = self._load_model()

    def _load_model(self):
        """
        Load the machine learning model from the pickle file.
        """
        if os.path.exists(self.model_path):
            with open(self.model_path, 'rb') as file:
                print(f"Successfully loaded model from {self.model_path}")
                return pickle.load(file)
        else:
            print(f"Warning: Model file '{self.model_path}' not found. Prediction will fail.")
            return None

    # ============================================================
    # PART 1: PREPROCESSING
    # ============================================================
    def preprocess(self, raw_data):
        """
        Clean, sort and prepare raw input data.
        """
        print("=" * 70)
        print("PREPROCESSING")
        print("=" * 70)

        # 1. LOAD DATA
        if isinstance(raw_data, str) and raw_data.endswith('.csv'):
            print(f"\nLoading: {raw_data}")
            df = pd.read_csv(raw_data)
        elif not isinstance(raw_data, pd.DataFrame):
            df = pd.DataFrame(raw_data)
        else:
            df = raw_data.copy()

        print(f"Original shape: {df.shape}")

        # 2. ADD HOUSE ID IF MISSING
        if "house_id" not in df.columns:
            df["house_id"] = 8
            
        # 3. CHECK REQUIRED COLUMNS
        required_columns = ["date", "consumption", "house_id"]
        missing_columns = [col for col in required_columns if col not in df.columns]

        if missing_columns:
            raise ValueError(f"Missing required columns: {missing_columns}")

        # 3. CONVERT DATA TYPES
        df["date"] = pd.to_datetime(df["date"], errors="coerce")
        df["consumption"] = pd.to_numeric(df["consumption"], errors="coerce")
        df["house_id"] = pd.to_numeric(df["house_id"], errors="coerce")

        # 4. REMOVE INVALID ROWS
        df = df.dropna(subset=["date", "consumption", "house_id"])

        # 5. SORT DATA
        df = df.sort_values(["house_id", "date"]).reset_index(drop=True)
        
        return df

    # ============================================================
    # PART 1.5: PREPARING CSV FORMAT
    # ============================================================
    def preparing_csv_format(self, daily_df):
        """
        Prepare the daily DataFrame coming from convert_to_daily_data
        into the CSV format expected by the predictor pipeline.

        Input columns  : date, consumption (and possibly others)
        Output columns : date, consumption, house_id

        house_id is set to 0 for every row because the app handles
        a single facility at a time.
        """
        print("=" * 70)
        print("PREPARING CSV FORMAT")
        print("=" * 70)

        df = daily_df.copy()

        # Ensure the required columns exist
        if "date" not in df.columns or "consumption" not in df.columns:
            raise ValueError(
                "Input DataFrame must contain 'date' and 'consumption' columns."
            )
        df["consumption"] = df["consumption"] * 1000
        # Add house_id = 0 for all rows
        df["house_id"] = 0

        # Keep only the three columns the pipeline needs
        df = df[["date", "consumption", "house_id"]].copy()

        print(f"Prepared shape: {df.shape}")
        print(f"Columns: {df.columns.tolist()}")
        print(f"house_id unique values: {df['house_id'].unique()}")

        return df

    # ============================================================
    # PART 2: FEATURE ENGINEERING
    # ============================================================
    def feature_engineering(self, df):
        """
        Feature engineering for water-consumption data.
        """
        print("=" * 70)
        print("FEATURE ENGINEERING")
        print("=" * 70)
        
        # 6. CALENDAR FEATURES
        df["day_of_week"] = df["date"].dt.dayofweek
        df["day_of_month"] = df["date"].dt.day
        df["week_of_year"] = df["date"].dt.isocalendar().week.astype(int)
        df["month"] = df["date"].dt.month
        df["quarter"] = df["date"].dt.quarter
        df["day_of_year"] = df["date"].dt.dayofyear
        df["days_since_start"] = (df["date"] - df["date"].min()).dt.days

        # 7. CURRENT CONSUMPTION
        df["current_consumption"] = df["consumption"]

        # 8. HOUSE-SPECIFIC LAGS
        grouped_consumption = df.groupby("house_id")["consumption"]
        lags = LAGS

        for lag in lags:
            df[f"lag_{lag}"] = grouped_consumption.shift(lag)

        # 9. RETURN DATASET
        print("\nFeature engineering completed.")
        print(f"Final shape: {df.shape}")
        print("\nFeatures:")
        print(df.columns.tolist())

        # Note: If the model requires strictly numeric inputs, 
        # you might need to drop rows with NaNs (from lags) or drop the 'date' column.
        # e.g., df = df.dropna().reset_index(drop=True)
        # e.g., df = df.drop(columns=['date'])

        return df




    #==============================================================




    # ============================================================
    # PART 4: FORECASTING FUNCTIONS
    # ============================================================
    @staticmethod
    def calculate_metrics(y_true, y_pred):
        y_true = np.asarray(y_true, dtype=np.float64)
        y_pred = np.asarray(y_pred, dtype=np.float64)
        mae = mean_absolute_error(y_true, y_pred)
        rmse = np.sqrt(mean_squared_error(y_true, y_pred))
        r2 = r2_score(y_true, y_pred)
        denominator = np.sum(np.abs(y_true))
        wape = (np.sum(np.abs(y_true - y_pred)) / denominator) * 100 if denominator != 0 else np.nan
        smape_denominator = np.abs(y_true) + np.abs(y_pred)
        valid_smape = smape_denominator != 0
        if np.any(valid_smape):
            smape = np.mean((2 * np.abs(y_pred[valid_smape] - y_true[valid_smape])) / smape_denominator[valid_smape]) * 100
        else:
            smape = np.nan
        return {"MAE": mae, "RMSE": rmse, "R2": r2, "WAPE (%)": wape, "sMAPE (%)": smape}

    @staticmethod
    def create_future_features(history, house_id, future_date):
        house_history = history[history["house_id"] == house_id].sort_values("date").reset_index(drop=True)
        if house_history.empty:
            raise ValueError(f"No historical data found for house_id={house_id}")
        future_date = pd.Timestamp(future_date)
        features = {
            "house_id": house_id,
            "day_of_week": future_date.dayofweek,
            "day_of_month": future_date.day,
            "week_of_year": int(future_date.isocalendar().week),
            "month": future_date.month,
            "quarter": future_date.quarter,
            "day_of_year": future_date.dayofyear,
            "days_since_start": (future_date - history["date"].min()).days
        }
        features["current_consumption"] = float(house_history[TARGET_COLUMN].iloc[-1])
        consumption = house_history[TARGET_COLUMN].to_numpy(dtype=np.float32)
        for lag in LAGS:
            features[f"lag_{lag}"] = float(consumption[-lag]) if len(consumption) >= lag else np.nan
        return pd.DataFrame([features], columns=FEATURE_COLUMNS)

    def forecast_horizon(self, history, model, horizon):
        results = []
        if horizon == "day": offset = pd.DateOffset(days=1)
        elif horizon == "week": offset = pd.DateOffset(weeks=1)
        elif horizon == "month": offset = pd.DateOffset(months=1)
        elif horizon == "quarter": offset = pd.DateOffset(months=3)
        else: raise ValueError(f"Unknown horizon: {horizon}")

        for house_id in sorted(history["house_id"].unique()):
            house_history = history[history["house_id"] == house_id].sort_values("date")
            if house_history.empty: continue
            last_date = house_history["date"].iloc[-1]
            future_date = last_date + offset
            future_features = self.create_future_features(history=history, house_id=house_id, future_date=future_date)
            if future_features.isna().any().any():
                print(f"Skipping house {house_id} for {horizon}: insufficient lag history.")
                continue
            X_future_df = future_features
            expected_features = getattr(model, "feature_names_in_", getattr(model, "feature_name_", None))
            if expected_features is not None:
                X_future = X_future_df[list(expected_features)].to_numpy(dtype=np.float32)
            else:
                X_future = X_future_df.to_numpy(dtype=np.float32)
                
            prediction = float(np.asarray(model.predict(X_future)).reshape(-1)[0])
            results.append({
                "house_id": house_id,
                "last_date": last_date,
                "forecast_date": future_date,
                "horizon": horizon,
                "predicted_consumption": prediction
            })
        return pd.DataFrame(results)


    def create_test_target(self, df, horizon):
        """
        Create the correct future target for each forecasting horizon.

        day     -> consumption after 1 day
        week    -> consumption after 7 days
        month   -> consumption after 30 days
        quarter -> consumption after 90 days
        """

        if horizon == "day":
            steps = 1

        elif horizon == "week":
            steps = 7

        elif horizon == "month":
            steps = 30

        elif horizon == "quarter":
            steps = 90

        else:
            raise ValueError(
                f"Unknown horizon: {horizon}"
            )

        test_df = df.copy()

        test_df = (
            test_df
            .sort_values(
                ["house_id", "date"]
            )
            .reset_index(drop=True)
        )

        # Future consumption
        test_df["target"] = (
            test_df
            .groupby("house_id")["consumption"]
            .shift(-steps)
        )

        return test_df



    # def predict(self, df):
    #     print("=" * 80)
    #     print("WATER CONSUMPTION MODEL TESTING")
    #     print("=" * 80)
        
    #     min_date = df["date"].min()
    #     max_date = df["date"].max()
    #     duration_days = (max_date - min_date).days
    #     duration_months = duration_days / 30.4375

    #     print(f"\nData start     : {min_date}")
    #     print(f"Data end       : {max_date}")
    #     print(f"Duration days  : {duration_days}")
    #     print(f"Duration months: {duration_months:.2f}")

    #     X = df[FEATURE_COLUMNS].copy()
    #     y = pd.to_numeric(df[TARGET_COLUMN], errors="coerce")
    #     X = X.apply(pd.to_numeric, errors="coerce")
    #     valid_mask = X.notna().all(axis=1) & y.notna()
    #     X = X.loc[valid_mask].copy()
    #     y = y.loc[valid_mask].copy()
    #     df_test = df.loc[valid_mask].copy()

    #     X_np = X.to_numpy(dtype=np.float32)
    #     y_np = y.to_numpy(dtype=np.float32)

    #     print(f"\nValid test samples: {len(X_np)}")

    #     all_models = {"XGBoost": XGBOOST_MODELS, "LightGBM": LIGHTGBM_MODELS}
    #     all_results = []
    #     all_predictions = df_test[["house_id", "date", TARGET_COLUMN]].copy()

    #     for model_type, models in all_models.items():
    #         print(f"\n{'=' * 80}\nTESTING {model_type}\n{'=' * 80}")
    #         for horizon, model_path in models.items():
    #             print(f"\nTesting {model_type} - {horizon}")
    #             if not os.path.exists(model_path):
    #                 raise FileNotFoundError(f"Model not found:\n{model_path}")
    #             model = joblib.load(model_path)
                
    #             expected_features = getattr(model, "feature_names_in_", getattr(model, "feature_name_", None))
    #             if expected_features is not None:
    #                 X_subset = X[list(expected_features)].to_numpy(dtype=np.float32)
    #             else:
    #                 X_subset = X_np
                    
    #             predictions = np.asarray(model.predict(X_subset)).reshape(-1)
    #             metrics = self.calculate_metrics(y_np, predictions)
    #             print(f"MAE       : {metrics['MAE']:.4f}")
    #             print(f"RMSE      : {metrics['RMSE']:.4f}")
    #             print(f"R²        : {metrics['R2']:.4f}")
    #             print(f"WAPE      : {metrics['WAPE (%)']:.4f}%")
    #             print(f"sMAPE     : {metrics['sMAPE (%)']:.4f}%")
    #             all_results.append({
    #                 "Model": model_type, "Horizon": horizon,
    #                 "MAE": metrics["MAE"], "RMSE": metrics["RMSE"], "R2": metrics["R2"],
    #                 "WAPE (%)": metrics["WAPE (%)"], "sMAPE (%)": metrics["sMAPE (%)"]
    #             })
    #             all_predictions[f"{model_type}_{horizon}_prediction"] = predictions

    #     results_df = pd.DataFrame(all_results)
        
    #     if not results_df.empty:
    #         print(f"\n{'=' * 80}\nMODEL COMPARISON\n{'=' * 80}")
    #         print(results_df.round(4).to_string(index=False))
    #         print(f"\n{'=' * 80}\nBEST MODEL PER HORIZON\n{'=' * 80}")
            
    #         best_models = []
    #         for horizon in ["day", "week", "month", "quarter"]:
    #             horizon_results = results_df[results_df["Horizon"] == horizon]
    #             if horizon_results.empty: continue
    #             best_index = horizon_results["MAE"].idxmin()
    #             best = results_df.loc[best_index]
    #             best_models.append(best)
    #             print(f"\n{horizon.upper()}\nModel : {best['Model']}\nMAE   : {best['MAE']:.4f}\nRMSE  : {best['RMSE']:.4f}\nR²    : {best['R2']:.4f}")
            
    #         best_models_df = pd.DataFrame(best_models)
    #         results_file, predictions_file = "model_test_results.csv", "model_test_predictions.csv"
    #         results_df.to_csv(results_file, index=False)
    #         all_predictions.to_csv(predictions_file, index=False)
    #         print(f"\n{'=' * 80}\nTEST RESULTS SAVED\n{'=' * 80}")
    #         print(os.path.abspath(results_file))
    #         print(os.path.abspath(predictions_file))
    #     else:
    #         best_models_df = pd.DataFrame()

    #     print(f"\n{'=' * 80}\nFUTURE FORECASTING\n{'=' * 80}")
    #     forecast_horizons = ["day", "week", "month"]
    #     if duration_months >= 6:
    #         forecast_horizons.append("quarter")
    #         print("\n✓ Data duration >= 6 months\n✓ Quarter forecast enabled")
    #     else:
    #         print("\nData duration < 6 months\nQuarter forecast disabled")

    #     forecast_results = []
    #     for horizon in forecast_horizons:
    #         horizon_results = results_df[results_df["Horizon"] == horizon] if not results_df.empty else pd.DataFrame()
    #         if horizon_results.empty:
    #             print(f"\nNo tested model for {horizon}")
    #             continue
            
    #         best_index = horizon_results["MAE"].idxmin()
    #         best_model_type = results_df.loc[best_index]["Model"]
    #         print(f"\n{horizon.upper()} FORECAST\nUsing: {best_model_type}")
            
    #         model_path = XGBOOST_MODELS[horizon] if best_model_type == "XGBoost" else LIGHTGBM_MODELS[horizon]
    #         if not os.path.exists(model_path):
    #             raise FileNotFoundError(f"Model not found:\n{model_path}")
            
    #         model = joblib.load(model_path)
    #         forecast_df = self.forecast_horizon(history=df, model=model, horizon=horizon)
            
    #         if not forecast_df.empty:
    #             forecast_df["model"] = best_model_type
    #             forecast_results.append(forecast_df)
    #             print(forecast_df.to_string(index=False))

    #     forecasts_df = pd.concat(forecast_results, ignore_index=True) if forecast_results else pd.DataFrame()
        
    #     if not forecasts_df.empty:
    #         forecast_file = "next_consumption_forecasts.csv"
    #         forecasts_df.to_csv(forecast_file, index=False)
    #         print(f"\n{'=' * 80}\nFORECASTS SAVED\n{'=' * 80}\n{os.path.abspath(forecast_file)}")

    #     return {
    #         "status": "success",
    #         "test_results": results_df.to_dict(orient="records") if not results_df.empty else [],
    #         "best_models": best_models_df.to_dict(orient="records") if not best_models_df.empty else [],
    #         "forecasts": forecasts_df.to_dict(orient="records") if not forecasts_df.empty else [],
    #         "duration_months": duration_months
    #     }











    def predict(self, df):

        print("=" * 80)
        print("WATER CONSUMPTION MODEL TESTING")
        print("=" * 80)

        # ============================================================
        # 1. PREPARE DATA
        # ============================================================

        df = df.copy()

        df["date"] = pd.to_datetime(
            df["date"],
            errors="coerce"
        )

        df["consumption"] = pd.to_numeric(
            df["consumption"],
            errors="coerce"
        )

        df["house_id"] = pd.to_numeric(
            df["house_id"],
            errors="coerce"
        )

        df = df.dropna(
            subset=[
                "date",
                "consumption",
                "house_id"
            ]
        ).copy()

        df = (
            df
            .sort_values(
                ["house_id", "date"]
            )
            .reset_index(drop=True)
        )

        # ============================================================
        # 2. DATA INFORMATION
        # ============================================================

        min_date = df["date"].min()
        max_date = df["date"].max()

        duration_days = (
            max_date - min_date
        ).days

        duration_months = (
            duration_days / 30.4375
        )

        print(
            f"\nData start     : {min_date}"
        )

        print(
            f"Data end       : {max_date}"
        )

        print(
            f"Duration days  : {duration_days}"
        )

        print(
            f"Duration months: {duration_months:.2f}"
        )

        print(
            f"Consumption min: {df['consumption'].min():.2f} L"
        )

        print(
            f"Consumption max: {df['consumption'].max():.2f} L"
        )

        # ============================================================
        # 3. MODEL PATHS
        # ============================================================

        all_models = {
            "XGBoost": XGBOOST_MODELS,
            "LightGBM": LIGHTGBM_MODELS
        }

        all_results = []

        # ============================================================
        # 4. TEST ALL MODELS
        # ============================================================

        for model_type, models in all_models.items():

            print("\n" + "=" * 80)
            print(f"TESTING {model_type}")
            print("=" * 80)

            for horizon, model_path in models.items():

                print(
                    f"\n{'-' * 80}"
                )

                print(
                    f"Testing {model_type} - {horizon}"
                )

                print(
                    f"{'-' * 80}"
                )

                # ====================================================
                # 4.1 CHECK MODEL
                # ====================================================

                if not os.path.exists(model_path):

                    raise FileNotFoundError(
                        f"Model not found:\n{model_path}"
                    )

                # ====================================================
                # 4.2 LOAD MODEL
                # ====================================================

                model = joblib.load(
                    model_path
                )

                print(
                    f"Model loaded: {model_path}"
                )

                # ====================================================
                # 4.3 DEFINE HORIZON
                # ====================================================

                if horizon == "day":

                    horizon_steps = 1

                elif horizon == "week":

                    horizon_steps = 7

                elif horizon == "month":

                    horizon_steps = 30

                elif horizon == "quarter":

                    horizon_steps = 90

                else:

                    raise ValueError(
                        f"Unknown horizon: {horizon}"
                    )

                print(
                    f"Target horizon: {horizon_steps} days"
                )

                # ====================================================
                # 4.4 CREATE FUTURE TARGET
                # ====================================================

                test_df = df.copy()

                test_df["target"] = (
                    test_df
                    .groupby("house_id")[
                        "consumption"
                    ]
                    .shift(-horizon_steps)
                )

                # ====================================================
                # 4.5 REMOVE ROWS WITHOUT TARGET
                # ====================================================

                test_df = test_df.dropna(
                    subset=[
                        "target"
                    ]
                ).copy()

                if test_df.empty:

                    print(
                        f"Skipping {model_type} "
                        f"{horizon}: no target data."
                    )

                    continue

                # ====================================================
                # 4.6 CREATE FEATURES
                # ====================================================

                X = test_df[
                    FEATURE_COLUMNS
                ].copy()

                # Convert every feature to numeric

                X = X.apply(
                    pd.to_numeric,
                    errors="coerce"
                )

                # ====================================================
                # 4.7 TARGET
                # ====================================================

                y = pd.to_numeric(
                    test_df["target"],
                    errors="coerce"
                )

                # ====================================================
                # 4.8 VALID ROWS
                # ====================================================

                valid_mask = (
                    X.notna().all(axis=1)
                    &
                    y.notna()
                )

                X = X.loc[
                    valid_mask
                ].copy()

                y = y.loc[
                    valid_mask
                ].copy()

                if X.empty:

                    print(
                        f"Skipping {model_type} "
                        f"{horizon}: no valid samples."
                    )

                    continue

                # ====================================================
                # 4.9 GET MODEL FEATURES
                # ====================================================

                expected_features = getattr(
                    model,
                    "feature_names_in_",
                    getattr(
                        model,
                        "feature_name_",
                        None
                    )
                )

                # ====================================================
                # 4.10 PREPARE X FOR MODEL
                # ====================================================

                if expected_features is not None:

                    expected_features = list(
                        expected_features
                    )

                    # Check missing model features

                    missing_features = [
                        feature
                        for feature in expected_features
                        if feature not in X.columns
                    ]

                    if missing_features:

                        raise ValueError(
                            f"Missing features for "
                            f"{model_type} {horizon}: "
                            f"{missing_features}"
                        )

                    X_model = X[
                        expected_features
                    ].to_numpy(
                        dtype=np.float32
                    )

                else:

                    X_model = X.to_numpy(
                        dtype=np.float32
                    )

                # ====================================================
                # 4.11 PREPARE Y
                # ====================================================

                y_true = y.to_numpy(
                    dtype=np.float64
                )

                # ====================================================
                # 4.12 PREDICT
                # ====================================================

                predictions = np.asarray(
                    model.predict(
                        X_model
                    )
                ).reshape(-1)

                # ====================================================
                # 4.13 CHECK LENGTH
                # ====================================================

                if len(y_true) != len(predictions):

                    raise ValueError(
                        f"Prediction length mismatch "
                        f"for {model_type} {horizon}: "
                        f"y={len(y_true)}, "
                        f"predictions={len(predictions)}"
                    )

                # ====================================================
                # 4.14 CALCULATE METRICS
                # ====================================================

                metrics = self.calculate_metrics(
                    y_true,
                    predictions
                )

                # ====================================================
                # 4.15 PRINT METRICS
                # ====================================================

                print(
                    f"Valid test samples: "
                    f"{len(y_true)}"
                )

                print(
                    f"MAE       : "
                    f"{metrics['MAE']:.4f}"
                )

                print(
                    f"RMSE      : "
                    f"{metrics['RMSE']:.4f}"
                )

                print(
                    f"R²        : "
                    f"{metrics['R2']:.4f}"
                )

                print(
                    f"WAPE      : "
                    f"{metrics['WAPE (%)']:.4f}%"
                )

                print(
                    f"sMAPE     : "
                    f"{metrics['sMAPE (%)']:.4f}%"
                )

                # ====================================================
                # 4.16 SAVE RESULTS
                # ====================================================

                all_results.append({

                    "Model":
                        model_type,

                    "Horizon":
                        horizon,

                    "MAE":
                        metrics["MAE"],

                    "RMSE":
                        metrics["RMSE"],

                    "R2":
                        metrics["R2"],

                    "WAPE (%)":
                        metrics["WAPE (%)"],

                    "sMAPE (%)":
                        metrics["sMAPE (%)"]

                })

        # ============================================================
        # 5. CREATE RESULTS DATAFRAME
        # ============================================================

        results_df = pd.DataFrame(
            all_results
        )

        # ============================================================
        # 6. MODEL COMPARISON
        # ============================================================

        if results_df.empty:

            print(
                "\nNo valid test results."
            )

            best_models_df = pd.DataFrame()

        else:

            print(
                "\n" + "=" * 80
            )

            print(
                "MODEL COMPARISON"
            )

            print(
                "=" * 80
            )

            print(
                results_df
                .round(4)
                .to_string(
                    index=False
                )
            )

            # ========================================================
            # 6.1 BEST MODEL PER HORIZON
            # ========================================================

            print(
                "\n" + "=" * 80
            )

            print(
                "BEST MODEL PER HORIZON"
            )

            print(
                "=" * 80
            )

            best_models = []

            for horizon in [
                "day",
                "week",
                "month",
                "quarter"
            ]:

                horizon_results = (
                    results_df[
                        results_df["Horizon"]
                        == horizon
                    ]
                )

                if horizon_results.empty:

                    continue

                # Best according to MAE

                best_index = (
                    horizon_results[
                        "MAE"
                    ].idxmin()
                )

                best = (
                    results_df
                    .loc[best_index]
                )

                best_models.append(
                    best
                )

                print(
                    f"\n{horizon.upper()}"
                )

                print(
                    f"Model : "
                    f"{best['Model']}"
                )

                print(
                    f"MAE   : "
                    f"{best['MAE']:.4f}"
                )

                print(
                    f"RMSE  : "
                    f"{best['RMSE']:.4f}"
                )

                print(
                    f"R²    : "
                    f"{best['R2']:.4f}"
                )

                print(
                    f"WAPE  : "
                    f"{best['WAPE (%)']:.4f}%"
                )

                print(
                    f"sMAPE : "
                    f"{best['sMAPE (%)']:.4f}%"
                )

            best_models_df = pd.DataFrame(
                best_models
            )

            # ========================================================
            # 6.2 SAVE TEST RESULTS
            # ========================================================

            results_file = (
                "model_test_results.csv"
            )

            results_df.to_csv(
                results_file,
                index=False
            )

            print(
                "\n" + "=" * 80
            )

            print(
                "TEST RESULTS SAVED"
            )

            print(
                "=" * 80
            )

            print(
                os.path.abspath(
                    results_file
                )
            )

        # ============================================================
        # 7. FUTURE FORECASTING
        # ============================================================

        print(
            "\n" + "=" * 80
        )

        print(
            "FUTURE FORECASTING"
        )

        print(
            "=" * 80
        )

        forecast_horizons = [
            "day",
            "week",
            "month"
        ]

        if duration_months >= 6:

            forecast_horizons.append(
                "quarter"
            )

            print(
                "\n✓ Data duration >= 6 months"
            )

            print(
                "✓ Quarter forecast enabled"
            )

        else:

            print(
                "\nData duration < 6 months"
            )

            print(
                "Quarter forecast disabled"
            )

        forecast_results = []

        # ============================================================
        # 8. FORECAST EACH HORIZON
        # ============================================================

        for horizon in forecast_horizons:

            if results_df.empty:

                print(
                    f"\nNo results for {horizon}"
                )

                continue

            horizon_results = (
                results_df[
                    results_df["Horizon"]
                    == horizon
                ]
            )

            if horizon_results.empty:

                print(
                    f"\nNo tested model "
                    f"for {horizon}"
                )

                continue

            # ========================================================
            # 8.1 SELECT BEST MODEL
            # ========================================================

            best_index = (
                horizon_results[
                    "MAE"
                ].idxmin()
            )

            best_model_type = (
                results_df
                .loc[
                    best_index,
                    "Model"
                ]
            )

            print(
                f"\n{horizon.upper()} FORECAST"
            )

            print(
                f"Using: "
                f"{best_model_type}"
            )

            # ========================================================
            # 8.2 MODEL PATH
            # ========================================================

            if best_model_type == "XGBoost":

                model_path = (
                    XGBOOST_MODELS[
                        horizon
                    ]
                )

            else:

                model_path = (
                    LIGHTGBM_MODELS[
                        horizon
                    ]
                )

            if not os.path.exists(
                model_path
            ):

                raise FileNotFoundError(
                    f"Model not found:\n"
                    f"{model_path}"
                )

            # ========================================================
            # 8.3 LOAD BEST MODEL
            # ========================================================

            model = joblib.load(
                model_path
            )

            # ========================================================
            # 8.4 FUTURE FORECAST
            # ========================================================

            forecast_df = (
                self.forecast_horizon(
                    history=df,
                    model=model,
                    horizon=horizon
                )
            )

            # ========================================================
            # 8.5 SAVE FORECAST
            # ========================================================

            if not forecast_df.empty:

                forecast_df[
                    "model"
                ] = best_model_type

                forecast_results.append(
                    forecast_df
                )

                print(
                    forecast_df.to_string(
                        index=False
                    )
                )

            else:

                print(
                    f"No forecast generated "
                    f"for {horizon}"
                )

        # ============================================================
        # 9. COMBINE FORECASTS
        # ============================================================

        if forecast_results:

            forecasts_df = pd.concat(
                forecast_results,
                ignore_index=True
            )

        else:

            forecasts_df = pd.DataFrame()

        # ============================================================
        # 10. SAVE FORECASTS
        # ============================================================

        if not forecasts_df.empty:

            forecast_file = (
                "next_consumption_forecasts.csv"
            )

            forecasts_df.to_csv(
                forecast_file,
                index=False
            )

            print(
                "\n" + "=" * 80
            )

            print(
                "FORECASTS SAVED"
            )

            print(
                "=" * 80
            )

            print(
                os.path.abspath(
                    forecast_file
                )
            )

        # ============================================================
        # 11. RETURN
        # ============================================================

        return {

            "status":
                "success",

            "test_results":
                (
                    results_df
                    .to_dict(
                        orient="records"
                    )
                    if not results_df.empty
                    else []
                ),

            "best_models":
                (
                    best_models_df
                    .to_dict(
                        orient="records"
                    )
                    if not best_models_df.empty
                    else []
                ),

            "forecasts":
                (
                    forecasts_df
                    .to_dict(
                        orient="records"
                    )
                    if not forecasts_df.empty
                    else []
                ),

            "duration_months":
                duration_months
        }




    # ============================================================
    # CALCULATE WASTE
    # ============================================================
    def calculate_waste(self, predictions_m3, num_persons):
        waste = {}
        thresholds = {
            "day": 0.2,
            "week": 1.4,
            "month": 6.0,
            "quarter": 18.0
        }
        for horizon, threshold in thresholds.items():
            pred_key = f"next_{horizon}"
            waste_key = f"waste_{horizon}"
            
            pred_val = predictions_m3.get(pred_key)
            if pred_val is not None:
                limit = num_persons * threshold
                if pred_val > limit:
                    waste[waste_key] = round(pred_val - limit, 2)
                else:
                    waste[waste_key] = 0.0
            else:
                waste[waste_key] = None
        return waste

    # ============================================================
    # PART 5: RESULT CONSUMPTION
    # ============================================================
    def get_result_consumption(self, raw_data):
        """
        Full pipeline: Preprocess -> Feature Engineering -> Predict -> Format Output.
        """
        # 1. Preprocess the raw data
        processed_data = self.preprocess(raw_data)
        
        # 2. Prepare CSV format (add house_id = 0)
        prepared_data = self.preparing_csv_format(processed_data)
        prepared_data.to_csv("result.csv", index=False)
        
        # 3. Extract Features
        engineered_data = self.feature_engineering(prepared_data)
        
        # 4. Predict future consumption
        full_result = self.predict(engineered_data)
        
        # 5. Extract day, week, month predictions
        forecasts = full_result.get("forecasts", [])
        
        predictions = {
            "next_day": None,
            "next_week": None,
            "next_month": None,
            "next_quarter": None
        }
        
        for f in forecasts:
            horizon = f.get("horizon")
            if horizon in ["day", "week", "month", "quarter"]:
                predictions[f"next_{horizon}"] = round(f.get("predicted_consumption", 0.0), 2)

        num_persons = 1
        try:
            if isinstance(raw_data, pd.DataFrame) and "household_size" in raw_data.columns:
                num_persons = int(raw_data["household_size"].iloc[-1])
            elif isinstance(raw_data, list) and len(raw_data) > 0 and "household_size" in raw_data[-1]:
                num_persons = int(raw_data[-1]["household_size"])
        except Exception:
            pass

        preds_m3 = {
            "next_day": (predictions["next_day"] / 1000.0 if predictions["next_day"] is not None else None),
            "next_week": (predictions["next_week"] / 1000.0 if predictions["next_week"] is not None else None),
            "next_month": (predictions["next_month"] / 1000.0 if predictions["next_month"] is not None else None),
            "next_quarter": (predictions["next_quarter"] / 1000.0 if predictions["next_quarter"] is not None else None)
        }

        waste = self.calculate_waste(preds_m3, num_persons)

        return {
            "status": "success",
            "next_day": preds_m3["next_day"],
            "next_week": preds_m3["next_week"],
            "next_month": preds_m3["next_month"],
            "next_quarter": preds_m3["next_quarter"],
            "waste": waste,
            "detailed_results": full_result
        }

# ============================================================
# EXAMPLE USAGE
# ============================================================
if __name__ == "__main__":
    # Example dummy data representing user inputs or historical data
    sample_data = [
        {"date": "2026-08-01", "temperature": 32.5, "household_size": 4},
        {"date": "2026-08-02", "temperature": 34.1, "household_size": 4},
        {"date": "2026-08-03", "temperature": 31.0, "household_size": 4},
    ]

    predictor = HouseWaterConsumptionPredictor(model_path="house_water_model.pkl")
    
    # Try to predict if the model file is available
    try:
        final_result = predictor.get_result_consumption(sample_data)
        print("Prediction Result:")
        print(final_result)
    except ValueError as e:
        print(e)

def process_house_water(df, facility_subtype, holiday_usage, holiday_days, duration_months, data_handling_method):
    predictor = HouseWaterConsumptionPredictor()
    return predictor.get_result_consumption(df)