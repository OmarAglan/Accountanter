import 'package:accountanter/features/main/app_page.dart';
import 'package:accountanter/features/main/widgets/app_sidebar.dart';
import 'package:accountanter/l10n/app_localizations.dart';
import 'package:accountanter/l10n/app_localizations_ar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Arabic localizations include translated sidebar items', () {
    final l10n = AppLocalizationsAr();
    expect(l10n.recurring, 'المتكرر');
    expect(l10n.payments, 'المدفوعات');
    expect(l10n.taxes, 'الضرائب');
    expect(l10n.currency, 'العملة');
    expect(l10n.documents, 'المستندات');
    expect(l10n.reports, 'التقارير');
    expect(l10n.notifications, 'الإشعارات');
  });

  testWidgets('Sidebar buttons use directional alignment for RTL', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: AppSidebar(
            isExpanded: true,
            currentPage: AppPage.dashboard,
            onPageSelected: (_) {},
            onLogout: () {},
          ),
        ),
      ),
    );

    final button = tester.widget<TextButton>(find.byType(TextButton).first);
    expect(button.style?.alignment, AlignmentDirectional.centerStart);
  });
}
