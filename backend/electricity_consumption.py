def process_electricity_consumption(df, environment_type: str, facility_subtype: str, holiday_usage: str, holiday_days: str, duration_months: int, data_handling_method: str):
    """
    Routes the electricity consumption data to the appropriate environment module.
    """
    if environment_type == 'house':
        from house_electricity_consumption_prediction import process_house_electricity
        return process_house_electricity(df, facility_subtype, holiday_usage, holiday_days, duration_months, data_handling_method)
    elif environment_type == 'factory':
        from factory_electricity_consumption_prediction import process_factory_electricity
        return process_factory_electricity(df, facility_subtype, holiday_usage, holiday_days, duration_months, data_handling_method)
    elif environment_type == 'company':
        from company_electricity_consumption_prediction import process_company_electricity
        return process_company_electricity(df, facility_subtype, holiday_usage, holiday_days, duration_months, data_handling_method)
    else:
        raise ValueError(f"Unknown environment type: {environment_type}")
