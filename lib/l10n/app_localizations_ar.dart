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
  String get recurring => 'المتكرر';

  @override
  String get payments => 'المدفوعات';

  @override
  String get taxes => 'الضرائب';

  @override
  String get currency => 'العملة';

  @override
  String get documents => 'المستندات';

  @override
  String get reports => 'التقارير';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get language => 'اللغة';

  @override
  String get englishLanguageName => 'الإنجليزية';

  @override
  String get arabicLanguageName => 'العربية';

  @override
  String get settingsNotImplemented => 'صفحة الإعدادات غير مُنفذة بعد.';

  @override
  String get helpNotImplemented => 'صفحة المساعدة غير مُنفذة بعد.';

  @override
  String get goodMorning => 'صباح الخير';

  @override
  String get goodAfternoon => 'مساء الخير';

  @override
  String get goodEvening => 'مساء الخير';

  @override
  String get dashboardSubtitle => 'إليك ما يحدث في عملك اليوم';

  @override
  String get searchPlaceholder => 'البحث عن العملاء والفواتير...';

  @override
  String get owner => 'المالك';

  @override
  String get quickActions => 'إجراءات سريعة';

  @override
  String get overview => 'نظرة عامة';

  @override
  String get totalReceivables => 'إجمالي المستحقات';

  @override
  String get totalPayables => 'إجمالي المدفوعات';

  @override
  String get overdueInvoices => 'الفواتير المتأخرة';

  @override
  String get activeClients => 'العملاء النشطون';

  @override
  String get cashFlowThisMonth => 'التدفق النقدي هذا الشهر';

  @override
  String get moneyIn => 'الأموال الواردة';

  @override
  String get moneyOut => 'الأموال الصادرة';

  @override
  String get netCashFlow => 'صافي التدفق النقدي:';

  @override
  String get actionRequired => 'إجراء مطلوب';

  @override
  String overdueInvoicesCount(Object count) {
    return '$count فواتير متأخرة';
  }

  @override
  String get followUpRequired => 'المتابعة مطلوبة';

  @override
  String invoicesDueSoon(Object count) {
    return '$count فواتير مستحقة قريباً';
  }

  @override
  String get dueWithinDays => 'مستحقة خلال 7 أيام';

  @override
  String draftInvoices(Object count) {
    return '$count فواتير مسودة';
  }

  @override
  String get readyToBeSent => 'جاهزة للإرسال إلى العملاء';

  @override
  String get recentActivity => 'النشاط الأخير';

  @override
  String get noRecentActivity => 'لا يوجد نشاط حديث.';

  @override
  String errorLoadingDashboard(Object error) {
    return 'خطأ في تحميل لوحة التحكم: $error';
  }

  @override
  String get noDataAvailable => 'لا توجد بيانات متاحة.';

  @override
  String get newInvoice => 'فاتورة جديدة';

  @override
  String get addClient => 'إضافة عميل';

  @override
  String get recordExpense => 'تسجيل مصروف';

  @override
  String get viewReports => 'عرض التقارير';

  @override
  String get all => 'الكل';

  @override
  String get paid => 'مدفوع';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get overdue => 'متأخر';

  @override
  String get draft => 'مسودة';

  @override
  String get sent => 'مُرسل';

  @override
  String get active => 'نشط';

  @override
  String get inactive => 'غير نشط';

  @override
  String get searchClients => 'البحث عن العملاء';

  @override
  String get searchInvoices => 'البحث عن الفواتير';

  @override
  String get searchInventory => 'البحث عن عناصر المخزون';

  @override
  String get searchExpenses => 'البحث عن المصروفات';

  @override
  String get addNewClient => 'إضافة عميل جديد';

  @override
  String get editClient => 'تعديل العميل';

  @override
  String get deleteClient => 'حذف العميل';

  @override
  String get clientName => 'اسم العميل';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get phone => 'الهاتف';

  @override
  String get address => 'العنوان';

  @override
  String get notes => 'ملاحظات';

  @override
  String get clientDetails => 'تفاصيل العميل';

  @override
  String get totalBilled => 'إجمالي الفواتير';

  @override
  String get unpaidAmount => 'المبلغ غير المدفوع';

  @override
  String get lastInvoice => 'آخر فاتورة';

  @override
  String get noClients => 'لم يتم العثور على عملاء.';

  @override
  String get confirmDeleteClient => 'هل أنت متأكد من حذف هذا العميل؟';

  @override
  String get deleteConfirmation => 'لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get createInvoice => 'إنشاء فاتورة';

  @override
  String get editInvoice => 'تعديل الفاتورة';

  @override
  String get deleteInvoice => 'حذف الفاتورة';

  @override
  String get invoiceNumber => 'رقم الفاتورة';

  @override
  String get date => 'التاريخ';

  @override
  String get dueDate => 'تاريخ الاستحقاق';

  @override
  String get client => 'العميل';

  @override
  String get amount => 'المبلغ';

  @override
  String get status => 'الحالة';

  @override
  String get actions => 'الإجراءات';

  @override
  String get items => 'العناصر';

  @override
  String get addItem => 'إضافة عنصر';

  @override
  String get description => 'الوصف';

  @override
  String get quantity => 'الكمية';

  @override
  String get unitPrice => 'سعر الوحدة';

  @override
  String get tax => 'الضريبة';

  @override
  String get total => 'المجموع';

  @override
  String get subtotal => 'المجموع الفرعي';

  @override
  String get saveAsDraft => 'حفظ كمسودة';

  @override
  String get saveAndSend => 'حفظ وإرسال';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get edit => 'تعديل';

  @override
  String get delete => 'حذف';

  @override
  String get view => 'عرض';

  @override
  String get download => 'تحميل';

  @override
  String get send => 'إرسال';

  @override
  String get markAsPaid => 'وضع علامة مدفوع';

  @override
  String get markAsPending => 'وضع علامة قيد الانتظار';

  @override
  String get noInvoices => 'لم يتم العثور على فواتير.';

  @override
  String get confirmDeleteInvoice => 'هل أنت متأكد من حذف هذه الفاتورة؟';

  @override
  String get addInventoryItem => 'إضافة عنصر مخزون';

  @override
  String get editInventoryItem => 'تعديل عنصر المخزون';

  @override
  String get deleteInventoryItem => 'حذف عنصر المخزون';

  @override
  String get itemName => 'اسم العنصر';

  @override
  String get sku => 'رمز المنتج';

  @override
  String get stockQuantity => 'كمية المخزون';

  @override
  String get price => 'السعر';

  @override
  String get category => 'الفئة';

  @override
  String get lowStock => 'مخزون منخفض';

  @override
  String get inStock => 'متوفر';

  @override
  String get outOfStock => 'نفد المخزون';

  @override
  String get noInventoryItems => 'لم يتم العثور على عناصر مخزون.';

  @override
  String get confirmDeleteInventoryItem => 'هل أنت متأكد من حذف هذا العنصر؟';

  @override
  String get addExpense => 'إضافة مصروف';

  @override
  String get editExpense => 'تعديل المصروف';

  @override
  String get deleteExpense => 'حذف المصروف';

  @override
  String get expenseDescription => 'وصف المصروف';

  @override
  String get vendor => 'المورد';

  @override
  String get receiptNumber => 'رقم الإيصال';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get cash => 'نقداً';

  @override
  String get creditCard => 'بطاقة ائتمان';

  @override
  String get bankTransfer => 'تحويل بنكي';

  @override
  String get other => 'أخرى';

  @override
  String get noExpenses => 'لم يتم العثور على مصروفات.';

  @override
  String get confirmDeleteExpense => 'هل أنت متأكد من حذف هذا المصروف؟';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get lastMonth => 'الشهر الماضي';

  @override
  String get thisYear => 'هذه السنة';

  @override
  String get add => 'إضافة';

  @override
  String get update => 'تحديث';

  @override
  String get close => 'إغلاق';

  @override
  String get confirm => 'تأكيد';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get ok => 'موافق';

  @override
  String get loading => 'جارٍ التحميل...';

  @override
  String get error => 'خطأ';

  @override
  String get success => 'نجاح';

  @override
  String get warning => 'تحذير';

  @override
  String get info => 'معلومات';

  @override
  String get required => 'مطلوب';

  @override
  String get optional => 'اختياري';

  @override
  String get invalidEmail => 'عنوان بريد إلكتروني غير صالح';

  @override
  String get invalidPhone => 'رقم هاتف غير صالح';

  @override
  String get fieldRequired => 'هذا الحقل مطلوب';

  @override
  String get pleaseSelect => 'الرجاء الاختيار';

  @override
  String get pleaseEnter => 'الرجاء الإدخال';

  @override
  String get searchHere => 'البحث هنا...';

  @override
  String get noResultsFound => 'لم يتم العثور على نتائج.';

  @override
  String get totalRevenue => 'إجمالي الإيرادات';

  @override
  String get totalExpenses => 'إجمالي المصروفات';

  @override
  String get netProfit => 'صافي الربح';

  @override
  String get pendingPayments => 'المدفوعات المعلقة';

  @override
  String get upcomingExpenses => 'المصروفات القادمة';

  @override
  String get selectClient => 'اختر العميل';

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get selectStatus => 'اختر الحالة';

  @override
  String get filter => 'تصفية';

  @override
  String get clearFilters => 'مسح الفلاتر';

  @override
  String get export => 'تصدير';

  @override
  String get import => 'استيراد';

  @override
  String get print => 'طباعة';
}
