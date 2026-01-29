import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:accountanter/data/database.dart';
import 'package:accountanter/features/expenses/expenses_screen.dart';

class CsvExportUtil {
  static Future<String?> exportInvoices(List<InvoiceWithStats> invoices) async {
    final List<List<dynamic>> rows = [
      ['Invoice Number', 'Client', 'Date', 'Due Date', 'Total Amount', 'Paid Amount', 'Balance', 'Status'],
    ];

    final dateFormat = DateFormat('yyyy-MM-dd');

    for (var i in invoices) {
      rows.add([
        i.invoice.invoiceNumber,
        i.client.name,
        dateFormat.format(i.invoice.issueDate),
        dateFormat.format(i.invoice.dueDate),
        i.invoice.totalAmount,
        i.paidAmount,
        i.balance,
        i.invoice.status,
      ]);
    }

    String csvContent = const ListToCsvConverter().convert(rows);
    return _saveFile(csvContent, 'invoices_export_${DateTime.now().millisecondsSinceEpoch}.csv');
  }

  static Future<String?> exportExpenses(List<ExpenseWithDetails> expenses) async {
    final List<List<dynamic>> rows = [
      ['Date', 'Description', 'Category', 'Vendor', 'Amount', 'Status'],
    ];

    final dateFormat = DateFormat('yyyy-MM-dd');

    for (var e in expenses) {
      rows.add([
        dateFormat.format(e.expense.date),
        e.expense.description,
        e.category.name,
        e.vendor?.name ?? 'N/A',
        e.expense.amount,
        e.expense.status,
      ]);
    }

    String csvContent = const ListToCsvConverter().convert(rows);
    return _saveFile(csvContent, 'expenses_export_${DateTime.now().millisecondsSinceEpoch}.csv');
  }

  static Future<String?> _saveFile(String content, String fileName) async {
    try {
      Directory? directory;
      if (Platform.isWindows) {
        directory = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final String path = '${directory.path}/$fileName';
      final File file = File(path);
      await file.writeAsString(content);
      return path;
    } catch (e) {
      return null;
    }
  }
}
