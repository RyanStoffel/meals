import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:meals/models/meal_plan.dart';
import 'package:meals/providers/meal_plan_provider.dart';
import 'package:meals/screens/meal_selector.dart';

class MealPlannerScreen extends ConsumerWidget {
  const MealPlannerScreen({super.key});

  String _getDayName(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final normalizedDate = DateTime(date.year, date.month, date.day);

    if (normalizedDate == today) return 'Today';
    if (normalizedDate == tomorrow) return 'Tomorrow';
    return DateFormat('EEE').format(date);
  }

  void _selectMealForSlot(
    BuildContext context,
    WidgetRef ref,
    DateTime day,
    MealTime mealTime,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => MealSelectorScreen(
          day: day,
          mealTime: mealTime,
        ),
      ),
    );
  }

  void _showClearDayDialog(BuildContext context, WidgetRef ref, DateTime day) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Clear Day Plan',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Remove all meals planned for ${DateFormat('EEEE, MMM d').format(day)}?',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(mealPlanProvider.notifier).clearDay(day);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Day plan cleared')),
              );
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Clear All Plans',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Remove all planned meals for the entire week?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(mealPlanProvider.notifier).clearAllPlans();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All plans cleared')),
              );
            },
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealPlan = ref.watch(mealPlanProvider);
    final totalMeals = ref.watch(totalPlannedMealsProvider);
    final weekDays = ref.read(mealPlanProvider.notifier).getWeekDays();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Planner'),
        actions: [
          if (totalMeals > 0)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => _showClearAllDialog(context, ref),
              tooltip: 'Clear All',
            ),
        ],
      ),
      body: Column(
        children: [
          // Summary card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Column(
              children: [
                Text(
                  '$totalMeals meals planned',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap any slot to assign a meal',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
              ],
            ),
          ),

          // Week view
          Expanded(
            child: ListView.builder(
              itemCount: weekDays.length,
              itemBuilder: (ctx, index) {
                final day = weekDays[index];
                final dayPlan = mealPlan[day]!;

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: dayPlan.isEmpty
                          ? Theme.of(context).colorScheme.surfaceVariant
                          : Theme.of(context).colorScheme.primary,
                      child: Text(
                        DateFormat('d').format(day),
                        style: TextStyle(
                          color: dayPlan.isEmpty
                              ? Theme.of(context).colorScheme.onSurfaceVariant
                              : Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      '${_getDayName(day)}, ${DateFormat('MMM d').format(day)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${dayPlan.mealCount} meal${dayPlan.mealCount == 1 ? '' : 's'} planned',
                    ),
                    trailing: dayPlan.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () =>
                                _showClearDayDialog(context, ref, day),
                            tooltip: 'Clear day',
                          ),
                    children: [
                      _buildMealSlot(
                        context,
                        ref,
                        day,
                        MealTime.breakfast,
                        'Breakfast',
                        dayPlan.breakfast,
                        Icons.free_breakfast,
                      ),
                      _buildMealSlot(
                        context,
                        ref,
                        day,
                        MealTime.lunch,
                        'Lunch',
                        dayPlan.lunch,
                        Icons.lunch_dining,
                      ),
                      _buildMealSlot(
                        context,
                        ref,
                        day,
                        MealTime.dinner,
                        'Dinner',
                        dayPlan.dinner,
                        Icons.dinner_dining,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealSlot(
    BuildContext context,
    WidgetRef ref,
    DateTime day,
    MealTime mealTime,
    String label,
    dynamic meal,
    IconData icon,
  ) {
    final hasAssignment = meal != null;

    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: hasAssignment
          ? Text(
              meal.title,
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            )
          : const Text('Not planned'),
      trailing: hasAssignment
          ? IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () {
                ref.read(mealPlanProvider.notifier).removeMeal(day, mealTime);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$label removed')),
                );
              },
            )
          : const Icon(Icons.add_circle_outline),
      onTap: () => _selectMealForSlot(context, ref, day, mealTime),
    );
  }
}
