import 'package:flutter/material.dart';
import 'package:accountanter/l10n/app_localizations.dart';
import 'package:accountanter/data/database.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:accountanter/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  final ValueChanged<Locale> onLocaleChanged;
  const SettingsScreen({super.key, required this.onLocaleChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AppDatabase _database = AppDatabase.instance;

  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _companyAddressController = TextEditingController();
  final TextEditingController _currencySymbolController = TextEditingController();
  bool _demoMode = false;
  TaxRate? _defaultTaxRate;
  bool _isLoading = true;
  String _localeCode = 'en';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _companyAddressController.dispose();
    _currencySymbolController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final name = await _database.getSettingString('company.name');
    final address = await _database.getSettingString('company.address');
    final symbol = await _database.getSettingString('currency.symbol');
    final demo = await _database.getSettingBool('demo.mode');
    final defaultTax = await _database.getDefaultTaxRate();
    final localeCode = await _database.getSettingString('ui.locale');

    if (!mounted) return;
    setState(() {
      _companyNameController.text = name ?? 'Your Company Name';
      _companyAddressController.text = address ?? '123 Business Street\nBusiness City, BC 12345';
      _currencySymbolController.text = symbol ?? '\$';
      _demoMode = demo ?? false;
      _defaultTaxRate = defaultTax;
      _localeCode = (localeCode == 'ar' || localeCode == 'en') ? (localeCode ?? 'en') : 'en';
      _isLoading = false;
    });
  }

  Future<void> _setLocaleCode(String code) async {
    await _database.setSettingString('ui.locale', code);
    widget.onLocaleChanged(Locale(code));
    if (!mounted) return;
    setState(() => _localeCode = code);
  }

  Future<void> _saveSettings() async {
    await _database.setSettingString('company.name', _companyNameController.text.trim());
    await _database.setSettingString('company.address', _companyAddressController.text.trim());
    await _database.setSettingString('currency.symbol', _currencySymbolController.text.trim().isEmpty ? '\$' : _currencySymbolController.text.trim());
    await _database.setSettingBool('demo.mode', _demoMode);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved.')));
  }

  Future<void> _confirmFactoryReset() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Factory reset?'),
        content: Text(l10n.deleteConfirmation),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancel)),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.destructive),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await _database.factoryReset();
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data cleared'),
        content: const Text('All local data was cleared. Restart the app to re-activate and log in again.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.settings, style: Theme.of(context).textTheme.headlineMedium),
                Text('Configure company defaults and app behavior.', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _saveSettings,
              icon: const Icon(LucideIcons.save, size: 16),
              label: Text(l10n.save),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildCompanyCard(context),
        const SizedBox(height: 24),
        _buildFinanceDefaultsCard(context),
        const SizedBox(height: 24),
        _buildLanguageCard(context),
        const SizedBox(height: 24),
        _buildDataToolsCard(context),
      ],
    );
  }

  Widget _buildCompanyCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Company', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _companyNameController,
              decoration: const InputDecoration(labelText: 'Company Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _companyAddressController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Company Address'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinanceDefaultsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Defaults', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _currencySymbolController,
              decoration: const InputDecoration(labelText: 'Currency Symbol'),
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<TaxRate>>(
              stream: _database.watchAllTaxRates(),
              builder: (context, snapshot) {
                final rates = snapshot.data ?? [];
                final selected = _defaultTaxRate != null
                    ? rates.where((r) => r.id == _defaultTaxRate!.id).firstOrNull
                    : rates.where((r) => r.isDefault).firstOrNull;

                return DropdownButtonFormField<TaxRate>(
                  key: ValueKey(selected?.id),
                  initialValue: selected,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Default Tax Rate'),
                  items: rates.map((r) {
                    return DropdownMenuItem(value: r, child: Text('${r.name} (${r.rate.toStringAsFixed(2)}%)'));
                  }).toList(),
                  onChanged: (value) async {
                    if (value == null) return;
                    await _database.setDefaultTaxRate(value.id);
                    if (!mounted) return;
                    setState(() => _defaultTaxRate = value);
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              value: _demoMode,
              onChanged: (v) => setState(() => _demoMode = v),
              contentPadding: EdgeInsets.zero,
              title: const Text('Demo Mode'),
              subtitle: const Text('Seed sample categories and vendors for demo purposes.'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataToolsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Data Tools', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _confirmFactoryReset,
              icon: const Icon(LucideIcons.trash2, size: 16, color: AppColors.destructive),
              label: const Text('Factory Reset'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.destructive,
                side: const BorderSide(color: AppColors.destructive),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Language', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: ValueKey('language:$_localeCode'),
              initialValue: _localeCode,
              decoration: const InputDecoration(isDense: true),
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'ar', child: Text('العربية')),
              ],
              onChanged: (value) {
                if (value == null) return;
                _setLocaleCode(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
