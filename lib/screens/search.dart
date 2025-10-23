import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meals/models/meal.dart';
import 'package:meals/providers/filters_provider.dart';
import 'package:meals/screens/filters.dart';
import 'package:meals/screens/meal_details.dart';
import 'package:meals/widgets/meal_item.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  void _selectMeal(BuildContext context, Meal meal) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => MealDetailsScreen(
          meal: meal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredMeals = _getFilteredMeals();
    final activeFilters = ref.watch(filtersProvider);

    final activeFiltersCount = activeFilters.values.where((isActive) => isActive).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Meals'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white), // Add this line!
              decoration: InputDecoration(
                hintText: 'Search by meal name or ingredient...',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.6), // Optional: style the hint text too
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.white), // Optional: white icon
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white), // Optional: white clear icon
                        onPressed: () {
                          _searchController.clear();
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
          if (activeFiltersCount > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Row(children: [
                Icon(
                  Icons.filter_alt,
                  size: 18,
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                const SizedBox(width: 8,),
                Text(
                  '$activeFiltersCount dietary filter(s) active',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const Spacer(),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const FiltersScreen(),
                        ),
                      );
                    },
                    child: const Text('Manage Filters'),
                  ),
              ],
              )
            ),
            Expanded(
              child: _buildResultsWidget(filteredMeals),
            ),
        ],
      ),
    );
  }

  Widget _buildResultsWidget(List<Meal> meals) {
    if (_searchQuery.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16,),
            Text(
              'Start typing to search meals',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 8,),
            Text(
              'Search by meal name or ingredient',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
              ),
            )
          ],
        ),
      );
    }
    // Show no results message
    if (meals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No meals found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                  ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Found ${meals.length} meal${meals.length == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: meals.length,
            itemBuilder: (ctx, index) => MealItem(
              meal: meals[index],
              onSelectMeal: (meal) => _selectMeal(context, meal),
            ),
          ),
        ),
      ],
    );
  }
}