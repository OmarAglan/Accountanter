import 'package:flutter/material.dart';
import 'package:accountanter/l10n/app_localizations.dart';
import 'package:accountanter/data/database.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final AppDatabase _database = AppDatabase.instance;
  final TextEditingController _symbolController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _symbolController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final symbol = await _database.getSettingString('currency.symbol');
    if (!mounted) return;
    setState(() {
      _symbolController.text = symbol ?? '\$';
      _isLoading = false;
    });
  }

  Future<void> _save() async {
    await _database.setSettingString('currency.symbol', _symbolController.text.trim().isEmpty ? '\$' : _symbolController.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Currency settings saved.')));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.currency, style: Theme.of(context).textTheme.headlineMedium),
                Text('Set your base currency display settings.', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(LucideIcons.save, size: 16),
              label: Text(l10n.save),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Base Currency', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                TextField(
                  controller: _symbolController,
                  decoration: const InputDecoration(
                    labelText: 'Currency Symbol',
                    hintText: r'$, €, £ …',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Multi-currency conversion and exchange rates are planned for later versions.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
