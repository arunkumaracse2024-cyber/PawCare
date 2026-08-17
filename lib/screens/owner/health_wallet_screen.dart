import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../theme/app_theme.dart';
import '../../../state/app_state.dart';
import '../../../state/encyclopedia_provider.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../models/health_record.dart';
import '../../../services/pdf_service.dart';
import '../../../services/file_storage_service.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
class HealthWalletScreen extends StatefulWidget {
  const HealthWalletScreen({super.key});

  @override
  State<HealthWalletScreen> createState() => _HealthWalletScreenState();
}

class _HealthWalletScreenState extends State<HealthWalletScreen> {
  bool _exporting = false;

  void _showAddRecordDialog(BuildContext context, {HealthRecord? record}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.8,
        child: AddEditRecordSheet(record: record),
      ),
    );
  }

  void _exportHealthWalletPDF(AppState state) async {
    setState(() {
      _exporting = true;
    });

    try {
      final pet = state.selectedPet!;
      final records = state.healthRecords
          .where((r) => r.petId == pet.id)
          .toList();
      final logs = state.behaviourLogs.where((l) => l.petId == pet.id).toList();

      final pdfFile = await PdfService.generatePetHealthReport(
        pet: pet,
        healthRecords: records,
        behaviourLogs: logs,
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.green),
                SizedBox(width: 8),
                Text('Report Ready!'),
              ],
            ),
            content: const Text(
              'Your comprehensive Health Wallet PDF has been securely generated and saved.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  OpenFilex.open(pdfFile.path);
                },
                child: const Text('Open'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  SharePlus.instance.share(
                    ShareParams(
                      files: [XFile(pdfFile.path)],
                      text: 'PawCare Health Report for ${pet.name}',
                    ),
                  );
                },
                icon: const Icon(Icons.share_rounded, size: 16),
                label: const Text('Share'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.tealSecondary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to compile PDF Report: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _exporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final pet = state.selectedPet;
    if (pet == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Health Wallet')),
        body: const Center(child: Text('Please select or add a pet first.')),
      );
    }

    final records = state.healthRecords
        .where((r) => r.petId == pet.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('${pet.name}\'s Health Wallet'),
        actions: [
          _exporting
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(
                    Icons.picture_as_pdf_outlined,
                    color: AppTheme.orangePrimary,
                  ),
                  onPressed: () => _exportHealthWalletPDF(state),
                  tooltip: 'Export PDF Summary',
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddRecordDialog(context),
        icon: const Icon(Icons.note_add_rounded),
        label: const Text('Add Document / Rec'),
        backgroundColor: AppTheme.tealSecondary,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : records.isEmpty
          ? _buildEmptyState(isDark)
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final rec = records[index];
                return _buildRecordCard(context, state, rec, isDark);
              },
            ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return EmptyStateWidget(
      icon: Icons.folder_shared_rounded,
      title: 'Your Health Wallet is Empty',
      message: 'Add medical reports, vaccination cards, prescriptions, or clinical bills to secure them in one offline app vault.',
      iconColor: Colors.amber,
      iconBackgroundColor: Colors.amber.withValues(alpha: 0.12),
    );
  }

  Widget _buildRecordCard(
    BuildContext context,
    AppState state,
    HealthRecord rec,
    bool isDark,
  ) {
    final recordColor = rec.type.toLowerCase() == 'vaccination'
        ? AppTheme.tealSecondary
        : rec.type.toLowerCase() == 'prescription'
        ? AppTheme.orangePrimary
        : rec.type.toLowerCase() == 'medical bill'
        ? Colors.amber
        : Colors.purple;

    final recordIcon = rec.type.toLowerCase() == 'vaccination'
        ? Icons.vaccines_rounded
        : rec.type.toLowerCase() == 'prescription'
        ? Icons.medication_liquid_rounded
        : rec.type.toLowerCase() == 'medical bill'
        ? Icons.receipt_long_rounded
        : Icons.biotech_rounded;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: recordColor.withValues(alpha: 0.12),
                  child: Icon(recordIcon, color: recordColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rec.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${rec.type} • Logged: ${rec.date.day}/${rec.date.month}/${rec.date.year}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _showAddRecordDialog(context, record: rec),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Icon(
                      Icons.edit_outlined,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    state.deleteHealthRecord(rec.id);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            if (rec.details.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(rec.details, style: const TextStyle(fontSize: 14)),
            ],
            if (rec.attachmentPath != null &&
                rec.attachmentPath!.isNotEmpty) ...[
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final path = rec.attachmentPath!;
                  final file = File(path);
                  if (await file.exists()) {
                     final result = await OpenFilex.open(path);
                     if (result.type != ResultType.done && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Could not open file: ${result.message}'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                     }
                  } else {
                     if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('File not found on device.'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                     }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF333333)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.attach_file_rounded,
                        size: 14,
                        color: AppTheme.tealSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        rec.attachmentPath!.split(Platform.pathSeparator).last,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AddEditRecordSheet extends StatefulWidget {
  final HealthRecord? record;
  const AddEditRecordSheet({super.key, this.record});

  @override
  State<AddEditRecordSheet> createState() => _AddEditRecordSheetState();
}

class _AddEditRecordSheetState extends State<AddEditRecordSheet> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _type = 'Vaccination';
  DateTime _selectedDate = DateTime.now();
  String _notes = '';
  String? _attachmentPath;
  String? _originalAttachmentPath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.record != null) {
      _title = widget.record!.title;
      _type = widget.record!.type;
      _selectedDate = widget.record!.date;
      _notes = widget.record!.details;
      _attachmentPath = widget.record!.attachmentPath;
      _originalAttachmentPath = widget.record!.attachmentPath;
    }
  }

  final List<String> _types = [
    'Vaccination',
    'Prescription',
    'Medical Bill',
    'Lab Result',
  ];

  void _pickAttachment() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _attachmentPath = result.files.single.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to picker file attachment: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Add Record / Bill',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 20),

            // Title
            if (_type == 'Vaccination')
              Autocomplete<String>(
                initialValue: TextEditingValue(text: _title),
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  final state = Provider.of<AppState>(context, listen: false);
                  final encyclopedia = Provider.of<EncyclopediaProvider>(context, listen: false);
                  final pet = state.selectedPet;
                  if (pet == null) return const Iterable<String>.empty();
                  final species = pet.species.toLowerCase();
                  return encyclopedia.vaccines
                      .where((v) => v.species == species)
                      .map((v) => v.name)
                      .where((name) => name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                },
                onSelected: (String selection) {
                  _title = selection;
                },
                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Diagnosis / Name',
                      prefixIcon: Icon(Icons.vaccines_rounded),
                      hintText: 'e.g. Parvovirus Vaccine',
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Please enter a name' : null,
                    onSaved: (v) => _title = v?.trim() ?? '',
                    onChanged: (v) => _title = v,
                  );
                },
              )
            else
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(
                  labelText: 'Diagnosis / Name',
                  prefixIcon: Icon(Icons.bookmark_added_outlined),
                  hintText: 'e.g. Parvovirus Vaccine, or Gastro Medication',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Please enter a name' : null,
                onSaved: (v) => _title = v?.trim() ?? '',
                onChanged: (v) => _title = v,
              ),
            const SizedBox(height: 16),

            // Type
            const Text(
              'Document Category',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF444444)
                      : const Color(0xFFEBE3D5),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _type,
                  isExpanded: true,
                  onChanged: (v) {
                    if (v != null) setState(() => _type = v);
                  },
                  items: _types
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Date
            const Text(
              'Record Date',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now().subtract(
                    const Duration(days: 1095),
                  ),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF444444)
                        : const Color(0xFFEBE3D5),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.today_rounded,
                      color: AppTheme.tealSecondary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              initialValue: _notes,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Clinical Notes & Details',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 32),
                  child: Icon(Icons.description_outlined),
                ),
              ),
              onSaved: (v) => _notes = v?.trim() ?? '',
            ),
            const SizedBox(height: 16),

            // File Attachment Picker
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickAttachment,
                    icon: const Icon(Icons.upload_file_rounded),
                    label: const Text('Add File/Image Attachment'),
                  ),
                ),
              ],
            ),
            if (_attachmentPath != null) ...[
              const SizedBox(height: 6),
              Text(
                'Attached: ${_attachmentPath!.split(Platform.pathSeparator).last}',
                style: const TextStyle(
                  color: AppTheme.tealSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],

            const Spacer(),
            ElevatedButton(
              onPressed: _isSaving ? null : () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  setState(() => _isSaving = true);
                  
                  try {
                    final state = Provider.of<AppState>(context, listen: false);
                    
                    // Handle attachment saving
                    String? finalAttachmentPath = _attachmentPath;
                    if (_attachmentPath != null && _attachmentPath != _originalAttachmentPath) {
                      // A new file was picked, save it properly
                      finalAttachmentPath = await FileStorageService.saveHealthAttachment(_attachmentPath!);
                      
                      // Delete the old one if it existed
                      if (_originalAttachmentPath != null) {
                        await FileStorageService.deleteAttachment(_originalAttachmentPath);
                      }
                    }
                    
                    if (widget.record == null) {
                       await state.addHealthRecord(
                          title: _title,
                          type: _type,
                          date: _selectedDate,
                          details: _notes,
                          attachmentPath: finalAttachmentPath,
                       );
                    } else {
                       final updated = widget.record!.copyWith(
                          title: _title,
                          type: _type,
                          date: _selectedDate,
                          details: _notes,
                          attachmentPath: finalAttachmentPath,
                       );
                       await state.updateHealthRecord(updated);
                    }
                    
                    if (context.mounted) Navigator.pop(context);
                  } finally {
                    if (mounted) {
                      setState(() => _isSaving = false);
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppTheme.orangePrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                  : Text(widget.record == null ? 'Save Record' : 'Update Record'),
            ),
          ],
        ),
      ),
    );
  }
}








