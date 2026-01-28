import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Accountanter'**
  String get appTitle;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @clients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get clients;

  /// No description provided for @invoices.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get invoices;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventory;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @recurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get recurring;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @taxes.
  ///
  /// In en, this message translates to:
  /// **'Taxes'**
  String get taxes;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @englishLanguageName.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLanguageName;

  /// No description provided for @arabicLanguageName.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabicLanguageName;

  /// No description provided for @settingsNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Settings page not implemented yet.'**
  String get settingsNotImplemented;

  /// No description provided for @helpNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Help page not implemented yet.'**
  String get helpNotImplemented;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Here\'s what\'s happening with your business today'**
  String get dashboardSubtitle;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search clients, invoices...'**
  String get searchPlaceholder;

  /// No description provided for @owner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get owner;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @totalReceivables.
  ///
  /// In en, this message translates to:
  /// **'Total Receivables'**
  String get totalReceivables;

  /// No description provided for @totalPayables.
  ///
  /// In en, this message translates to:
  /// **'Total Payables'**
  String get totalPayables;

  /// No description provided for @overdueInvoices.
  ///
  /// In en, this message translates to:
  /// **'Overdue Invoices'**
  String get overdueInvoices;

  /// No description provided for @activeClients.
  ///
  /// In en, this message translates to:
  /// **'Active Clients'**
  String get activeClients;

  /// No description provided for @cashFlowThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Cash Flow This Month'**
  String get cashFlowThisMonth;

  /// No description provided for @moneyIn.
  ///
  /// In en, this message translates to:
  /// **'Money In'**
  String get moneyIn;

  /// No description provided for @moneyOut.
  ///
  /// In en, this message translates to:
  /// **'Money Out'**
  String get moneyOut;

  /// No description provided for @netCashFlow.
  ///
  /// In en, this message translates to:
  /// **'Net Cash Flow:'**
  String get netCashFlow;

  /// No description provided for @actionRequired.
  ///
  /// In en, this message translates to:
  /// **'Action Required'**
  String get actionRequired;

  /// No description provided for @overdueInvoicesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Overdue Invoices'**
  String overdueInvoicesCount(Object count);

  /// No description provided for @followUpRequired.
  ///
  /// In en, this message translates to:
  /// **'Follow up required'**
  String get followUpRequired;

  /// No description provided for @invoicesDueSoon.
  ///
  /// In en, this message translates to:
  /// **'{count} Invoices Due Soon'**
  String invoicesDueSoon(Object count);

  /// No description provided for @dueWithinDays.
  ///
  /// In en, this message translates to:
  /// **'Due within 7 days'**
  String get dueWithinDays;

  /// No description provided for @draftInvoices.
  ///
  /// In en, this message translates to:
  /// **'{count} Draft Invoices'**
  String draftInvoices(Object count);

  /// No description provided for @readyToBeSent.
  ///
  /// In en, this message translates to:
  /// **'Ready to be sent to clients'**
  String get readyToBeSent;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @noRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'No recent activity.'**
  String get noRecentActivity;

  /// No description provided for @errorLoadingDashboard.
  ///
  /// In en, this message translates to:
  /// **'Error loading dashboard: {error}'**
  String errorLoadingDashboard(Object error);

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available.'**
  String get noDataAvailable;

  /// No description provided for @newInvoice.
  ///
  /// In en, this message translates to:
  /// **'New Invoice'**
  String get newInvoice;

  /// No description provided for @addClient.
  ///
  /// In en, this message translates to:
  /// **'Add Client'**
  String get addClient;

  /// No description provided for @recordExpense.
  ///
  /// In en, this message translates to:
  /// **'Record Expense'**
  String get recordExpense;

  /// No description provided for @viewReports.
  ///
  /// In en, this message translates to:
  /// **'View Reports'**
  String get viewReports;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draft;

  /// No description provided for @sent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sent;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @searchClients.
  ///
  /// In en, this message translates to:
  /// **'Search clients'**
  String get searchClients;

  /// No description provided for @searchInvoices.
  ///
  /// In en, this message translates to:
  /// **'Search invoices'**
  String get searchInvoices;

  /// No description provided for @searchInventory.
  ///
  /// In en, this message translates to:
  /// **'Search inventory items'**
  String get searchInventory;

  /// No description provided for @searchExpenses.
  ///
  /// In en, this message translates to:
  /// **'Search expenses'**
  String get searchExpenses;

  /// No description provided for @addNewClient.
  ///
  /// In en, this message translates to:
  /// **'Add New Client'**
  String get addNewClient;

  /// No description provided for @editClient.
  ///
  /// In en, this message translates to:
  /// **'Edit Client'**
  String get editClient;

  /// No description provided for @deleteClient.
  ///
  /// In en, this message translates to:
  /// **'Delete Client'**
  String get deleteClient;

  /// No description provided for @clientName.
  ///
  /// In en, this message translates to:
  /// **'Client Name'**
  String get clientName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @clientDetails.
  ///
  /// In en, this message translates to:
  /// **'Client Details'**
  String get clientDetails;

  /// No description provided for @totalBilled.
  ///
  /// In en, this message translates to:
  /// **'Total Billed'**
  String get totalBilled;

  /// No description provided for @unpaidAmount.
  ///
  /// In en, this message translates to:
  /// **'Unpaid Amount'**
  String get unpaidAmount;

  /// No description provided for @lastInvoice.
  ///
  /// In en, this message translates to:
  /// **'Last Invoice'**
  String get lastInvoice;

  /// No description provided for @noClients.
  ///
  /// In en, this message translates to:
  /// **'No clients found.'**
  String get noClients;

  /// No description provided for @confirmDeleteClient.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this client?'**
  String get confirmDeleteClient;

  /// No description provided for @deleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deleteConfirmation;

  /// No description provided for @createInvoice.
  ///
  /// In en, this message translates to:
  /// **'Create Invoice'**
  String get createInvoice;

  /// No description provided for @editInvoice.
  ///
  /// In en, this message translates to:
  /// **'Edit Invoice'**
  String get editInvoice;

  /// No description provided for @deleteInvoice.
  ///
  /// In en, this message translates to:
  /// **'Delete Invoice'**
  String get deleteInvoice;

  /// No description provided for @invoiceNumber.
  ///
  /// In en, this message translates to:
  /// **'Invoice Number'**
  String get invoiceNumber;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// No description provided for @client.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get client;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @unitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get unitPrice;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @saveAsDraft.
  ///
  /// In en, this message translates to:
  /// **'Save as Draft'**
  String get saveAsDraft;

  /// No description provided for @saveAndSend.
  ///
  /// In en, this message translates to:
  /// **'Save & Send'**
  String get saveAndSend;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @markAsPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark as Paid'**
  String get markAsPaid;

  /// No description provided for @markAsPending.
  ///
  /// In en, this message translates to:
  /// **'Mark as Pending'**
  String get markAsPending;

  /// No description provided for @noInvoices.
  ///
  /// In en, this message translates to:
  /// **'No invoices found.'**
  String get noInvoices;

  /// No description provided for @confirmDeleteInvoice.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this invoice?'**
  String get confirmDeleteInvoice;

  /// No description provided for @addInventoryItem.
  ///
  /// In en, this message translates to:
  /// **'Add Inventory Item'**
  String get addInventoryItem;

  /// No description provided for @editInventoryItem.
  ///
  /// In en, this message translates to:
  /// **'Edit Inventory Item'**
  String get editInventoryItem;

  /// No description provided for @deleteInventoryItem.
  ///
  /// In en, this message translates to:
  /// **'Delete Inventory Item'**
  String get deleteInventoryItem;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get itemName;

  /// No description provided for @sku.
  ///
  /// In en, this message translates to:
  /// **'SKU'**
  String get sku;

  /// No description provided for @stockQuantity.
  ///
  /// In en, this message translates to:
  /// **'Stock Quantity'**
  String get stockQuantity;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get lowStock;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get inStock;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @noInventoryItems.
  ///
  /// In en, this message translates to:
  /// **'No inventory items found.'**
  String get noInventoryItems;

  /// No description provided for @confirmDeleteInventoryItem.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get confirmDeleteInventoryItem;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// No description provided for @editExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get editExpense;

  /// No description provided for @deleteExpense.
  ///
  /// In en, this message translates to:
  /// **'Delete Expense'**
  String get deleteExpense;

  /// No description provided for @expenseDescription.
  ///
  /// In en, this message translates to:
  /// **'Expense Description'**
  String get expenseDescription;

  /// No description provided for @vendor.
  ///
  /// In en, this message translates to:
  /// **'Vendor'**
  String get vendor;

  /// No description provided for @receiptNumber.
  ///
  /// In en, this message translates to:
  /// **'Receipt Number'**
  String get receiptNumber;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @creditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get creditCard;

  /// No description provided for @bankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get bankTransfer;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @noExpenses.
  ///
  /// In en, this message translates to:
  /// **'No expenses found.'**
  String get noExpenses;

  /// No description provided for @confirmDeleteExpense.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this expense?'**
  String get confirmDeleteExpense;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get lastMonth;

  /// No description provided for @thisYear.
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get thisYear;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get info;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmail;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get invalidPhone;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @pleaseSelect.
  ///
  /// In en, this message translates to:
  /// **'Please select'**
  String get pleaseSelect;

  /// No description provided for @pleaseEnter.
  ///
  /// In en, this message translates to:
  /// **'Please enter'**
  String get pleaseEnter;

  /// No description provided for @searchHere.
  ///
  /// In en, this message translates to:
  /// **'Search here...'**
  String get searchHere;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found.'**
  String get noResultsFound;

  /// No description provided for @totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get totalRevenue;

  /// No description provided for @totalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get totalExpenses;

  /// No description provided for @netProfit.
  ///
  /// In en, this message translates to:
  /// **'Net Profit'**
  String get netProfit;

  /// No description provided for @pendingPayments.
  ///
  /// In en, this message translates to:
  /// **'Pending Payments'**
  String get pendingPayments;

  /// No description provided for @upcomingExpenses.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Expenses'**
  String get upcomingExpenses;

  /// No description provided for @selectClient.
  ///
  /// In en, this message translates to:
  /// **'Select Client'**
  String get selectClient;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @selectStatus.
  ///
  /// In en, this message translates to:
  /// **'Select Status'**
  String get selectStatus;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @print.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get print;

  /// No description provided for @helpQuickHelpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Quick help for the beta starter edition.'**
  String get helpQuickHelpSubtitle;

  /// No description provided for @helpGettingStartedTitle.
  ///
  /// In en, this message translates to:
  /// **'Getting Started'**
  String get helpGettingStartedTitle;

  /// No description provided for @helpGettingStartedBulletAddClient.
  ///
  /// In en, this message translates to:
  /// **'Add a client from Clients → Add New Client.'**
  String get helpGettingStartedBulletAddClient;

  /// No description provided for @helpGettingStartedBulletCreateInvoice.
  ///
  /// In en, this message translates to:
  /// **'Create an invoice from Invoices → New Invoice.'**
  String get helpGettingStartedBulletCreateInvoice;

  /// No description provided for @helpGettingStartedBulletTrackStock.
  ///
  /// In en, this message translates to:
  /// **'Track stock in Inventory and record Expenses as they happen.'**
  String get helpGettingStartedBulletTrackStock;

  /// No description provided for @helpGettingStartedBulletRecordPayments.
  ///
  /// In en, this message translates to:
  /// **'Record invoice payments in Payments to mark invoices as Paid.'**
  String get helpGettingStartedBulletRecordPayments;

  /// No description provided for @helpBetaNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Beta Notes'**
  String get helpBetaNotesTitle;

  /// No description provided for @helpBetaNotesBulletLocalStorage.
  ///
  /// In en, this message translates to:
  /// **'All data is stored locally on your device (SQLite).'**
  String get helpBetaNotesBulletLocalStorage;

  /// No description provided for @helpBetaNotesBulletNoCloudSync.
  ///
  /// In en, this message translates to:
  /// **'No cloud sync is included in this beta.'**
  String get helpBetaNotesBulletNoCloudSync;

  /// No description provided for @helpBetaNotesBulletDocumentsRegistry.
  ///
  /// In en, this message translates to:
  /// **'Documents are stored as file paths in a registry (no file picker yet).'**
  String get helpBetaNotesBulletDocumentsRegistry;

  /// No description provided for @helpKeyboardShortcutsTitle.
  ///
  /// In en, this message translates to:
  /// **'Keyboard Shortcuts'**
  String get helpKeyboardShortcutsTitle;

  /// No description provided for @helpKeyboardShortcutsBulletSearch.
  ///
  /// In en, this message translates to:
  /// **'Use the top search bar to quickly jump between pages.'**
  String get helpKeyboardShortcutsBulletSearch;

  /// No description provided for @helpSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get helpSupportTitle;

  /// No description provided for @helpSupportBulletBugReport.
  ///
  /// In en, this message translates to:
  /// **'If you find a bug, capture steps to reproduce and screenshots.'**
  String get helpSupportBulletBugReport;

  /// No description provided for @helpSupportBulletShareFeedback.
  ///
  /// In en, this message translates to:
  /// **'Share feedback with your beta contact/channel.'**
  String get helpSupportBulletShareFeedback;

  /// No description provided for @helpTipDemoMode.
  ///
  /// In en, this message translates to:
  /// **'Tip: Use Settings → Demo Mode to seed sample categories for testing.'**
  String get helpTipDemoMode;

  /// No description provided for @documentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Store and link documents to your records.'**
  String get documentsSubtitle;

  /// No description provided for @documentsAddDocument.
  ///
  /// In en, this message translates to:
  /// **'Add Document'**
  String get documentsAddDocument;

  /// No description provided for @documentsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search documents…'**
  String get documentsSearchHint;

  /// No description provided for @documentsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No documents yet.'**
  String get documentsEmpty;

  /// No description provided for @documentsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Document'**
  String get documentsDeleteTitle;

  /// No description provided for @documentsTableTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get documentsTableTitle;

  /// No description provided for @documentsTableType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get documentsTableType;

  /// No description provided for @documentsTableLinkedTo.
  ///
  /// In en, this message translates to:
  /// **'Linked To'**
  String get documentsTableLinkedTo;

  /// No description provided for @documentsTablePath.
  ///
  /// In en, this message translates to:
  /// **'Path'**
  String get documentsTablePath;

  /// No description provided for @documentsTableUploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get documentsTableUploaded;

  /// No description provided for @documentsTableActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get documentsTableActions;

  /// No description provided for @documentsDialogAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Document'**
  String get documentsDialogAddTitle;

  /// No description provided for @documentsDialogEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Document'**
  String get documentsDialogEditTitle;

  /// No description provided for @documentsFieldTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title *'**
  String get documentsFieldTitleLabel;

  /// No description provided for @documentsFieldFileTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'File Type *'**
  String get documentsFieldFileTypeLabel;

  /// No description provided for @documentsFieldFilePathLabel.
  ///
  /// In en, this message translates to:
  /// **'File Path *'**
  String get documentsFieldFilePathLabel;

  /// No description provided for @documentsFieldRelatedToLabel.
  ///
  /// In en, this message translates to:
  /// **'Related To'**
  String get documentsFieldRelatedToLabel;

  /// No description provided for @documentsFieldRelatedEntityIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Related Entity ID'**
  String get documentsFieldRelatedEntityIdLabel;

  /// No description provided for @documentsRelatedNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get documentsRelatedNone;

  /// No description provided for @documentsRelatedInvoice.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get documentsRelatedInvoice;

  /// No description provided for @documentsRelatedExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get documentsRelatedExpense;

  /// No description provided for @documentsRelatedClient.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get documentsRelatedClient;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @revealInFolder.
  ///
  /// In en, this message translates to:
  /// **'Reveal in Folder'**
  String get revealInFolder;

  /// No description provided for @copyPath.
  ///
  /// In en, this message translates to:
  /// **'Copy Path'**
  String get copyPath;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard.'**
  String get copiedToClipboard;

  /// No description provided for @fileNotFound.
  ///
  /// In en, this message translates to:
  /// **'File not found.'**
  String get fileNotFound;

  /// No description provided for @couldNotOpenFile.
  ///
  /// In en, this message translates to:
  /// **'Could not open file.'**
  String get couldNotOpenFile;

  /// No description provided for @operationNotSupported.
  ///
  /// In en, this message translates to:
  /// **'This action is not supported on this platform.'**
  String get operationNotSupported;

  /// No description provided for @fileSavedTo.
  ///
  /// In en, this message translates to:
  /// **'Saved to {path}'**
  String fileSavedTo(Object path);

  /// No description provided for @reportsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A quick overview of revenue, expenses, and outstanding balances.'**
  String get reportsSubtitle;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @reportRevenue12m.
  ///
  /// In en, this message translates to:
  /// **'Revenue (12m)'**
  String get reportRevenue12m;

  /// No description provided for @reportExpenses12m.
  ///
  /// In en, this message translates to:
  /// **'Expenses (12m)'**
  String get reportExpenses12m;

  /// No description provided for @reportNet12m.
  ///
  /// In en, this message translates to:
  /// **'Net (12m)'**
  String get reportNet12m;

  /// No description provided for @reportInvoicesAll.
  ///
  /// In en, this message translates to:
  /// **'Invoices (All)'**
  String get reportInvoicesAll;

  /// No description provided for @reportPaidRevenueByMonth.
  ///
  /// In en, this message translates to:
  /// **'Paid Revenue by Month'**
  String get reportPaidRevenueByMonth;

  /// No description provided for @reportExpensesByMonth.
  ///
  /// In en, this message translates to:
  /// **'Expenses by Month'**
  String get reportExpensesByMonth;

  /// No description provided for @reportNoData.
  ///
  /// In en, this message translates to:
  /// **'No data.'**
  String get reportNoData;

  /// No description provided for @reportMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get reportMonth;

  /// No description provided for @reportTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get reportTotal;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Configure company defaults and app behavior.'**
  String get settingsSubtitle;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved.'**
  String get settingsSaved;

  /// No description provided for @companySection.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get companySection;

  /// No description provided for @companyName.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get companyName;

  /// No description provided for @companyAddress.
  ///
  /// In en, this message translates to:
  /// **'Company Address'**
  String get companyAddress;

  /// No description provided for @companyNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Your Company Name'**
  String get companyNamePlaceholder;

  /// No description provided for @companyAddressPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'123 Business Street\nBusiness City, BC 12345'**
  String get companyAddressPlaceholder;

  /// No description provided for @defaultsSection.
  ///
  /// In en, this message translates to:
  /// **'Defaults'**
  String get defaultsSection;

  /// No description provided for @currencySymbol.
  ///
  /// In en, this message translates to:
  /// **'Currency Symbol'**
  String get currencySymbol;

  /// No description provided for @defaultTaxRate.
  ///
  /// In en, this message translates to:
  /// **'Default Tax Rate'**
  String get defaultTaxRate;

  /// No description provided for @demoMode.
  ///
  /// In en, this message translates to:
  /// **'Demo Mode'**
  String get demoMode;

  /// No description provided for @demoModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Seed sample categories and vendors for demo purposes.'**
  String get demoModeSubtitle;

  /// No description provided for @dataTools.
  ///
  /// In en, this message translates to:
  /// **'Data Tools'**
  String get dataTools;

  /// No description provided for @factoryReset.
  ///
  /// In en, this message translates to:
  /// **'Factory Reset'**
  String get factoryReset;

  /// No description provided for @factoryResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Factory reset?'**
  String get factoryResetTitle;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @dataClearedTitle.
  ///
  /// In en, this message translates to:
  /// **'Data cleared'**
  String get dataClearedTitle;

  /// No description provided for @dataClearedMessage.
  ///
  /// In en, this message translates to:
  /// **'All local data was cleared. Restart the app to re-activate and log in again.'**
  String get dataClearedMessage;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @usernameOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Username or Email'**
  String get usernameOrEmail;

  /// No description provided for @usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get usernameRequired;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember Me'**
  String get rememberMe;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @invalidUsernameOrPassword.
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password.'**
  String get invalidUsernameOrPassword;

  /// No description provided for @activateAccountanter.
  ///
  /// In en, this message translates to:
  /// **'Activate Accountanter'**
  String get activateAccountanter;

  /// No description provided for @activationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your license key and create your local user account.'**
  String get activationSubtitle;

  /// No description provided for @licenseKey.
  ///
  /// In en, this message translates to:
  /// **'License Key'**
  String get licenseKey;

  /// No description provided for @licenseKeyRequired.
  ///
  /// In en, this message translates to:
  /// **'License key is required'**
  String get licenseKeyRequired;

  /// No description provided for @passwordMinChars.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinChars;

  /// No description provided for @activateAndCreateUser.
  ///
  /// In en, this message translates to:
  /// **'Activate and Create User'**
  String get activateAndCreateUser;

  /// No description provided for @invalidLicenseKey.
  ///
  /// In en, this message translates to:
  /// **'Invalid License Key.'**
  String get invalidLicenseKey;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
