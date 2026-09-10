# Neural-Watt — Comprehensive Application Report

## 1. Overview

**Neural-Watt** (branded as **NeuralWatt** in the UI) is a full-stack, AI-driven utility consumption intelligence platform. It allows users to:

- Track and predict **Water**, **Electricity**, and **Gas** consumption.
- Operate across **House**, **Company**, and **Factory** environments.
- Upload historical CSV data and get ML-powered forecasts (next day, next week, next month, next quarter).
- Detect **waste and anomalies** in consumption.
- Receive **LLM-generated advice** tailored to their environment type and equipment.
- View **analytics dashboards** with monthly breakdowns, consumption charts, and cost tables.

**Version:** 1.0.0+1  
**SDK:** Dart ^3.10.7  
**Platform Targets:** Android, iOS, Web, Windows, macOS, Linux

---

## 2. Technology Stack

### 2.1 Frontend — Flutter (Dart)

| Dependency               | Version    | Purpose                                    |
|--------------------------|------------|--------------------------------------------|
| `flutter`                | SDK        | Cross-platform UI framework                |
| `cupertino_icons`        | ^1.0.8     | iOS-style icons                            |
| `shared_preferences`     | ^2.5.5     | Local key-value persistence (auth, theme)  |
| `file_picker`            | ^8.1.7     | Selecting CSV files for upload              |
| `http`                   | ^1.2.0     | HTTP communication with the Python backend |
| `intl`                   | ^0.20.3    | Number and date formatting                 |

**Dev Dependencies:**  
- `flutter_test` (unit testing)  
- `flutter_lints` ^6.0.0 (lint rules)

### 2.2 Backend — Python (FastAPI)

| Component    | Technology  | Purpose                                                  |
|--------------|-------------|----------------------------------------------------------|
| Web Server   | FastAPI     | REST API framework                                       |
| Runner       | Uvicorn     | ASGI server                                              |
| Data         | Pandas      | CSV processing, time-series aggregation                  |
| ML Models    | Custom      | Prediction models stored in `Models/` directory          |
| LLM Advice   | Custom      | Rule-based advice engine with equipment-specific tips    |

The backend runs **two servers**:
1. **`app.py`** on port **8000** — Handles CSV analysis & missing-day detection.
2. **`neural_watt_main.py`** on port **8005** — Handles predictions, analytics, waste calculation, and LLM advice generation.

### 2.3 Design System

- **Material 3** (useMaterial3: true) with a custom `Inter` font family.
- **Full Light/Dark theme** with persistence via `SharedPreferences`.
- Custom `AppColors` class for consistent semantic color tokens across both themes.
- Animated `ThemeToggleButton` (sun/moon with rotation and scale transitions) present on every screen's AppBar.

---

## 3. Bottom Navigation Bar (5 Tabs)

The app uses a persistent **5-tab `BottomNavigationBar`** present on the Home Screen and the Prediction Screen. Here are all 5 navigation items:

| Index | Label        | Icon                         | Content / Screen                                                                         |
|-------|-------------|------------------------------|------------------------------------------------------------------------------------------|
| 0     | **HOME**     | `Icons.home_filled`          | Resource selection (Electricity, Water, Gas) — launches the 6-step setup wizard.         |
| 1     | **ANALYTICS**| `Icons.analytics_outlined`   | Full analytics dashboard with consumption history, charts, cost breakdowns.              |
| 2     | **PREDICT**  | `Icons.auto_awesome_outlined`| AI Prediction results screen (or placeholder: "Forecast energy demand, peak loads…").    |
| 3     | **WASTE**    | `Icons.delete_outline`       | Waste & Anomaly Detection placeholder: "Identify phantom loads, standby power waste…"   |
| 4     | **PROFILE**  | `Icons.person_outline`       | Facility Profile & Settings placeholder: "Manage organization parameters, meters…"     |

**Nav bar styling:** The selected tab icon is highlighted with a pill-shaped `Container` (accent blue background, rounded corners). The nav bar background respects light/dark theme.

> **Note:** The WASTE and PROFILE tabs currently render **placeholder views** with a centered icon, title, and subtitle. They do not yet have full implementations.

---

