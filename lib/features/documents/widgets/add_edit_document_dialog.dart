import 'package:accountanter/data/database.dart';
import 'package:accountanter/l10n/app_localizations.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddEditDocumentDialog extends StatefulWidget {
  final Document? document;

  const AddEditDocumentDialog({
    super.key,
    this.document,
  });

  @override
  State<AddEditDocumentDialog> createState() => _AddEditDocumentDialogState();
}

class _AddEditDocumentDialogState extends State<AddEditDocumentDialog> {
  final AppDatabase _database = AppDatabase.instance;
  final _formKey = GlobalKey<FormState>();

  bool get _isEditing => widget.document != null;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _filePathController = TextEditingController();
  final TextEditingController _fileTypeController = TextEditingController();
  String? _relatedType;
  final TextEditingController _relatedIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final d = widget.document;
    if (d != null) {
      _titleController.text = d.title;
      _filePathController.text = d.filePath;
      _fileTypeController.text = d.fileType;
      _relatedType = d.relatedEntityType;
      _relatedIdController.text = d.relatedEntityId?.toString() ?? '';
    } else {
      _fileTypeController.text = 'PDF';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _filePathController.dispose();
    _fileTypeController.dispose();
    _relatedIdController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final relatedId = int.tryParse(_relatedIdController.text.trim());
    final companion = DocumentsCompanion(
      id: _isEditing ? Value(widget.document!.id) : const Value.absent(),
      title: Value(_titleController.text.trim()),
      filePath: Value(_filePathController.text.trim()),
      fileType: Value(_fileTypeController.text.trim()),
      relatedEntityType: Value(_relatedType),
      relatedEntityId: Value(_relatedType == null ? null : relatedId),
    );

    if (_isEditing) {
      await _database.updateDocument(companion);
    } else {
      await _database.insertDocument(companion);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(_isEditing ? 'Edit Document' : 'Add Document'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title *'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fileTypeController,
                  decoration: const InputDecoration(labelText: 'File Type *'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _filePathController,
                  decoration: const InputDecoration(labelText: 'File Path *'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  key: ValueKey(_relatedType),
                  initialValue: _relatedType,
                  decoration: const InputDecoration(labelText: 'Related To'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('None')),
                    DropdownMenuItem(value: 'Invoice', child: Text('Invoice')),
                    DropdownMenuItem(value: 'Expense', child: Text('Expense')),
                    DropdownMenuItem(value: 'Client', child: Text('Client')),
                  ],
                  onChanged: (value) => setState(() => _relatedType = value),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _relatedIdController,
                  enabled: _relatedType != null,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Related Entity ID'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
        ElevatedButton(onPressed: _save, child: Text(_isEditing ? l10n.update : l10n.save)),
      ],
    );
  }
}
