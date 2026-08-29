import pandas as pd

def process_row_cost_house(consumption, source_type, period='monthly'):
    import pandas as pd
    if pd.isna(consumption):
        return 0, 0.0, 0.0

    # Determine threshold multiplier based on the period
    if period == 'daily':
        multiplier = 1 / 30
    elif period == 'weekly':
        multiplier = 1 / 4
    elif period == 'monthly':
        multiplier = 1.0
    elif period == 'quarter' or period == 'quarterly':
        multiplier = 3.0
    else:
        multiplier = 1.0  # Default to monthly

    if source_type == 'water':
        if consumption <= 10 * multiplier:
            return 1, 2.00, consumption * 2.00
        elif consumption <= 20 * multiplier:
            return 2, 3.00, consumption * 3.00
        elif consumption <= 30 * multiplier:
            return 3, 4.00, consumption * 4.00
        else:
            return 4, 4.50, consumption * 4.50

    elif source_type == 'electricity':
        if consumption <= 50 * multiplier:
            return 1, 0.68, consumption * 0.68
        elif consumption <= 100 * multiplier:
            return 2, 0.78, consumption * 0.78
        elif consumption <= 200 * multiplier:
            return 3, 0.95, consumption * 0.95
        elif consumption <= 350 * multiplier:
            return 4, 1.55, consumption * 1.55
        elif consumption <= 650 * multiplier:
            return 5, 1.95, consumption * 1.95
        elif consumption <= 1000 * multiplier:
            return 6, 2.10, consumption * 2.10
        else:
            return 7, 2.58, consumption * 2.58

    elif source_type == 'gas':
        if consumption <= 30 * multiplier:
            return 1, 4.00, consumption * 4.00
        elif consumption <= 60 * multiplier:
            return 2, 5.00, consumption * 5.00
        else:
            return 3, 7.00, consumption * 7.00

    return 0, 0.0, 0.0

def waste_water_house(total_consumption, facility_subtype, months):
    try:
        num_persons = int(str(facility_subtype))
    except (ValueError, TypeError):
        num_persons = 1
        
    thresholds = {
        1: 6.0,
        3: 18.0,
        6: 36.0,
        12: 72.0
    }
    
    if months in thresholds:
        limit = num_persons * thresholds[months]
        if total_consumption > limit:
            waste_amt = total_consumption - limit
            waste_amount = round(waste_amt, 2)
            waste_percentage = round((waste_amt / limit) * 100, 2)
            return waste_amount, waste_percentage
            
    return None, None

def waste_electricity_house(total_consumption, facility_subtype, months):
    try:
        num_persons = int(str(facility_subtype))
    except (ValueError, TypeError):
        num_persons = 1
        
    base_person_usage_monthly = 180
    limit = base_person_usage_monthly * num_persons * months
    
    if total_consumption > limit:
        waste_amt = total_consumption - limit
        waste_amount = round(waste_amt / 60, 2)
        waste_percentage = round((waste_amt / (limit * 60)) * 100, 2)
        return waste_amount, waste_percentage
        
    return None, None

def waste_gas_house(total_consumption, facility_subtype, months):
    try:
        num_persons = int(str(facility_subtype))
    except (ValueError, TypeError):
        num_persons = 1
        
    base_person_usage_monthly = 15.0
    limit = base_person_usage_monthly * num_persons * months
    
    if total_consumption > limit:
        waste_amt = total_consumption - limit
        waste_amount = int(waste_amt)
        waste_percentage = round((waste_amt / limit) * 100, 2)
        return waste_amount, waste_percentage
        
    return None, None