## 4. App Flow & All Screens (Detailed)

### 4.1 Entry Point — `main.dart`

- Initializes `MyApp` as a `StatelessWidget`.
- Uses a `ValueListenableBuilder<ThemeMode>` listening to `AppThemeNotifier.instance` for reactive theme switching.
- Sets `LoginScreen` as the home page.
- Disables the debug banner.
- Configures smooth theme animation (350ms, `Curves.easeInOut`).

---

### 4.2 Login Screen — `login_screen.dart`

**Purpose:** User authentication with email and password.

**UI Components:**
- **NeuralWatt logo** — A bolt icon inside a rounded card with shadow.
- **App title** — "NeuralWatt" with subtitle "Smart Consumption Intelligence".
- **Work Email field** — With envelope icon, rounded borders, and focus highlight.
- **Password field** — With lock icon, toggle visibility (eye icon), "Forgot?" link.
- **"Get Started" button** — Full-width, black (light) or accent blue (dark), with arrow icon.
- **Social login divider** — "Or continue with" separator.
- **Google login button** — With red G icon.
- **SSO login button** — With blue business icon, labeled "SSO".
- **"Don't have an account? Request access"** link — navigates to `SignupScreen`.

**Logic:**
- Reads stored credentials from `SharedPreferences` (`user_email`, `user_password`).
- If this is the first time (no stored email), the user is allowed in.
- If credentials match stored values, navigates to `HomeScreen`.
- Otherwise, shows "Invalid email or password" snackbar.

---

### 4.3 Signup Screen — `signup_screen.dart`

**Purpose:** New account creation.

**UI Components:**
- **Responsive layout** — On wide screens (≥900px): split-view with left branding panel (deep blue gradient, feature highlights) and right form. On narrow screens: single-column form.
- **Left branding panel** (wide only):
  - NeuralWatt logo, "Join NeuralWatt" heading.
  - Three feature rows with icons:
    1. ⚡ "Instant Telemetry Ingestion" — Upload CSV or stream live metrics.
    2. ✨ "Automated Gap Resolution" — AI fills missing historical data.
    3. 📊 "Precision Analytics" — Insights for homes, offices & plants.
- **Form fields:**
  - Full Name (person icon)
  - Work Email (envelope icon)
  - Password (lock icon, toggle visibility)
- **"Sign Up" button** — Full-width, black background.
- **Social signup options** — Google and Enterprise SSO buttons.
- **"Already have an account? Log in"** — Navigates back to `LoginScreen`.

**Logic:**
- Saves name, email, password to `SharedPreferences`.
- Shows "Account created successfully! Please login." and redirects to `LoginScreen`.

---

### 4.4 Home Screen — `home_screen.dart`

**Purpose:** Main dashboard and navigation hub.

**Structure:**
- AppBar with "NeuralWatt" title and `ThemeToggleButton`.
- Body content switches based on the selected bottom navigation index (see Section 3 above).
- When `HOME` (index 0) is selected, displays the **Resource Selection** view.

**Resource Selection View (HOME tab):**
- Title: "Select Resource" with subtitle "Choose ONE resource to analyze."
- Three resource cards in a responsive layout (row on wide screens, column on narrow):

| Resource       | Unit | Icon                                | Icon Color |
|----------------|------|-------------------------------------|------------|
| **Electricity** | KWH  | `Icons.bolt_rounded`                | Amber      |
| **Water**       | M³   | `Icons.water_drop_outlined`         | Blue       |
| **Gas**         | M³   | `Icons.local_fire_department_outlined` | Indigo  |

- Each card shows the resource name and unit. Tapping a card sets it as selected (blue border + checkmark) and navigates to `AnalysisSetupScreen` with the resource embedded in a `SetupConfig` object.

**Waste Tab (Index 3):**
- Placeholder view titled "Waste & Anomaly Detection" with subtitle "Identify phantom loads, standby power waste, and thermal leaks."
- Uses `Icons.delete_outline` icon.

**Profile Tab (Index 4):**
- Placeholder view titled "Facility Profile & Settings" with subtitle "Manage organization parameters, meters, and API integrations."
- Uses `Icons.person_outline` icon.

