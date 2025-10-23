import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:meals/models/meal.dart';
import 'package:meals/models/meal_plan.dart';

class MealPlanNotifier extends StateNotifier<Map<DateTime, DayMealPlan>> {
  MealPlanNotifier() : super({}) {
    _initializeWeek();
  }

  void _initializeWeek() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Initialize 7 days starting from today
    final newState = <DateTime, DayMealPlan>{};
    for (int i = 0; i < 7; i++) {
      final day = today.add(Duration(days: i));
      newState[day] = DayMealPlan(day: day);
    }
    state = newState;
  }

  void assignMeal(DateTime day, MealTime mealTime, Meal meal) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final currentPlan = state[normalizedDay] ?? DayMealPlan(day: normalizedDay);

    DayMealPlan updatedPlan;
    if (mealTime == MealTime.breakfast) {
      updatedPlan = currentPlan.copyWith(breakfast: meal);
    } else if (mealTime == MealTime.lunch) {
      updatedPlan = currentPlan.copyWith(lunch: meal);
    } else {
      updatedPlan = currentPlan.copyWith(dinner: meal);
    }

    state = {...state, normalizedDay: updatedPlan};
  }

  void removeMeal(DateTime day, MealTime mealTime) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final currentPlan = state[normalizedDay];

    if (currentPlan == null) return;

    DayMealPlan updatedPlan;
    if (mealTime == MealTime.breakfast) {
      updatedPlan = currentPlan.copyWith(clearBreakfast: true);
    } else if (mealTime == MealTime.lunch) {
      updatedPlan = currentPlan.copyWith(clearLunch: true);
    } else {
      updatedPlan = currentPlan.copyWith(clearDinner: true);
    }

    state = {...state, normalizedDay: updatedPlan};
  }

  void clearDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    state = {
      ...state,
      normalizedDay: DayMealPlan(day: normalizedDay),
    };
  }

  void clearAllPlans() {
    _initializeWeek();
  }

  int getTotalMealCount() {
    return state.values.fold(0, (sum, dayPlan) => sum + dayPlan.mealCount);
  }

  List<DateTime> getWeekDays() {
    final days = state.keys.toList();
    days.sort();
    return days;
  }
}

final mealPlanProvider =
    StateNotifierProvider<MealPlanNotifier, Map<DateTime, DayMealPlan>>((ref) {
  return MealPlanNotifier();
});

// Convenience provider to get total meal count
final totalPlannedMealsProvider = Provider<int>((ref) {
  final mealPlan = ref.watch(mealPlanProvider);
  return mealPlan.values.fold(0, (sum, dayPlan) => sum + dayPlan.mealCount);
});
