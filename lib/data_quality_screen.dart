import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'handle_missing_data_screen.dart';
import 'missing_data_detected_screen.dart';
import 'models/consumption_analysis_result.dart';
import 'models/setup_config.dart';
import 'utils/responsive.dart';
import 'utils/theme.dart';
import 'utils/theme_toggle_button.dart';

class DataQualityScreen extends StatelessWidget {
  final ConsumptionAnalysisResult? analysisResult;
  final SetupConfig? config;

  const DataQualityScreen({super.key, this.analysisResult, this.config});

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
            maxWidth: 960,
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Text(
                  'dataQuality'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'dataQualityDesc'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),

                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: _buildCompletenessCard(colors, result),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 6,
                        child: _buildStatsGrid(colors, result),
                      ),
                    ],
                  )
                else ...[
                  _buildCompletenessCard(colors, result),
                  const SizedBox(height: 16),
                  _buildStatsGrid(colors, result),
                ],

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    final destination = result.completenessPercentage >= 100.0
                        ? HandleMissingDataScreen(analysisResult: result, config: config)
                        : MissingDataDetectedScreen(analysisResult: result, config: config);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => destination,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.isDark ? colors.accentBlue : Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'finalReviewBtn'.tr(),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletenessCard(AppColors colors, ConsumptionAnalysisResult result) {
    final double pct = result.completenessPercentage;
    final double valueProgress = (pct / 100.0).clamp(0.0, 1.0);

    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.cardBorder),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'dataCompleteness'.tr(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: colors.textSecondary,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 130,
                  height: 130,
                  child: CircularProgressIndicator(
                    value: valueProgress,
                    strokeWidth: 12,
                    backgroundColor: colors.accentContainer,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.accentBlue),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${pct.toInt()}%',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      'completeText'.tr(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(AppColors colors, ConsumptionAnalysisResult result) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.calendar_today_outlined,
                label: 'expectedDays'.tr(),
                value: '${result.expectedDaysCount}',
                colors: colors,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                icon: Icons.check_circle,
                label: 'available'.tr(),
                value: '${result.availableDaysCount}',
                borderColor: colors.accentBlue,
                iconColor: colors.accentBlue,
                labelColor: colors.accentBlue,
                colors: colors,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.error_rounded,
                label: 'missing'.tr(),
                value: '${result.missingDaysCount}',
                borderColor: const Color(0xFFDC2626),
                iconColor: const Color(0xFFDC2626),
                labelColor: const Color(0xFFDC2626),
                colors: colors,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                icon: Icons.auto_awesome,
                label: 'estimated'.tr(),
                value: '${result.missingDaysCount}',
                borderColor: colors.isDark ? colors.accentBlue : const Color(0xFF0D1B3E),
                iconColor: colors.isDark ? colors.accentBlue : const Color(0xFF0D1B3E),
                labelColor: colors.isDark ? colors.accentBlue : const Color(0xFF0D1B3E),
                colors: colors,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required AppColors colors,
    Color? borderColor,
    Color? iconColor,
    Color? labelColor,
  }) {
    final effectiveAccentColor = borderColor ?? colors.cardBorder;
    final effectiveIconColor = iconColor ?? colors.iconColor;
    final effectiveLabelColor = labelColor ?? colors.textSecondary;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: colors.isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: IntrinsicHeight(
          child: Row(
            children: [
              if (borderColor != null)
                Container(
                  width: 4,
                  color: effectiveAccentColor,
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(icon, size: 16, color: effectiveIconColor),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: effectiveLabelColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
