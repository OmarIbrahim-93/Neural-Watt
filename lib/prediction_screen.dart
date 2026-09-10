import 'dart:ui';
import 'home_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import 'utils/responsive.dart';
import 'utils/theme.dart';
import 'utils/units_localization.dart';
import 'utils/advice_translator.dart';
import 'utils/theme_toggle_button.dart';

class PredictionScreen extends StatefulWidget {
  final int durationMonths;
  final String resourceType;
  final Map<String, dynamic>? predictionData;
  final String? facilityName;
  final String? environmentType;

  static int? lastDurationMonths;
  static String? lastResourceType;
  static Map<String, dynamic>? lastPredictionData;
  static String? lastFacilityName;
  static String? lastEnvironmentType;

  static void clearCache() {
    lastDurationMonths = null;
    lastResourceType = null;
    lastPredictionData = null;
    lastFacilityName = null;
    lastEnvironmentType = null;
  }

  PredictionScreen({
    super.key,
    this.durationMonths = 1,
    this.resourceType = 'Electricity',
    this.predictionData,
    this.facilityName,
    this.environmentType,
  }) {
    if (predictionData != null) {
      lastDurationMonths = durationMonths;
      lastResourceType = resourceType;
      lastPredictionData = predictionData;
      if (facilityName != null) lastFacilityName = facilityName;
      if (environmentType != null) lastEnvironmentType = environmentType;
    }
  }

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  int _selectedTabIndex = 0;
  late List<String> _tabs;

  @override
  void initState() {
    super.initState();

    if (widget.predictionData != null) {
      _tabs = [];
      if (widget.predictionData!['next_day_prediction'] != null)
        _tabs.add('NEXT DAY');
      if (widget.predictionData!['next_week_prediction'] != null)
        _tabs.add('NEXT WEEK');
      if (widget.predictionData!['next_month_prediction'] != null)
        _tabs.add('NEXT MONTH');
      if (widget.predictionData!['next_quarter_prediction'] != null)
        _tabs.add('NEXT QUARTER');

      // Fallback if all are null (should not happen, but safe)
      if (_tabs.isEmpty) {
        _tabs = ['NEXT DAY', 'NEXT WEEK', 'NEXT MONTH'];
      }
    } else {
      _tabs = ['NEXT DAY', 'NEXT WEEK', 'NEXT MONTH'];
      if (widget.durationMonths >= 9) {
        _tabs.add('NEXT QUARTER');
      }
    }
  }

  String _formatPrediction(dynamic value) {
    if (value == null) return '0';
    if (value is num) {
      int wholeDigits = value.truncate().abs().toString().length;
      int allowedDecimals = 8 - wholeDigits;

      String pattern = '#,##0';
      if (allowedDecimals >= 3) {
        pattern += '.###';
      } else if (allowedDecimals == 2) {
        pattern += '.##';
      } else if (allowedDecimals == 1) {
        pattern += '.#';
      }

      return NumberFormat(pattern, 'en_US').format(value);
    }
    return value.toString();
  }

  String _getPredictedConsumption() {
    final data = widget.predictionData;
    if (data != null) {
      switch (_tabs[_selectedTabIndex]) {
        case 'NEXT DAY':
          return _formatPrediction(data['next_day_prediction']);
        case 'NEXT WEEK':
          return _formatPrediction(data['next_week_prediction']);
        case 'NEXT MONTH':
          return _formatPrediction(data['next_month_prediction']);
        case 'NEXT QUARTER':
          return _formatPrediction(
            data['next_quarter_prediction'] ??
                (data['next_month_prediction'] != null
                    ? (data['next_month_prediction'] as num) * 3
                    : null),
          );
      }
    }

    switch (_tabs[_selectedTabIndex]) {
      case 'NEXT DAY':
        return '45';
      case 'NEXT WEEK':
        return '315';
      case 'NEXT MONTH':
        return '1,310';
      case 'NEXT QUARTER':
        return '3,950';
      default:
        return '0';
    }
  }

