import 'package:flutter/material.dart';
import 'widgets/app_sidebar.dart';
import 'widgets/app_header.dart';
// We will create placeholder screens for these soon
import '../dashboard/dashboard_screen.dart'; 
import '../clients/clients_screen.dart';
import '../invoices/invoices_screen.dart';
import '../inventory/inventory_screen.dart';
import '../expenses/expenses_screen.dart'; // 1. IMPORT the new screen

// 2. ADD 'expenses' to the enum
enum AppPage { dashboard, clients, invoices, inventory, expenses }

class MainScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const MainScreen({super.key, required this.onLogout});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  AppPage _currentPage = AppPage.dashboard;
  final bool _isSidebarExpanded = true; // For now, let's keep it simple

  // A map to easily get the widget for the current page
  Widget _getCurrentPageWidget() {
    switch (_currentPage) {
      case AppPage.dashboard:
        return const DashboardScreen();
      case AppPage.clients:
        return const ClientsScreen();
      case AppPage.invoices:
        return const InvoicesScreen();
      case AppPage.inventory:
        return const InventoryScreen();
      case AppPage.expenses: // 3. ADD a case for the new screen
        return const ExpensesScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    // A more robust way to handle desktop vs mobile layout
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: Row(
        children: [
          // The Sidebar
          AppSidebar(
            isExpanded: _isSidebarExpanded,
            currentPage: _currentPage,
            onPageSelected: (page) {
              setState(() {
                _currentPage = page;
              });
            },
            onLogout: widget.onLogout,
          ),
          
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // The Header
                const AppHeader(userName: "John"),
                
                // The Page Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: _getCurrentPageWidget(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}