**Predict Tab (Index 2) — Special Behavior:**
- If `PredictionScreen.lastPredictionData` is available (a prior prediction was made), tapping the PREDICT tab navigates directly to the `PredictionScreen` with the cached prediction results.
- Otherwise, shows a placeholder view titled "AI Predictive Models" with subtitle "Forecast energy demand, peak loads, and cost optimization."

---

### 4.5 Six-Step Setup Wizard

The app guides the user through a **6-step configuration wizard** (tracked with a progress bar) before running predictions:

#### Step 1 — Resource Selection (Home Screen)
Select Electricity, Water, or Gas.

#### Step 2 — Analysis Setup — `analysis_setup_screen.dart`
- Title: "What do you want to analyze?"
- Subtitle: "Select an environment to begin monitoring energy flows."
- Two environment cards (responsive row/column):
  - **House** (home icon) — "Analyze household consumption"
  - **Company** (business icon) — "Analyze company/building usage"
- Selecting an environment navigates to `EnvironmentConfigScreen`.

#### Step 3 — Environment Configuration — `environment_config_screen.dart`
- Title adapts to environment type: "House Environment", "Company Environment", or "Factory Environment".
- **Form fields (all mandatory):**
  - **Name** (e.g., "Smith Residence", "Acme Corp Headquarters")
  - **Location** (City, Country)
  - **Type/Size Dropdown:**
    - House: Number of Persons (1–10)
    - Company/Factory: Company Type (Bakery, Office, Hotel, Restaurant, School, SuperMarket)
  - **Company Size** (small/medium/large) — only shown for Company & Factory environments.
  - **Gas Price** (EGP/m³) — only shown for Company + Gas resource combination.
- **"Intelligence Initialization" info box** — Explains that NeuralWatt provisions relevant templates automatically.
- **"Continue Setup" button** — Validates all mandatory fields, then navigates to `HolidayScheduleScreen`.

#### Step 4 — Holiday Schedule — `holiday_schedule_screen.dart`
- Title: "Holiday Schedule"
- Subtitle: "Configure your typical holiday and resource usage patterns for accurate predictions."
- **Day selector** — 7 day chips (Mon–Sun), defaulting to Sat & Sun selected.
- **Toggle** — "Use [resource] during holidays" — Affects prediction model behavior.
- Navigates to `HistoricalDataPeriodScreen`.

#### Step 5 — Historical Data Period — `historical_data_period_screen.dart`
- Title: "Historical Data Period"
- Subtitle: "Select the time horizon for the AI quality analysis."
- **Duration selector** — User picks the number of months of historical data (from the provided options).
- Navigates to `UploadConsumptionScreen`.

#### Step 6 — Upload Consumption File — `upload_consumption_screen.dart`
- Title: "Upload Consumption File"
- Subtitle: "Import historical energy data to calibrate your predictive models."
- **Upload area** with dashed border:
  - "Drag & Drop CSV" or browse button.
  - Supports only `.csv` files, max 50MB.
  - After selecting, shows the file name.
- **Schema Requirements box:**
  - Must include `timestamp` column (ISO 8601).
  - Must include `consumption_kwh` column (Numeric).
- **"Continue" button** — Sends the CSV to the backend's `/api/analyze-consumption` endpoint for quality analysis, then navigates to `DataQualityScreen`.
- Shows "Analyzing Telemetry…" loading state during API call.
- Falls back to sample data if the API is unreachable.

---

### 4.6 Data Quality & Missing Data Handling

#### Data Quality Screen — `data_quality_screen.dart`
- Title: "Data Quality"
- Subtitle: "Review the completeness of your energy datasets before final processing."
- **Completeness card** — Shows a circular or linear indicator with the completeness percentage (e.g., 96%).
- **Statistics cards** — Expected days/hours count, existing count, missing count.
- **Continue / Handle Missing Data** — If data is complete, goes straight to `ReviewConfigurationScreen`. If missing days exist, navigates to `MissingDataDetectedScreen`.

