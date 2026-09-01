import pandas as pd
import numpy as np
import joblib
import os

def forecast_universal_electricity(csv_path, model_path='../Models/Electricity/Company/neural_watts_electricity_universal_engine.pkl', sample_building_id=None):
    print("=" * 75)
    print("      NEURAL WATTS - UNIVERSAL ELECTRICITY INFERENCE ENGINE (1297 Bldgs)      ")
    print("=" * 75)
    
    # 1. تحميل الحزمة الشاملة
    if not os.path.exists(model_path):
        print(f"Model path {model_path} not found.")
        return {}

    package = joblib.load(model_path)
    b2c_models = package['b2c']['models']
    b2c_features = package['b2c']['features']
    b2b_models = package['b2b']['models']
    b2b_features = package['b2b']['features']
    encoders = package['encoders']
    valid_buildings = set(package['valid_buildings'])
    
    # 2. قراءة ملف الكهرباء واستخلاص المباني الصالحة فقط
    df = pd.read_csv(csv_path)
    
    if 'timestamp' not in df.columns:
        df.rename(columns={df.columns[0]: 'timestamp'}, inplace=True)
        
    df['timestamp'] = pd.to_datetime(df['timestamp'])
    
    if 'building_id' not in df.columns:
        df.set_index('timestamp', inplace=True)
        avail_cols = [c for c in df.columns if c in valid_buildings]
        if not avail_cols:
            # Fallback if building IDs don't match exactly, just take the first one or original data
            avail_cols = df.columns.tolist()
            
        df_clean = df[avail_cols].interpolate(method='time', limit=6).ffill().bfill()
        df_clean.reset_index(inplace=True)
        
        # 3. تحويل إلى Long Format والتجميع اليومي
        long_df = pd.melt(df_clean, id_vars=['timestamp'], var_name='building_id', value_name='Electricity_kWh')
    else:
        # Already in long format?
        long_df = df.copy()
        long_df.rename(columns={long_df.columns[2]: 'Electricity_kWh'}, inplace=True)
        
    long_df['primary_use'] = long_df['building_id'].apply(lambda x: x.split('_')[1] if len(x.split('_')) > 1 else 'unknown')
    
    daily_df = (
        long_df.groupby(['building_id', 'primary_use', pd.Grouper(key='timestamp', freq='D')])['Electricity_kWh']
        .sum()
        .reset_index()
    )
    daily_df.sort_values(['building_id', 'timestamp'], inplace=True)
    
    # 4. استخراج الـ Features
    daily_df['sin_month'] = np.sin(2 * np.pi * daily_df['timestamp'].dt.month / 12.0).astype(np.float32)
    daily_df['cos_month'] = np.cos(2 * np.pi * daily_df['timestamp'].dt.month / 12.0).astype(np.float32)
    daily_df['sin_dayofweek'] = np.sin(2 * np.pi * daily_df['timestamp'].dt.dayofweek / 7.0).astype(np.float32)
    daily_df['cos_dayofweek'] = np.cos(2 * np.pi * daily_df['timestamp'].dt.dayofweek / 7.0).astype(np.float32)
    daily_df['quarter'] = daily_df['timestamp'].dt.quarter.astype(np.int8)
    daily_df['Is_Weekend'] = daily_df['timestamp'].dt.dayofweek.isin([5, 6]).astype(np.int8)

    grp = daily_df.groupby('building_id')['Electricity_kWh']
    
    # ميزات B2C
    daily_df['Lag_1D'] = grp.shift(1).astype(np.float32)
    daily_df['Lag_2D'] = grp.shift(2).astype(np.float32)
    daily_df['Lag_7D'] = grp.shift(7).astype(np.float32)
    daily_df['Lag_14D'] = grp.shift(14).astype(np.float32)
    daily_df['Lag_30D'] = grp.shift(30).astype(np.float32)
    daily_df['Rolling_Mean_7D'] = grp.transform(lambda x: x.shift(1).rolling(7).mean()).astype(np.float32)
    daily_df['Rolling_Mean_30D'] = grp.transform(lambda x: x.shift(1).rolling(30).mean()).astype(np.float32)
    daily_df['Rolling_Std_7D'] = grp.transform(lambda x: x.shift(1).rolling(7).std()).astype(np.float32)
    daily_df['diff_1d_7d'] = (daily_df['Lag_1D'] - daily_df['Rolling_Mean_7D']).astype(np.float32)
    daily_df['ratio_1d_7d'] = (daily_df['Lag_1D'] / (daily_df['Rolling_Mean_7D'] + 1e-5)).astype(np.float32)

    # ميزات B2B
    daily_df['Lag_90D'] = grp.shift(90).astype(np.float32)
    daily_df['Lag_180D'] = grp.shift(180).astype(np.float32)
    daily_df['Rolling_Mean_90D'] = grp.transform(lambda x: x.shift(1).rolling(90).mean()).astype(np.float32)
    daily_df['Rolling_Mean_180D'] = grp.transform(lambda x: x.shift(1).rolling(180).mean()).astype(np.float32)
    daily_df['Rolling_Std_30D'] = grp.transform(lambda x: x.shift(1).rolling(30).std()).astype(np.float32)
    daily_df['ratio_30d_90d'] = (daily_df['Rolling_Mean_30D'] / (daily_df['Rolling_Mean_90D'] + 1e-5)).astype(np.float32)
    
    eval_df = daily_df.bfill().ffill().copy()
    
    # الترميز الفئوي
    eval_df['building_code'] = eval_df['building_id'].map(encoders.get('building_id', {})).fillna(0).astype(np.int32)
    eval_df['primary_use_code'] = eval_df['primary_use'].map(encoders.get('primary_use', {})).fillna(0).astype(np.int32)
    
    # 5. اختيار المبنى وتجهيز المدخلات
    if sample_building_id is not None and sample_building_id in valid_buildings:
        target_row = eval_df[eval_df['building_id'] == sample_building_id].iloc[-1:]
    else:
        target_row = eval_df.iloc[-1:]
        
    b_name = target_row['building_id'].values[0] if not target_row.empty else "Unknown"
    p_use = target_row['primary_use'].values[0] if not target_row.empty else "Unknown"
    last_date = target_row['timestamp'].dt.date.values[0] if not target_row.empty else "Unknown"
    
    for col in b2c_features:
        if col not in target_row.columns:
            target_row[col] = 0
            
    for col in b2b_features:
        if col not in target_row.columns:
            target_row[col] = 0

    in_b2c = target_row[b2c_features]
    in_b2b = target_row[b2b_features]

    print(f"\n🏢 المبنى المختار : {b_name} | النشاط: {p_use}")
    print(f"📅 تاريخ آخر قراءة : {last_date}\n")
    print(f"{'الأفق الزمني':<28} | {'التوقع التقديري (kWh)':<25}")
    print("-" * 65)

    forecast_results = {}
    
    # توقعات المنازل
    for target_key, label in [('Target_Next_Day', '1. اليوم القادم (B2C)'), ('Target_Next_Week', '2. الأسبوع القادم (B2C)'), ('Target_Next_Month', '3. الشهر القادم (B2C)')]:
        val = max(0.0, float(b2c_models[target_key].predict(in_b2c)[0]))
        forecast_results[target_key] = val
        print(f"{label:<28} | {val:>15,.2f} kWh")
        
    # توقعات الشركات
    for target_key, label in [('Target_Next_Quarter', '4. الربع سنوي (B2B)'), ('Target_Next_SemiAnnual', '5. النصف سنوي (B2B)'), ('Target_Next_Annual', '6. السنوي الكامل (B2B)')]:
        val = max(0.0, float(b2b_models[target_key].predict(in_b2b)[0]))
        forecast_results[target_key] = val
        print(f"{label:<28} | {val:>15,.2f} kWh")
        
    print("=" * 75)
    return forecast_results

