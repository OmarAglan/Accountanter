// lib/features/main/widgets/app_sidebar.dart
import 'package:flutter/material.dart';
import 'package:accountanter/l10n/app_localizations.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:accountanter/theme/app_colors.dart';
import '../main_screen.dart'; // Import the AppPage enum

class AppSidebar extends StatelessWidget {
  final bool isExpanded;
  final AppPage currentPage;
  final ValueChanged<AppPage> onPageSelected;
  final VoidCallback onLogout;

  const AppSidebar({
    super.key,
    required this.isExpanded,
    required this.currentPage,
    required this.onPageSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isExpanded ? 256 : 64,
      color: AppColors.sidebar,
      child: Column(
        children: [
          _buildHeader(context),
          const Divider(color: AppColors.sidebarBorder, height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildNavItem(context, AppPage.dashboard, LucideIcons.layoutDashboard, AppLocalizations.of(context)!.dashboard),
                _buildNavItem(context, AppPage.clients, LucideIcons.users, AppLocalizations.of(context)!.clients),
                _buildNavItem(context, AppPage.invoices, LucideIcons.fileText, AppLocalizations.of(context)!.invoices),
                _buildNavItem(context, AppPage.recurring, LucideIcons.repeat, AppLocalizations.of(context)!.recurring),
                _buildNavItem(context, AppPage.payments, LucideIcons.creditCard, AppLocalizations.of(context)!.payments),
                _buildNavItem(context, AppPage.inventory, LucideIcons.package, AppLocalizations.of(context)!.inventory),
                _buildNavItem(context, AppPage.expenses, LucideIcons.receipt, AppLocalizations.of(context)!.expenses),
                _buildNavItem(context, AppPage.taxes, LucideIcons.calculator, AppLocalizations.of(context)!.taxes),
                _buildNavItem(context, AppPage.currency, LucideIcons.globe, AppLocalizations.of(context)!.currency),
                _buildNavItem(context, AppPage.documents, LucideIcons.folderOpen, AppLocalizations.of(context)!.documents),
                _buildNavItem(context, AppPage.reports, LucideIcons.chartBar, AppLocalizations.of(context)!.reports),
              ],
            ),
          ),
          const Divider(color: AppColors.sidebarBorder, height: 1),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: 73, // To match the header height
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isExpanded)
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.sidebarPrimary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(LucideIcons.package, size: 20, color: AppColors.sidebarPrimaryForeground),
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.appTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.sidebarForeground,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          // We can add a toggle button here later if needed
          // IconButton(...)
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, AppPage page, IconData icon, String label) {
    final bool isActive = currentPage == page;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: isActive ? AppColors.sidebarPrimary : Colors.transparent,
          foregroundColor: isActive ? AppColors.sidebarPrimaryForeground : AppColors.sidebarForeground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          alignment: Alignment.centerLeft,
        ),
        onPressed: () => onPageSelected(page),
        child: Row(
          children: [
            Icon(icon, size: 20),
            if (isExpanded) ...[
              const SizedBox(width: 12),
              Text(label),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    // This is a placeholder for Settings and Help. They won't change the page for now.
    _onSettingsTapped() {
      // TODO: Navigate to settings page
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.settingsNotImplemented)));
    }
     _onHelpTapped() {
      // TODO: Navigate to help page
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.helpNotImplemented)));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
           _buildFooterItem(context, LucideIcons.settings, AppLocalizations.of(context)!.settings, () => onPageSelected(AppPage.settings), isActive: currentPage == AppPage.settings),
           _buildFooterItem(context, LucideIcons.circleQuestionMark, AppLocalizations.of(context)!.help, () => onPageSelected(AppPage.help), isActive: currentPage == AppPage.help),
           _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildFooterItem(BuildContext context, IconData icon, String label, VoidCallback onTap, {bool isActive = false}) {
     return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: isActive ? AppColors.sidebarPrimary : Colors.transparent,
          foregroundColor: isActive ? AppColors.sidebarPrimaryForeground : AppColors.sidebarForeground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          alignment: Alignment.centerLeft,
        ),
        onPressed: onTap,
        child: Row(
          children: [
            Icon(icon, size: 20),
            if (isExpanded) ...[
              const SizedBox(width: 12),
              Text(label),
            ]
          ],
        ),
      ),
    );
  }

   Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.sidebarForeground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          alignment: Alignment.centerLeft,
        ),
        onPressed: onLogout,
        child: Row(
          children: [
            const Icon(LucideIcons.logOut, size: 20),
            if (isExpanded) ...[
              const SizedBox(width: 12),
              Text(AppLocalizations.of(context)!.logout),
            ]
          ],
        ),
      ),
    );
  }
}