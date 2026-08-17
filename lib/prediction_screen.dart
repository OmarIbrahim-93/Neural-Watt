import 'dart:ui';
import 'package:flutter/material.dart';
import 'utils/responsive.dart';
import 'utils/theme.dart';
import 'utils/theme_toggle_button.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['NEXT DAY', 'NEXT WEEK', 'NEXT MONTH'];

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isWide = MediaQuery.of(context).size.width >= 800;
    
    // Derived colors for this specific UI
    final cardBgColor = colors.isDark ? const Color(0xFF1E293B).withValues(alpha: 0.5) : Colors.white;
    final cardBorderColor = colors.isDark ? Colors.white.withValues(alpha: 0.1) : colors.cardBorder;

    return Scaffold(
      backgroundColor: colors.isDark ? const Color(0xFF0B1120) : colors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'NeuralWatt',
          style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold),
        ),
        actions: const [
          ThemeToggleButton(),
          SizedBox(width: 8),
        ],
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
                            _buildPredictedConsumptionCard(colors, cardBgColor, cardBorderColor),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(child: _buildEstWasteCard(colors, cardBgColor, cardBorderColor)),
                                const SizedBox(width: 16),
                                Expanded(child: _buildWasteRatioCard(colors, cardBgColor, cardBorderColor)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 6,
                        child: _buildConsumptionForecastCard(colors, cardBgColor, cardBorderColor),
                      ),
                    ],
                  )
                else ...[
                  _buildPredictedConsumptionCard(colors, cardBgColor, cardBorderColor),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildEstWasteCard(colors, cardBgColor, cardBorderColor)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildWasteRatioCard(colors, cardBgColor, cardBorderColor)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildConsumptionForecastCard(colors, cardBgColor, cardBorderColor),
                ],
                
                const SizedBox(height: 32),
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF4F8AFC) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _tabs[index],
              style: TextStyle(
                color: isSelected ? Colors.white : colors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPredictedConsumptionCard(AppColors colors, Color bg, Color border) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PREDICTED CONSUMPTION',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '1,310',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'kWh',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF064E3B).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_down, color: Color(0xFF34D399), size: 16),
                    SizedBox(width: 4),
                    Text(
                      '-4.2% vs avg',
                      style: TextStyle(
                        color: Color(0xFF34D399),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            right: -10,
            top: -10,
            child: Icon(
              Icons.auto_awesome,
              size: 100,
              color: colors.isDark ? Colors.white.withValues(alpha: 0.05) : colors.accentBlue.withValues(alpha: 0.1),
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
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.delete_outline, size: 16, color: colors.textSecondary),
              const SizedBox(width: 6),
              Text(
                'EST. WASTE',
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '85',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'kWh',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWasteRatioCard(AppColors colors, Color bg, Color border) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WASTE RATIO',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: colors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '6.5%',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFBBF24),
              height: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: colors.isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: 0.065,
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

  Widget _buildConsumptionForecastCard(AppColors colors, Color bg, Color border) {
    final isWide = MediaQuery.of(context).size.width >= 800;
    return Container(
      padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CONSUMPTION FORECAST',
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
              _buildLegendItem('Actual', colors.textSecondary, isDashed: false),
              const SizedBox(width: 16),
              _buildLegendItem('Predicted', const Color(0xFF4F8AFC), isDashed: true),
            ],
          ),
          const SizedBox(height: 24),
            SizedBox(
              height: isWide ? 260 : 140, // Taller chart for wide screens
              child: CustomPaint(
              painter: ForecastChartPainter(
                lineColor: colors.textSecondary.withValues(alpha: 0.5),
                predictColor: const Color(0xFF4F8AFC),
                gridColor: colors.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.3) : const Color(0xFFDBEAFE),
                        border: Border.all(
                          color: const Color(0xFF4F8AFC).withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.hub, color: Color(0xFF4F8AFC), size: 30),
                      ),
                    ),
                  ),
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

  Widget _buildBottomNav(AppColors colors) {
    return Container(
      padding: const EdgeInsets.only(bottom: 24, top: 12, left: 16, right: 16),
      decoration: BoxDecoration(
        color: colors.isDark ? const Color(0xFF111827) : Colors.white,
        border: Border(top: BorderSide(color: colors.isDark ? Colors.white.withValues(alpha: 0.05) : colors.cardBorder)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_outlined, 'Home', false, colors),
            _buildNavItem(Icons.analytics_outlined, 'Analytics', false, colors),
            _buildPredictNavItem(colors),
            _buildNavItem(Icons.delete_outline, 'Waste', false, colors),
            _buildNavItem(Icons.person_outline, 'Profile', false, colors),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected, AppColors colors) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isSelected ? const Color(0xFF4F8AFC) : colors.textSecondary,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF4F8AFC) : colors.textSecondary,
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildPredictNavItem(AppColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: colors.isDark ? const Color(0xFF334155).withValues(alpha: 0.8) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Predict',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class ForecastChartPainter extends CustomPainter {
  final Color lineColor;
  final Color predictColor;
  final Color gridColor;

  ForecastChartPainter({
    required this.lineColor,
    required this.predictColor,
    required this.gridColor,
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
    
    _drawDashedLine(canvas, Offset(0, height * 0.2), Offset(width, height * 0.2), gridPaint);
    _drawDashedLine(canvas, Offset(0, height * 0.5), Offset(width, height * 0.5), gridPaint);
    _drawDashedLine(canvas, Offset(0, height * 0.8), Offset(width, height * 0.8), gridPaint);

    // Points for actual data (smooth curve)
    final actualPoints = [
      Offset(0, height * 0.7),
      Offset(width * 0.15, height * 0.55),
      Offset(width * 0.3, height * 0.6),
      Offset(width * 0.45, height * 0.3),
      Offset(width * 0.6, height * 0.65), // intersection point
    ];

    // Points for predicted data (dashed smooth curve)
    final predictPoints = [
      Offset(width * 0.6, height * 0.65),
      Offset(width * 0.7, height * 0.5),
      Offset(width * 0.8, height * 0.55),
      Offset(width * 0.9, height * 0.45),
      Offset(width, height * 0.25),
    ];

    // Draw Actual Line
    final actualPath = _createSplinePath(actualPoints);
    final actualPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(actualPath, actualPaint);

    // Draw Actual Dots
    final dotPaint = Paint()..color = lineColor;
    for (int i = 1; i < actualPoints.length - 1; i++) {
      canvas.drawCircle(actualPoints[i], 4, dotPaint);
    }

    // Draw Predicted Line (Dashed)
    final predictPath = _createSplinePath(predictPoints);
    final predictPaint = Paint()
      ..color = predictColor
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    _drawDashedPath(canvas, predictPath, predictPaint);

    // Draw Predicted Dots
    final predictDotPaint = Paint()..color = predictColor;
    for (int i = 0; i < predictPoints.length; i++) {
      canvas.drawCircle(predictPoints[i], 4, predictDotPaint);
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
      path.cubicTo(
        controlPointX, p0.dy,
        controlPointX, p1.dy,
        p1.dx, p1.dy,
      );
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
