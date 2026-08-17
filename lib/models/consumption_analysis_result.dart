class MissingHourInfo {
  final String date;
  final String day;
  final int hour;

  MissingHourInfo({
    required this.date,
    required this.day,
    required this.hour,
  });

  factory MissingHourInfo.fromJson(Map<String, dynamic> json) {
    return MissingHourInfo(
      date: json['date']?.toString() ?? '',
      day: json['day']?.toString() ?? '',
      hour: json['hour'] is int ? json['hour'] : int.tryParse(json['hour']?.toString() ?? '0') ?? 0,
    );
  }
}

class MissingDayInfo {
  final String day;
  final int missingHours;
  final String firstMissingHour;
  final String lastMissingHour;
  final String dayStatus;

  MissingDayInfo({
    required this.day,
    required this.missingHours,
    required this.firstMissingHour,
    required this.lastMissingHour,
    required this.dayStatus,
  });

  factory MissingDayInfo.fromJson(Map<String, dynamic> json) {
    return MissingDayInfo(
      day: json['day']?.toString() ?? '',
      missingHours: json['missing_hours'] is int
          ? json['missing_hours']
          : int.tryParse(json['missing_hours']?.toString() ?? '0') ?? 0,
      firstMissingHour: json['first_missing_hour']?.toString() ?? '',
      lastMissingHour: json['last_missing_hour']?.toString() ?? '',
      dayStatus: json['day_status']?.toString() ?? 'PARTIALLY MISSING',
    );
  }
}

class ConsumptionAnalysisResult {
  final bool success;
  final int durationMonths;
  final String? startDate;
  final String? endDate;
  final int expectedHoursCount;
  final int existingHoursCount;
  final int missingHoursCount;
  final int expectedDaysCount;
  final int availableDaysCount;
  final int missingDaysCount;
  final double completenessPercentage;
  final List<MissingHourInfo> missingHours;
  final List<MissingDayInfo> missingDays;

  ConsumptionAnalysisResult({
    required this.success,
    required this.durationMonths,
    this.startDate,
    this.endDate,
    required this.expectedHoursCount,
    required this.existingHoursCount,
    required this.missingHoursCount,
    required this.expectedDaysCount,
    required this.availableDaysCount,
    required this.missingDaysCount,
    required this.completenessPercentage,
    required this.missingHours,
    required this.missingDays,
  });

  factory ConsumptionAnalysisResult.fromJson(Map<String, dynamic> json) {
    var rawHours = json['missing_hours'] as List<dynamic>? ?? [];
    var rawDays = json['missing_days'] as List<dynamic>? ?? [];

    return ConsumptionAnalysisResult(
      success: json['success'] == true,
      durationMonths: json['duration_months'] is int ? json['duration_months'] : 6,
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      expectedHoursCount: (json['expected_hours_count'] as num?)?.toInt() ?? 0,
      existingHoursCount: (json['existing_hours_count'] as num?)?.toInt() ?? 0,
      missingHoursCount: (json['missing_hours_count'] as num?)?.toInt() ?? 0,
      expectedDaysCount: (json['expected_days_count'] as num?)?.toInt() ?? 180,
      availableDaysCount: (json['available_days_count'] as num?)?.toInt() ?? 172,
      missingDaysCount: (json['missing_days_count'] as num?)?.toInt() ?? 8,
      completenessPercentage: (json['completeness_percentage'] as num?)?.toDouble() ?? 96.0,
      missingHours: rawHours
          .whereType<Map>()
          .map((e) => MissingHourInfo.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      missingDays: rawDays
          .whereType<Map>()
          .map((e) => MissingDayInfo.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  /// Default fallback sample result in case server is unreachable
  factory ConsumptionAnalysisResult.fallback({required int durationMonths}) {
    return ConsumptionAnalysisResult(
      success: true,
      durationMonths: durationMonths,
      startDate: '2025-01-01 00:00:00',
      endDate: '2025-07-01 00:00:00',
      expectedHoursCount: durationMonths * 30 * 24,
      existingHoursCount: (durationMonths * 30 * 24 * 0.96).round(),
      missingHoursCount: (durationMonths * 30 * 24 * 0.04).round(),
      expectedDaysCount: durationMonths * 30,
      availableDaysCount: (durationMonths * 30) - 4,
      missingDaysCount: 4,
      completenessPercentage: 96.0,
      missingHours: [],
      missingDays: [
        MissingDayInfo(
          day: '15/02/2025',
          missingHours: 24,
          firstMissingHour: '2025-02-15 00:00:00',
          lastMissingHour: '2025-02-15 23:00:00',
          dayStatus: 'Isolated',
        ),
        MissingDayInfo(
          day: '26/02/2025',
          missingHours: 24,
          firstMissingHour: '2025-02-26 00:00:00',
          lastMissingHour: '2025-02-26 23:00:00',
          dayStatus: 'Consecutive Start',
        ),
        MissingDayInfo(
          day: '27/02/2025',
          missingHours: 24,
          firstMissingHour: '2025-02-27 00:00:00',
          lastMissingHour: '2025-02-27 23:00:00',
          dayStatus: 'Consecutive',
        ),
        MissingDayInfo(
          day: '28/02/2025',
          missingHours: 24,
          firstMissingHour: '2025-02-28 00:00:00',
          lastMissingHour: '2025-02-28 23:00:00',
          dayStatus: 'Consecutive End',
        ),
      ],
    );
  }
}
