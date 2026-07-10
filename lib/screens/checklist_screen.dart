import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state.dart';
import '../../models/pet.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _categories = ['All', 'Day 1', 'Week 1', 'Month 1'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    final total = checklist.length;
    final completed = checklist.where((c) => c.isDone).length;
    final double percent = total > 0 ? (completed / total) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('${pet.name}\'s Milestones'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.tealSecondary,
          labelColor: AppTheme.tealDark,
          unselectedLabelColor: isDark ? Colors.white60 : Colors.black45,
          tabs: _categories.map((c) => Tab(text: c)).toList(),
        ),
      ),
      body: Column(
        children: [
          // Header Progress Indicator
          Container(
            padding: const EdgeInsets.all(20),
            color: isDark
                ? const Color(0xFF252525)
                : Colors.amber.withOpacity(0.08),
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
                        : Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.tealSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _categories.map((category) {
                final filteredItems = category == 'All'
                    ? checklist
                    : checklist
                          .where(
                            (c) =>
                                c.category.toLowerCase() ==
                                category.toLowerCase(),
                          )
                          .toList();

                if (filteredItems.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 64,
                            color: AppTheme.tealSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No items registered for "$category"',
                            style: TextStyle(
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];

                    return AnimatedChecklistItemTile(
                      key: ValueKey(item.id),
                      item: item,
                      onChanged: (val) {
                        state.toggleChecklistItem(item.id, val);
                      },
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedChecklistItemTile extends StatefulWidget {
  final ChecklistItem item;
  final ValueChanged<bool> onChanged;

  const AnimatedChecklistItemTile({
    super.key,
    required this.item,
    required this.onChanged,
  });

  @override
  State<AnimatedChecklistItemTile> createState() =>
      _AnimatedChecklistItemTileState();
}

class _AnimatedChecklistItemTileState extends State<AnimatedChecklistItemTile> {
  late bool _checked;

  @override
  void initState() {
    super.initState();
    _checked = widget.item.isDone;
  }

  @override
  void didUpdateWidget(covariant AnimatedChecklistItemTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.isDone != widget.item.isDone) {
      setState(() {
        _checked = widget.item.isDone;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _checked
              ? AppTheme.tealSecondary.withOpacity(0.3)
              : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: GestureDetector(
          onTap: () {
            setState(() {
              _checked = !_checked;
            });
            widget.onChanged(_checked);
          },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: _checked
                ? const Icon(
                    Icons.check_circle_rounded,
                    color: AppTheme.tealSecondary,
                    size: 28,
                    key: ValueKey('icon_checked'),
                  )
                : Icon(
                    Icons.circle_outlined,
                    color: isDark ? Colors.white30 : Colors.grey.shade400,
                    size: 28,
                    key: ValueKey('icon_unchecked'),
                  ),
          ),
        ),
        title: Text(
          widget.item.title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            decoration: _checked ? TextDecoration.lineThrough : null,
            color: _checked
                ? (isDark ? Colors.white38 : Colors.black38)
                : (isDark ? Colors.white : Colors.black.withOpacity(0.85)),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _checked
                ? Colors.grey.withOpacity(0.1)
                : AppTheme.orangePrimary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.item.category,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _checked ? Colors.grey : AppTheme.orangeDeep,
            ),
          ),
        ),
      ),
    );
  }
}
