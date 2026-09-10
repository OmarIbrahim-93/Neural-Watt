import 'package:flutter/material.dart';
import 'upload_consumption_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'models/setup_config.dart';
import 'utils/responsive.dart';
import 'utils/theme.dart';
import 'utils/theme_toggle_button.dart';

class HistoricalDataPeriodScreen extends StatefulWidget {
  final SetupConfig config;

  const HistoricalDataPeriodScreen({super.key, required this.config});

  @override
  State<HistoricalDataPeriodScreen> createState() =>
      _HistoricalDataPeriodScreenState();
}

class _HistoricalDataPeriodScreenState
    extends State<HistoricalDataPeriodScreen> {
  int _selectedMonths = 6;

  @override
  Widget build(BuildContext context) {
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
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: const [ThemeToggleButton(), SizedBox(width: 8)],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ResponsiveCenter(
            maxWidth: 680,
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Text(
                  'stepNof6'.tr(args: ['5']).toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colors.textSecondary,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: 5 / 6,
                    backgroundColor: colors.accentContainer,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colors.accentBlue,
                    ),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'historicalDataPeriod'.tr(),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'historicalDataDesc'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),

                // Duration Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                          color: colors.iconColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'durationMonths'.tr(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colors.accentContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'minMaxMonths'.tr(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colors.accentBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Grid of months with container-relative width
                LayoutBuilder(
                  builder: (context, constraints) {
                    final double cardWidth = (constraints.maxWidth - 16) / 2;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: List.generate(8, (index) {
                        int month = index + 5;
                        return _buildMonthCard(
                          month,
                          width: cardWidth,
                          colors: colors,
                        );
                      }),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // AI Recommendation Box
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colors.accentContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colors.accentBlue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.accentBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'aiRecommendation'.tr(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'aiRecDesc'.tr(),
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
                  ),
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UploadConsumptionScreen(
                          durationMonths: _selectedMonths,
                          config: widget.config,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.isDark
                        ? colors.accentBlue
                        : Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          'analyzeQuality'.tr(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthCard(
    int month, {
    required double width,
    required AppColors colors,
  }) {
    bool isSelected = _selectedMonths == month;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMonths = month;
        });
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: width,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? colors.accentBlue : colors.cardBorder,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.isDark
                      ? Colors.black26
                      : Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$month',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? colors.accentBlue : colors.textPrimary,
                  ),
                ),
                Text(
                  'monthsText'.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? colors.accentBlue
                        : colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colors.accentBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
            ),
        ],
      ),
    );
  }
}
