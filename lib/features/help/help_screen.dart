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
        Text(l10n.helpQuickHelpSubtitle, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 24),
        _buildCard(
          context,
          title: l10n.helpGettingStartedTitle,
          icon: LucideIcons.rocket,
          children: [
            _Bullet(l10n.helpGettingStartedBulletAddClient),
            _Bullet(l10n.helpGettingStartedBulletCreateInvoice),
            _Bullet(l10n.helpGettingStartedBulletTrackStock),
            _Bullet(l10n.helpGettingStartedBulletRecordPayments),
          ],
        ),
        const SizedBox(height: 16),
        _buildCard(
          context,
          title: l10n.helpBetaNotesTitle,
          icon: LucideIcons.flaskConical,
          children: [
            _Bullet(l10n.helpBetaNotesBulletLocalStorage),
            _Bullet(l10n.helpBetaNotesBulletNoCloudSync),
            _Bullet(l10n.helpBetaNotesBulletDocumentsRegistry),
          ],
        ),
        const SizedBox(height: 16),
        _buildCard(
          context,
          title: l10n.helpKeyboardShortcutsTitle,
          icon: LucideIcons.keyboard,
          children: [
            _Bullet(l10n.helpKeyboardShortcutsBulletSearch),
          ],
        ),
        const SizedBox(height: 16),
        _buildCard(
          context,
          title: l10n.helpSupportTitle,
          icon: LucideIcons.lifeBuoy,
          children: [
            _Bullet(l10n.helpSupportBulletBugReport),
            _Bullet(l10n.helpSupportBulletShareFeedback),
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
                    l10n.helpTipDemoMode,
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
