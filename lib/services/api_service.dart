import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/consumption_analysis_result.dart';

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
}
