// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'محاسب';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get clients => 'العملاء';

  @override
  String get invoices => 'الفواتير';

  @override
  String get inventory => 'المخزون';

  @override
  String get expenses => 'المصروفات';

  @override
  String get settings => 'الإعدادات';

  @override
  String get help => 'المساعدة';

  @override
  String get logout => 'تسجيل الخروج';
}
