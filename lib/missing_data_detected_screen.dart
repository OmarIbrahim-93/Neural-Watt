import 'package:flutter/material.dart';
import 'handle_missing_data_screen.dart';
import 'manual_entry_screen.dart';
import 'models/consumption_analysis_result.dart';
import 'models/setup_config.dart';
import 'utils/responsive.dart';
import 'utils/theme.dart';
import 'utils/theme_toggle_button.dart';

class MissingDataDetectedScreen extends StatelessWidget {
  final ConsumptionAnalysisResult? analysisResult;
  final SetupConfig? config;

  const MissingDataDetectedScreen({super.key, this.analysisResult, this.config});

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 800;
    final colors = AppColors.of(context);
    final result = analysisResult ?? ConsumptionAnalysisResult.fallback(durationMonths: 6);

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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ResponsiveCenter(
            maxWidth: 960,
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: Column(
                          children: [
                            _buildWarningHeader(colors),
                            const SizedBox(height: 32),
                            _buildIdentifiedGapsBox(colors, result),
                          ],
                        ),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Text(
                              'Do you have values for these\ndates?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildSelectionBox(
                              icon: Icons.edit_note,
                              title: 'Yes',
                              subtitle: 'Proceed to manual entry',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ManualEntryScreen(
                                      analysisResult: result,
                                      config: config,
                                    ),
                                  ),
                                );
                              },
                              colors: colors,
                            ),
                            const SizedBox(height: 16),
                            _buildSelectionBox(
                              icon: Icons.close,
                              title: 'No',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HandleMissingDataScreen(
                                      analysisResult: result,
                                      config: config,
                                    ),
                                  ),
                                );
                              },
                              iconColor: Colors.white,
                              iconBgColor: colors.accentBlue,
                              colors: colors,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                else ...[
                  _buildWarningHeader(colors),
                  const SizedBox(height: 32),
                  _buildIdentifiedGapsBox(colors, result),
                  const SizedBox(height: 40),
                  Text(
                    'Do you have values for these\ndates?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSelectionBox(
                    icon: Icons.edit_note,
                    title: 'Yes',
                    subtitle: 'Proceed to manual entry',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManualEntryScreen(
                            analysisResult: result,
                            config: config,
                          ),
                        ),
                      );
                    },
                    colors: colors,
                  ),
                  const SizedBox(height: 16),
                  _buildSelectionBox(
                    icon: Icons.close,
                    title: 'No',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HandleMissingDataScreen(
                            analysisResult: result,
                            config: config,
                          ),
                        ),
                      );
                    },
                    iconColor: Colors.white,
                    iconBgColor: colors.accentBlue,
                    colors: colors,
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWarningHeader(AppColors colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.isDark ? const Color(0x33EF4444) : const Color(0xFFFEE2E8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 32),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Missing Data\nDetected',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "We've identified gaps in your energy consumption dataset. To ensure accurate predictions and analytics, please review the isolated and consecutive missing dates below.",
                style: TextStyle(
                  fontSize: 14,
                  color: colors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIdentifiedGapsBox(AppColors colors, ConsumptionAnalysisResult result) {
    final gaps = result.missingDays;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'IDENTIFIED GAPS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                '${gaps.length} Dates Total',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFDC2626).withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (gaps.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'No missing days detected in period!',
                style: TextStyle(color: colors.textSecondary, fontSize: 14),
              ),
            )
          else
            ...gaps.take(10).map((gap) {
              final String tagText = gap.dayStatus;
              final bool isFull = tagText == 'FULL DAY MISSING';
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _buildGapItem(
                  date: gap.day,
                  tag: isFull ? 'Full Day Missing (${gap.missingHours}h)' : 'Partial (${gap.missingHours}h)',
                  tagColor: isFull ? colors.accentBlue : colors.accentContainer,
                  textColor: isFull ? Colors.white : colors.accentBlue,
                  colors: colors,
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildGapItem({
    required String date,
    required String tag,
    required Color tagColor,
    required Color textColor,
    required AppColors colors,
    bool showLeftBorder = false,
    bool isIndented = false,
  }) {
    return Container(
      margin: EdgeInsets.only(left: isIndented ? 16 : 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: colors.isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(8),
        border: showLeftBorder ? Border(left: BorderSide(color: colors.accentBlue, width: 2)) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 16, color: colors.iconColor),
              const SizedBox(width: 12),
              Text(
                date,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: tagColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              tag,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionBox({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required AppColors colors,
    Color? iconColor,
    Color? iconBgColor,
  }) {
    final effectiveIconColor = iconColor ?? colors.textPrimary;
    final effectiveIconBgColor = iconBgColor ?? colors.accentContainer;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.accentContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.cardBorder),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: effectiveIconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: effectiveIconColor, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
