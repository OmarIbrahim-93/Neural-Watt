import json

# 2. Function to populate the Dynamic User Prompt with runtime data
def generate_energy_advice(facility_data: dict) -> dict:
    """
    Mock LLM generator. Does not require an API key.
    Generates a realistic JSON response based on facility data.
    """
    name = facility_data.get('name', 'the facility')
    water_actual = facility_data.get('water', {}).get('actual', 'N/A')
    elec_actual = facility_data.get('electricity', {}).get('actual', 'N/A')
    gas_actual = facility_data.get('gas', {}).get('actual', 'N/A')
    
    # Return a mocked realistic response matching the expected schema
    return {
        "day": [
            f"Reduce immediate peak load for {name} by staggering HVAC start times today.",
            "Inspect water valves and cooling towers for detected overnight leakage.",
            f"Shift high-energy operations to off-peak hours to manage {elec_actual} kWh daily consumption."
        ],
        "week": [
            "Perform weekly maintenance on main HVAC units to improve efficiency and reduce baseline.",
            f"Review natural gas heating schedules to optimize the {gas_actual} m³ usage.",
            "Install and calibrate smart sensors in low-traffic zones to reduce baseline electricity waste."
        ],
        "month": [
            "Analyze monthly utility bills to verify tier migration success and tariff reduction.",
            "Conduct staff training on energy and water conservation protocols.",
            f"Retrofit high-flow water fixtures to help reduce the {water_actual} m³ monthly consumption."
        ],
        "quarter": [
            "Implement a comprehensive energy management system (EMS) for real-time monitoring across all utilities.",
            "Negotiate new tariff rates with utility providers based on improved and stable load profiles.",
            "Plan capital expenditure for solar panel installation or high-efficiency LED lighting upgrades."
        ]
    }
