import 'package:flutter/material.dart';
import 'environment_config_screen.dart';
import 'models/consumption_analysis_result.dart';
import 'models/setup_config.dart';
import 'prediction_screen.dart';
import 'utils/responsive.dart';
import 'utils/theme.dart';
import 'utils/theme_toggle_button.dart';

import 'services/api_service.dart';

class ReviewConfigurationScreen extends StatefulWidget {
  final ConsumptionAnalysisResult? analysisResult;
  final String dataHandlingMethod;
  final SetupConfig? config;

  const ReviewConfigurationScreen({
    super.key,
    this.analysisResult,
    required this.dataHandlingMethod,
    this.config,
  });

  @override
  State<ReviewConfigurationScreen> createState() =>
      _ReviewConfigurationScreenState();
}

class _ReviewConfigurationScreenState extends State<ReviewConfigurationScreen> {
  bool _isPredicting = false;

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 800;
    final colors = AppColors.of(context);
    final result =
        widget.analysisResult ??
        ConsumptionAnalysisResult.fallback(durationMonths: 6);
    final setup = widget.config ?? SetupConfig();

    final String targetFacility = setup.facilityName.isEmpty
        ? 'ABC Factory'
        : setup.facilityName;
    final String facilityLocation = setup.facilityLocation.isEmpty
        ? 'Industrial Zone, Sector 4'
        : setup.facilityLocation;
    final String resource = setup.resource.isEmpty
        ? 'Electricity'
        : setup.resource;
    final bool holidayUsageEnabled = setup.holidayUsageEnabled;