#### Missing Data Detected Screen — `missing_data_detected_screen.dart`
- **Warning header** alerting about data gaps.
- **Identified Gaps box** — Lists each missing day with its date, status (Isolated, Consecutive Start/End), and hours missing.
- **Decision prompt** — "Do you have values for these dates?"
  - **"Yes, I have meter values"** → navigates to `ManualEntryScreen`.
  - **"No, let the AI fill them"** → navigates to `HandleMissingDataScreen` with AI interpolation method.

#### Manual Entry Screen — `manual_entry_screen.dart`
- Allows the user to manually enter meter reading values for each identified missing day.
- Saves values into `config.manualMeterValues`.

#### Handle Missing Data Screen — `handle_missing_data_screen.dart`
- Presents data handling methods (e.g., AI interpolation, zero-fill, average-fill).
- The chosen method is passed to the backend as `data_handling_method`.

---

### 4.7 Review Configuration Screen — `review_configuration_screen.dart`

- Title: "Review Configuration"
- Subtitle: "Verify your prediction parameters before initialization."
- **Summary of all configuration:**
  - Target Facility name and location
  - Resource type (Electricity/Water/Gas)
  - Environment type (House/Company/Factory)
  - Holiday settings
  - Data quality score
  - Duration months
  - Data handling method
- **"Initialize AI Prediction" button** — Sends all config + CSV data to the backend's `/api/predict` endpoint.
- Shows "Predicting…" loading state.
- On success, navigates to `PredictionScreen` with the full response data.

---

### 4.8 Prediction Screen — `prediction_screen.dart`

**Purpose:** Displays AI-generated consumption forecasts, waste analysis, and efficiency advice.

**Tabs (dynamic, based on available data):**
- **NEXT DAY** — Predicted consumption for tomorrow.
- **NEXT WEEK** — 7-day forecast.
- **NEXT MONTH** — 30-day forecast.
- **NEXT QUARTER** — 90-day forecast (appears for ≥9 months historical data).

**Cards & Components:**

| Card                        | Content                                                                             |
|-----------------------------|-------------------------------------------------------------------------------------|
| **Predicted Consumption**    | Large numeric value + unit (kWh or m³). Resource icon (bolt/droplet/fire). Decorative sparkle icon. |
| **Est. Waste**               | Estimated wasted amount in the same unit. Warning icon.                             |
| **Waste Ratio**              | Percentage of predicted consumption that is waste. Yellow progress bar.             |
| **Waste Cost**               | Monetary value of the wasted resource in **LE (Egyptian Pounds)**. Down-arrow icon.  |
| **Consumption Forecast**     | Custom `ForecastChartPainter` (a hand-drawn spline chart with gradient fill). Shows actual history (solid line) vs. predicted value (dashed blue line). Legend: "Actual" vs "Predicted". |
| **AI Efficiency Advisor**    | LLM-generated advice cards. Each card has a type-specific icon and color:            |
|                             | • `waste_reduction` — orange sweep icon                                              |
|                             | • `category_reduction` — green trending-down icon                                   |
|                             | • `category_maintenance` — green verified icon                                       |
|                             | • `equipment_check` — red build icon                                                 |
|                             | • `general_advice` — yellow lightbulb icon                                           |

**Static data caching:** The `PredictionScreen` stores the last prediction in static fields (`lastPredictionData`, `lastResourceType`, `lastFacilityName`, `lastEnvironmentType`, `lastDurationMonths`) so the user can re-visit the PREDICT tab from the nav bar.

**Bottom Navigation Bar:** Also present on this screen (PREDICT tab highlighted). Tapping other tabs navigates back to `HomeScreen` with the appropriate initial index.

---

### 4.9 Analytics Screen — `analytics_screen.dart`

**Purpose:** Historical consumption analytics dashboard. Accessible from the ANALYTICS tab.

**Content:**
- **Target & Resource cards** — Display the facility name and resource type.
- **Period dropdown** — Select analysis period: Last 12 Months, Last 6 Months, Last 3 Months, Last 1 Month.
- **Total Consumption** stat card — Large value with resource icon.
- **Waste Amount** stat card (if waste > 0) — with warning icon.
- **Waste %** stat card — Percentage of total that is waste.
- **Waste Cost** stat card — In LE (Egyptian Pounds).
- **Avg. Daily Consumption** stat card — Trend icon.
- **Consumption Comparison chart** — Custom bar chart (`_buildDynamicChart`):
  - Scrollable horizontal bar chart.
  - Month labels (Jan, Feb, etc.).
  - Compact value labels above each bar.
  - Background grid lines.
