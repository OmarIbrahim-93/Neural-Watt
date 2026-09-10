import 'package:flutter/material.dart';
import 'prediction_screen.dart';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'utils/responsive.dart';
import 'utils/theme.dart';
import 'utils/units_localization.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late String _resourceType;
  int _selectedPeriodMonths = 12; // Default to 12

  Map<String, dynamic>? _analyticsData;
  List<int> _availablePeriods = [12, 6, 3, 1];

  @override
  void initState() {
    super.initState();

    _resourceType = PredictionScreen.lastResourceType ?? 'Electricity';
    _resourceType = _resourceType.isNotEmpty
        ? '${_resourceType[0].toUpperCase()}${_resourceType.substring(1)}'
        : 'Electricity';

    final predictionData = PredictionScreen.lastPredictionData ?? {};
    if (predictionData.containsKey('analytics') &&
        predictionData['analytics'] != null) {
      _analyticsData = Map<String, dynamic>.from(predictionData['analytics']);
    } else {
      _analyticsData = null;
    }
  }

  String _buildTargetName(BuildContext context) {
    final facilityName = PredictionScreen.lastFacilityName ?? 'ABC Factory';
    final envTypeStr = PredictionScreen.lastEnvironmentType ?? 'factory';

    // Use the translation key (e.g. 'house'.tr() → 'منزل' in Arabic, 'House' in English)
    final envTypeLabel = envTypeStr.isNotEmpty
        ? envTypeStr.tr()
        : 'Factory'.tr();

    final isAr = context.locale.languageCode == 'ar';
    if (isAr) {
      // Arabic: type before name → "منزل اسم المنزل"
      return '$envTypeLabel $facilityName';
    } else {
      // English: name before type → "My Home House"
      return '$facilityName $envTypeLabel';
    }
  }

  // Method to get data for current period
  Map<String, dynamic> _getCurrentPeriodData() {
    if (_analyticsData == null) return {};

    final key = 'last_${_selectedPeriodMonths}_months';
    if (_analyticsData!.containsKey(key)) {
      return Map<String, dynamic>.from(_analyticsData![key]);
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final periodData = _getCurrentPeriodData();

    final totalConsumption = periodData['total_consumption'] ?? 0.0;
    final avgDaily = periodData['average_daily_consumption'] ?? 0.0;

    final monthlyCosts = periodData['monthly_costs'] != null
        ? Map<String, dynamic>.from(periodData['monthly_costs'])
        : <String, dynamic>{};

    final monthlyConsumptions = periodData['monthly_consumption'] != null
        ? Map<String, dynamic>.from(periodData['monthly_consumption'])
        : <String, dynamic>{};

    final unit = UnitsLocalization.getLocalizedUnit(context, _resourceType);

    IconData resourceIcon = Icons.bolt;
    Color resourceColor = colors.accentBlue;
    if (_resourceType.toLowerCase() == 'water') {
      resourceIcon = Icons.water_drop;
      resourceColor = Colors.blue;
    } else if (_resourceType.toLowerCase() == 'gas') {
      resourceIcon = Icons.local_fire_department;
      resourceColor = Colors.orange;
    }

    final NumberFormat formatter = NumberFormat('#,##0.00', 'en_US');

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'analyticsHistory'.tr(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'analyticsHistoryDesc'.tr(),
            style: TextStyle(fontSize: 14, color: colors.textSecondary),
          ),
          const SizedBox(height: 24),

          // Target and Resource cards
          Row(
            children: [
              Expanded(
                child: _buildTextCard(
                  'target'.tr(),
                  _buildTargetName(context),
                  colors,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextCard(
                  'resource'.tr(),
                  _resourceType.toLowerCase().tr(),
                  colors,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Period Dropdown
          _buildDropdown(
            'period'.tr(),
            'lastNMonths'.tr(args: [_selectedPeriodMonths.toString()]),
            _availablePeriods
                .map((m) => 'lastNMonths'.tr(args: [m.toString()]))
                .toList(),
            (val) {
              if (val != null) {
                final numberString = val.replaceAll(RegExp(r'[^0-9]'), '');
                setState(() {
                  _selectedPeriodMonths = int.tryParse(numberString) ?? 12;
                });
              }
            },
            colors,
          ),

          const SizedBox(height: 24),

          if (_analyticsData == null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'noAnalyticsData'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.textSecondary),
                ),
              ),
            )
          else ...[
            // Total Consumption Card
            _buildStatCard(
              colors: colors,
              icon: resourceIcon,
              iconColor: resourceColor,
              title: 'totalConsumption'.tr(),
              value: formatter.format(totalConsumption),
              unit: unit,
            ),

            if (periodData['waste_amount'] != null &&
                periodData['waste_amount'] > 0) ...[
              const SizedBox(height: 16),
              _buildStatCard(
                colors: colors,
                icon: Icons.warning_amber_rounded,
                iconColor: Colors.redAccent,
                title: 'wasteAmount'.tr(),
                value: formatter.format(periodData['waste_amount']),
                unit: unit,
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                colors: colors,
                icon: Icons.pie_chart_outline,
                iconColor: Colors.redAccent,
                title: 'wastePercentage'.tr(),
                value: '${periodData['waste_percentage']}',
                unit: '%',
              ),
              if (periodData['waste_cost'] != null) ...[
                const SizedBox(height: 16),
                _buildStatCard(
                  colors: colors,
                  icon: Icons.attach_money,
                  iconColor: Colors.green,
                  title: 'wasteCost'.tr(),
                  value: formatter.format(periodData['waste_cost']),
                  unit: 'le'.tr(),
                ),
              ],
            ],

            const SizedBox(height: 16),

            _buildStatCard(
              colors: colors,
              icon: Icons.show_chart,
              iconColor: colors.textSecondary,
              title: 'avgDailyConsumption'.tr(),
              value: formatter.format(avgDaily),
              unit: unit,
            ),

            const SizedBox(height: 24),

            // Consumption Comparison Chart
            _buildChartCard(colors, monthlyConsumptions),

            const SizedBox(height: 24),

            // Detailed Breakdown Table
            _buildDetailedBreakdown(
              colors,
              monthlyConsumptions,
              monthlyCosts,
              unit,
            ),
          ],

          const SizedBox(height: 80), // Padding for bottom nav
        ],
      ),
    );
  }

  Widget _buildTextCard(String label, String value, AppColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        border: Border.all(color: colors.cardBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: colors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String prefix,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
    AppColors colors,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        border: Border.all(color: colors.cardBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: colors.textSecondary,
            size: 20,
          ),
          isExpanded: false,
          style: TextStyle(color: colors.textPrimary, fontSize: 14),
          dropdownColor: colors.cardBackground,
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required AppColors colors,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String unit,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        border: Border.all(color: colors.cardBorder),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: colors.textPrimary,
                    height: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(
    AppColors colors,
    Map<String, dynamic> monthlyConsumptions,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        border: Border.all(color: colors.cardBorder),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'consumptionComparison'.tr(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 24),

          Container(
            decoration: BoxDecoration(
              color: colors.scaffoldBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.cardBorder),
            ),
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 200,
              child: _buildDynamicChart(colors, monthlyConsumptions),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicChart(
    AppColors colors,
    Map<String, dynamic> monthlyConsumptions,
  ) {
    if (monthlyConsumptions.isEmpty) {
      return Center(
        child: Text(
          'noDataAvailable'.tr(),
          style: TextStyle(color: colors.textSecondary),
        ),
      );
    }

    // Convert to sorted lists
    final entries = monthlyConsumptions.entries.toList();
    entries.sort((a, b) => a.key.compareTo(b.key));

    final labels = entries.map<String>((e) {
      final parts = e.key.split('-');
      if (parts.length == 2) {
        final monthInt = int.tryParse(parts[1]) ?? 1;
        final date = DateTime(2000, monthInt);
        return DateFormat('MMM', context.locale.languageCode).format(date);
      }
      return e.key;
    }).toList();

    final rawValues = entries.map((e) => (e.value as num).toDouble()).toList();
    final maxValue = rawValues.isEmpty
        ? 1.0
        : rawValues.reduce((a, b) => a > b ? a : b);

    // Normalize to 0.0 - 1.0
    final values = rawValues
        .map((v) => maxValue > 0 ? v / maxValue : 0.0)
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height =
            constraints.maxHeight - 40; // 20 for labels, 20 for values

        final visibleItems = 6;
        final double itemWidth =
            width /
            (values.length < visibleItems ? values.length : visibleItems);
        final double scrollableWidth = itemWidth * values.length;

        return Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  // Fixed Grid lines
                  CustomPaint(
                    size: Size(width, height),
                    painter: _GridPainter(colors.cardBorder),
                  ),

                  // Scrollable Bars and Labels
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: scrollableWidth,
                      child: Column(
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: List.generate(values.length, (index) {
                                final valFormat = NumberFormat.compact(
                                  locale: 'en_US',
                                ).format(rawValues[index]);
                                return SizedBox(
                                  width: itemWidth,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        valFormat,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: colors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        width: itemWidth * 0.6,
                                        height: height * values[index],
                                        decoration: BoxDecoration(
                                          color: colors.accentBlue,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(4),
                                            topRight: Radius.circular(4),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Labels
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: labels.map((label) {
                              return SizedBox(
                                width: itemWidth,
                                child: Text(
                                  label,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailedBreakdown(
    AppColors colors,
    Map<String, dynamic> monthlyConsumptions,
    Map<String, dynamic> monthlyCosts,
    String unit,
  ) {
    // Convert to sorted list descending (newest first)
    final entries = monthlyConsumptions.entries.toList();
    entries.sort((a, b) => b.key.compareTo(a.key));

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.cardBackground,
        border: Border.all(color: colors.cardBorder),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'detailedCost'.tr(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
          ),
          const Divider(height: 1),

          // Table Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text('month'.tr(), style: _tableHeaderStyle(colors)),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'consumptionUnit'.tr(args: [unit]),
                    textAlign: TextAlign.center,
                    style: _tableHeaderStyle(colors),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'costLe'.tr(),
                    textAlign: TextAlign.end,
                    style: _tableHeaderStyle(colors),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Table Rows
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                  'noDataForPeriod'.tr(),
                  style: TextStyle(color: colors.textSecondary),
                ),
              ),
            )
          else
            ...entries.asMap().entries.map((entry) {
              final index = entry.key;
              final e = entry.value;

              final monthStr = e.key; // '2023-06'
              String displayMonth = monthStr;
              final parts = monthStr.split('-');
              if (parts.length == 2) {
                final monthInt = int.tryParse(parts[1]) ?? 1;
                final date = DateTime(int.tryParse(parts[0]) ?? 2000, monthInt);
                displayMonth = DateFormat(
                  'MMMM\nyyyy',
                  context.locale.languageCode,
                ).format(date);
              }

              final consumption = e.value as num;
              final cost = monthlyCosts[monthStr] as num? ?? 0;

              final formatCons = NumberFormat(
                '#,##0.00',
                'en_US',
              ).format(consumption);
              final formatCost =
                  '${NumberFormat('#,##0.00', 'en_US').format(cost)} ${UnitsLocalization.getLocalizedCurrency(context)}';

              return Column(
                children: [
                  _buildTableRow(displayMonth, formatCons, formatCost, colors),
                  if (index != entries.length - 1) const Divider(height: 1),
                ],
              );
            }),
        ],
      ),
    );
  }

  TextStyle _tableHeaderStyle(AppColors colors) {
    return TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.bold,
      color: colors.textSecondary,
      letterSpacing: 0.5,
    );
  }

  Widget _buildTableRow(
    String month,
    String consumption,
    String cost,
    AppColors colors,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              month,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              consumption,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              cost,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final int lines = 4;
    for (int i = 0; i <= lines; i++) {
      final double y = size.height - (size.height / lines) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