    final int duration = result.durationMonths;
    final double qualityScore = result.completenessPercentage;

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
        actions: const [ThemeToggleButton(), SizedBox(width: 8)],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ResponsiveCenter(
            maxWidth: 800,
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Text(
                  'Review Configuration',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Verify your prediction parameters before initialization.',
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),

                if (isWide)
                  Row(
                    children: [
                      Expanded(
                        child: _buildTargetFacilityCard(
                          colors,
                          setup,
                          targetFacility,
                          facilityLocation,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: _buildResourceCard(colors, resource)),
                    ],
                  )
                else ...[
                  _buildTargetFacilityCard(
                    colors,
                    setup,
                    targetFacility,
                    facilityLocation,
                  ),
                  const SizedBox(height: 16),
                  _buildResourceCard(colors, resource),
                ],

                const SizedBox(height: 16),

                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _buildForecastHorizonCard(duration, colors),
                            const SizedBox(height: 16),
                            _buildHolidayUsageCard(colors, setup),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDataHandlingCard(
                          widget.dataHandlingMethod,
                          qualityScore,
                          colors,
                        ),
                      ),
                    ],
                  )
                else ...[
                  _buildForecastHorizonCard(duration, colors),
                  const SizedBox(height: 16),
                  _buildDataHandlingCard(
                    widget.dataHandlingMethod,
                    qualityScore,
                    colors,
                  ),
                  const SizedBox(height: 16),
                  _buildHolidayUsageCard(colors, setup),
                ],

                const SizedBox(height: 40),

                ElevatedButton(
                  onPressed: _isPredicting
                      ? null
                      : () async {
                          setState(() {
                            _isPredicting = true;
                          });
                          try {
                            // Call API
                            final backendResult =
                                await ApiService.submitPrediction(
                                  config: setup,
                                  durationMonths: duration,
                                  hasMissingDays: result.missingDaysCount > 0,
                                  dataHandlingMethod: widget.dataHandlingMethod,
                                );

                            if (mounted) {
                              setState(() {
                                _isPredicting = false;
                              });
                              // You could pass backendResult to PredictionScreen if needed
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PredictionScreen(
                                    durationMonths: duration,
                                    resourceType: resource,
                                    predictionData: backendResult,
                                    facilityName: setup.facilityName,
                                    environmentType: setup.environmentType.name,
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              setState(() {
                                _isPredicting = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.isDark
                        ? colors.accentBlue
                        : Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isPredicting
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Sending Data...',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome, size: 20),
                            SizedBox(width: 12),
                            Text(
                              'Predict',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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

  Widget _buildCard({
    required Widget child,
    required AppColors colors,
    Color? backgroundColor,
    Color? borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? colors.cardBorder, width: 1),
      ),
      child: child,
    );
  }

  void _showEditDialog(SetupConfig setup, AppColors colors) {
    TextEditingController nameController = TextEditingController(
      text: setup.facilityName,
    );
    TextEditingController locationController = TextEditingController(
      text: setup.facilityLocation,
    );
    TextEditingController typeController = TextEditingController(
      text: setup.facilitySubType,
    );
    TextEditingController sizeController = TextEditingController(
      text: setup.facilitySize,
    );

    String? factoryType = setup.facilitySubType.isNotEmpty
        ? setup.facilitySubType
        : null;
    String? factorySize = setup.facilitySize.isNotEmpty
        ? setup.facilitySize
        : null;

    final factoryTypeOptions = [
      "Bakery",
      "Office",
      "Hotel",
      "Restaurant",
      "School",
      "SuperMarket",
    ];
    final factorySizeOptions = ["small", "midium", "large"];

    if (setup.environmentType == EnvironmentType.factory ||
        setup.environmentType == EnvironmentType.company) {
      if (!factoryTypeOptions.contains(factoryType))
        factoryType = factoryTypeOptions.first;
      if (!factorySizeOptions.contains(factorySize))
        factorySize = factorySizeOptions.first;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: colors.cardBackground,
              title: Text(
                'Edit Configuration',
                style: TextStyle(color: colors.textPrimary),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      style: TextStyle(color: colors.textPrimary),
                      decoration: InputDecoration(
                        labelText:
                            setup.environmentType == EnvironmentType.house
                            ? 'House Name'
                            : setup.environmentType == EnvironmentType.company
                            ? 'Company Name'
                            : 'Factory Name',
                        labelStyle: TextStyle(color: colors.textSecondary),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colors.cardBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colors.accentBlue),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: locationController,
                      style: TextStyle(color: colors.textPrimary),
                      decoration: InputDecoration(
                        labelText:
                            setup.environmentType == EnvironmentType.house
                            ? 'House Location'
                            : setup.environmentType == EnvironmentType.company
                            ? 'Company Location'
                            : 'Factory Location',
                        labelStyle: TextStyle(color: colors.textSecondary),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colors.cardBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colors.accentBlue),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (setup.environmentType == EnvironmentType.house) ...[
                      TextField(
                        controller: typeController,
                        style: TextStyle(color: colors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Number of Persons',
                          labelStyle: TextStyle(color: colors.textSecondary),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: colors.cardBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: colors.accentBlue),
                          ),
                        ),
                      ),
                    ] else if (setup.environmentType ==
                            EnvironmentType.company ||
                        setup.environmentType == EnvironmentType.factory) ...[
                      DropdownButtonFormField<String>(
                        value: factoryType,
                        dropdownColor: colors.cardBackground,
                        decoration: InputDecoration(
                          labelText:
                              setup.environmentType == EnvironmentType.company
                              ? 'Company Type'
                              : 'Industry Type',
                          labelStyle: TextStyle(color: colors.textSecondary),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: colors.cardBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: colors.accentBlue),
                          ),
                        ),
                        items: factoryTypeOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(color: colors.textPrimary),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setDialogState(() {
                            factoryType = val;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: factorySize,
                        dropdownColor: colors.cardBackground,
                        decoration: InputDecoration(
                          labelText:
                              setup.environmentType == EnvironmentType.company
                              ? 'Company Size'
                              : 'Factory Size',
                          labelStyle: TextStyle(color: colors.textSecondary),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: colors.cardBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: colors.accentBlue),
                          ),
                        ),
                        items: factorySizeOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(color: colors.textPrimary),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setDialogState(() {
                            factorySize = val;
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      setup.facilityName = nameController.text;
                      setup.facilityLocation = locationController.text;

                      if (setup.environmentType == EnvironmentType.house) {
                        setup.facilitySubType = typeController.text;
                      } else if (setup.environmentType ==
                          EnvironmentType.company) {
                        setup.facilitySubType = typeController.text;
                        setup.facilitySize = sizeController.text;
                      } else if (setup.environmentType ==
                          EnvironmentType.factory) {
                        setup.facilitySubType = factoryType ?? '';
                        setup.facilitySize = factorySize ?? '';
                      }
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.accentBlue,
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTargetFacilityCard(
    AppColors colors,
    SetupConfig setup,
    String name,
    String location,
  ) {
    String topLabel = 'TARGET FACILITY';
    if (setup.facilitySubType.isNotEmpty) {
      switch (setup.environmentType) {
        case EnvironmentType.house:
          topLabel = 'NUMBER OF PERSONS: ${setup.facilitySubType}';
          break;
        case EnvironmentType.company:
          topLabel = 'COMPANY TYPE: ${setup.facilitySubType.toUpperCase()}';
          if (setup.facilitySize.isNotEmpty)
            topLabel += ' | SIZE: ${setup.facilitySize.toUpperCase()}';
          break;
        case EnvironmentType.factory:
          topLabel = 'INDUSTRY TYPE: ${setup.facilitySubType.toUpperCase()}';
          if (setup.facilitySize.isNotEmpty)
            topLabel += ' | SIZE: ${setup.facilitySize.toUpperCase()}';
          break;
      }
    }

    return _buildCard(
      colors: colors,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: colors.textSecondary,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: colors.accentBlue,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: colors.accentBlue, size: 20),
            onPressed: () => _showEditDialog(setup, colors),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard(AppColors colors, String resource) {
    IconData icon = Icons.bolt_rounded;
    if (resource.toLowerCase() == 'water') icon = Icons.water_drop_outlined;
    if (resource.toLowerCase() == 'gas')
      icon = Icons.local_fire_department_outlined;

    return _buildCard(
      colors: colors,
      backgroundColor: colors.accentBlue,
      borderColor: colors.accentBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RESOURCE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                resource,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildForecastHorizonCard(int duration, AppColors colors) {
    return _buildCard(
      colors: colors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FORECAST HORIZON',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: colors.textSecondary,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$duration',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Months',
                style: TextStyle(
                  fontSize: 18,
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

  Widget _buildDataHandlingCard(
    String method,
    double qualityScore,
    AppColors colors,
  ) {
    return _buildCard(
      colors: colors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DATA HANDLING',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: colors.textSecondary,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (method == 'Estimate Missing Values') ...[
                Icon(Icons.auto_awesome, color: colors.textPrimary, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                method,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            method == 'Estimate Missing Values'
                ? 'Missing data points will be synthesized using historical patterns.'
                : 'Using actual available data. No synthetic estimation applied.',
            style: TextStyle(
              fontSize: 13,
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Divider(color: colors.cardBorder),
          ),

          Text(
            'DATA QUALITY SCORE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: colors.textSecondary,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                '${qualityScore.toInt()}%',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: qualityScore / 100,
                    backgroundColor: colors.accentContainer,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colors.accentBlue,
                    ),
                    minHeight: 8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            qualityScore >= 90
                ? 'Excellent base for prediction.'
                : 'Moderate base for prediction.',
            style: TextStyle(fontSize: 13, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildHolidayUsageCard(AppColors colors, SetupConfig setup) {
    return _buildCard(
      colors: colors,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_note_outlined,
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
                  'Holiday Usage',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Adjusts baseline for known regional holidays.',
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.textSecondary,
                    height: 1.4,
                  ),
                ),
                if (setup.holidayUsageEnabled &&
                    setup.holidayDays.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Off-days: ${setup.holidayDays.join(', ')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.accentBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: setup.holidayUsageEnabled
                      ? colors.accentBlue
                      : colors.cardBorder,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  setup.holidayUsageEnabled ? 'Enabled' : 'Disabled',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  color: colors.accentBlue,
                  size: 18,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _showHolidayEditDialog(setup, colors),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showHolidayEditDialog(SetupConfig setup, AppColors colors) {
    bool isEnabled = setup.holidayUsageEnabled;
    List<String> selectedDays = List.from(setup.holidayDays);
    final List<String> weekDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: colors.cardBackground,
              title: Text(
                'Edit Holiday Usage',
                style: TextStyle(color: colors.textPrimary),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: isEnabled,
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                isEnabled = val;
                              });
                            }
                          },
                          activeColor: colors.accentBlue,
                        ),
                        Expanded(
                          child: Text(
                            'Enable Holiday Usage',
                            style: TextStyle(color: colors.textPrimary),
                          ),
                        ),
                        Tooltip(
                          message:
                              'Adjusts baseline prediction by considering the selected days as holidays or off-days with lower resource usage.',
                          child: Icon(
                            Icons.help_outline,
                            color: colors.textSecondary,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    if (isEnabled) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Select off-days:',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...weekDays.map((day) {
                        return CheckboxListTile(
                          title: Text(
                            day,
                            style: TextStyle(color: colors.textPrimary),
                          ),
                          value: selectedDays.contains(day),
                          activeColor: colors.accentBlue,
                          onChanged: (bool? value) {
                            setDialogState(() {
                              if (value == true) {
                                selectedDays.add(day);
                              } else {
                                selectedDays.remove(day);
                              }
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        );
                      }).toList(),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      setup.holidayUsageEnabled = isEnabled;
                      setup.holidayDays = selectedDays;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.accentBlue,
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
