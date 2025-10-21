import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.rating, // Current rating (0-5)
    required this.onRatingChanged, // Callback when user taps a star/changes rating
    this.starSize = 40.0,
  });

  final int rating;
  final Function(int) onRatingChanged;
  final double starSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < rating ? Icons.star : Icons.star_border, // Show filled star if rated and empty if not
            color: Colors.amber,
            size: starSize,
          ),
          onPressed: () {
            final newRating = index + 1; // Star number (1-5)
            if (rating == 1 && newRating == 1) {
              onRatingChanged(0); // Remove all stars if clicked a 1 star to make it 0 star
            } else {
              onRatingChanged(newRating); // Set rating to the clicked star
            }
          },
        );
      }),
    );
  }
}
