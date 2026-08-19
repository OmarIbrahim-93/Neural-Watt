import '../environment_config_screen.dart';

class SetupConfig {
  String resource;
  EnvironmentType environmentType;
  String facilityName;
  String facilityLocation;
  String facilitySubType;
  bool holidayUsageEnabled;
  List<String> holidayDays;
  String? csvFilePath;
  String? csvFileName;
  dynamic csvFileBytes;
  Map<String, String>? manualMeterValues;
  SetupConfig({
    this.resource = 'Electricity',
    this.environmentType = EnvironmentType.house,
    this.facilityName = 'ABC Factory',
    this.facilityLocation = 'Industrial Zone, Sector 4',
    this.facilitySubType = '',
    this.holidayUsageEnabled = true,
    this.holidayDays = const [],
    this.csvFilePath,
    this.csvFileName,
    this.csvFileBytes,
    this.manualMeterValues,
  });
}