  String _getWaste() {
    final data = widget.predictionData;
    if (data != null && data['waste'] != null) {
      final wasteData = data['waste'] as Map<String, dynamic>;
      switch (_tabs[_selectedTabIndex]) {
        case 'NEXT DAY':
          return _formatPrediction(wasteData['waste_day']);
        case 'NEXT WEEK':
          return _formatPrediction(wasteData['waste_week']);
        case 'NEXT MONTH':
          return _formatPrediction(wasteData['waste_month']);
        case 'NEXT QUARTER':
          return _formatPrediction(wasteData['waste_quarter']);
      }
    }

    switch (_tabs[_selectedTabIndex]) {
      case 'NEXT DAY':
        return '2';
      case 'NEXT WEEK':
        return '15';
      case 'NEXT MONTH':
        return '85';
      case 'NEXT QUARTER':
        return '250';
      default:
        return '0';
    }
  }

  bool _hasWaste() {
    return _getWaste() != '0';
  }

  double _getCalculatedWasteRatio() {
    final data = widget.predictionData;
    if (data != null && data['waste'] != null) {
      final wasteData = data['waste'] as Map<String, dynamic>;
      double? wasteVal;
      double? predVal;

      switch (_tabs[_selectedTabIndex]) {
        case 'NEXT DAY':
          wasteVal = (wasteData['waste_day'] as num?)?.toDouble();
          predVal = (data['next_day_prediction'] as num?)?.toDouble();
          break;
        case 'NEXT WEEK':
          wasteVal = (wasteData['waste_week'] as num?)?.toDouble();
          predVal = (data['next_week_prediction'] as num?)?.toDouble();
          break;
        case 'NEXT MONTH':
          wasteVal = (wasteData['waste_month'] as num?)?.toDouble();
          predVal = (data['next_month_prediction'] as num?)?.toDouble();
          break;
        case 'NEXT QUARTER':
          wasteVal = (wasteData['waste_quarter'] as num?)?.toDouble();
          predVal = (data['next_quarter_prediction'] as num?)?.toDouble();
          break;
      }

      if (wasteVal != null && predVal != null && predVal > 0) {
        return wasteVal / predVal;
      }
      return 0.0;
    }

    switch (_tabs[_selectedTabIndex]) {
      case 'NEXT DAY':
        return 0.044;
      case 'NEXT WEEK':
        return 0.047;
      case 'NEXT MONTH':
        return 0.065;
      case 'NEXT QUARTER':
        return 0.063;
      default:
        return 0.0;
    }
  }

  String _getWasteRatio() {
    final data = widget.predictionData;
    if (data != null && data['waste'] != null) {
      final ratio = _getCalculatedWasteRatio() * 100;
      return '${ratio.toStringAsFixed(1)}%';
    }

    switch (_tabs[_selectedTabIndex]) {
      case 'NEXT DAY':
        return '4.4%';
      case 'NEXT WEEK':
        return '4.7%';
      case 'NEXT MONTH':
        return '6.5%';
      case 'NEXT QUARTER':
        return '6.3%';
      default:
        return '0%';
    }
  }

  double _getWasteRatioValue() {
    return _getCalculatedWasteRatio().clamp(0.0, 1.0);
  }

  String _getUnit() {
    return UnitsLocalization.getLocalizedUnit(context, widget.resourceType);
  }

  IconData _getResourceIcon() {
    if (widget.resourceType.toLowerCase() == 'water') {
      return Icons.water_drop;
    } else if (widget.resourceType.toLowerCase() == 'gas') {
      return Icons.local_fire_department;
    }
    return Icons.bolt;
  }

