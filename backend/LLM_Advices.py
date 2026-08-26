import os
import json
from google import genai
from google.genai import types

# 1. Define the System Instruction (Static Rules)
SYSTEM_INSTRUCTION = """
You are an expert Multi-Utility Efficiency & Energy Management Consultant (Water, Natural Gas, Electricity) for the AquaGuard AI platform.

Your primary mission is utility tariff-bracket migration and penalty avoidance.
Analyze commercial/residential utility consumption, baseline forecasts, load profiles, and multi-tier rate structures. Construct an actionable, data-driven conservation and load-shifting plan.

You MUST return your response as a valid JSON object matching this schema:
{
  "day": ["actionable bullet 1 for the next 24h", "bullet 2"],
  "week": ["actionable bullet 1 for the next 7 days", "bullet 2"],
  "month": ["actionable bullet 1 for the next 30 days", "bullet 2"],
  "quarter": ["actionable bullet 1 for the next 90 days", "bullet 2"]
}
Do NOT output any markdown blocks, just the raw JSON object. Keep bullet points direct, quantitative, and engineering-focused.
"""

try:
    client = genai.Client(api_key=os.environ.get("GEMINI_API_KEY"))
except Exception as e:
    client = None
    print(f"Warning: Could not initialize Gemini API client. {e}")

# 2. Function to populate the Dynamic User Prompt with runtime data
def generate_energy_advice(facility_data: dict) -> dict:
    if client is None:
        return {
            "day": ["Gemini API key is not configured. Please set GEMINI_API_KEY."],
            "week": ["Gemini API key is not configured."],
            "month": ["Gemini API key is not configured."],
            "quarter": ["Gemini API key is not configured."]
        }
    # Build the dynamic user prompt with actual values
    user_prompt = f"""
Analyze the following multi-utility consumption profile and provide a prioritized plan to migrate this facility into lower tariff brackets:

### FACILITY CONTEXT:
- Facility Name: {facility_data.get('name', 'N/A')}
- Facility Type: {facility_data.get('type', 'N/A')}
- Location: {facility_data.get('location', 'N/A')}

### 1. 💧 WATER:
- Actual Usage: {facility_data.get('water', {}).get('actual', 'N/A')} m³ | Baseline: {facility_data.get('water', {}).get('baseline', 'N/A')} m³
- Detected Waste: {facility_data.get('water', {}).get('waste', 'N/A')} m³
- Current Tier: {facility_data.get('water', {}).get('current_tier', 'N/A')} (Rate: {facility_data.get('water', {}).get('current_rate', 'N/A')})
- Target Lower Tier Limit: ≤ {facility_data.get('water', {}).get('target_limit', 'N/A')} m³ (Rate: {facility_data.get('water', {}).get('target_rate', 'N/A')})
- Context / Anomaly: {facility_data.get('water', {}).get('notes', 'N/A')}

### 2. ⚡ ELECTRICITY:
- Total Consumption: {facility_data.get('electricity', {}).get('actual', 'N/A')} kWh | Baseline: {facility_data.get('electricity', {}).get('baseline', 'N/A')} kWh
- Peak Demand: {facility_data.get('electricity', {}).get('peak_kw', 'N/A')} kW (Target Peak Limit: ≤ {facility_data.get('electricity', {}).get('peak_limit', 'N/A')} kW)
- Current Tier: {facility_data.get('electricity', {}).get('current_tier', 'N/A')}
- Target Lower Tier Limit: ≤ {facility_data.get('electricity', {}).get('target_limit', 'N/A')} kWh
- Context / Anomaly: {facility_data.get('electricity', {}).get('notes', 'N/A')}

### 3. 🔥 NATURAL GAS:
- Actual Usage: {facility_data.get('gas', {}).get('actual', 'N/A')} m³ | Baseline: {facility_data.get('gas', {}).get('baseline', 'N/A')} m³
- Current Tier: {facility_data.get('gas', {}).get('current_tier', 'N/A')}
- Target Lower Tier Limit: ≤ {facility_data.get('gas', {}).get('target_limit', 'N/A')} m³
- Context / Anomaly: {facility_data.get('gas', {}).get('notes', 'N/A')}
"""

    try:
        # 3. Call the model with system instruction + dynamic user prompt
        response = client.models.generate_content(
            model="gemini-2.5-flash",
            contents=user_prompt,
            config=types.GenerateContentConfig(
                system_instruction=SYSTEM_INSTRUCTION,
                temperature=0.2, # Low temperature for analytical accuracy
                response_mime_type="application/json"
            ),
        )
        
        return json.loads(response.text)
    except Exception as e:
        print(f"Error generating LLM advice: {e}")
        return {
            "day": ["Could not generate advice at this time."],
            "week": ["Could not generate advice at this time."],
            "month": ["Could not generate advice at this time."],
            "quarter": ["Could not generate advice at this time."]
        }
