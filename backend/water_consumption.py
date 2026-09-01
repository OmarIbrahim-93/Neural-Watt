def process_water_consumption(df, environment_type: str, facility_subtype: str, holiday_usage: str, holiday_days: str, duration_months: int, data_handling_method: str, facility_size: str = ""):
    """
    Routes the water consumption data to the appropriate environment module.
    """
    if environment_type == 'house':
        from house_water_consumption_prediction import process_house_water
        return process_house_water(df, facility_subtype, holiday_usage, holiday_days, duration_months, data_handling_method)
    elif environment_type == 'factory':
        from factory_water_consumption_prediction import process_factory_water
        return process_factory_water(df, facility_subtype, holiday_usage, holiday_days, duration_months, data_handling_method)
    elif environment_type == 'company':
        from company_water_consumption_prediction import process_company_water
        return process_company_water(df, facility_subtype, holiday_usage, holiday_days, duration_months, data_handling_method)
    else:
        raise ValueError(f"Unknown environment type: {environment_type}")
