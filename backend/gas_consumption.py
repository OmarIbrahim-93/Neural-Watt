def process_gas_consumption(df, environment_type: str, facility_subtype: str, holiday_usage: str, holiday_days: str, duration_months: int, data_handling_method: str, tmp_path: str = None):
    """
    Routes the gas consumption data to the appropriate environment module.
    """
    if environment_type == 'house':
        from house_gas_consumption_prediction import process_house_gas
        return process_house_gas(df, facility_subtype, holiday_usage, holiday_days, duration_months, data_handling_method)
    elif environment_type == 'factory':
        from factory_gas_consumption_prediction import process_factory_gas
        return process_factory_gas(df, facility_subtype, holiday_usage, holiday_days, duration_months, data_handling_method)
    elif environment_type == 'company':
        from company_gas_consumption_prediction import process_company_gas
        return process_company_gas(df, facility_subtype, holiday_usage, holiday_days, duration_months, data_handling_method, tmp_path)
    else:
        raise ValueError(f"Unknown environment type: {environment_type}")
