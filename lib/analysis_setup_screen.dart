import 'package:flutter/material.dart';
import 'environment_config_screen.dart';
import 'models/setup_config.dart';
import 'utils/responsive.dart';
import 'utils/theme.dart';
import 'utils/theme_toggle_button.dart';

class AnalysisSetupScreen extends StatefulWidget {
  final SetupConfig config;

  const AnalysisSetupScreen({super.key, required this.config});

  @override
  State<AnalysisSetupScreen> createState() => _AnalysisSetupScreenState();
}

class _AnalysisSetupScreenState extends State<AnalysisSetupScreen> {
  String _selectedEnv = 'House';

  @override
  Widget build(BuildContext context) {
    final bool isWide = Responsive.isWide(context);
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
          'NeuralWatt',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: const [ThemeToggleButton(), SizedBox(width: 8)],
      ),
      body: ResponsiveCenter(
        maxWidth: 1000,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              'Step 2 of 6',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: 2 / 6,
                backgroundColor: colors.accentContainer,
                valueColor: AlwaysStoppedAnimation<Color>(colors.accentBlue),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'What do you want to analyze?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Select an environment to begin monitoring energy flows.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: colors.textSecondary),
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
                            child: _buildEnvironmentCard(
                              context,
                              title: 'House',
                              subtitle: 'Analyze household consumption',
                              icon: Icons.home_rounded,
                              type: EnvironmentType.house,
                              colors: colors,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildEnvironmentCard(
                              context,
                              title: 'Company',
                              subtitle: 'Analyze company/building usage',
                              icon: Icons.business_rounded,
                              type: EnvironmentType.company,
                              colors: colors,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _buildEnvironmentCard(
                            context,
                            title: 'House',
                            subtitle: 'Analyze household consumption',
                            icon: Icons.home_rounded,
                            type: EnvironmentType.house,
                            colors: colors,
                          ),
                          const SizedBox(height: 16),
                          _buildEnvironmentCard(
                            context,
                            title: 'Company',
                            subtitle: 'Analyze company/building usage',
                            icon: Icons.business_rounded,
                            type: EnvironmentType.company,
                            colors: colors,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnvironmentCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required EnvironmentType type,
    required AppColors colors,
  }) {
    bool isSelected = _selectedEnv == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedEnv = title;
        });
        widget.config.environmentType = type;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                EnvironmentConfigScreen(type: type, config: widget.config),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colors.accentBlue : colors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.accentContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: isSelected ? colors.accentBlue : colors.iconColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