  Color _getResourceColor(AppColors colors) {
    if (widget.resourceType.toLowerCase() == 'water') {
      return Colors.blue;
    } else if (widget.resourceType.toLowerCase() == 'gas') {
      return Colors.orange;
    }
    return colors.accentBlue;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isWide = MediaQuery.of(context).size.width >= 800;

    // Derived colors for this specific UI
    final cardBgColor = colors.isDark
        ? const Color(0xFF1E293B).withValues(alpha: 0.5)
        : Colors.white;
    final cardBorderColor = colors.isDark
        ? Colors.white.withValues(alpha: 0.1)
        : colors.cardBorder;

    return Scaffold(
      backgroundColor: colors.isDark
          ? const Color(0xFF0B1120)
          : colors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
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
        actions: const [ThemeToggleButton(), SizedBox(width: 8)],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ResponsiveCenter(
            maxWidth: 800,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                _buildTabs(colors),
                const SizedBox(height: 24),

                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            _buildPredictedConsumptionCard(
                              colors,
                              cardBgColor,
                              cardBorderColor,
                            ),
                            if (_hasWaste()) ...[
                              const SizedBox(height: 16),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  if (constraints.maxWidth < 400) {
                                    return Column(
                                      children: [
                                        SizedBox(
                                          width: double.infinity,
                                          child: _buildEstWasteCard(
                                            colors,
                                            cardBgColor,
                                            cardBorderColor,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          width: double.infinity,
                                          child: _buildWasteRatioCard(
                                            colors,
                                            cardBgColor,
                                            cardBorderColor,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          width: double.infinity,
                                          child: _buildWasteCostCard(
                                            colors,
                                            cardBgColor,
                                            cardBorderColor,
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  return Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildEstWasteCard(
                                              colors,
                                              cardBgColor,
                                              cardBorderColor,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: _buildWasteRatioCard(
                                              colors,
                                              cardBgColor,
                                              cardBorderColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildWasteCostCard(
                                              colors,
                                              cardBgColor,
                                              cardBorderColor,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          const Spacer(),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (_selectedTabIndex != 0) ...[
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 6,
                          child: _buildConsumptionForecastCard(
                            colors,
                            cardBgColor,
                            cardBorderColor,
                          ),
                        ),
                      ],
                    ],
                  )
                else ...[
                  _buildPredictedConsumptionCard(
                    colors,
                    cardBgColor,
                    cardBorderColor,
                  ),
                  if (_hasWaste()) ...[
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 400) {
                          return Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: _buildEstWasteCard(
                                  colors,
                                  cardBgColor,
                                  cardBorderColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: _buildWasteRatioCard(
                                  colors,
                                  cardBgColor,
                                  cardBorderColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: _buildWasteCostCard(
                                  colors,
                                  cardBgColor,
                                  cardBorderColor,
                                ),
                              ),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildEstWasteCard(
                                    colors,
                                    cardBgColor,
                                    cardBorderColor,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildWasteRatioCard(
                                    colors,
                                    cardBgColor,
                                    cardBorderColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildWasteCostCard(
                                    colors,
                                    cardBgColor,
                                    cardBorderColor,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Spacer(),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildConsumptionForecastCard(
                    colors,
                    cardBgColor,
                    cardBorderColor,
                  ),
                  const SizedBox(height: 16),
                  _buildAdviceCard(colors, cardBgColor, cardBorderColor),
                  const SizedBox(height: 32),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(colors),
    );
  }

  Widget _buildTabs(AppColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_tabs.length, (index) {
        final isSelected = _selectedTabIndex == index;
        return GestureDetector(
          onTap: () => setState(() => _selectedTabIndex = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: _tabs.length > 3 ? 12 : 20,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF4F8AFC) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getTabTranslation(_tabs[index]),
              style: TextStyle(
                color: isSelected ? Colors.white : colors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: _tabs.length > 3 ? 10 : 12,
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
      }),
    );
  }

  String _getTabTranslation(String tab) {
    switch (tab) {
      case 'NEXT DAY':
        return 'nextDay'.tr();
      case 'NEXT WEEK':
        return 'nextWeek'.tr();
      case 'NEXT MONTH':
        return 'nextMonth'.tr();
      case 'NEXT QUARTER':
        return 'nextQuarter'.tr();
      default:
        return tab;
    }
  }

  Widget _buildPredictedConsumptionCard(
    AppColors colors,
    Color bg,
    Color border,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.cardGradient == null ? colors.cardBackground : null,
        gradient: colors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getResourceIcon(),
                    size: 16,
                    color: _getResourceColor(colors),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'predictedConsumption'.tr(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: colors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _getPredictedConsumption(),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getUnit(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            right: -10,
            top: -10,
            child: Icon(
              Icons.auto_awesome,
              size: 100,
              color: colors.isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : colors.accentBlue.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstWasteCard(AppColors colors, Color bg, Color border) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.cardGradient == null ? colors.cardBackground : null,
        gradient: colors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 16,
                color: Colors.redAccent,
              ),
              const SizedBox(width: 6),
              Text(
                'estWaste'.tr(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: colors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  _getWaste(),
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                    height: 1.0,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _getUnit(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWasteRatioCard(AppColors colors, Color bg, Color border) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.cardGradient == null ? colors.cardBackground : null,
        gradient: colors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart_outline, size: 16, color: Colors.redAccent),
              const SizedBox(width: 6),
              Text(
                'wasteRatio'.tr(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: colors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '${_getWasteRatio()} ',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFBBF24),
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: colors.isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: _getWasteRatioValue(),
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBBF24),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _calculateWastedMoney() {
    final data = widget.predictionData;
    if (data == null) {
      switch (_tabs[_selectedTabIndex]) {
        case 'NEXT DAY':
          return 3.12;
        case 'NEXT WEEK':
          return 23.25;
        case 'NEXT MONTH':
          return 178.50;
        case 'NEXT QUARTER':
          return 645.00;
        default:
          return 0.0;
      }
    }

    if (data['waste'] == null) return 0.0;

    final wasteData = data['waste'] as Map<String, dynamic>;

    switch (_tabs[_selectedTabIndex]) {
      case 'NEXT DAY':
        return (wasteData['waste_cost_day'] as num?)?.toDouble() ?? 0.0;
      case 'NEXT WEEK':
        return (wasteData['waste_cost_week'] as num?)?.toDouble() ?? 0.0;
      case 'NEXT MONTH':
        return (wasteData['waste_cost_month'] as num?)?.toDouble() ?? 0.0;
      case 'NEXT QUARTER':
        return (wasteData['waste_cost_quarter'] as num?)?.toDouble() ?? 0.0;
      default:
        return 0.0;
    }
  }

  Widget _buildWasteCostCard(AppColors colors, Color bg, Color border) {
    double cost = _calculateWastedMoney();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.cardGradient == null ? colors.cardBackground : null,
        gradient: colors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.attach_money, size: 16, color: Colors.green),
              const SizedBox(width: 6),
              Text(
                'wasteCost'.tr(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: colors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                const Icon(
                  Icons.arrow_downward,
                  color: Colors.redAccent,
                  size: 28,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatPrediction(cost),
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                    height: 1.0,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'le'.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<double> _getHistoryValues() {
    final data = widget.predictionData;
    if (data == null || data['history'] == null) return [30, 45, 35];

    final history = data['history'] as Map<String, dynamic>;
    List<dynamic> rawList = [];
    switch (_tabs[_selectedTabIndex]) {
      case 'NEXT DAY':
        rawList = history['day'] ?? [];
        break;
      case 'NEXT WEEK':
        rawList = history['week'] ?? [];
        break;
      case 'NEXT MONTH':
        rawList = history['month'] ?? [];
        break;
      case 'NEXT QUARTER':
        rawList = history['quarter'] ?? [];
        break;
    }
    return rawList.map((e) => (e as num).toDouble()).toList();
  }

  double _getRawPredictionValue() {
    final data = widget.predictionData;
    if (data != null) {
      switch (_tabs[_selectedTabIndex]) {
        case 'NEXT DAY':
          return (data['next_day_prediction'] as num?)?.toDouble() ?? 50.0;
        case 'NEXT WEEK':
          return (data['next_week_prediction'] as num?)?.toDouble() ?? 50.0;
        case 'NEXT MONTH':
          return (data['next_month_prediction'] as num?)?.toDouble() ?? 50.0;
        case 'NEXT QUARTER':
          final q = data['next_quarter_prediction'] as num?;
          if (q != null) return q.toDouble();
          final m = data['next_month_prediction'] as num?;
          return m != null ? m.toDouble() * 3 : 50.0;
      }
    }
    return 50.0;
  }

  Widget _buildConsumptionForecastCard(
    AppColors colors,
    Color bg,
    Color border,
  ) {
    final isWide = MediaQuery.of(context).size.width >= 800;
    return Container(
      padding: const EdgeInsetsDirectional.only(
        top: 24,
        start: 24,
        end: 24,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: colors.cardGradient == null ? colors.cardBackground : null,
        gradient: colors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'consumptionForecast'.tr(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: colors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildLegendItem(
                'actual'.tr(),
                colors.textSecondary,
                isDashed: false,
              ),
              const SizedBox(width: 16),
              _buildLegendItem(
                'predicted'.tr(),
                colors.accentBlue,
                isDashed: true,
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: isWide ? 260 : 140, // Taller chart for wide screens
            child: CustomPaint(
              painter: ForecastChartPainter(
                lineColor: colors.textSecondary.withValues(alpha: 0.5),
                predictColor: colors.accentBlue,
                gridColor: colors.isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05),
                actualValues: _getHistoryValues(),
                predictedValue: _getRawPredictionValue(),
              ),
              child: Stack(children: [
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, {required bool isDashed}) {
    return Row(
      children: [
        SizedBox(
          width: 16,
          child: isDashed
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(width: 6, height: 2, color: color),
                    Container(width: 6, height: 2, color: color),
                  ],
                )
              : Container(width: 16, height: 2, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color == const Color(0xFF4F8AFC) ? color : Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAdviceCard(AppColors colors, Color bg, Color border) {
    final data = widget.predictionData;
    if (data == null || data['llm_advices'] == null) {
      return const SizedBox.shrink();
    }

    final advices = data['llm_advices'] as Map<String, dynamic>;

    String horizonKey;
    switch (_tabs[_selectedTabIndex]) {
      case 'NEXT DAY':
        horizonKey = 'next_day';
        break;
      case 'NEXT WEEK':
        horizonKey = 'next_week';
        break;
      case 'NEXT MONTH':
        horizonKey = 'next_month';
        break;
      case 'NEXT QUARTER':
        horizonKey = 'next_quarter';
        break;
      default:
        horizonKey = 'next_month';
    }

    final horizonData = advices[horizonKey] as Map<String, dynamic>?;
    final messages = horizonData?['messages'] as List<dynamic>?;

    if (messages == null || messages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            children: [
              Icon(Icons.auto_awesome, size: 18, color: colors.accentBlue),
              const SizedBox(width: 8),
              Text(
                'aiInsights'.tr(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colors.textSecondary,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...messages.map((msg) {
          final type = msg['type'] as String?;
          final rawTitle = msg['title'] as String? ?? 'Advice';
          final rawText = msg['message'] as String? ?? '';

          final title = AdviceTranslator.translateTitle(context, rawTitle);
          final text = AdviceTranslator.translateMessage(context, rawText);

          IconData iconData;
          Color iconColor;

          switch (type) {
            case 'waste_reduction':
              iconData = Icons.delete_sweep_rounded;
              iconColor = colors.warning;
              break;
            case 'category_reduction':
              iconData = Icons.trending_down_rounded;
              iconColor = colors.success;
              break;
            case 'category_maintenance':
              iconData = Icons.verified_rounded;
              iconColor = colors.success;
              break;
            case 'equipment_check':
              iconData = Icons.build_circle_rounded;
              iconColor = colors.danger;
              break;
            case 'general_advice':
            default:
              iconData = Icons.lightbulb_rounded;
              iconColor = colors.info;
              break;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(iconData, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        text,
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
          );
        }).toList(),
      ],
    );
  }

  Widget _buildBottomNav(AppColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.navBarBackground,
        border: Border(top: BorderSide(color: colors.navBarBorder)),
      ),
      child: SafeArea(
        child: Align(
          alignment: Alignment.center,
          heightFactor: 1.0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: BottomNavigationBar(
              currentIndex: 2, // PREDICT is active
              onTap: (index) {
                if (index != 2) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(initialIndex: index),
                    ),
                    (route) => false,
                  );
                }
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: colors.navBarBackground,
              elevation: 0,
              selectedItemColor: colors.accentBlue,
              unselectedItemColor: colors.textSecondary,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 12,
              ),
              items: [
                BottomNavigationBarItem(
                  icon: _buildNavIcon(Icons.home_filled, 0, colors),
                  label: 'navHome'.tr(),
                ),
                BottomNavigationBarItem(
                  icon: _buildNavIcon(Icons.analytics_outlined, 1, colors),
                  label: 'navAnalytics'.tr(),
                ),
                BottomNavigationBarItem(
                  icon: _buildNavIcon(Icons.auto_awesome_outlined, 2, colors),
                  label: 'navPredict'.tr(),
                ),
                BottomNavigationBarItem(
                  icon: _buildNavIcon(Icons.person_outline, 3, colors),
                  label: 'navProfile'.tr(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index, AppColors colors) {
    bool isSelected = 2 == index;
    if (!isSelected) return Icon(icon);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: colors.accentContainer,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: Icon(icon, color: colors.accentBlue),
    );
  }
}

class ForecastChartPainter extends CustomPainter {
  final Color lineColor;
  final Color predictColor;
  final Color gridColor;
  final List<double> actualValues;
  final double predictedValue;

  ForecastChartPainter({
    required this.lineColor,
    required this.predictColor,
    required this.gridColor,
    required this.actualValues,
    required this.predictedValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    // Draw horizontal dashed grid lines
    final Paint gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    _drawDashedLine(
      canvas,
      Offset(0, height * 0.2),
      Offset(width, height * 0.2),
      gridPaint,
    );
    _drawDashedLine(
      canvas,
      Offset(0, height * 0.5),
      Offset(width, height * 0.5),
      gridPaint,
    );
    _drawDashedLine(
      canvas,
      Offset(0, height * 0.8),
      Offset(width, height * 0.8),
      gridPaint,
    );

    // Combine values to find min and max
    final allValues = [...actualValues, predictedValue];
    if (allValues.isEmpty) return;

    double maxVal = allValues.reduce((a, b) => a > b ? a : b);
    double minVal = allValues.reduce((a, b) => a < b ? a : b);

    // Add some padding to min/max
    if (maxVal == minVal) {
      maxVal = maxVal == 0 ? 1 : maxVal * 1.5;
      minVal = 0;
    } else {
      final padding = (maxVal - minVal) * 0.2;
      maxVal += padding;
      minVal = (minVal - padding).clamp(0.0, double.infinity);
    }

    // Chart bounds
    final double topY = height * 0.1;
    final double bottomY = height * 0.9;
    final double drawHeight = bottomY - topY;

    double normalizeY(double val) {
      return bottomY - ((val - minVal) / (maxVal - minVal)) * drawHeight;
    }

    // Calculate x spacing
    final int totalPoints = actualValues.length + 1; // actuals + 1 predicted
    final double xSpacing = totalPoints > 1 ? width / (totalPoints - 1) : width;

    // Points for actual data
    final List<Offset> actualPoints = [];
    for (int i = 0; i < actualValues.length; i++) {
      actualPoints.add(Offset(i * xSpacing, normalizeY(actualValues[i])));
    }

    // Points for predicted data (connecting last actual to predicted)
    final List<Offset> predictPoints = [];
    if (actualPoints.isNotEmpty) {
      predictPoints.add(actualPoints.last);
      predictPoints.add(
        Offset(actualValues.length * xSpacing, normalizeY(predictedValue)),
      );
    }

    // Draw Actual Line and Fill
    final actualPath = _createSplinePath(actualPoints);
    final actualPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (actualPoints.isNotEmpty) {
      // Draw Gradient Fill
      final fillPath = Path.from(actualPath);
      fillPath.lineTo(actualPoints.last.dx, height);
      fillPath.lineTo(actualPoints.first.dx, height);
      fillPath.close();

      final Rect shaderRect = Rect.fromLTRB(
        actualPoints.first.dx,
        topY,
        actualPoints.last.dx,
        height,
      );

      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.3),
          lineColor.withValues(alpha: 0.0),
        ],
      ).createShader(shaderRect);

      canvas.drawPath(fillPath, Paint()..shader = gradient);

      // Draw Stroke
      canvas.drawPath(actualPath, actualPaint);
    }

    // Draw Predicted Line (Dashed) and Fill
    if (predictPoints.length > 1) {
      final predictPath = _createSplinePath(predictPoints);
      final predictPaint = Paint()
        ..color = predictColor
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      // Draw Gradient Fill
      final predictFillPath = Path.from(predictPath);
      predictFillPath.lineTo(predictPoints.last.dx, height);
      predictFillPath.lineTo(predictPoints.first.dx, height);
      predictFillPath.close();

      final Rect predictRect = Rect.fromLTRB(
        predictPoints.first.dx,
        topY,
        predictPoints.last.dx,
        height,
      );

      final predictGradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          predictColor.withValues(alpha: 0.3),
          predictColor.withValues(alpha: 0.0),
        ],
      ).createShader(predictRect);

      canvas.drawPath(predictFillPath, Paint()..shader = predictGradient);

      // Draw Dashed Stroke
      _drawDashedPath(canvas, predictPath, predictPaint);
    }

    // Draw Actual Dots
    for (int i = 0; i < actualPoints.length; i++) {
      // Glow
      canvas.drawCircle(
        actualPoints[i],
        8,
        Paint()..color = lineColor.withValues(alpha: 0.2),
      );
      // Outer
      canvas.drawCircle(actualPoints[i], 4, Paint()..color = lineColor);
      // Inner
      canvas.drawCircle(actualPoints[i], 2, Paint()..color = Colors.white);
    }

    // Draw Predicted Dots (skip the first point since it's the last actual dot)
    for (int i = 1; i < predictPoints.length; i++) {
      // Glow
      canvas.drawCircle(
        predictPoints[i],
        8,
        Paint()..color = predictColor.withValues(alpha: 0.2),
      );
      // Outer
      canvas.drawCircle(predictPoints[i], 4, Paint()..color = predictColor);
      // Inner
      canvas.drawCircle(predictPoints[i], 2, Paint()..color = Colors.white);
    }
  }

  Path _createSplinePath(List<Offset> points) {
    final path = Path();
    if (points.isEmpty) return path;
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlPointX = p0.dx + (p1.dx - p0.dx) / 2;
      path.cubicTo(controlPointX, p0.dy, controlPointX, p1.dy, p1.dx, p1.dy);
    }
    return path;
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const double dashWidth = 10;
    const double dashSpace = 10;
    double distance = 0;
    final double length = (end - start).distance;
    final Offset direction = (end - start) / length;

    while (distance < length) {
      final double nextDistance = (distance + dashWidth).clamp(0.0, length);
      canvas.drawLine(
        start + direction * distance,
        start + direction * nextDistance,
        paint,
      );
      distance += dashWidth + dashSpace;
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const double dashWidth = 10;
    const double dashSpace = 10;
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
