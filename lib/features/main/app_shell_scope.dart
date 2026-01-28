import 'package:flutter/material.dart';
import 'main_screen.dart';

class AppShellActions {
  final ValueChanged<AppPage> navigateTo;
  final VoidCallback createInvoice;
  final VoidCallback addClient;
  final VoidCallback addInventoryItem;
  final VoidCallback openNotifications;
  final VoidCallback openSearch;

  const AppShellActions({
    required this.navigateTo,
    required this.createInvoice,
    required this.addClient,
    required this.addInventoryItem,
    required this.openNotifications,
    required this.openSearch,
  });
}

class AppShellScope extends InheritedWidget {
  final AppShellActions actions;

  const AppShellScope({
    super.key,
    required this.actions,
    required super.child,
  });

  static AppShellActions of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppShellScope>();
    if (scope == null) {
      throw StateError('AppShellScope not found in widget tree.');
    }
    return scope.actions;
  }

  @override
  bool updateShouldNotify(covariant AppShellScope oldWidget) => actions != oldWidget.actions;
}
