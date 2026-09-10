import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'handle_missing_data_screen.dart';
import 'models/consumption_analysis_result.dart';
import 'models/setup_config.dart';
import 'utils/responsive.dart';
import 'utils/theme.dart';
import 'utils/theme_toggle_button.dart';

class ManualEntryScreen extends StatefulWidget {
  final ConsumptionAnalysisResult? analysisResult;
  final SetupConfig? config;

  const ManualEntryScreen({super.key, this.analysisResult, this.config});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    final result = widget.analysisResult ?? ConsumptionAnalysisResult.fallback(durationMonths: 6);
    for (var gap in result.missingDays) {
      _controllers[gap.day] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final result = widget.analysisResult ?? ConsumptionAnalysisResult.fallback(durationMonths: 6);
    final gaps = result.missingDays;

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
          'appTitle'.tr(),
          style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: const [
          ThemeToggleButton(),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ResponsiveCenter(
            maxWidth: 600,
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Text(
                  'manualDataEntry'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'manualDataEntryDesc'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                
                if (gaps.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Text(
                      'noMissingDaysEntry'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.textSecondary, fontSize: 16),
                    ),
                  )
                else
                  ...gaps.map((gap) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colors.cardBorder),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 20, color: colors.accentBlue),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                gap.day,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              child: TextField(
                                controller: _controllers[gap.day],
                                keyboardType: TextInputType.number,
                                style: TextStyle(color: colors.textPrimary),
                                decoration: InputDecoration(
                                  hintText: 'valueHint'.tr(),
                                  hintStyle: TextStyle(color: colors.textSecondary),
                                  filled: true,
                                  fillColor: colors.isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                const SizedBox(height: 32),
                
                ElevatedButton(
                  onPressed: () {
                    if (widget.config != null) {
                      Map<String, String> values = {};
                      _controllers.forEach((date, controller) {
                        if (controller.text.isNotEmpty) {
                          values[date] = controller.text;
                        }
                      });
                      widget.config!.manualMeterValues = values;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HandleMissingDataScreen(
                          analysisResult: widget.analysisResult,
                          config: widget.config,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.isDark ? colors.accentBlue : Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'saveContinueBtn'.tr(),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
