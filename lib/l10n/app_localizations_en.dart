// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Accountanter';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get clients => 'Clients';

  @override
  String get invoices => 'Invoices';

  @override
  String get inventory => 'Inventory';

  @override
  String get expenses => 'Expenses';

  @override
  String get settings => 'Settings';

  @override
  String get help => 'Help';

  @override
  String get recurring => 'Recurring';

  @override
  String get payments => 'Payments';

  @override
  String get taxes => 'Taxes';

  @override
  String get currency => 'Currency';

  @override
  String get documents => 'Documents';

  @override
  String get reports => 'Reports';

  @override
  String get notifications => 'Notifications';

  @override
  String get logout => 'Logout';

  @override
  String get language => 'Language';

  @override
  String get englishLanguageName => 'English';

  @override
  String get arabicLanguageName => 'Arabic';

  @override
  String get settingsNotImplemented => 'Settings page not implemented yet.';

  @override
  String get helpNotImplemented => 'Help page not implemented yet.';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get dashboardSubtitle =>
      'Here\'s what\'s happening with your business today';

  @override
  String get searchPlaceholder => 'Search clients, invoices...';

  @override
  String get owner => 'Owner';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get overview => 'Overview';

  @override
  String get totalReceivables => 'Total Receivables';

  @override
  String get totalPayables => 'Total Payables';

  @override
  String get overdueInvoices => 'Overdue Invoices';

  @override
  String get activeClients => 'Active Clients';

  @override
  String get cashFlowThisMonth => 'Cash Flow This Month';

  @override
  String get moneyIn => 'Money In';

  @override
  String get moneyOut => 'Money Out';

  @override
  String get netCashFlow => 'Net Cash Flow:';

  @override
  String get actionRequired => 'Action Required';

  @override
  String overdueInvoicesCount(Object count) {
    return '$count Overdue Invoices';
  }

  @override
  String get followUpRequired => 'Follow up required';

  @override
  String invoicesDueSoon(Object count) {
    return '$count Invoices Due Soon';
  }

  @override
  String get dueWithinDays => 'Due within 7 days';

  @override
  String draftInvoices(Object count) {
    return '$count Draft Invoices';
  }

  @override
  String get readyToBeSent => 'Ready to be sent to clients';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get noRecentActivity => 'No recent activity.';

  @override
  String errorLoadingDashboard(Object error) {
    return 'Error loading dashboard: $error';
  }

  @override
  String get noDataAvailable => 'No data available.';

  @override
  String get newInvoice => 'New Invoice';

  @override
  String get addClient => 'Add Client';

  @override
  String get recordExpense => 'Record Expense';

  @override
  String get viewReports => 'View Reports';

  @override
  String get all => 'All';

  @override
  String get paid => 'Paid';

  @override
  String get pending => 'Pending';

  @override
  String get overdue => 'Overdue';

  @override
  String get draft => 'Draft';

  @override
  String get sent => 'Sent';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get searchClients => 'Search clients';

  @override
  String get searchInvoices => 'Search invoices';

  @override
  String get searchInventory => 'Search inventory items';

  @override
  String get searchExpenses => 'Search expenses';

  @override
  String get addNewClient => 'Add New Client';

  @override
  String get editClient => 'Edit Client';

  @override
  String get deleteClient => 'Delete Client';

  @override
  String get clientName => 'Client Name';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone';

  @override
  String get address => 'Address';

  @override
  String get notes => 'Notes';

  @override
  String get clientDetails => 'Client Details';

  @override
  String get totalBilled => 'Total Billed';

  @override
  String get unpaidAmount => 'Unpaid Amount';

  @override
  String get lastInvoice => 'Last Invoice';

  @override
  String get noClients => 'No clients found.';

  @override
  String get confirmDeleteClient =>
      'Are you sure you want to delete this client?';

  @override
  String get deleteConfirmation => 'This action cannot be undone.';

  @override
  String get createInvoice => 'Create Invoice';

  @override
  String get editInvoice => 'Edit Invoice';

  @override
  String get deleteInvoice => 'Delete Invoice';

  @override
  String get invoiceNumber => 'Invoice Number';

  @override
  String get date => 'Date';

  @override
  String get dueDate => 'Due Date';

  @override
  String get client => 'Client';

  @override
  String get amount => 'Amount';

  @override
  String get status => 'Status';

  @override
  String get actions => 'Actions';

  @override
  String get items => 'Items';

  @override
  String get addItem => 'Add Item';

  @override
  String get description => 'Description';

  @override
  String get quantity => 'Quantity';

  @override
  String get unitPrice => 'Unit Price';

  @override
  String get tax => 'Tax';

  @override
  String get total => 'Total';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get saveAsDraft => 'Save as Draft';

  @override
  String get saveAndSend => 'Save & Send';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get view => 'View';

  @override
  String get download => 'Download';

  @override
  String get send => 'Send';

  @override
  String get markAsPaid => 'Mark as Paid';

  @override
  String get markAsPending => 'Mark as Pending';

  @override
  String get noInvoices => 'No invoices found.';

  @override
  String get confirmDeleteInvoice =>
      'Are you sure you want to delete this invoice?';

  @override
  String get addInventoryItem => 'Add Inventory Item';

  @override
  String get editInventoryItem => 'Edit Inventory Item';

  @override
  String get deleteInventoryItem => 'Delete Inventory Item';

  @override
  String get itemName => 'Item Name';

  @override
  String get sku => 'SKU';

  @override
  String get stockQuantity => 'Stock Quantity';

  @override
  String get price => 'Price';

  @override
  String get category => 'Category';

  @override
  String get lowStock => 'Low Stock';

  @override
  String get inStock => 'In Stock';

  @override
  String get outOfStock => 'Out of Stock';

  @override
  String get noInventoryItems => 'No inventory items found.';

  @override
  String get confirmDeleteInventoryItem =>
      'Are you sure you want to delete this item?';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get editExpense => 'Edit Expense';

  @override
  String get deleteExpense => 'Delete Expense';

  @override
  String get expenseDescription => 'Expense Description';

  @override
  String get vendor => 'Vendor';

  @override
  String get receiptNumber => 'Receipt Number';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get cash => 'Cash';

  @override
  String get creditCard => 'Credit Card';

  @override
  String get bankTransfer => 'Bank Transfer';

  @override
  String get other => 'Other';

  @override
  String get noExpenses => 'No expenses found.';

  @override
  String get confirmDeleteExpense =>
      'Are you sure you want to delete this expense?';

  @override
  String get thisMonth => 'This Month';

  @override
  String get lastMonth => 'Last Month';

  @override
  String get thisYear => 'This Year';

  @override
  String get add => 'Add';

  @override
  String get update => 'Update';

  @override
  String get close => 'Close';

  @override
  String get confirm => 'Confirm';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get ok => 'OK';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Information';

  @override
  String get required => 'Required';

  @override
  String get optional => 'Optional';

  @override
  String get invalidEmail => 'Invalid email address';

  @override
  String get invalidPhone => 'Invalid phone number';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get pleaseSelect => 'Please select';

  @override
  String get pleaseEnter => 'Please enter';

  @override
  String get searchHere => 'Search here...';

  @override
  String get noResultsFound => 'No results found.';

  @override
  String get totalRevenue => 'Total Revenue';

  @override
  String get totalExpenses => 'Total Expenses';

  @override
  String get netProfit => 'Net Profit';

  @override
  String get pendingPayments => 'Pending Payments';

  @override
  String get upcomingExpenses => 'Upcoming Expenses';

  @override
  String get selectClient => 'Select Client';

  @override
  String get selectDate => 'Select Date';

  @override
  String get selectStatus => 'Select Status';

  @override
  String get filter => 'Filter';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get export => 'Export';

  @override
  String get import => 'Import';

  @override
  String get print => 'Print';

  @override
  String get helpQuickHelpSubtitle => 'Quick help for the beta starter edition.';

  @override
  String get helpGettingStartedTitle => 'Getting Started';

  @override
  String get helpGettingStartedBulletAddClient =>
      'Add a client from Clients → Add New Client.';

  @override
  String get helpGettingStartedBulletCreateInvoice =>
      'Create an invoice from Invoices → New Invoice.';

  @override
  String get helpGettingStartedBulletTrackStock =>
      'Track stock in Inventory and record Expenses as they happen.';

  @override
  String get helpGettingStartedBulletRecordPayments =>
      'Record invoice payments in Payments to mark invoices as Paid.';

  @override
  String get helpBetaNotesTitle => 'Beta Notes';

  @override
  String get helpBetaNotesBulletLocalStorage =>
      'All data is stored locally on your device (SQLite).';

  @override
  String get helpBetaNotesBulletNoCloudSync =>
      'No cloud sync is included in this beta.';

  @override
  String get helpBetaNotesBulletDocumentsRegistry =>
      'Documents are stored as file paths in a registry (no file picker yet).';

  @override
  String get helpKeyboardShortcutsTitle => 'Keyboard Shortcuts';

  @override
  String get helpKeyboardShortcutsBulletSearch =>
      'Use the top search bar to quickly jump between pages.';

  @override
  String get helpSupportTitle => 'Support';

  @override
  String get helpSupportBulletBugReport =>
      'If you find a bug, capture steps to reproduce and screenshots.';

  @override
  String get helpSupportBulletShareFeedback =>
      'Share feedback with your beta contact/channel.';

  @override
  String get helpTipDemoMode =>
      'Tip: Use Settings → Demo Mode to seed sample categories for testing.';

  @override
  String get documentsSubtitle => 'Store and link documents to your records.';

  @override
  String get documentsAddDocument => 'Add Document';

  @override
  String get documentsSearchHint => 'Search documents…';

  @override
  String get documentsEmpty => 'No documents yet.';

  @override
  String get documentsDeleteTitle => 'Delete Document';

  @override
  String get documentsTableTitle => 'Title';

  @override
  String get documentsTableType => 'Type';

  @override
  String get documentsTableLinkedTo => 'Linked To';

  @override
  String get documentsTablePath => 'Path';

  @override
  String get documentsTableUploaded => 'Uploaded';

  @override
  String get documentsTableActions => 'Actions';

  @override
  String get documentsDialogAddTitle => 'Add Document';

  @override
  String get documentsDialogEditTitle => 'Edit Document';

  @override
  String get documentsFieldTitleLabel => 'Title *';

  @override
  String get documentsFieldFileTypeLabel => 'File Type *';

  @override
  String get documentsFieldFilePathLabel => 'File Path *';

  @override
  String get documentsFieldRelatedToLabel => 'Related To';

  @override
  String get documentsFieldRelatedEntityIdLabel => 'Related Entity ID';

  @override
  String get documentsRelatedNone => 'None';

  @override
  String get documentsRelatedInvoice => 'Invoice';

  @override
  String get documentsRelatedExpense => 'Expense';

  @override
  String get documentsRelatedClient => 'Client';

  @override
  String get open => 'Open';

  @override
  String get revealInFolder => 'Reveal in Folder';

  @override
  String get copyPath => 'Copy Path';

  @override
  String get copiedToClipboard => 'Copied to clipboard.';

  @override
  String get fileNotFound => 'File not found.';

  @override
  String get couldNotOpenFile => 'Could not open file.';

  @override
  String get operationNotSupported =>
      'This action is not supported on this platform.';

  @override
  String fileSavedTo(Object path) {
    return 'Saved to $path';
  }

  @override
  String get reportsSubtitle =>
      'A quick overview of revenue, expenses, and outstanding balances.';

  @override
  String get refresh => 'Refresh';

  @override
  String get reportRevenue12m => 'Revenue (12m)';

  @override
  String get reportExpenses12m => 'Expenses (12m)';

  @override
  String get reportNet12m => 'Net (12m)';

  @override
  String get reportInvoicesAll => 'Invoices (All)';

  @override
  String get reportPaidRevenueByMonth => 'Paid Revenue by Month';

  @override
  String get reportExpensesByMonth => 'Expenses by Month';

  @override
  String get reportNoData => 'No data.';

  @override
  String get reportMonth => 'Month';

  @override
  String get reportTotal => 'Total';

  @override
  String get settingsSubtitle => 'Configure company defaults and app behavior.';

  @override
  String get settingsSaved => 'Settings saved.';

  @override
  String get companySection => 'Company';

  @override
  String get companyName => 'Company Name';

  @override
  String get companyAddress => 'Company Address';

  @override
  String get companyNamePlaceholder => 'Your Company Name';

  @override
  String get companyAddressPlaceholder =>
      '123 Business Street\nBusiness City, BC 12345';

  @override
  String get defaultsSection => 'Defaults';

  @override
  String get currencySymbol => 'Currency Symbol';

  @override
  String get defaultTaxRate => 'Default Tax Rate';

  @override
  String get demoMode => 'Demo Mode';

  @override
  String get demoModeSubtitle =>
      'Seed sample categories and vendors for demo purposes.';

  @override
  String get dataTools => 'Data Tools';

  @override
  String get factoryReset => 'Factory Reset';

  @override
  String get factoryResetTitle => 'Factory reset?';

  @override
  String get reset => 'Reset';

  @override
  String get dataClearedTitle => 'Data cleared';

  @override
  String get dataClearedMessage =>
      'All local data was cleared. Restart the app to re-activate and log in again.';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get usernameOrEmail => 'Username or Email';

  @override
  String get usernameRequired => 'Username is required';

  @override
  String get password => 'Password';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get rememberMe => 'Remember Me';

  @override
  String get login => 'Login';

  @override
  String get invalidUsernameOrPassword => 'Invalid username or password.';

  @override
  String get activateAccountanter => 'Activate Accountanter';

  @override
  String get activationSubtitle =>
      'Enter your license key and create your local user account.';

  @override
  String get licenseKey => 'License Key';

  @override
  String get licenseKeyRequired => 'License key is required';

  @override
  String get passwordMinChars => 'Password must be at least 6 characters';

  @override
  String get activateAndCreateUser => 'Activate and Create User';

  @override
  String get invalidLicenseKey => 'Invalid License Key.';
}
