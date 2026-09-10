import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../data/utility_companies.dart';
import '../utils/theme.dart';

class UtilityCompanyPicker extends StatefulWidget {
  final String label;
  final UtilityCompany? selectedCompany;
  final String currentSector;
  final ValueChanged<UtilityCompany> onCompanySelected;

  const UtilityCompanyPicker({
    super.key,
    required this.label,
    required this.selectedCompany,
    required this.currentSector,
    required this.onCompanySelected,
  });

  @override
  State<UtilityCompanyPicker> createState() => _UtilityCompanyPickerState();
}

class _UtilityCompanyPickerState extends State<UtilityCompanyPicker> {
  void _showPickerSheet(AppColors colors) {
    if (widget.currentSector.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('selectResource'.tr())),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return _CompanySearchSheet(
          sector: widget.currentSector,
          colors: colors,
          onSelected: (company) {
            Navigator.pop(ctx);
            widget.onCompanySelected(company);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isAr = context.locale.languageCode == 'ar';
    
    String displayValue = '';
    if (widget.selectedCompany != null) {
      displayValue = isAr ? widget.selectedCompany!.nameAr : widget.selectedCompany!.nameEn;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _showPickerSheet(colors),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: colors.inputFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.inputBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayValue.isEmpty ? widget.label : displayValue,
                    style: TextStyle(
                      color: displayValue.isEmpty ? colors.textSecondary.withValues(alpha: 0.6) : colors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down_rounded, color: colors.iconColor),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CompanySearchSheet extends StatefulWidget {
  final String sector;
  final AppColors colors;
  final ValueChanged<UtilityCompany> onSelected;

  const _CompanySearchSheet({
    required this.sector,
    required this.colors,
    required this.onSelected,
  });

  @override
  State<_CompanySearchSheet> createState() => _CompanySearchSheetState();
}

class _CompanySearchSheetState extends State<_CompanySearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<UtilityCompany> _allCompanies = [];
  List<UtilityCompany> _filteredCompanies = [];

  @override
  void initState() {
    super.initState();
    _allCompanies = getCompaniesForSector(widget.sector);
    _filteredCompanies = _allCompanies;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCompanies = _allCompanies;
      } else {
        _filteredCompanies = _allCompanies.where((company) {
          return company.nameAr.toLowerCase().contains(query) ||
                 company.nameEn.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.locale.languageCode == 'ar';

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: 24,
        end: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: widget.colors.iconColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              autofocus: true,
              style: TextStyle(color: widget.colors.textPrimary),
              decoration: InputDecoration(
                hintText: 'orgInfo'.tr(), 
                prefixIcon: Icon(Icons.search, color: widget.colors.iconColor),
                filled: true,
                fillColor: widget.colors.inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: widget.colors.inputBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: widget.colors.inputBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: widget.colors.accentBlue, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: _filteredCompanies.length,
                separatorBuilder: (ctx, idx) => Divider(color: widget.colors.cardBorder, height: 1),
                itemBuilder: (ctx, idx) {
                  final company = _filteredCompanies[idx];
                  final displayName = isAr ? company.nameAr : company.nameEn;
                  
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      displayName,
                      style: TextStyle(color: widget.colors.textPrimary, fontSize: 15),
                    ),
                    onTap: () => widget.onSelected(company),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
