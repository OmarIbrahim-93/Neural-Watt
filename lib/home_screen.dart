import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'prediction_screen.dart';
import 'analysis_setup_screen.dart';
import 'analytics_screen.dart';
import 'profile_screen.dart';
import 'models/setup_config.dart';
import 'utils/responsive.dart';
import 'utils/theme.dart';
import 'utils/theme_toggle_button.dart';
import 'utils/units_localization.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  
  const HomeScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedIndex;
  String _selectedResource = 'Electricity';

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

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
          'appTitle'.tr(),
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
                  if (index == 2 && PredictionScreen.lastPredictionData != null) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PredictionScreen(
                          durationMonths: PredictionScreen.lastDurationMonths ?? 1,
                          resourceType: PredictionScreen.lastResourceType ?? 'Electricity',
                          predictionData: PredictionScreen.lastPredictionData,
                          facilityName: PredictionScreen.lastFacilityName,
                          environmentType: PredictionScreen.lastEnvironmentType,
                        ),
                      ),
                      (route) => false,
                    );
                    return;
                  }
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
      ),
    );
  }

  Widget _buildBodyContent(bool isWide, AppColors colors) {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeResourceSelection(isWide, colors);
      case 1:
        return const AnalyticsScreen();
      case 2:
        return _buildPlaceholderView('aiPredictiveModels'.tr(), 'forecastEnergyDemand'.tr(), Icons.auto_awesome_outlined, colors);
      case 3:
        return const ProfileScreen();
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
          'selectResource'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'chooseOneResource'.tr(),
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
                          id: 'Electricity',
                          title: 'electricity'.tr(),
                          unit: UnitsLocalization.getLocalizedUnit(context, 'Electricity'),
                          icon: Icons.bolt_rounded,
                          iconColor: Colors.amber,
                          iconBgColor: colors.isDark ? const Color(0x33F59E0B) : const Color(0xFFFFFBEB),
                          colors: colors,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildResourceCard(
                          id: 'Water',
                          title: 'water'.tr(),
                          unit: UnitsLocalization.getLocalizedUnit(context, 'Water'),
                          icon: Icons.water_drop_outlined,
                          iconColor: Colors.blue,
                          iconBgColor: colors.isDark ? const Color(0x333B82F6) : const Color(0xFFEFF6FF),
                          colors: colors,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildResourceCard(
                          id: 'Gas',
                          title: 'gas'.tr(),
                          unit: UnitsLocalization.getLocalizedUnit(context, 'Gas'),
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
                        id: 'Electricity',
                        title: 'electricity'.tr(),
                        unit: UnitsLocalization.getLocalizedUnit(context, 'Electricity'),
                        icon: Icons.bolt_rounded,
                        iconColor: Colors.amber,
                        iconBgColor: colors.isDark ? const Color(0x33F59E0B) : const Color(0xFFFFFBEB),
                        colors: colors,
                      ),
                      const SizedBox(height: 16),
                      _buildResourceCard(
                        id: 'Water',
                        title: 'water'.tr(),
                        unit: UnitsLocalization.getLocalizedUnit(context, 'Water'),
                        icon: Icons.water_drop_outlined,
                        iconColor: Colors.blue,
                        iconBgColor: colors.isDark ? const Color(0x333B82F6) : const Color(0xFFEFF6FF),
                        colors: colors,
                      ),
                      const SizedBox(height: 16),
                      _buildResourceCard(
                        id: 'Gas',
                        title: 'gas'.tr(),
                        unit: UnitsLocalization.getLocalizedUnit(context, 'Gas'),
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
    required String id,
    required String title,
    required String unit,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required AppColors colors,
  }) {
    bool isSelected = _selectedResource == id;

    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedResource = id;
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnalysisSetupScreen(
                config: SetupConfig(resource: id),
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
