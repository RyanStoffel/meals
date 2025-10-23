import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:meals/models/meal.dart';
import 'package:meals/models/meal_plan.dart';
import 'package:meals/providers/filters_provider.dart';
import 'package:meals/providers/meal_plan_provider.dart';
import 'package:meals/widgets/meal_item.dart';
import 'package:meals/screens/meal_details.dart';

class MealSelectorScreen extends ConsumerStatefulWidget {
  const MealSelectorScreen({
    super.key,
    required this.day,
    required this.mealTime,
  });

  final DateTime day;
  final MealTime mealTime;

  @override
  ConsumerState<MealSelectorScreen> createState() => _MealSelectorScreenState();
}

class _MealSelectorScreenState extends ConsumerState<MealSelectorScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getMealTimeLabel() {
    if (widget.mealTime == MealTime.breakfast) {
      return 'Breakfast';
    } else if (widget.mealTime == MealTime.lunch) {
      return 'Lunch';
    } else {
      return 'Dinner';
    }
  }

  List<Meal> _getFilteredMeals() {
    final availableMeals = ref.watch(filteredMealsProvider);

    if (_searchQuery.isEmpty) {
      return availableMeals;
    }

    return availableMeals.where((meal) {
      final titleMatch = meal.title.toLowerCase().contains(_searchQuery);
      final ingredientMatch = meal.ingredients.any(
        (ingredient) => ingredient.toLowerCase().contains(_searchQuery),
      );
      return titleMatch || ingredientMatch;
    }).toList();
  }

  void _assignMeal(Meal meal) {
    ref.read(mealPlanProvider.notifier).assignMeal(
          widget.day,
          widget.mealTime,
          meal,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${meal.title} added to ${_getMealTimeLabel()} on ${DateFormat('MMM d').format(widget.day)}',
        ),
      ),
    );

    Navigator.of(context).pop();
  }

  void _viewMealDetails(Meal meal) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => MealDetailsScreen(meal: meal),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredMeals = _getFilteredMeals();

    return Scaffold(
      appBar: AppBar(
        title: Text('Select ${_getMealTimeLabel()}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              decoration: InputDecoration(
                hintText: 'Search meals...',
                hintStyle: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimaryContainer
                      .withOpacity(0.6),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color:
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tap a meal to assign, long press to view details',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                ),
              ],
            ),
          ),

          // Meal list
          Expanded(
            child: filteredMeals.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No meals found',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredMeals.length,
                    itemBuilder: (ctx, index) {
                      final meal = filteredMeals[index];
                      return InkWell(
                        onTap: () => _assignMeal(meal),
                        onLongPress: () => _viewMealDetails(meal),
                        child: MealItem(
                          meal: meal,
                          onSelectMeal: (_) => _assignMeal(meal),
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
