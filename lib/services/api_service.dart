import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/consumption_analysis_result.dart';
import '../models/setup_config.dart';

class ApiService {
  static const List<String> baseUrls = [
    'http://127.0.0.1:8000',
    'http://localhost:8000',
    'http://10.0.2.2:8000',
    'http://127.0.0.1:8005',
    'http://localhost:8005',
    'http://10.0.2.2:8005',
  ];

  static Future<ConsumptionAnalysisResult> analyzeConsumption({
    required int durationMonths,
    String? filePath,
    Uint8List? fileBytes,
    required String fileName,
  }) async {
    Object? lastError;

    for (final baseUrl in baseUrls) {
      try {
        final uri = Uri.parse('$baseUrl/api/analyze-consumption');
        final request = http.MultipartRequest('POST', uri);

        request.fields['duration_months'] = durationMonths.toString();

        if (fileBytes != null && fileBytes.isNotEmpty) {
          request.files.add(
            http.MultipartFile.fromBytes('file', fileBytes, filename: fileName),
          );
        } else if (filePath != null && filePath.isNotEmpty && !kIsWeb) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'file',
              filePath,
              filename: fileName,
            ),
          );
        } else {
          throw Exception(
            'CSV file bytes or file path are missing. Please re-select your file.',
          );
        }

        final streamedResponse = await request.send().timeout(
          const Duration(seconds: 3),
        );
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          final Map<String, dynamic> data =
              jsonDecode(response.body) as Map<String, dynamic>;
          debugPrint('================ API BACKEND RESPONSE ================');
          debugPrint('Status Code: 200 OK');
          debugPrint('Duration Months: ${data['duration_months']}');
          debugPrint('Expected Days Count: ${data['expected_days_count']}');
          debugPrint('Available Days Count: ${data['available_days_count']}');
          debugPrint('Missing Days Count: ${data['missing_days_count']}');
          debugPrint('Completeness Percentage: ${data['completeness_percentage']}%');
          debugPrint('Missing Days List Length: ${(data['missing_days'] as List?)?.length}');
          debugPrint('======================================================');
          return ConsumptionAnalysisResult.fromJson(data);
        } else {
          String detail = 'API error (${response.statusCode})';
          try {
            final decoded = jsonDecode(response.body);
            if (decoded is Map && decoded.containsKey('detail')) {
              detail = decoded['detail'].toString();
            } else if (decoded is String) {
              detail = decoded;
            }
          } catch (_) {}
          throw Exception(detail);
        }
      } catch (e) {
        lastError = e;
        debugPrint('ApiService connection attempt on $baseUrl failed: $e');
        if (e.toString().contains('Missing required columns') ||
            e.toString().contains('CSV does not contain') ||
            e.toString().contains('must be an integer') ||
            e.toString().contains('CSV file bytes')) {
          rethrow;
        }
      }
    }

    throw Exception(
      'Could not connect to Python API backend server ($lastError). Please run: python -m uvicorn app:app --port 8000',
    );
  }

  static Future<Map<String, dynamic>> submitPrediction({
    required SetupConfig config,
    required int durationMonths,
    required bool hasMissingDays,
    required String dataHandlingMethod,
  }) async {
    Object? lastError;

    // Use the 8005 endpoints for the main backend
    final List<String> mainBackendUrls = [
      'http://127.0.0.1:8005',
      'http://localhost:8005',
      'http://10.0.2.2:8005',
    ];

    for (final baseUrl in mainBackendUrls) {
      try {
        final uri = Uri.parse('$baseUrl/api/predict');
        final request = http.MultipartRequest('POST', uri);

        request.fields['resource_type'] = config.resource;
        request.fields['environment_type'] = config.environmentType.name;
        request.fields['facility_subtype'] = config.facilitySubType;
        request.fields['holiday_usage'] = config.holidayUsageEnabled.toString();
        request.fields['holiday_days'] = config.holidayDays.join(',');
        request.fields['duration_months'] = durationMonths.toString();
        request.fields['has_missing_days'] = hasMissingDays.toString();
        request.fields['data_handling_method'] = dataHandlingMethod;

        // ---- DEBUG: Log everything being sent to the API ----
        debugPrint('================ SUBMIT PREDICTION REQUEST ================');
        debugPrint('URL: $uri');
        request.fields.forEach((key, value) {
          debugPrint('  Field: $key = $value');
        });
        debugPrint('  File attached: ${config.csvFileBytes != null || (config.csvFilePath != null && config.csvFilePath!.isNotEmpty)}');
        debugPrint('  File name: ${config.csvFileName ?? "consumption.csv"}');
        debugPrint('============================================================');

        if (config.manualMeterValues != null && config.manualMeterValues!.isNotEmpty) {
          final List<Map<String, String>> missingValues = config.manualMeterValues!.entries
              .map((e) => {'date': e.key, 'meter_value': e.value})
              .toList();
          request.fields['missing_values'] = jsonEncode(missingValues);

          debugPrint('  Missing Values (${missingValues.length} entries):');
          for (final mv in missingValues) {
            debugPrint('    date: ${mv['date']}, meter_value: ${mv['meter_value']}');
          }
        } else {
          debugPrint('  Missing Values: none');
        }

        if (config.csvFileBytes != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'file', 
              config.csvFileBytes as Uint8List, 
              filename: config.csvFileName ?? 'consumption.csv'
            ),
          );
        } else if (config.csvFilePath != null && config.csvFilePath!.isNotEmpty && !kIsWeb) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'file',
              config.csvFilePath!,
              filename: config.csvFileName ?? 'consumption.csv',
            ),
          );
        } else {
          throw Exception('CSV file is missing. Please go back and upload it again.');
        }

        final streamedResponse = await request.send().timeout(
          const Duration(seconds: 15),
        );
        final response = await http.Response.fromStream(streamedResponse);

        // ---- DEBUG: Log the full API response ----
        debugPrint('================ SUBMIT PREDICTION RESPONSE ================');
        debugPrint('Status Code: ${response.statusCode}');
        debugPrint('Response Body: ${response.body}');
        debugPrint('=============================================================');

        if (response.statusCode == 200) {
          return jsonDecode(response.body) as Map<String, dynamic>;
        } else {
          String detail = 'API error (${response.statusCode})';
          try {
            final decoded = jsonDecode(response.body);
            if (decoded is Map && decoded.containsKey('detail')) {
              detail = decoded['detail'].toString();
            } else if (decoded is String) {
              detail = decoded;
            }
          } catch (_) {}
          throw Exception(detail);
        }
      } catch (e) {
        lastError = e;
        debugPrint('ApiService submitPrediction connection attempt on $baseUrl failed: $e');
        if (e.toString().contains('CSV file is missing')) {
          rethrow;
        }
      }
    }

    throw Exception(
      'Could not connect to NeuralWatt Main Backend ($lastError). Please run: python neural_watt_main.py',
    );
  }
}
