import 'package:flutter/material.dart';
import 'package:accountanter/l10n/app_localizations.dart';
import 'package:accountanter/data/database.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:intl/intl.dart';
import 'package:accountanter/theme/app_colors.dart';
import 'widgets/add_edit_document_dialog.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final AppDatabase _database = AppDatabase.instance;
  String _searchTerm = '';

  void _openAdd() {
    showDialog(context: context, builder: (context) => const AddEditDocumentDialog());
  }

  void _openEdit(Document doc) {
    showDialog(context: context, builder: (context) => AddEditDocumentDialog(document: doc));
  }

  void _confirmDelete(Document doc) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text(l10n.deleteConfirmation),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.destructive),
            onPressed: () async {
              await _database.deleteDocument(doc.id);
              if (context.mounted) Navigator.of(context).pop();
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('MMM d, yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.documents, style: Theme.of(context).textTheme.headlineMedium),
                Text('Store and link documents to your records.', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _openAdd,
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('Add Document'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (v) => setState(() => _searchTerm = v),
              decoration: InputDecoration(
                hintText: 'Search documents…',
                prefixIcon: const Icon(LucideIcons.search, size: 16),
                isDense: true,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Card(
          clipBehavior: Clip.antiAlias,
          child: StreamBuilder<List<Document>>(
            stream: _database.watchAllDocuments(),
            builder: (context, snapshot) {
              final all = snapshot.data ?? [];
              final q = _searchTerm.toLowerCase();
              final docs = all.where((d) {
                return q.isEmpty ||
                    d.title.toLowerCase().contains(q) ||
                    d.fileType.toLowerCase().contains(q) ||
                    d.filePath.toLowerCase().contains(q) ||
                    (d.relatedEntityType?.toLowerCase().contains(q) ?? false);
              }).toList();

              if (docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: Text('No documents yet.')),
                );
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Title')),
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Linked To')),
                    DataColumn(label: Text('Path')),
                    DataColumn(label: Text('Uploaded')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: docs.map((d) {
                    final link = d.relatedEntityType == null ? '-' : '${d.relatedEntityType} #${d.relatedEntityId ?? ''}';
                    return DataRow(cells: [
                      DataCell(Text(d.title)),
                      DataCell(Text(d.fileType)),
                      DataCell(Text(link)),
                      DataCell(SizedBox(width: 320, child: Text(d.filePath, overflow: TextOverflow.ellipsis))),
                      DataCell(Text(dateFormat.format(d.uploadDate))),
                      DataCell(
                        PopupMenuButton<String>(
                          onSelected: (v) {
                            if (v == 'edit') _openEdit(d);
                            if (v == 'delete') _confirmDelete(d);
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text(l10n.delete, style: const TextStyle(color: AppColors.destructive)),
                            ),
                          ],
                          icon: const Icon(LucideIcons.ellipsisVertical, size: 16),
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
