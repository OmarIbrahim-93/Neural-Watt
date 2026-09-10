import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'login_screen.dart';
import 'utils/responsive.dart';
import 'utils/theme_toggle_button.dart';
import 'utils/theme.dart';
import 'data/utility_companies.dart';
import 'widgets/utility_company_picker.dart';
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String _selectedSector = 'electricity';
  UtilityCompany? _selectedCompany;
  final _regionController = TextEditingController();
  final _emailController = TextEditingController();
  final _empNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;


  Future<void> _signup() async {
    final region = _regionController.text.trim();
    final email = _emailController.text.trim();
    final empName = _empNameController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (_selectedCompany == null || region.isEmpty || email.isEmpty || empName.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('fillAllFields'.tr())));
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('passwordsMismatch'.tr())));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('org_sector', _selectedSector);
    await prefs.setString('org_id', _selectedCompany!.id);
    await prefs.setString('org_name', context.locale.languageCode == 'ar' ? _selectedCompany!.nameAr : _selectedCompany!.nameEn);
    await prefs.setString('org_region', region);
    await prefs.setString('user_email', email);
    await prefs.setString('user_name', empName);
    await prefs.setString('user_password', password);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('orgCreated'.tr()),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _regionController.dispose();
    _emailController.dispose();
    _empNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width >= 900;
    final colors = AppColors.of(context);
    
    final inputBorder = OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: colors.inputBorder),
    );

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      body: SafeArea(
        child: isWideScreen
            ? Row(
                children: [
                  // Left side hero branding for desktop/wide screens
                  Expanded(
                    flex: 5,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF0D1B3E),
                            Color(0xFF1E3A8A),
                            Color(0xFF2563EB),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(48.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.bolt_rounded,
                              size: 40,
                              color: Color(0xFF0D1B3E),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'joinNeuralWatt'.tr(),
                            style: const TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'superchargeFacility'.tr(),
                            style: const TextStyle(
                              fontSize: 20,
                              color: Color(0xFF93C5FD),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 48),
                          _buildHeroFeatureRow(
                            Icons.speed_rounded,
                            'instantTelemetry'.tr(),
                            'uploadCsv'.tr(),
                            colors,
                          ),
                          const SizedBox(height: 24),
                          _buildHeroFeatureRow(
                            Icons.auto_awesome,
                            'automatedGap'.tr(),
                            'aiFillsData'.tr(),
                            colors,
                          ),
                          const SizedBox(height: 24),
                          _buildHeroFeatureRow(
                            Icons.query_stats,
                            'precisionAnalytics'.tr(),
                            'gainInsights'.tr(),
                            colors,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Right side signup form
                  Expanded(
                    flex: 6,
                    child: Center(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(48.0),
                        child: ResponsiveCenter(
                          maxWidth: 460,
                          padding: EdgeInsets.zero,
                          child: _buildSignupForm(isWide: true, colors: colors, inputBorder: inputBorder),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 24.0,
                  ),
                  child: ResponsiveCenter(
                    maxWidth: 480,
                    padding: EdgeInsets.zero,
                    child: _buildSignupForm(isWide: false, colors: colors, inputBorder: inputBorder),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeroFeatureRow(IconData icon, String title, String subtitle, AppColors colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14, color: Color(0xFFBFDBFE)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectorSegment(String sectorId, String title, IconData icon, AppColors colors) {
    final isSelected = _selectedSector == sectorId;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedSector = sectorId;
            _selectedCompany = null; // Reset company when sector changes
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? colors.accentBlue.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? colors.accentBlue : colors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? colors.accentBlue : colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignupForm({required bool isWide, required AppColors colors, required OutlineInputBorder inputBorder}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isWide) ...[
          Align(
            alignment: Alignment.topRight,
            child: const ThemeToggleButton(),
          ),
          const SizedBox(height: 10),
          // Logo
          RepaintBoundary(
            child: Center(
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: colors.isDark ? Colors.black26 : const Color(0x0D000000),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.bolt_rounded,
                    size: 35,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'appTitle'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'createYourAccount'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'joinFuture'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: colors.textSecondary),
          ),
          const SizedBox(height: 32),
        ] else ...[
          Text(
            'createYourAccountTitle'.tr(),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'getStartedToday'.tr(),
            style: TextStyle(fontSize: 15, color: colors.textSecondary),
          ),
          const SizedBox(height: 32),
        ],

        Text(
          'selectResource'.tr(), // Reusing this key or we could add a new one, but let's just use it
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: colors.inputFill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.inputBorder),
          ),
          child: Row(
            children: [
              _buildSectorSegment('electricity', 'electricity'.tr(), Icons.bolt, colors),
              _buildSectorSegment('water', 'water'.tr(), Icons.water_drop, colors),
              _buildSectorSegment('gas', 'gas'.tr(), Icons.local_fire_department, colors),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Organization Name Picker
        UtilityCompanyPicker(
          label: 'orgName'.tr(),
          selectedCompany: _selectedCompany,
          currentSector: _selectedSector,
          onCompanySelected: (company) {
            setState(() {
              _selectedCompany = company;
            });
          },
        ),
        const SizedBox(height: 20),

        // Managed Region/Sector Field
        Text(
          'managedRegion'.tr(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        RepaintBoundary(
          child: TextField(
            controller: _regionController,
            style: TextStyle(color: colors.textPrimary),
            decoration: InputDecoration(
              hintText: 'regionHint'.tr(),
              hintStyle: TextStyle(color: colors.textSecondary.withValues(alpha: 0.7)),
              prefixIcon: Icon(Icons.map_outlined, size: 20, color: colors.iconColor),
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
        ),
        const SizedBox(height: 20),

        // Work Email Field
        Text(
          'orgEmail'.tr(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        RepaintBoundary(
          child: TextField(
            controller: _emailController,
            style: TextStyle(color: colors.textPrimary),
            decoration: InputDecoration(
              hintText: 'emailHint'.tr(),
              hintStyle: TextStyle(color: colors.textSecondary.withValues(alpha: 0.7)),
              prefixIcon: Icon(Icons.email_outlined, size: 20, color: colors.iconColor),
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
        ),
        const SizedBox(height: 20),

        // Employee Full Name Field
        Text(
          'empName'.tr(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        RepaintBoundary(
          child: TextField(
            controller: _empNameController,
            style: TextStyle(color: colors.textPrimary),
            decoration: InputDecoration(
              hintText: 'nameHint'.tr(),
              hintStyle: TextStyle(color: colors.textSecondary.withValues(alpha: 0.7)),
              prefixIcon: Icon(Icons.person_outline, size: 20, color: colors.iconColor),
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
        ),
        const SizedBox(height: 20),

        // Password Field
        Text(
          'password'.tr(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        RepaintBoundary(
          child: TextField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            style: TextStyle(color: colors.textPrimary),
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: TextStyle(color: colors.textSecondary.withValues(alpha: 0.7)),
              prefixIcon: Icon(Icons.lock_outline, size: 20, color: colors.iconColor),
              filled: true,
              fillColor: colors.inputFill,
              border: inputBorder,
              enabledBorder: inputBorder,
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: colors.accentBlue, width: 2),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: colors.iconColor,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Confirm Password Field
        Text(
          'confirmPassword'.tr(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        RepaintBoundary(
          child: TextField(
            controller: _confirmPasswordController,
            obscureText: !_isConfirmPasswordVisible,
            style: TextStyle(color: colors.textPrimary),
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: TextStyle(color: colors.textSecondary.withValues(alpha: 0.7)),
              prefixIcon: Icon(Icons.lock_outline, size: 20, color: colors.iconColor),
              filled: true,
              fillColor: colors.inputFill,
              border: inputBorder,
              enabledBorder: inputBorder,
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: colors.accentBlue, width: 2),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: colors.iconColor,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Sign Up Button
        ElevatedButton(
          onPressed: _signup,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.isDark ? colors.accentBlue : Colors.black,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'signUpBtn'.tr(),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 20),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Divider
        Row(
          children: [
            Expanded(child: Divider(color: colors.cardBorder)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'orSignUpWith'.tr(),
                style: TextStyle(color: colors.textSecondary, fontSize: 14),
              ),
            ),
            Expanded(child: Divider(color: colors.cardBorder)),
          ],
        ),
        const SizedBox(height: 24),

        // Social Buttons
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.g_mobiledata, size: 28, color: Colors.red),
          label: Text(
            'google'.tr(),
            style: TextStyle(color: colors.textPrimary),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.isDark ? colors.cardBackground : const Color(0xFFEEF2FF),
            elevation: 0,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: colors.cardBorder),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () {},
          icon: Icon(Icons.business, size: 20, color: colors.accentBlue),
          label: Text(
            'enterpriseSSO'.tr(),
            style: TextStyle(color: colors.textPrimary),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.isDark ? colors.cardBackground : const Color(0xFFEEF2FF),
            elevation: 0,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: colors.cardBorder),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Log in link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "alreadyHaveAccount".tr(),
              style: TextStyle(color: colors.textSecondary),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: Text(
                'logIn'.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colors.accentText,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