- **Detailed Cost breakdown table:**
  - Columns: Month | Consumption (kWh or m³) | Cost (LE).
  - Sorted newest-first.
  - Month formatted as "MMMM yyyy".

---

## 5. Backend Architecture (Detailed)

### 5.1 Data Analysis Server — `app.py` (Port 8000)

**Endpoints:**
- `GET /health` — Returns `{"status": "ok", "service": "NeuralWatt Backend API"}`.
- `POST /api/analyze-consumption` — Accepts a CSV file + `duration_months`. Returns missing day analysis.

**Data Processing Pipeline:**
1. Read uploaded CSV → save to temp file.
2. `convert_to_daily_data()` — Converts any frequency (1min, 5min, hourly, etc.) to daily by grouping on calendar date and summing values.
3. `find_missing_consumption_days()` — Creates expected date range, finds gaps, calculates completeness %, returns structured result.

### 5.2 Main Prediction Server — `neural_watt_main.py` (Port 8005)

**Endpoints:**
- `GET /` — Returns welcome message.
- `GET /health` — Health check.
- `POST /api/predict` — Main prediction endpoint.

**`/api/predict` accepts (all via multipart form):**
- `resource_type` (water/electricity/gas)
- `environment_type` (house/company/factory)
- `facility_subtype` (Bakery/Office/Hotel/Restaurant/School/SuperMarket)
- `facility_size` (small/medium/large)
- `gas_price` (optional, EGP/m³)
- `holiday_usage` (true/false)
- `holiday_days` (comma-separated day abbreviations)
- `duration_months` (2–12)
- `has_missing_days`, `data_handling_method`
- `missing_values` (JSON: `[{"date": "...", "meter_value": "..."}]`)
- `file` (CSV upload)

**Processing Pipeline:**
1. Save CSV to temp file → `calc_consumption()` (diff consecutive meter readings).
2. `convert_to_daily_data()` with user-provided missing values.
3. **Analytics** — `Analytics()` from `Analytics.py`:
   - Calculates total/avg consumption for last 1, 3, 6, 12 months.
   - Monthly consumption & cost breakdowns.
   - Waste amount, waste %, waste cost.
   - Uses tiered pricing models for Egyptian Pound costs (house vs company rates).
4. **Prediction** — Routes to the appropriate prediction module.
5. **Waste Cost** — Calculates monetary cost of waste per horizon.
6. **LLM Advice** — `generate_energy_advice()` from `LLM_Advices.py`.
7. **History** — Resamples daily data to day/week/month/quarter for the forecast chart.
8. Returns comprehensive JSON response.

### 5.3 Resource Routing Modules

Each resource type has a router that dispatches to environment-specific predictors:

| Router File                | Dispatches To                                             |
|---------------------------|-----------------------------------------------------------|
| `water_consumption.py`     | `house_water_consumption_prediction.py`, `factory_water_consumption_prediction.py`, `company_water_consumption_prediction.py` |
| `electricity_consumption.py` | `house_electricity_consumption_prediction.py`, `factory_electricity_consumption_prediction.py`, `company_electricity_consumption_prediction.py` |
| `gas_consumption.py`       | `house_gas_consumption_prediction.py`, `factory_gas_consumption_prediction.py`, `company_gas_consumption_prediction.py` |

This results in a **3×3 prediction matrix** (3 resource types × 3 environment types = 9 prediction modules).

### 5.4 Analytics Module — `Analytics.py`

**Cost Models (Egyptian Pound Tiered Pricing):**

**House Electricity Rates:**
| Tier | Threshold (monthly kWh) | Rate (LE/kWh) |
|------|------------------------|---------------|
| 1    | ≤ 50                   | 0.68          |
| 2    | ≤ 100                  | 0.78          |
| 3    | ≤ 200                  | 0.95          |
| 4    | ≤ 350                  | 1.55          |
| 5    | ≤ 650                  | 1.95          |
| 6    | ≤ 1000                 | 2.10          |
| 7    | > 1000                 | 2.58          |

