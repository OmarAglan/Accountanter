import 'package:flutter/material.dart';
import 'package:accountanter/l10n/app_localizations.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:accountanter/theme/app_colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.help, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text('Quick help for the beta starter edition.', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 24),
        _buildCard(
          context,
          title: 'Getting Started',
          icon: LucideIcons.rocket,
          children: const [
            _Bullet('Add a client from Clients → Add New Client.'),
            _Bullet('Create an invoice from Invoices → New Invoice.'),
            _Bullet('Track stock in Inventory and record Expenses as they happen.'),
            _Bullet('Record invoice payments in Payments to mark invoices as Paid.'),
          ],
        ),
        const SizedBox(height: 16),
        _buildCard(
          context,
          title: 'Beta Notes',
          icon: LucideIcons.flaskConical,
          children: const [
            _Bullet('All data is stored locally on your device (SQLite).'),
            _Bullet('No cloud sync is included in this beta.'),
            _Bullet('Documents are stored as file paths in a registry (no file picker yet).'),
          ],
        ),
        const SizedBox(height: 16),
        _buildCard(
          context,
          title: 'Keyboard Shortcuts',
          icon: LucideIcons.keyboard,
          children: const [
            _Bullet('Use the top search bar to quickly jump between pages.'),
          ],
        ),
        const SizedBox(height: 16),
        _buildCard(
          context,
          title: 'Support',
          icon: LucideIcons.lifeBuoy,
          children: const [
            _Bullet('If you find a bug, capture steps to reproduce and screenshots.'),
            _Bullet('Share feedback with your beta contact/channel.'),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(LucideIcons.info, size: 18, color: AppColors.accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tip: Use Settings → Demo Mode to seed sample categories for testing.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, {required String title, required IconData icon, required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: AppColors.accent),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6.0),
            child: Icon(Icons.circle, size: 6, color: AppColors.mutedForeground),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