def Analytics(df: pd.DataFrame, source_type: str, environment_type: str = "", facility_subtype: str = ""):
    source_type = source_type.lower()
    
    # Check if consumption column exists, if not, try to calculate from meter_value
    if 'consumption' not in df.columns:
        if 'meter_value' in df.columns:
            df = df.sort_values(df.columns[0]).reset_index(drop=True)
            df['consumption'] = df['meter_value'].diff()
            df = df.dropna(subset=['consumption'])
            df = df[df['consumption'] >= 0].copy()
        else:
            # assume the second column is consumption
            df.rename(columns={df.columns[1]: 'consumption'}, inplace=True)

    # 1. Apply costs to each row
    categories = []
    unit_prices = []
    costs = []
    
    for _, row in df.iterrows():
        if environment_type.lower() == 'house':
            cat, price, cost = process_row_cost_house(row['consumption'], source_type)
        else:
            cat, price, cost = 0, 0.0, 0.0
            
        categories.append(f"Category {cat}")
        unit_prices.append(price)
        costs.append(cost)
        
    df['consumption_category'] = categories
    df['unit_price'] = unit_prices
    df['consumption_cost'] = costs
    
    # 2. Intervals Analysis (12, 6, 3, 1 months)
    # Find a date column
    date_col = None
    for col in df.columns:
        if 'date' in col.lower() or 'time' in col.lower():
            date_col = col
            break
            
    if date_col:
        df[date_col] = pd.to_datetime(df[date_col], errors='coerce')
        df = df.dropna(subset=[date_col])
        
        if 'is_missing_day' in df.columns:
            actual_data = df[df['is_missing_day'] == 0]
            if not actual_data.empty:
                max_date = actual_data[date_col].max()
            else:
                max_date = df[date_col].max()
        else:
            max_date = df[date_col].max()
    else:
        return {"error": "No date/timestamp column found in CSV"}, df
        
    if df.empty:
        return {"error": "Empty dataframe after processing dates"}, df
        
    intervals = [12, 6, 3, 1]
    analysis_results = {}
    
    for months in intervals:
        start_date = (max_date.replace(day=1) - pd.DateOffset(months=months - 1))
        mask = (df[date_col] >= start_date) & (df[date_col] <= max_date)
        interval_df = df.loc[mask].copy()
        
        if interval_df.empty:
            analysis_results[f"last_{months}_months"] = {
                "total_consumption": 0,
                "average_daily_consumption": 0,
                "monthly_costs": {},
                "monthly_consumption": {},
                "waste_amount": None,
                "waste_percentage": None
            }
            continue
            
        total_consumption = interval_df['consumption'].sum()
        days_in_interval = len(interval_df)
        avg_daily = (
            int(round(total_consumption / days_in_interval))
            if source_type == 'gas' and days_in_interval > 0
            else total_consumption / days_in_interval
            if days_in_interval > 0
            else 0
        )
        interval_df['month_year'] = interval_df[date_col].dt.to_period('M').astype(str)
        monthly_costs = interval_df.groupby('month_year')['consumption_cost'].sum().to_dict()
        monthly_consumption = interval_df.groupby('month_year')['consumption'].sum().to_dict()
        
        display_total_consumption = (
            int(round(total_consumption))
            if source_type == 'gas'
            else total_consumption / 60
            if source_type == 'electricity'
            else total_consumption
        )

        waste_amount = None
        waste_percentage = None
        
        if environment_type.lower() == "house" and source_type == "water":
            waste_amount, waste_percentage = waste_water_house(display_total_consumption, facility_subtype, months)
        elif environment_type.lower() == "house" and source_type == "electricity":
            waste_amount, waste_percentage = waste_electricity_house(display_total_consumption, facility_subtype, months)
        elif environment_type.lower() == "house" and source_type == "gas":
            waste_amount, waste_percentage = waste_gas_house(display_total_consumption, facility_subtype, months)
        
        waste_cost = None
        if waste_amount is not None:
            monthly_avg_consumption = display_total_consumption / months if months > 0 else 0
            cat, rate, total_cost = process_row_cost_house(monthly_avg_consumption, source_type, period='monthly')
            waste_cost = round(waste_amount * rate, 2)
        
        analysis_results[f"last_{months}_months"] = {
            "total_consumption": round(display_total_consumption, 2),
            "average_daily_consumption": round(avg_daily, 2),
            "monthly_costs": {k: round(v / 60, 2) if source_type == 'electricity' else round(v, 2) for k, v in monthly_costs.items()},
            "monthly_consumption": {k: round(v / 60, 2) if source_type == 'electricity' else round(v, 2) for k, v in monthly_consumption.items()},
            "waste_amount": waste_amount,
            "waste_percentage": waste_percentage,
            "waste_cost": waste_cost
        }
        
    return analysis_results, df