**House Water Rates:**
| Tier | Threshold (monthly m³) | Rate (LE/m³) |
|------|------------------------|--------------|
| 1    | ≤ 10                   | 2.00         |
| 2    | ≤ 20                   | 3.00         |
| 3    | ≤ 30                   | 4.00         |
| 4    | > 30                   | 4.50         |

**House Gas Rates:**
| Tier | Threshold (monthly m³) | Rate (LE/m³) |
|------|------------------------|--------------|
| 1    | ≤ 30                   | 4.00         |
| 2    | ≤ 60                   | 5.00         |
| 3    | > 60                   | 7.00         |

**Company rates** follow a similar tiered structure with different thresholds.  
**Company gas** uses a user-provided `gas_price` (defaults to 3.4 LE/m³ if not specified).

Cost multipliers are applied to daily, weekly, monthly, and quarterly periods.

### 5.5 LLM Advice Engine — `LLM_Advices.py`

Generates personalized, context-aware advice for all 4 time horizons. It is a **rule-based engine** (not an actual LLM API call) that uses:

- **Environment-specific equipment lists** for 7 facility types × 3 resource types = 21 unique equipment lists. Examples:
  - House/Electricity: refrigerator, deep freezer, washing machine, air conditioner, etc.
  - Hotel/Water: showers, toilets, swimming-pool systems, irrigation systems, etc.
  - Bakery/Gas: gas bakery oven, gas burner, gas boiler, etc.
- **Advice types:** `waste_reduction`, `category_reduction`, `category_maintenance`, `equipment_check`, `general_advice`.
- Each advice card has a `title` and `message` with specific recommendations.

---

## 6. Data Models (Dart)

### 6.1 `SetupConfig` — `models/setup_config.dart`
Carries all wizard configuration through the setup flow:

| Field                 | Type              | Default                         |
|-----------------------|-------------------|---------------------------------|
| `resource`            | `String`          | `'Electricity'`                 |
| `environmentType`     | `EnvironmentType` | `EnvironmentType.house`         |
| `facilityName`        | `String`          | `'ABC Factory'`                 |
| `facilityLocation`    | `String`          | `'Industrial Zone, Sector 4'`   |
| `facilitySubType`     | `String`          | `''`                            |
| `facilitySize`        | `String`          | `''`                            |
| `gasPrice`            | `String`          | `''`                            |
| `holidayUsageEnabled` | `bool`            | `true`                          |
| `holidayDays`         | `List<String>`    | `[]`                            |
| `csvFilePath`         | `String?`         | `null`                          |
| `csvFileName`         | `String?`         | `null`                          |
| `csvFileBytes`        | `dynamic`         | `null`                          |
| `manualMeterValues`   | `Map<String, String>?` | `null`                     |

### 6.2 `ConsumptionAnalysisResult` — `models/consumption_analysis_result.dart`
Stores the result of the CSV quality analysis:

| Field                    | Type                   | Description                             |
|--------------------------|------------------------|-----------------------------------------|
| `success`                | `bool`                 | Whether analysis succeeded              |
| `durationMonths`         | `int`                  | Requested analysis window               |
| `startDate` / `endDate`  | `String?`              | Data range boundaries                   |
| `expectedHoursCount`     | `int`                  | Total expected data points              |
| `existingHoursCount`     | `int`                  | Actual data points found                |
| `missingHoursCount`      | `int`                  | Gap size                                |
| `expectedDaysCount`      | `int`                  | Calendar days expected                  |
| `availableDaysCount`     | `int`                  | Calendar days with data                 |
| `missingDaysCount`       | `int`                  | Days without data                       |
| `completenessPercentage` | `double`               | Data completeness (0–100)               |
| `missingHours`           | `List<MissingHourInfo>`| Individual missing hours                |
| `missingDays`            | `List<MissingDayInfo>` | Individual missing days with status     |

`MissingDayInfo` includes: `day`, `missingHours`, `firstMissingHour`, `lastMissingHour`, `dayStatus` (Isolated, Consecutive Start, Consecutive, Consecutive End, Missing).

---

## 7. API Service — `services/api_service.dart`

Handles all communication between the Flutter app and the Python backends.