def process_company_electricity(df, facility_subtype, holiday_usage, holiday_days, duration_months, data_handling_method, tmp_path=None, facility_size="small"):
    """
    Processes company electricity consumption data.
    """
    if tmp_path and os.path.exists(tmp_path):
        csv_path = tmp_path
    else:
        csv_path = "Actual_daily_consumption.csv"
        if not os.path.exists(csv_path):
            df.to_csv(csv_path, index=False)
            
    try:
        print("========== CSV Data Before Prediction ==========")
        print(pd.read_csv(csv_path))
        print("================================================")
        # Note the user provided "neural_watts_electricity_universal_engine.pkl"
        forecast = forecast_universal_electricity(csv_path, model_path='../Models/Electricity/Company/neural_watts_electricity_universal_engine.pkl')
    except Exception as e:
        print(f"Error in utility pipeline: {e}")
        forecast = {}

    def calc_waste(pred, factor=1.0):
        if not pred: return 0.0, 0.0
        electricity_thresholds = {
            'Bakery': {'small': 5000, 'medium': 20000, 'large': 60000},
            'Office': {'small': 2500, 'medium': 10000, 'large': 30000},
            'Hotel': {'small': 10000, 'medium': 40000, 'large': 120000},
            'Restaurant': {'small': 8000, 'medium': 30000, 'large': 100000},
            'School': {'small': 3000, 'medium': 12000, 'large': 35000},
            'SuperMarket': {'small': 10000, 'medium': 50000, 'large': 150000},
        }
        base_threshold = 2500
        if facility_subtype in electricity_thresholds:
            size = facility_size.lower() if facility_size else 'small'
            if size not in electricity_thresholds[facility_subtype]:
                size = 'small'
            base_threshold = electricity_thresholds[facility_subtype][size]
        
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
        "next_day": forecast.get("Target_Next_Day") * 4,
        "next_week": forecast.get("Target_Next_Week") * 4,
        "next_month": forecast.get("Target_Next_Month"),
        "next_quarter": forecast.get("Target_Next_Quarter"),
        "next_semi_annual": forecast.get("Target_Next_SemiAnnual"),
        "next_annual": forecast.get("Target_Next_Annual"),
        "waste": waste_dict
    }
    
    return prediction_result
