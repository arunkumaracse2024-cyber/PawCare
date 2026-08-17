import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_theme.dart';
import '../../../state/app_state.dart';
import '../../../models/pet.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  String _selectedCategory = 'All';

  void _showAddEditItemDialog(BuildContext context, {ChecklistItem? item}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.6,
        child: AddEditChecklistSheet(item: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (state.selectedPet == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Milestone Checklist')),
        body: const Center(child: Text('Please select or add a pet first.')),
      );
    }

    final pet = state.selectedPet!;
    final checklist = pet.checklist;
    
    // Dynamic categories
    final Set<String> categorySet = {'All'};
    for (var item in checklist) {
       categorySet.add(item.category);
    }
    final List<String> categories = categorySet.toList();
    if (!categories.contains(_selectedCategory)) {
       _selectedCategory = 'All'; // fallback if deleted
    }

    // Progress
    final total = checklist.length;
    final completed = checklist.where((c) => c.isDone).length;
    final double percent = total > 0 ? (completed / total) : 0.0;

    // Filter
    final filteredList = _selectedCategory == 'All' 
       ? checklist 
       : checklist.where((c) => c.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('${pet.name}\'s Milestones'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditItemDialog(context),
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('Add Task'),
        backgroundColor: AppTheme.tealSecondary,
      ),
      body: Column(
        children: [
          // Header Progress Indicator
          Container(
            padding: const EdgeInsets.all(20),
            color: isDark
                ? const Color(0xFF252525)
                : Colors.amber.withValues(alpha: 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Prep Checklist Completed',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${(percent * 100).toInt()}%',
                      style: const TextStyle(
                        color: AppTheme.tealSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 10,
                    backgroundColor: isDark
                        ? const Color(0xFF444444)
                        : Colors.white,
                    color: AppTheme.tealSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Dynamic Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: categories.map((c) {
                final isSelected = _selectedCategory == c;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(c),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCategory = c);
                    },
                    selectedColor: AppTheme.tealSecondary.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.tealSecondary : (isDark ? Colors.white70 : Colors.black87),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          const Divider(height: 1),

          // List
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Text(
                      'No tasks in this category.',
                      style: TextStyle(color: isDark ? Colors.white54 : Colors.grey.shade600),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      final isSystem = item.id.startsWith('sys_');

                      return Dismissible(
                        key: Key(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_outline, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          state.deleteChecklistItem(item.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Task deleted')),
                          );
                        },
                        child: Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: item.isDone
                                  ? AppTheme.tealSecondary.withValues(alpha: 0.5)
                                  : isDark
                                      ? const Color(0xFF444444)
                                      : const Color(0xFFEBE3D5),
                            ),
                          ),
                          color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: InkWell(
                              onTap: () {
                                state.toggleChecklistItem(item.id, !item.isDone);
                              },
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: item.isDone
                                        ? AppTheme.tealSecondary
                                        : Colors.grey.shade400,
                                    width: 2,
                                  ),
                                  color: item.isDone
                                      ? AppTheme.tealSecondary
                                      : Colors.transparent,
                                ),
                                child: item.isDone
                                    ? const Icon(Icons.check,
                                        size: 18, color: Colors.white)
                                    : null,
                              ),
                            ),
                            title: Text(
                              item.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: item.isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: item.isDone ? Colors.grey : null,
                              ),
                            ),
                            subtitle: Row(
                               children: [
                                  Text(
                                    item.category,
                                    style: TextStyle(
                                      color: isDark ? Colors.white60 : Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (isSystem)
                                     Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                           color: Colors.blueAccent.withValues(alpha: 0.1),
                                           borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text('Guide', style: TextStyle(fontSize: 10, color: Colors.blueAccent)),
                                     )
                                  else 
                                     Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                           color: Colors.purpleAccent.withValues(alpha: 0.1),
                                           borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text('Custom', style: TextStyle(fontSize: 10, color: Colors.purpleAccent)),
                                     )
                               ],
                            ),
                            trailing: IconButton(
                               icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey),
                               onPressed: () => _showAddEditItemDialog(context, item: item),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class AddEditChecklistSheet extends StatefulWidget {
  final ChecklistItem? item;
  const AddEditChecklistSheet({super.key, this.item});

  @override
  State<AddEditChecklistSheet> createState() => _AddEditChecklistSheetState();
}

class _AddEditChecklistSheetState extends State<AddEditChecklistSheet> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _category = 'Custom';

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _title = widget.item!.title;
      _category = widget.item!.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context, listen: false);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
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
              Text(
                widget.item == null ? 'New Task' : 'Edit Task',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 20),

              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  prefixIcon: Icon(Icons.check_box_outlined),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter a title' : null,
                onSaved: (v) => _title = v?.trim() ?? '',
              ),
              const SizedBox(height: 16),

              TextFormField(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter a category' : null,
                onSaved: (v) => _category = v?.trim() ?? '',
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  _formKey.currentState!.save();

                  if (widget.item == null) {
                     final newItem = ChecklistItem(
                        id: 'cus_${DateTime.now().millisecondsSinceEpoch}',
                        title: _title,
                        category: _category,
                        isDone: false,
                     );
                     await state.addChecklistItem(newItem);
                  } else {
                     final updated = widget.item!.copyWith(
                        title: _title,
                        category: _category,
                     );
                     await state.updateChecklistItem(updated);
                  }

                  if (context.mounted) Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.tealSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(widget.item == null ? 'Add Task' : 'Update Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


