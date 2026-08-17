import 'package:flutter/material.dart';
import 'historical_data_period_screen.dart';
import 'models/setup_config.dart';
import 'utils/responsive.dart';
import 'utils/theme.dart';
import 'utils/theme_toggle_button.dart';

class HolidayScheduleScreen extends StatefulWidget {
  final SetupConfig config;

  const HolidayScheduleScreen({super.key, required this.config});

  @override
  State<HolidayScheduleScreen> createState() => _HolidayScheduleScreenState();
}

class _HolidayScheduleScreenState extends State<HolidayScheduleScreen> {
  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final Set<String> _selectedDays = {'Sat', 'Sun'};
  bool _useElectricityDuringHolidays = true;

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
          'NeuralWatt',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
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
                maxWidth: 680,
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          'Step 4 of 6',
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
                            value: 4 / 6,
                            backgroundColor: colors.accentContainer,
                            valueColor: AlwaysStoppedAnimation<Color>(colors.accentBlue),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Holiday Schedule',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Configure your typical holiday and resource usage patterns for accurate predictions.',
                          style: TextStyle(
                            fontSize: 16,
                            color: colors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          'Select Holiday Days',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Which days of the week are typically considered holidays or non-working days for this facility?',
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _days
                              .map((day) => _buildDayChip(day, colors))
                              .toList(),
                        ),
                        const SizedBox(height: 32),
                        Divider(color: colors.cardBorder),
                        const SizedBox(height: 32),
                        _buildResourceUsageBox(colors),
                        const SizedBox(height: 32),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            widget.config.holidayUsageEnabled = _useElectricityDuringHolidays;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HistoricalDataPeriodScreen(
                                  config: widget.config,
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
                          child: const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDayChip(String day, AppColors colors) {
    bool isSelected = _selectedDays.contains(day);
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedDays.remove(day);
            } else {
              _selectedDays.add(day);
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.accentBlue
                : colors.cardBackground,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isSelected
                  ? colors.accentBlue
                  : colors.cardBorder,
            ),
          ),
          child: Text(
            day,
            style: TextStyle(
              color: isSelected ? Colors.white : colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResourceUsageBox(AppColors colors) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.accentContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.accentBlue.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bolt, color: colors.accentBlue, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Resource Usage',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Do you use this resource during holidays?',
              style: TextStyle(
                fontSize: 16,
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Switch(
                  value: _useElectricityDuringHolidays,
                  onChanged: (value) {
                    setState(() {
                      _useElectricityDuringHolidays = value;
                    });
                  },
                  activeThumbColor: colors.accentBlue,
                  activeTrackColor: colors.accentContainer,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _useElectricityDuringHolidays ? 'Yes' : 'No',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
