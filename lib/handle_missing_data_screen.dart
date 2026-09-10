import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'utils/responsive.dart';
import 'utils/theme.dart';
import 'utils/theme_toggle_button.dart';

import 'models/consumption_analysis_result.dart';
import 'models/setup_config.dart';
import 'review_configuration_screen.dart';

class HandleMissingDataScreen extends StatefulWidget {
  final ConsumptionAnalysisResult? analysisResult;
  final SetupConfig? config;

  const HandleMissingDataScreen({super.key, this.analysisResult, this.config});

  @override
  State<HandleMissingDataScreen> createState() => _HandleMissingDataScreenState();
}

class _HandleMissingDataScreenState extends State<HandleMissingDataScreen> {
  int _selectedValue = 1; // 1 for Auto, 2 for Continue Without

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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ResponsiveCenter(
                maxWidth: 880,
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
                          'stepNofM'.tr(args: ['3', '4']).toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colors.accentBlue,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'zeroConsumptionDetected'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'zeroConsumptionDesc'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: colors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 40),

                        if (isWide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildOptionCard(
                                  value: 1,
                                  title: 'estimateMissing'.tr(),
                                  subtitle: 'estimateMissingDesc'.tr(),
                                  showRecommended: true,
                                  colors: colors,
                                  child: _buildAutoIllustration(colors),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: _buildOptionCard(
                                  value: 2,
                                  title: 'keepZeros'.tr(),
                                  subtitle: 'keepZerosDesc'.tr(),
                                  isSimple: true,
                                  colors: colors,
                                ),
                              ),
                            ],
                          )
                        else ...[
                          // Option 1: Auto Estimate
                          _buildOptionCard(
                            value: 1,
                            title: 'estimateMissing'.tr(),
                            subtitle: 'estimateMissingDesc'.tr(),
                            showRecommended: true,
                            colors: colors,
                            child: _buildAutoIllustration(colors),
                          ),
                          const SizedBox(height: 16),

                          // Option 2: Continue Without
                          _buildOptionCard(
                            value: 2,
                            title: 'keepZeros'.tr(),
                            subtitle: 'keepZerosDesc'.tr(),
                            isSimple: true,
                            colors: colors,
                          ),
                        ],
                        
                        const SizedBox(height: 32),
                        const SizedBox(height: 32),
                        
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReviewConfigurationScreen(
                                  analysisResult: widget.analysisResult,
                                  config: widget.config,
                                  dataHandlingMethod: _selectedValue == 1 
                                      ? 'Estimate Missing Values' 
                                      : 'Keep Zeros',
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
                                'finalReviewBtn'.tr(),
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
              );
          },
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required int value,
    required String title,
    required String subtitle,
    required AppColors colors,
    bool showRecommended = false,
    bool isSimple = false,
    Widget? child,
  }) {
    bool isSelected = _selectedValue == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedValue = value),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? colors.accentBlue : colors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? colors.accentBlue : colors.cardBorder,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: colors.accentBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              isSimple ? title.replaceAll('\n', ' ') : title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                          if (showRecommended)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: colors.accentContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'recommended'.tr(),
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: colors.accentBlue,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      if (child != null) ...[
                        const SizedBox(height: 20),
                        child,
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoIllustration(AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              color: colors.cardBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward, size: 16, color: colors.accentBlue),
          const SizedBox(width: 8),
          Container(
            width: 80,
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.cardBorder, colors.accentBlue],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
