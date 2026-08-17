import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../services/todo_merge_engine.dart';
import '../../theme/app_theme.dart';

class TodoFeedScreen extends StatelessWidget {
  const TodoFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pet = state.selectedPet;

    return Scaffold(
      appBar: AppBar(
        title: Text(pet != null ? "${pet.name}'s Care Checklist" : "Merged Care Feed"),
      ),
      body: pet == null
          ? const Center(child: Text("Please add a pet to view care items."))
          : state.mergedTodoFeed.isEmpty
              ? const Center(child: Text("All care items complete!"))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: state.mergedTodoFeed.length,
                  itemBuilder: (context, index) {
                    final item = state.mergedTodoFeed[index];
                    return _buildTodoCard(context, state, item, isDark, theme);
                  },
                ),
    );
  }

  Widget _buildTodoCard(
    BuildContext context,
    AppState state,
    MergedTodoItem item,
    bool isDark,
    ThemeData theme,
  ) {
    // Icon mapping
    IconData getIcon() {
      switch (item.category.toLowerCase()) {
        case 'vaccination':
          return Icons.vaccines_rounded;
        case 'feeding':
          return Icons.restaurant_rounded;
        case 'grooming':
          return Icons.content_cut_rounded;
        case 'medicine':
          return Icons.medication_rounded;
        case 'checkup':
        default:
          return Icons.health_and_safety_rounded;
      }
    }

    // Source color mapping
    Color getSourceColor() {
      switch (item.source) {
        case 'vet':
          return Colors.purple;
        case 'shop':
          return AppTheme.tealSecondary;
        case 'breedStandard':
        default:
          return AppTheme.orangePrimary;
      }
    }

    final isOverdue = item.date.isBefore(DateTime.now()) && !item.isDone;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: item.isSatisfied ? 0 : 2,
      color: item.isSatisfied
          ? (isDark ? const Color(0xFF222222) : Colors.grey.shade100)
          : (isDark ? const Color(0xFF2A2A2A) : Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: item.isSatisfied
              ? Colors.transparent
              : getSourceColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Category Icon
                CircleAvatar(
                  backgroundColor: getSourceColor().withValues(alpha: 0.12),
                  child: Icon(getIcon(), color: getSourceColor()),
                ),
                const SizedBox(width: 12),
                // Title and timeline
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: item.isSatisfied ? TextDecoration.lineThrough : null,
                          color: item.isSatisfied
                              ? Colors.grey
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Category: ${item.category.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white38 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                // Source badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: getSourceColor().withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.sourceLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: getSourceColor(),
                    ),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(),
            ),
            Text(
              item.description,
              style: TextStyle(
                fontSize: 14,
                color: item.isSatisfied
                    ? Colors.grey
                    : (isDark ? Colors.white70 : Colors.black54),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isOverdue ? "Overdue milestone!" : "Due: ${item.date.day}/${item.date.month}/${item.date.year}",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                    color: isOverdue ? Colors.redAccent : Colors.grey,
                  ),
                ),
                if (item.isSatisfied)
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        "Satisfied by ${item.supersededByTitle}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  )
                else
                  Checkbox(
                    value: item.isDone,
                    activeColor: getSourceColor(),
                    onChanged: (val) {
                      if (val != null) {
                        // Mark as done
                        // If it's a breed standard checklist item, toggle standard checklist
                        if (item.source == 'breedStandard') {
                          state.toggleChecklistItem(item.id, val);
                        } else if (item.source == 'shop') {
                          // Update shop note status
                          // Since shop notes are stored in pet model
                          final pet = state.selectedPet!;
                          final updatedShopNotes = pet.shopNotes.map((note) {
                            if (note.id == item.id) {
                              return note.copyWith(isResolved: val);
                            }
                            return note;
                          }).toList();
                          state.updatePet(pet.copyWith(shopNotes: updatedShopNotes));
                        } else if (item.source == 'vet') {
                          // Update vet instruction note status
                          state.updateAppointmentStatus(item.id, 'completed', postVisitNotes: item.description, category: item.category, instructionTitle: item.title);
                        }
                        state.refreshState();
                      }
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

