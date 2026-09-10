import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'analysis_setup_screen.dart';
import 'login_screen.dart';
import 'prediction_screen.dart';
import 'models/setup_config.dart';
import 'utils/theme.dart';
import 'utils/locale_notifier.dart';
import 'data/utility_companies.dart';
import 'widgets/utility_company_picker.dart';

// ─────────────────────────────────────────────────────────────
// Mock data
// ─────────────────────────────────────────────────────────────

final List<Map<String, String>> _mockFacilities = [
  {'name': 'Maadi Residential Block A', 'type': 'House', 'meterId': 'MTR-H-001284'},
  {'name': 'Cairo East Substation', 'type': 'Company', 'meterId': 'MTR-C-005912'},
  {'name': 'Helwan Cement Plant', 'type': 'Factory', 'meterId': 'MTR-F-003471'},
  {'name': 'New Cairo Office Tower', 'type': 'Company', 'meterId': 'MTR-C-007823'},
  {'name': 'Shoubra Water Pump Station', 'type': 'Factory', 'meterId': 'MTR-F-001196'},
  {'name': 'Nasr City Apartment Complex', 'type': 'House', 'meterId': 'MTR-H-004450'},
  {'name': '6th October Industrial Zone', 'type': 'Factory', 'meterId': 'MTR-F-008832'},
  {'name': 'Zamalek District Office', 'type': 'Company', 'meterId': 'MTR-C-002105'},
];

