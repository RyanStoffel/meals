import 'package:meals/models/meal.dart';

enum MealTime {
  breakfast,
  lunch,
  dinner,
}

class DayMealPlan {
  const DayMealPlan({
    required this.day,
    this.breakfast,
    this.lunch,
    this.dinner,
  });

  final DateTime day;
  final Meal? breakfast;
  final Meal? lunch;
  final Meal? dinner;

  DayMealPlan copyWith({
    DateTime? day,
    Meal? breakfast,
    Meal? lunch,
    Meal? dinner,
    bool clearBreakfast = false,
    bool clearLunch = false,
    bool clearDinner = false,
  }) {
    return DayMealPlan(
      day: day ?? this.day,
      breakfast: clearBreakfast ? null : (breakfast ?? this.breakfast),
      lunch: clearLunch ? null : (lunch ?? this.lunch),
      dinner: clearDinner ? null : (dinner ?? this.dinner),
    );
  }

  int get mealCount {
    int count = 0;
    if (breakfast != null) count++;
    if (lunch != null) count++;
    if (dinner != null) count++;
    return count;
  }

  bool get isEmpty => mealCount == 0;
  bool get isFull => mealCount == 3;
}
