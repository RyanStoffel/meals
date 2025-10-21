import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart'; // package for persistent storage

class RatingsNotifier extends StateNotifier<Map<String, int>> {
  RatingsNotifier() : super({}) {
    _loadRatings(); // Load saved ratings when app starts
  }

  // Load all ratings from device storage
  Future<void> _loadRatings() async {
    final prefs = await SharedPreferences.getInstance();// accesing storage
    final keys = prefs.getKeys();
    final ratingsMap = <String, int>{};
    
    for (final key in keys) {
      if (key.startsWith('rating_')) {
        final mealId = key.substring(7); // Remove rating_ prefix to get Id
        ratingsMap[mealId] = prefs.getInt(key) ?? 0;
      }
    }
    
    state = ratingsMap;
  }

  // Save a rating for a meal (persists to storage)
  Future<void> setRating(String mealId, int rating) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('rating_$mealId', rating); // Saves meal ID and rating device as rating_meal1234
    state = {...state, mealId: rating}; // Update app state using spread
  }

  // Get rating for a meal by taking in mealId, return 0 if not rated
  int getRating(String mealId) {
    return state[mealId] ?? 0;
  }
}

// Provider to access ratings throughout the app
final ratingsProvider = StateNotifierProvider<RatingsNotifier, Map<String, int>>((ref) {
  return RatingsNotifier();
});