**Connection Strategy:** Tries multiple base URLs in order to support various environments:
- `http://127.0.0.1:8000` / `http://localhost:8000` / `http://10.0.2.2:8000` (Analysis API)
- `http://127.0.0.1:8005` / `http://localhost:8005` / `http://10.0.2.2:8005` (Main Prediction API)

`10.0.2.2` is the Android emulator alias for the host machine's localhost.

### Methods:

**`analyzeConsumption()`** — Calls `POST /api/analyze-consumption` on port 8000:
- Sends CSV as multipart file + `duration_months`.
- Timeout: 30 seconds.
- Returns `ConsumptionAnalysisResult`.

**`submitPrediction()`** — Calls `POST /api/predict` on port 8005:
- Sends all `SetupConfig` fields + CSV as multipart.
- Sends `missing_values` as JSON-encoded string.
- Timeout: 120 seconds.
- Returns full prediction response `Map<String, dynamic>`.

Both methods include extensive `debugPrint` logging of requests and responses.

---

## 8. Utilities

### 8.1 Responsive Design — `utils/responsive.dart`

| Breakpoint | Width        | Classification |
|-----------|--------------|----------------|
| Mobile    | < 600px      | Single column  |
| Tablet    | 600–1024px   | Adaptive       |
| Desktop   | ≥ 1024px     | Wide layout    |

- `Responsive` widget returns `mobile`, `tablet`, or `desktop` children.
- `ResponsiveCenter` constrains max content width (default 600px) for readability on large screens.
- Most screens use `ResponsiveCenter` with widths ranging from 480px to 1000px.

### 8.2 Theme System — `utils/theme.dart`

**`AppThemeNotifier`** — Singleton `ValueNotifier<ThemeMode>` with:
- Persists theme preference (`'dark'`/`'light'`) to `SharedPreferences`.
- `toggleTheme()` — Switches between light and dark modes.
- `isDark()` — Accounts for system brightness when in system mode.

**`AppColors`** — Semantic color tokens:
| Token               | Light                | Dark                 |
|---------------------|----------------------|----------------------|
| scaffoldBackground  | `#F8FAFF`            | `#090D16`            |
| cardBackground      | `White`              | `#151D2A`            |
| cardBorder          | `#E2E8F0`            | `#243044`            |
| textPrimary         | `#0D1B3E`            | `#F1F5F9`            |
| textSecondary       | `#64748B`            | `#94A3B8`            |
| accentBlue          | `#2563EB`            | `#3B82F6`            |
| accentContainer     | `#EEF2FF`            | `#3B82F6` @ 15%      |
| inputFill           | `White`              | `#1E293B`            |
| navBarBackground    | `White`              | `#0F172A`            |

### 8.3 Theme Toggle Button — `utils/theme_toggle_button.dart`

- Animated icon switcher with rotation + scale transitions.
- **Dark mode:** Shows golden amber sun icon (`Icons.wb_sunny_outlined`).
- **Light mode:** Shows slate moon icon (`Icons.dark_mode_outlined`).
- Animation duration: 300ms.

---

## 9. Saved ML Models — `Models/` Directory

Pre-trained models are organized by resource type:

```
Models/
├── Electricity/     # Electricity consumption prediction models
├── Gas/             # Gas consumption prediction models
└── Water/           # Water consumption prediction models
```

---

## 10. Project File Tree (Complete)