// ─────────────────────────────────────────────────────────────
// Profile Screen
// ─────────────────────────────────────────────────────────────

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _orgName = 'Cairo Electricity Distribution Company';
  String _orgRegion = 'Greater Cairo — Sector 4';
  String _orgSector = 'electricity';
  String _orgId = '';
  String _userName = 'Ahmed Hassan';
  String _userEmail = 'a.hassan@cedco.gov.eg';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Determine language to resolve company name
    final isAr = context.locale.languageCode == 'ar';
    
    setState(() {
      _orgSector = prefs.getString('org_sector') ?? _orgSector;
      _orgId = prefs.getString('org_id') ?? _orgId;
      _orgRegion = prefs.getString('org_region') ?? _orgRegion;
      _userName = prefs.getString('user_name') ?? _userName;
      _userEmail = prefs.getString('user_email') ?? _userEmail;
      
      // Resolve name from ID if possible
      if (_orgId.isNotEmpty) {
        final companies = getCompaniesForSector(_orgSector);
        try {
          final comp = companies.firstWhere((c) => c.id == _orgId);
          _orgName = isAr ? comp.nameAr : comp.nameEn;
        } catch (_) {
          _orgName = prefs.getString('org_name') ?? _orgName;
        }
      } else {
        _orgName = prefs.getString('org_name') ?? _orgName;
      }
    });
  }

  // API integration toggles
  bool _smartMeterSync = true;
  bool _govBillingSystem = false;
  bool _scadaIntegration = true;

  // Language
  String get _selectedLanguage => context.locale.languageCode == 'ar' ? 'العربية' : 'English';

  // Facility search
  String _facilityQuery = '';

  List<Map<String, String>> get _filteredFacilities {
    if (_facilityQuery.isEmpty) return _mockFacilities;
    final q = _facilityQuery.toLowerCase();
    return _mockFacilities
        .where((f) =>
            (f['name'] ?? '').toLowerCase().contains(q) ||
            (f['type'] ?? '').toLowerCase().contains(q) ||
            (f['meterId'] ?? '').toLowerCase().contains(q))
        .toList();
  }

  // ───────────────────────────────────────────────────────────
  // Build
  // ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'profileTitle'.tr(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'profileSubtitle'.tr(),
            style: TextStyle(fontSize: 14, color: colors.textSecondary),
          ),
          const SizedBox(height: 24),

          // 1. Organization Info
          _buildOrganizationCard(colors),
          const SizedBox(height: 16),

          // 2. Account & Role
          _buildAccountCard(colors),
          const SizedBox(height: 16),

          // 3. Managed Facilities
          _buildFacilitiesSection(colors),
          const SizedBox(height: 16),

          // 4. API Integrations
          _buildIntegrationsCard(colors),
          const SizedBox(height: 16),

          // 5. App Settings
          _buildSettingsCard(colors),

          const SizedBox(height: 80), // Bottom nav padding
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 1. Organization Info
  // ═══════════════════════════════════════════════════════════

  Widget _buildOrganizationCard(AppColors colors) {
    return _Card(
      colors: colors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.accentContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.business_rounded, color: colors.accentBlue, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'orgInfo'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Edit organization',
                onPressed: () => _showEditOrgSheet(colors),
                icon: Icon(Icons.edit_outlined, size: 20, color: colors.iconColor),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _InfoRow(
            icon: Icons.domain_rounded,
            label: 'companyName'.tr(),
            value: _orgName,
            colors: colors,
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.map_outlined,
            label: 'managedRegion'.tr(),
            value: _orgRegion,
            colors: colors,
          ),
        ],
      ),
    );
  }

  void _showEditOrgSheet(AppColors colors) {
    final regionCtrl = TextEditingController(text: _orgRegion);
    String sheetSector = _orgSector;
    UtilityCompany? sheetCompany;
    
    if (_orgId.isNotEmpty) {
      try {
        sheetCompany = getCompaniesForSector(sheetSector).firstWhere((c) => c.id == _orgId);
      } catch (_) {}
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setSheetState) {
            return Padding(
              padding: EdgeInsetsDirectional.only(
                start: 24,
                end: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.iconColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'editOrg'.tr(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  Text(
                    'selectResource'.tr(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: colors.inputFill,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.inputBorder),
                    ),
                    child: Row(
                      children: [
                        _buildSheetSectorSegment('electricity', 'electricity'.tr(), Icons.bolt, colors, sheetSector, (s) {
                          setSheetState(() {
                            sheetSector = s;
                            sheetCompany = null;
                          });
                        }),
                        _buildSheetSectorSegment('water', 'water'.tr(), Icons.water_drop, colors, sheetSector, (s) {
                          setSheetState(() {
                            sheetSector = s;
                            sheetCompany = null;
                          });
                        }),
                        _buildSheetSectorSegment('gas', 'gas'.tr(), Icons.local_fire_department, colors, sheetSector, (s) {
                          setSheetState(() {
                            sheetSector = s;
                            sheetCompany = null;
                          });
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  UtilityCompanyPicker(
                    label: 'companyName'.tr(),
                    selectedCompany: sheetCompany,
                    currentSector: sheetSector,
                    onCompanySelected: (company) {
                      setSheetState(() {
                        sheetCompany = company;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _sheetField('managedRegion'.tr(), regionCtrl, colors),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      if (sheetCompany == null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('fillAllFields'.tr())));
                        return;
                      }
                      
                      final newOrgRegion = regionCtrl.text.trim().isEmpty ? _orgRegion : regionCtrl.text.trim();
                      final isAr = context.locale.languageCode == 'ar';
                      final newOrgName = isAr ? sheetCompany!.nameAr : sheetCompany!.nameEn;
                      
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('org_sector', sheetSector);
                      await prefs.setString('org_id', sheetCompany!.id);
                      await prefs.setString('org_name', newOrgName);
                      await prefs.setString('org_region', newOrgRegion);
                      
                      setState(() {
                        _orgSector = sheetSector;
                        _orgId = sheetCompany!.id;
                        _orgName = newOrgName;
                        _orgRegion = newOrgRegion;
                      });
                      if (context.mounted) Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.isDark ? colors.accentBlue : const Color(0xFF0D1B3E),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('saveChanges'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _sheetField(String label, TextEditingController ctrl, AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          style: TextStyle(color: colors.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: colors.inputFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.accentBlue, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSheetSectorSegment(
    String sectorId,
    String title,
    IconData icon,
    AppColors colors,
    String currentSector,
    ValueChanged<String> onSelected,
  ) {
    final isSelected = currentSector == sectorId;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelected(sectorId),
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

  // ═══════════════════════════════════════════════════════════
  // 2. Account & Role
  // ═══════════════════════════════════════════════════════════

  Widget _buildAccountCard(AppColors colors) {
    return _Card(
      colors: colors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.accentContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.person_rounded, color: colors.accentBlue, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'accountRole'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: colors.accentContainer,
                child: Text(
                  _userName.isNotEmpty ? _userName.substring(0, 2).toUpperCase() : 'AH',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: colors.accentBlue,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _userEmail,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.accentContainer,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.accentBlue.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'roleValue'.tr(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: colors.accentBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _showLogoutDialog(colors);
              },
              icon: Icon(Icons.logout_rounded, size: 18, color: Colors.redAccent.shade200),
              label: Text(
                'logout'.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.redAccent.shade200,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: Colors.redAccent.shade200.withValues(alpha: 0.4)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(AppColors colors) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: colors.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'logoutTitle'.tr(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          content: Text(
            'logoutConfirm'.tr(),
            style: TextStyle(
              color: colors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(
                foregroundColor: colors.textSecondary,
              ),
              child: Text('cancel'.tr(), style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('is_logged_in', false);
                PredictionScreen.clearCache();
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('loggedOutSuccess'.tr())),
                  );
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.shade200,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('logoutTitle'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 3. Managed Facilities
  // ═══════════════════════════════════════════════════════════

  Widget _buildFacilitiesSection(AppColors colors) {
    final filtered = _filteredFacilities;

    return _Card(
      colors: colors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.accentContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.location_city_rounded, color: colors.accentBlue, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'managedFacilities'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              Text(
                '${_mockFacilities.length} ${'total'.tr()}',
                style: TextStyle(fontSize: 12, color: colors.textSecondary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search
          TextField(
            onChanged: (val) => setState(() => _facilityQuery = val),
            style: TextStyle(color: colors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'searchHint'.tr(),
              hintStyle: TextStyle(color: colors.textSecondary.withValues(alpha: 0.6), fontSize: 13),
              prefixIcon: Icon(Icons.search_rounded, size: 20, color: colors.iconColor),
              filled: true,
              fillColor: colors.inputFill,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.inputBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.inputBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.accentBlue, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // List
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'noResults'.tr(),
                  style: TextStyle(color: colors.textSecondary),
                ),
              ),
            )
          else
            ...filtered.map((f) => _buildFacilityTile(f, colors)),

          const SizedBox(height: 12),

          // Add Facility button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AnalysisSetupScreen(config: SetupConfig()),
                  ),
                );
              },
              icon: Icon(Icons.add_rounded, size: 20, color: colors.accentBlue),
              label: Text(
                'addFacility'.tr(),
                style: TextStyle(fontWeight: FontWeight.w600, color: colors.accentBlue),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: colors.accentBlue.withValues(alpha: 0.4)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityTile(Map<String, String> facility, AppColors colors) {
    final type = facility['type'] ?? 'House';
    final IconData icon;
    final Color iconColor;

    switch (type) {
      case 'Factory':
        icon = Icons.factory_rounded;
        iconColor = Colors.orange;
      case 'Company':
        icon = Icons.business_rounded;
        iconColor = Colors.indigo;
      default:
        icon = Icons.home_rounded;
        iconColor = Colors.teal;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showFacilityDetail(facility, colors),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: colors.scaffoldBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.cardBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: colors.isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        facility['name'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${facility['meterId']}  •  $type',
                        style: TextStyle(fontSize: 12, color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, size: 20, color: colors.iconColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFacilityDetail(Map<String, String> facility, AppColors colors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final type = facility['type'] ?? 'House';
        final IconData icon;
        final Color iconColor;
        switch (type) {
          case 'Factory':
            icon = Icons.factory_rounded;
            iconColor = Colors.orange;
          case 'Company':
            icon = Icons.business_rounded;
            iconColor = Colors.indigo;
          default:
            icon = Icons.home_rounded;
            iconColor = Colors.teal;
        }

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.iconColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: colors.isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                facility['name'] ?? '',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.accentContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  type,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colors.accentBlue,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _detailRow(Icons.speed_rounded, 'meterId'.tr(), facility['meterId'] ?? '—', colors),
              const SizedBox(height: 12),
              _detailRow(Icons.check_circle_outline, 'status'.tr(), 'active'.tr(), colors),
              const SizedBox(height: 12),
              _detailRow(Icons.calendar_today_rounded, 'connectedSince'.tr(), 'Jan 2024', colors),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String label, String value, AppColors colors) {
    return Row(
      children: [
        Icon(icon, size: 18, color: colors.iconColor),
        const SizedBox(width: 12),
        Text(
          '$label:  ',
          style: TextStyle(fontSize: 14, color: colors.textSecondary),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 4. API Integrations
  // ═══════════════════════════════════════════════════════════

  Widget _buildIntegrationsCard(AppColors colors) {
    return _Card(
      colors: colors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.accentContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.api_rounded, color: colors.accentBlue, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'apiIntegrations'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildToggleTile(
            icon: Icons.speed_rounded,
            title: 'smartMeterSync'.tr(),
            subtitle: 'smartMeterDesc'.tr(),
            value: _smartMeterSync,
            onChanged: (v) => setState(() => _smartMeterSync = v),
            colors: colors,
          ),
          Divider(height: 1, color: colors.cardBorder),
          _buildToggleTile(
            icon: Icons.account_balance_rounded,
            title: 'govBilling'.tr(),
            subtitle: 'govBillingDesc'.tr(),
            value: _govBillingSystem,
            onChanged: (v) => setState(() => _govBillingSystem = v),
            colors: colors,
          ),
          Divider(height: 1, color: colors.cardBorder),
          _buildToggleTile(
            icon: Icons.monitor_heart_rounded,
            title: 'scadaTelemetry'.tr(),
            subtitle: 'scadaDesc'.tr(),
            value: _scadaIntegration,
            onChanged: (v) => setState(() => _scadaIntegration = v),
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required AppColors colors,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colors.iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: colors.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: colors.accentBlue,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 5. App Settings
  // ═══════════════════════════════════════════════════════════

  Widget _buildSettingsCard(AppColors colors) {
    return _Card(
      colors: colors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.accentContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.settings_rounded, color: colors.accentBlue, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'appSettings'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Theme toggle (functional)
          ValueListenableBuilder<ThemeMode>(
            valueListenable: AppThemeNotifier.instance,
            builder: (context, mode, _) {
              final isDark = AppThemeNotifier.instance.isDark(context);
              return _buildToggleTile(
                icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                title: 'darkMode'.tr(),
                subtitle: isDark ? 'darkThemeActive'.tr() : 'lightThemeActive'.tr(),
                value: isDark,
                onChanged: (_) => AppThemeNotifier.instance.toggleTheme(context),
                colors: colors,
              );
            },
          ),

          Divider(height: 1, color: colors.cardBorder),
          const SizedBox(height: 14),

          // Language dropdown
          Row(
            children: [
              Icon(Icons.translate_rounded, size: 20, color: colors.iconColor),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'language'.tr(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'appDisplayLanguage'.tr(),
                      style: TextStyle(fontSize: 12, color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.inputFill,
                  border: Border.all(color: colors.inputBorder),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedLanguage,
                    icon: Icon(Icons.keyboard_arrow_down, size: 18, color: colors.iconColor),
                    style: TextStyle(fontSize: 13, color: colors.textPrimary, fontWeight: FontWeight.w500),
                    dropdownColor: colors.cardBackground,
                    items: [
                      DropdownMenuItem(value: 'English', child: Text('english'.tr())),
                      DropdownMenuItem(value: 'العربية', child: Text('arabic'.tr())),
                    ],
                    onChanged: (val) async {
                      if (val != null) {
                        if (val == 'English') {
                          await AppLocaleNotifier.instance.setLocale(context, const Locale('en'));
                        } else {
                          await AppLocaleNotifier.instance.setLocale(context, const Locale('ar'));
                        }
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Shared widgets
// ─────────────────────────────────────────────────────────────

/// Consistent card wrapper matching the analytics/prediction style.
class _Card extends StatelessWidget {
  final AppColors colors;
  final Widget child;
  const _Card({required this.colors, required this.child});

  @override
  Widget build(BuildContext context) {
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
      child: child,
    );
  }
}

/// Compact label → value row with a leading icon.
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final AppColors colors;
  const _InfoRow({required this.icon, required this.label, required this.value, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: colors.iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: colors.textSecondary,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
