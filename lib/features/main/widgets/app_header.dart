import 'package:flutter/material.dart';
import 'package:accountanter/l10n/app_localizations.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:accountanter/theme/app_colors.dart';
import 'package:accountanter/features/main/app_shell_scope.dart';
import '../app_page.dart';

enum _AccountMenuAction { settings, help, logout }

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final String subtitle;

  const AppHeader({
    super.key,
    required this.userName,
    required this.subtitle,
  });

  String getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    final l10n = AppLocalizations.of(context)!;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 18) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final actions = AppShellScope.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Greeting
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${getGreeting(context)}, $userName',
                style: textTheme.headlineSmall?.copyWith(fontSize: 20),
              ),
              Text(
                subtitle,
                style: textTheme.bodyMedium,
              ),
            ],
          ),

          // Search and Profile
          Row(
            children: [
              // Search Bar
              SizedBox(
                width: 320,
                child: TextField(
                  readOnly: true,
                  onTap: actions.openSearch,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.searchPlaceholder,
                    prefixIcon: const Icon(LucideIcons.search, size: 16),
                    contentPadding: EdgeInsets.zero,
                    fillColor: AppColors.background,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Notifications
              IconButton(
                icon: const Icon(LucideIcons.bell),
                onPressed: actions.openNotifications,
                color: AppColors.mutedForeground,
              ),
              const SizedBox(width: 16),

              // User Avatar
              PopupMenuButton<_AccountMenuAction>(
                tooltip: '',
                onSelected: (value) {
                  switch (value) {
                    case _AccountMenuAction.settings:
                      actions.navigateTo(AppPage.settings);
                      break;
                    case _AccountMenuAction.help:
                      actions.navigateTo(AppPage.help);
                      break;
                    case _AccountMenuAction.logout:
                      actions.logout();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _AccountMenuAction.settings,
                    child: Text(l10n.settings),
                  ),
                  PopupMenuItem(
                    value: _AccountMenuAction.help,
                    child: Text(l10n.help),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: _AccountMenuAction.logout,
                    child: Text(l10n.logout),
                  ),
                ],
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
                        style: const TextStyle(color: AppColors.primaryForeground),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userName, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
                        Text(l10n.owner, style: textTheme.bodyMedium),
                      ],
                    ),
                    const SizedBox(width: 8),
                    const Icon(LucideIcons.chevronDown, size: 16, color: AppColors.mutedForeground),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(72.0);
}