```
Neural-Watt/
└── neural_watt/
    ├── lib/                                    # Flutter Frontend
    │   ├── main.dart                           # App entry point, MaterialApp config
    │   ├── login_screen.dart                   # Login with email/password + social auth
    │   ├── signup_screen.dart                  # Registration with responsive split-layout
    │   ├── home_screen.dart                    # Nav bar hub + resource selection
    │   ├── analysis_setup_screen.dart          # Step 2: Choose House or Company
    │   ├── environment_config_screen.dart       # Step 3: Facility name, location, type
    │   ├── holiday_schedule_screen.dart         # Step 4: Holiday day picker + toggle
    │   ├── historical_data_period_screen.dart   # Step 5: Duration months selector
    │   ├── upload_consumption_screen.dart       # Step 6: CSV upload with schema hints
    │   ├── data_quality_screen.dart             # Data completeness dashboard
    │   ├── missing_data_detected_screen.dart    # Gap identification + decision prompt
    │   ├── handle_missing_data_screen.dart      # AI fill method selection
    │   ├── manual_entry_screen.dart             # Manual meter value input for gaps
    │   ├── review_configuration_screen.dart     # Config summary + launch prediction
    │   ├── prediction_screen.dart               # Forecast results + waste + charts + LLM advice
    │   ├── analytics_screen.dart                # Historical analytics dashboard
    │   ├── models/
    │   │   ├── setup_config.dart                # SetupConfig data model
    │   │   └── consumption_analysis_result.dart # Analysis result + missing day models
    │   ├── services/
    │   │   └── api_service.dart                 # HTTP client for both backend APIs
    │   └── utils/
    │       ├── responsive.dart                  # Breakpoints + ResponsiveCenter widget
    │       ├── theme.dart                       # AppThemeNotifier + AppColors + AppTheme
    │       └── theme_toggle_button.dart         # Animated sun/moon toggle
    │
    ├── backend/                                # Python Backend
    │   ├── app.py                              # FastAPI server (port 8000) — CSV analysis
    │   ├── neural_watt_main.py                 # FastAPI server (port 8005) — predictions
    │   ├── Analytics.py                        # Consumption analytics + cost calculation
    │   ├── LLM_Advices.py                      # Rule-based advice generation engine
    │   ├── water_consumption.py                # Water prediction router
    │   ├── electricity_consumption.py          # Electricity prediction router
    │   ├── gas_consumption.py                  # Gas prediction router
    │   ├── house_water_consumption_prediction.py        # House-water ML predictor
    │   ├── house_electricity_consumption_prediction.py   # House-electricity ML predictor
    │   ├── house_gas_consumption_prediction.py           # House-gas ML predictor
    │   ├── company_water_consumption_prediction.py       # Company-water ML predictor
    │   ├── company_electricity_consumption_prediction.py # Company-electricity ML predictor
    │   ├── company_gas_consumption_prediction.py         # Company-gas ML predictor
    │   ├── factory_water_consumption_prediction.py       # Factory-water ML predictor
    │   ├── factory_electricity_consumption_prediction.py # Factory-electricity ML predictor
    │   ├── factory_gas_consumption_prediction.py         # Factory-gas ML predictor
    │   ├── Actual_daily_consumption.csv         # Generated daily data output
    │   ├── model_test_results.csv               # Model evaluation results
    │   ├── next_consumption_forecasts.csv       # Forecast output
    │   ├── result.csv                           # General results
    │   ├── CSV/                                 # Input data storage
    │   └── test_results/                        # Test output storage
    │
    ├── Models/                                 # Pre-trained ML models
    │   ├── Electricity/
    │   ├── Gas/
    │   └── Water/
    │
    ├── pubspec.yaml                            # Flutter dependencies & config
    ├── pubspec.lock                            # Locked dependency versions
    ├── analysis_options.yaml                   # Dart linter rules
    └── (android/ ios/ web/ windows/ macos/ linux/)  # Platform-specific build dirs
```

---

## 11. Summary

Neural-Watt is a comprehensive, production-quality utility intelligence application. It features:

- ✅ **16 Dart screens** covering authentication, 6-step configuration wizard, data quality handling, prediction results, and analytics.
- ✅ **5-tab navigation** (Home, Analytics, Predict, Waste, Profile) — Waste and Profile are placeholder tabs awaiting implementation.
- ✅ **Full Light/Dark theming** with animated toggle and persistence.
- ✅ **Responsive design** adapting to mobile, tablet, and desktop layouts across all screens.
- ✅ **9 prediction modules** (3 resources × 3 environments) in the Python backend.
- ✅ **Tiered Egyptian Pound pricing models** for cost analytics.
- ✅ **Custom chart rendering** (bar charts, spline forecast charts with gradient fills).
- ✅ **21 equipment-specific advice templates** for context-aware AI recommendations.
- ✅ **Robust data pipeline** converting any-frequency CSV data to daily consumption with missing-day detection and fill strategies.
