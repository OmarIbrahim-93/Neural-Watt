import 'package:flutter/foundation.dart';
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'data_quality_screen.dart';
import 'models/consumption_analysis_result.dart';
import 'models/setup_config.dart';
import 'services/api_service.dart';
import 'utils/responsive.dart';
import 'utils/theme.dart';
import 'utils/theme_toggle_button.dart';

class UploadConsumptionScreen extends StatefulWidget {
  final int durationMonths;
  final SetupConfig? config;
  const UploadConsumptionScreen({super.key, this.durationMonths = 6, this.config});

  @override
  State<UploadConsumptionScreen> createState() => _UploadConsumptionScreenState();
}

class _UploadConsumptionScreenState extends State<UploadConsumptionScreen> {
  String? _fileName;
  PlatformFile? _pickedFile;
  Uint8List? _fileBytes;
  bool _isAnalyzing = false;

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        Uint8List? bytes = file.bytes;

        if (bytes == null && file.path != null && !kIsWeb) {
          try {
            bytes = await io.File(file.path!).readAsBytes();
          } catch (e) {
            debugPrint('Could not read file bytes from path: $e');
          }
        }

        setState(() {
          _pickedFile = file;
          _fileName = file.name;
          _fileBytes = bytes;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Selected: $_fileName')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  Future<void> _analyzeAndContinue() async {
    setState(() => _isAnalyzing = true);

    try {
      ConsumptionAnalysisResult result;
      if (_fileName != null) {
        result = await ApiService.analyzeConsumption(
          durationMonths: widget.durationMonths,
          filePath: _pickedFile?.path,
          fileBytes: _fileBytes ?? _pickedFile?.bytes,
          fileName: _fileName ?? 'consumption.csv',
        );
      } else {
        result = ConsumptionAnalysisResult.fallback(
          durationMonths: widget.durationMonths,
        );
      }

      if (mounted) {
        setState(() => _isAnalyzing = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DataQualityScreen(
              analysisResult: result,
              config: widget.config,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notice: $e. Displaying sample data preview.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DataQualityScreen(
              analysisResult: ConsumptionAnalysisResult.fallback(
                durationMonths: widget.durationMonths,
              ),
              config: widget.config,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 800;
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'NeuralWatt',
          style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: const [
          ThemeToggleButton(),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ResponsiveCenter(
                maxWidth: 960,
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight.isFinite
                        ? constraints.maxHeight
                        : 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                        const SizedBox(height: 20),
                        Text(
                          'STEP 6 OF 6',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colors.accentBlue,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: 1.0,
                            backgroundColor: colors.accentContainer,
                            valueColor: AlwaysStoppedAnimation<Color>(colors.accentBlue),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Upload Consumption File',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Import historical energy data to calibrate your predictive models. Ensure your CSV follows the standard NeuralWatt schema.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: colors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 36),

                        if (isWide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 6,
                                child: _buildUploadArea(colors),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 5,
                                child: _buildSchemaRequirementsBox(colors),
                              ),
                            ],
                          )
                        else ...[
                          _buildUploadArea(colors),
                          const SizedBox(height: 24),
                          _buildSchemaRequirementsBox(colors),
                        ],

                        const SizedBox(height: 56),
                        ElevatedButton(
                          onPressed: _isAnalyzing
                              ? null
                              : _analyzeAndContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.isDark ? colors.accentBlue : Colors.black,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isAnalyzing
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Analyzing Telemetry...',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                )
                              : const Text(
                                  'Continue',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              );
          },
        ),
      ),
    );
  }

  Widget _buildUploadArea(AppColors colors) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: _pickFile,
        child: Container(
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: BorderRadius.circular(24),
          ),
          child: CustomPaint(
            painter: DashedRectPainter(color: colors.cardBorder),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isAnalyzing)
                    CircularProgressIndicator(color: colors.accentBlue)
                  else ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colors.accentContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _fileName == null ? Icons.cloud_upload_outlined : Icons.insert_drive_file,
                        size: 40,
                        color: colors.iconColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _fileName ?? 'Drag & Drop CSV',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    if (_fileName == null)
                      Text(
                        'or browse your local files',
                        style: TextStyle(
                          fontSize: 16,
                          color: colors.textSecondary,
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: colors.accentContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'CSV',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: colors.accentBlue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Max 50MB',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _pickFile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.isDark ? colors.accentBlue : Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _fileName == null ? 'Select File' : 'Change File',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSchemaRequirementsBox(AppColors colors) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.accentContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.accentBlue.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Schema Requirements',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildRequirementRow("Must include 'timestamp' column (ISO 8601).", colors),
            const SizedBox(height: 12),
            _buildRequirementRow("Must include 'consumption_kwh' column (Numeric).", colors),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementRow(String text, AppColors colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: colors.iconColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: colors.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;

  DashedRectPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 5, dashSpace = 5;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    Path path = Path();
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(24),
    ));

    for (PathMetric pathMetric in path.computeMetrics()) {
      double distance = 0;
      while (distance < pathMetric.length) {
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
