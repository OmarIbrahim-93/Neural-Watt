import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'holiday_schedule_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'models/setup_config.dart';
import 'utils/responsive.dart';
import 'utils/theme.dart';
import 'utils/units_localization.dart';
import 'utils/theme_toggle_button.dart';

enum EnvironmentType { house, company, factory }

class EnvironmentConfigScreen extends StatefulWidget {
  final EnvironmentType type;
  final SetupConfig config;

  const EnvironmentConfigScreen({
    super.key,
    required this.type,
    required this.config,
  });

  @override
  State<EnvironmentConfigScreen> createState() =>
      _EnvironmentConfigScreenState();
}

class _EnvironmentConfigScreenState extends State<EnvironmentConfigScreen> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _gasPriceController = TextEditingController();
  String? _selectedDropdownValue;
  String? _selectedSizeValue;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _gasPriceController.dispose();
    super.dispose();
  }

  String get _title {
    switch (widget.type) {
      case EnvironmentType.house:
        return 'houseEnvironment'.tr();
      case EnvironmentType.company:
        return 'companyEnvironment'.tr();
      case EnvironmentType.factory:
        return 'factoryEnvironment'.tr();
    }
  }

  String get _description {
    switch (widget.type) {
      case EnvironmentType.house:
        return 'houseEnvDesc'.tr();
      case EnvironmentType.company:
        return 'companyEnvDesc'.tr();
      case EnvironmentType.factory:
        return 'factoryEnvDesc'.tr();
    }
  }

  String get _nameLabel {
    switch (widget.type) {
      case EnvironmentType.house:
        return 'houseName'.tr();
      case EnvironmentType.company:
        return 'companyName'.tr();
      case EnvironmentType.factory:
        return 'factoryName'.tr();
    }
  }

  String get _nameHint {
    switch (widget.type) {
      case EnvironmentType.house:
        return 'houseNameHint'.tr();
      case EnvironmentType.company:
        return 'companyNameHint'.tr();
      case EnvironmentType.factory:
        return 'factoryNameHint'.tr();
    }
  }

  IconData get _nameIcon {
    switch (widget.type) {
      case EnvironmentType.house:
        return Icons.home_outlined;
      case EnvironmentType.company:
        return Icons.business_outlined;
      case EnvironmentType.factory:
        return Icons.factory_outlined;
    }
  }

  String get _dropdownLabel {
    switch (widget.type) {
      case EnvironmentType.house:
        return 'numberOfPersons'.tr();
      case EnvironmentType.company:
        return 'companyType'.tr();
      case EnvironmentType.factory:
        return 'primaryIndustry'.tr();
    }
  }

  String get _dropdownHint {
    switch (widget.type) {
      case EnvironmentType.house:
        return 'selectHouseholdSize'.tr();
      case EnvironmentType.company:
        return 'selectCompanyType'.tr();
      case EnvironmentType.factory:
        return 'selectIndustryType'.tr();
    }
  }

  IconData get _dropdownIcon {
    switch (widget.type) {
      case EnvironmentType.house:
        return Icons.people_outline;
      case EnvironmentType.company:
        return Icons.category_outlined;
      case EnvironmentType.factory:
        return Icons.category_outlined;
    }
  }

  int get _currentStep {
    switch (widget.type) {
      case EnvironmentType.house:
      case EnvironmentType.company:
      case EnvironmentType.factory:
        return 3;
    }
  }

  String get _infoText {
    switch (widget.type) {
      case EnvironmentType.house:
        return 'houseInfoText'.tr();
      case EnvironmentType.company:
        return 'companyInfoText'.tr();
      case EnvironmentType.factory:
        return 'factoryInfoText'.tr();
    }
  }

  List<String> get _dropdownItems {
    switch (widget.type) {
      case EnvironmentType.house:
        return List.generate(10, (index) => (index + 1).toString());
      case EnvironmentType.company:
      case EnvironmentType.factory:
        return [
          'bakery'.tr(),
          'office'.tr(),
          'hotel'.tr(),
          'restaurant'.tr(),
          'school'.tr(),
          'superMarket'.tr(),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ResponsiveCenter(
                maxWidth: 680,
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'stepNof6'.tr(args: [_currentStep.toString()]),
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
                          value: _currentStep / 6,
                          backgroundColor: colors.accentContainer,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colors.accentBlue,
                          ),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        _title,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _description,
                        style: TextStyle(
                          fontSize: 16,
                          color: colors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Form Fields
                      _buildLabel(_nameLabel, colors),
                      const SizedBox(height: 8),
                      _buildTextField(
                        _nameController,
                        _nameHint,
                        _nameIcon,
                        colors,
                      ),
                      const SizedBox(height: 20),

                      _buildLabel('location'.tr(), colors),
                      const SizedBox(height: 8),
                      _buildTextField(
                        _locationController,
                        'locationHint'.tr(),
                        Icons.location_on_outlined,
                        colors,
                      ),
                      const SizedBox(height: 20),

                      _buildLabel(_dropdownLabel, colors),
                      const SizedBox(height: 8),
                      _buildDropdownField(
                        _dropdownHint,
                        _dropdownIcon,
                        _dropdownItems,
                        _selectedDropdownValue,
                        (value) {
                          setState(() {
                            _selectedDropdownValue = value;
                          });
                        },
                        colors,
                      ),

                      if (widget.type == EnvironmentType.company ||
                          widget.type == EnvironmentType.factory) ...[
                        const SizedBox(height: 20),
                        _buildLabel('companySize'.tr(), colors),
                        const SizedBox(height: 8),
                        _buildDropdownField(
                          'selectCompanySize'.tr(),
                          Icons.group_outlined,
                          ['small'.tr(), 'medium'.tr(), 'large'.tr()],
                          _selectedSizeValue,
                          (value) {
                            setState(() {
                              _selectedSizeValue = value;
                            });
                          },
                          colors,
                        ),
                      ],

                      if (widget.type == EnvironmentType.company &&
                          widget.config.resource.toLowerCase() == 'gas') ...[
                        const SizedBox(height: 20),
                        _buildLabel('gasPrice'.tr(), colors),
                        const SizedBox(height: 8),
                        _buildTextField(
                          _gasPriceController,
                          'enterGasPrice'.tr(),
                          Icons.monetization_on_outlined,
                          colors,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.]'),
                            ),
                          ],
                          suffixText: UnitsLocalization.getLocalizedRate(
                            context,
                            'Gas',
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Info Box
                      RepaintBoundary(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colors.accentContainer,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(16),
                            ),
                            border: Border.all(
                              color: colors.accentBlue.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.auto_awesome,
                                    color: colors.accentBlue,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'intelligenceInit'.tr(),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: colors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _infoText,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colors.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          if (_nameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'isMandatory'.tr(args: [_nameLabel]),
                                ),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }

                          if (_locationController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'isMandatory'.tr(args: ['location'.tr()]),
                                ),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }

                          if (_selectedDropdownValue == null ||
                              _selectedDropdownValue!.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'isMandatory'.tr(args: [_dropdownLabel]),
                                ),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }

                          if ((widget.type == EnvironmentType.company ||
                                  widget.type == EnvironmentType.factory) &&
                              (_selectedSizeValue == null ||
                                  _selectedSizeValue!.isEmpty)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('companySizeMandatory'.tr()),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }

                          if (widget.type == EnvironmentType.company &&
                              widget.config.resource.toLowerCase() == 'gas') {
                            if (_gasPriceController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('gasPriceMandatory'.tr()),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              return;
                            }
                          }

                          widget.config.environmentType = widget.type;
                          widget.config.facilityName = _nameController.text;
                          widget.config.facilityLocation =
                              _locationController.text;
                          widget.config.facilitySubType =
                              _selectedDropdownValue ?? '';
                          if (widget.type == EnvironmentType.company ||
                              widget.type == EnvironmentType.factory) {
                            widget.config.facilitySize =
                                _selectedSizeValue ?? '';
                          } else {
                            widget.config.facilitySize = '';
                          }
                          if (widget.type == EnvironmentType.company &&
                              widget.config.resource.toLowerCase() == 'gas') {
                            widget.config.gasPrice = _gasPriceController.text;
                          } else {
                            widget.config.gasPrice = '';
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  HolidayScheduleScreen(config: widget.config),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.isDark
                              ? colors.accentBlue
                              : const Color(0xFF0D1B3E),
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
                                'continueSetup'.tr(),
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

  Widget _buildLabel(String label, AppColors colors) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon,
    AppColors colors, {
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? suffixText,
  }) {
    final inputBorder = OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: colors.inputBorder),
    );

    return RepaintBoundary(
      child: TextField(
        controller: controller,
        style: TextStyle(color: colors.textPrimary),
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: colors.textSecondary.withValues(alpha: 0.7),
          ),
          prefixIcon: Icon(icon, size: 22, color: colors.iconColor),
          suffixText: suffixText,
          suffixStyle: TextStyle(color: colors.textSecondary),
          filled: true,
          fillColor: colors.inputFill,
          border: inputBorder,
          enabledBorder: inputBorder,
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: colors.accentBlue, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String hint,
    IconData icon,
    List<String> items,
    String? value,
    ValueChanged<String?> onChanged,
    AppColors colors,
  ) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: colors.inputFill,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          border: Border.all(color: colors.inputBorder),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            dropdownColor: colors.cardBackground,
            menuMaxHeight: 250,
            value: value,
            hint: Row(
              children: [
                Icon(icon, size: 22, color: colors.iconColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hint,
                    style: TextStyle(color: colors.textSecondary, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            icon: Icon(Icons.keyboard_arrow_down, color: colors.iconColor),
            items: items.map((String val) {
              return DropdownMenuItem<String>(
                value: val,
                child: Text(val, style: TextStyle(color: colors.textPrimary)),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
