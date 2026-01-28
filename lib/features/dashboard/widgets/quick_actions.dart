import 'package:flutter/material.dart';
import 'package:accountanter/l10n/app_localizations.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:accountanter/theme/app_colors.dart';
import 'package:accountanter/features/main/app_shell_scope.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = AppShellScope.of(context);
    return Wrap(
      spacing: 16.0,
      runSpacing: 16.0,
      children: [
        ElevatedButton.icon(
          onPressed: actions.createInvoice,
          icon: const Icon(LucideIcons.fileText, size: 20),
          label: Text(AppLocalizations.of(context)!.newInvoice),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.accentForeground,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          ),
        ),
        OutlinedButton.icon(
          onPressed: actions.addClient,
          icon: const Icon(LucideIcons.userPlus, size: 20),
          label: Text(AppLocalizations.of(context)!.addClient),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          ),
        ),
         OutlinedButton.icon(
          onPressed: actions.addInventoryItem,
          icon: const Icon(LucideIcons.package, size: 20),
          label: Text(AppLocalizations.of(context)!.addInventoryItem),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.accent,
            side: const BorderSide(color: AppColors.accent),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          ),
        ),
      ],
    );
  }
}
