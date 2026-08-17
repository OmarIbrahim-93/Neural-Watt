import '../environment_config_screen.dart';

class SetupConfig {
  String resource;
  EnvironmentType environmentType;
  String facilityName;
  String facilityLocation;
  String facilitySubType;
  bool holidayUsageEnabled;

  SetupConfig({
    this.resource = 'Electricity',
    this.environmentType = EnvironmentType.house,
    this.facilityName = 'ABC Factory',
    this.facilityLocation = 'Industrial Zone, Sector 4',
    this.facilitySubType = '',
    this.holidayUsageEnabled = true,
  });
}
