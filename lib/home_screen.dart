import 'package:flutter/material.dart';
import 'analysis_setup_screen.dart';
import 'models/setup_config.dart';
import 'utils/responsive.dart';
import 'utils/theme.dart';
import 'utils/theme_toggle_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _selectedResource = 'Electricity';

  @override
  Widget build(BuildContext context) {
    final bool isWide = Responsive.isWide(context);
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
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
        child: ResponsiveCenter(
          maxWidth: 1000,
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: _buildBodyContent(isWide, colors),
        ),
      ),
      bottomNavigationBar: Container(
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
                currentIndex: _selectedIndex,
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                type: BottomNavigationBarType.fixed,
                backgroundColor: colors.navBarBackground,
                elevation: 0,
                selectedItemColor: colors.accentBlue,
                unselectedItemColor: colors.textSecondary,
                selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
                items: [
                  BottomNavigationBarItem(
                    icon: _buildNavIcon(Icons.home_filled, 0, colors),
                    label: 'HOME',
                  ),
                  BottomNavigationBarItem(
                    icon: _buildNavIcon(Icons.analytics_outlined, 1, colors),
                    label: 'ANALYTICS',
                  ),
                  BottomNavigationBarItem(
                    icon: _buildNavIcon(Icons.auto_awesome_outlined, 2, colors),
                    label: 'PREDICT',
                  ),
                  BottomNavigationBarItem(
                    icon: _buildNavIcon(Icons.delete_outline, 3, colors),
                    label: 'WASTE',
                  ),
                  BottomNavigationBarItem(
                    icon: _buildNavIcon(Icons.person_outline, 4, colors),
                    label: 'PROFILE',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBodyContent(bool isWide, AppColors colors) {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeResourceSelection(isWide, colors);
      case 1:
        return _buildPlaceholderView('Analytics Overview', 'View real-time telemetry, load curves, and efficiency breakdown.', Icons.analytics_outlined, colors);
      case 2:
        return _buildPlaceholderView('AI Predictive Models', 'Forecast energy demand, peak loads, and cost optimization.', Icons.auto_awesome_outlined, colors);
      case 3:
        return _buildPlaceholderView('Waste & Anomaly Detection', 'Identify phantom loads, standby power waste, and thermal leaks.', Icons.delete_outline, colors);
      case 4:
        return _buildPlaceholderView('Facility Profile & Settings', 'Manage organization parameters, meters, and API integrations.', Icons.person_outline, colors);
      default:
        return _buildHomeResourceSelection(isWide, colors);
    }
  }

  Widget _buildHomeResourceSelection(bool isWide, AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Text(
          'Select Resource',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose ONE resource to analyze.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 40),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildResourceCard(
                          title: 'Electricity',
                          unit: 'KWH',
                          icon: Icons.bolt_rounded,
                          iconColor: Colors.amber,
                          iconBgColor: colors.isDark ? const Color(0x33F59E0B) : const Color(0xFFFFFBEB),
                          colors: colors,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildResourceCard(
                          title: 'Water',
                          unit: 'M³',
                          icon: Icons.water_drop_outlined,
                          iconColor: Colors.blue,
                          iconBgColor: colors.isDark ? const Color(0x333B82F6) : const Color(0xFFEFF6FF),
                          colors: colors,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildResourceCard(
                          title: 'Gas',
                          unit: 'M³',
                          icon: Icons.local_fire_department_outlined,
                          iconColor: Colors.indigo,
                          iconBgColor: colors.isDark ? const Color(0x336366F1) : const Color(0xFFEEF2FF),
                          colors: colors,
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _buildResourceCard(
                        title: 'Electricity',
                        unit: 'KWH',
                        icon: Icons.bolt_rounded,
                        iconColor: Colors.amber,
                        iconBgColor: colors.isDark ? const Color(0x33F59E0B) : const Color(0xFFFFFBEB),
                        colors: colors,
                      ),
                      const SizedBox(height: 16),
                      _buildResourceCard(
                        title: 'Water',
                        unit: 'M³',
                        icon: Icons.water_drop_outlined,
                        iconColor: Colors.blue,
                        iconBgColor: colors.isDark ? const Color(0x333B82F6) : const Color(0xFFEFF6FF),
                        colors: colors,
                      ),
                      const SizedBox(height: 16),
                      _buildResourceCard(
                        title: 'Gas',
                        unit: 'M³',
                        icon: Icons.local_fire_department_outlined,
                        iconColor: Colors.indigo,
                        iconBgColor: colors.isDark ? const Color(0x336366F1) : const Color(0xFFEEF2FF),
                        colors: colors,
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderView(String title, String subtitle, IconData icon, AppColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.accentContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: colors.accentBlue),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index, AppColors colors) {
    bool isSelected = _selectedIndex == index;
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

  Widget _buildResourceCard({
    required String title,
    required String unit,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required AppColors colors,
  }) {
    bool isSelected = _selectedResource == title;

    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedResource = title;
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnalysisSetupScreen(
                config: SetupConfig(resource: title),
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? colors.accentBlue : colors.cardBorder,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colors.accentBlue.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      unit,
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: colors.accentBlue,
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
