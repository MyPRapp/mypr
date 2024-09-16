import 'package:flutter/material.dart';

class InteractiveRatingStars extends StatefulWidget {
  final double initialStars; // Initial stars value (if already rated)
  final ValueChanged<double> onRatingChanged;

  const InteractiveRatingStars({
    super.key,
    required this.initialStars,
    required this.onRatingChanged,
  });

  @override
  InteractiveRatingStarsState createState() => InteractiveRatingStarsState();
}

class InteractiveRatingStarsState extends State<InteractiveRatingStars> {
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialStars > 0 ? widget.initialStars : 0;
  }

  void _onStarTapped(int index) {
    setState(() {
      _currentRating = index.toDouble();
    });
    widget.onRatingChanged(_currentRating);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        return IconButton(
          onPressed: () => _onStarTapped(index + 1),
          icon: Icon(
            _currentRating >= index + 1
                ? Icons.star
                : Icons.star_border_outlined,
            size: 30,
            color: _currentRating >= index + 1
                ? const Color(0xFF9C0C04)
                : Colors.white30,
          ),
        );
      }),
    );
  }
}

class InteractiveNameAndStars extends StatefulWidget {
  final String clubName;
  final double initialStars;

  const InteractiveNameAndStars({
    super.key,
    required this.clubName,
    required this.initialStars,
  });

  @override
  InteractiveNameAndStarsState createState() => InteractiveNameAndStarsState();
}

class InteractiveNameAndStarsState extends State<InteractiveNameAndStars> {
  double _currentStars = 0;
  bool _isThankYouMessageVisible = false;

  @override
  void initState() {
    super.initState();
    _currentStars = widget.initialStars;
  }

  void _handleRatingChanged(double newRating) {
    setState(() {
      _currentStars = newRating;
      _isThankYouMessageVisible = true;
    });

    // Hide the thank you message after 2 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _isThankYouMessageVisible = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.clubName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9C0C04),
              ),
              textAlign: TextAlign.start,
            ),
            InteractiveRatingStars(
              initialStars: _currentStars,
              onRatingChanged: _handleRatingChanged,
            ),
          ],
        ),
        if (_isThankYouMessageVisible)
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              'Ευχαριστούμε που μοιράστηκες την γνώμη σου.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
      ],
    );
  }
}
