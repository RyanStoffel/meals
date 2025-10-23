import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class StarRating extends StatefulWidget {
  const StarRating({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.starSize = 40.0,
  });

  final int rating;
  final Function(int) onRatingChanged;
  final double starSize;

  @override
  State<StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  late ConfettiController _controllerLeft; //animation controllers
  late ConfettiController _controllerRight;
  late ConfettiController _controllerUp;
  late ConfettiController _controllerDown;

  @override
  void initState() {
    super.initState();
    _controllerLeft = ConfettiController(duration: const Duration(seconds: 1));
    _controllerRight = ConfettiController(duration: const Duration(seconds: 1));
    _controllerUp = ConfettiController(duration: const Duration(seconds: 1));
    _controllerDown = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() { //dispose controllers
    _controllerLeft.dispose();
    _controllerRight.dispose();
    _controllerUp.dispose();
    _controllerDown.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Left confetti
        Align(
          alignment: Alignment.centerLeft,
          child: ConfettiWidget(
            confettiController: _controllerLeft,
            blastDirection: 0, // Shoot right
            emissionFrequency: 0.05,
            numberOfParticles: 200,
            gravity: 0.1,
            colors: const [Colors.amber, Colors.orange, Colors.yellow],
          ),
        ),
        // Right confetti
        Align(
          alignment: Alignment.centerRight,
          child: ConfettiWidget(
            confettiController: _controllerRight,
            blastDirection: pi, // Shoot left
            emissionFrequency: 0.05,
            numberOfParticles: 200,
            gravity: 0.1,
            colors: const [Colors.amber, Colors.orange, Colors.yellow],
          ),
        ),
        // Up confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _controllerUp,
            blastDirection: -pi/2,
            emissionFrequency: 0.05,
            numberOfParticles: 200,
            gravity: 0.1,
            colors: const [Colors.amber, Colors.orange, Colors.yellow],
          ),
        ),
        // Down confetti
        Align(
          alignment: Alignment.bottomCenter,
          child: ConfettiWidget(
            confettiController: _controllerDown,
            blastDirection: pi/2, // Shoot left
            emissionFrequency: 0.05,
            numberOfParticles: 200,
            gravity: 0.1,
            colors: const [Colors.amber, Colors.orange, Colors.yellow],
          ),
        ),
        // Star buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < widget.rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: widget.starSize,
              ),
              onPressed: () {
                final newRating = index + 1;
                if (widget.rating == 1 && newRating == 1) {
                  widget.onRatingChanged(0); // goes from 1 star to 0 stars
                } else if (newRating == 5) {
                  // Trigger confettis
                  _controllerLeft.play();
                  _controllerRight.play();
                  _controllerUp.play();
                  _controllerDown.play();
                  widget.onRatingChanged(newRating);
                } else {
                  widget.onRatingChanged(newRating); //sets new rating to what is selected
                }
              },
            );
          }),
        ),
      ],
    );
  }
}
