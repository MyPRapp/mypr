import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class FadeText extends StatefulWidget {
  const FadeText({super.key, required this.points});

  final int points;

  @override
  FadeTextState createState() => FadeTextState();
}

class FadeTextState extends State<FadeText> {
  bool _isVisible = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Listen for scroll events on the controller
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection !=
          ScrollDirection.idle) {
        _toggleTextVisibility();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleTextVisibility() {
    // Check if it's already visible to avoid triggering again
    if (!_isVisible) {
      setState(() {
        _isVisible = true;
      });

      // Set a timer to automatically hide the text after 4 seconds
      Timer(const Duration(seconds: 1), () {
        setState(() {
          _isVisible = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // AnimatedOpacity for fading effect
        AnimatedOpacity(
          opacity: _isVisible ? 1.0 : 0.0,
          duration: const Duration(seconds: 1), // Fade duration
          child: const Text(
            'Πόντοι:',
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        NumberScrollBox(
            scrollController: _scrollController, points: widget.points),
      ],
    );
  }
}

class NumberScrollBox extends StatelessWidget {
  const NumberScrollBox(
      {super.key, required this.scrollController, required this.points});
  final ScrollController scrollController;
  final int points;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.red[900]!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.7),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController, // Use the scroll controller
            physics: const BouncingScrollPhysics(),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Text(
                  '$points', // Fixed number to display
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileDialog extends StatelessWidget {
  final String name;
  final String email;
  final String phone;

  const ProfileDialog(
      {super.key,
      required this.name,
      required this.email,
      required this.phone});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "ΠΡΟΦΙΛ",
              style: TextStyle(
                color: Color(0xFF9C0C04),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(
              color: Colors.grey,
              thickness: 0.5,
            ),
            const SizedBox(height: 10),
            ProfileInfoRow(label: "Ονοματεπώνυμο", value: name),
            const SizedBox(height: 10),
            ProfileInfoRow(label: "Email", value: email),
            const SizedBox(height: 10),
            ProfileInfoRow(label: "Τηλέφωνο", value: phone),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF9C0C04),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const ProfileInfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$label:",
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class GradientProgressBar extends StatefulWidget {
  final int points;

  const GradientProgressBar({super.key, required this.points});

  @override
  GradientProgressBarState createState() => GradientProgressBarState();
}

class GradientProgressBarState extends State<GradientProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showLabel = false;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0, end: widget.points / 20.toDouble())
        .animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ))
      ..addListener(() {
        setState(() {});
      });

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant GradientProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points != widget.points) {
      // Update the animation end value smoothly
      _animation = Tween<double>(
        begin: 0, // Start from the current animation value
        end: widget.points / 20,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ))
        ..addListener(() {
          setState(() {});
        });

      _controller
        ..reset() // Reset the controller to the beginning
        ..forward(); // Animate forward from 0 to the new end value
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showPercentageLabel() async {
    if (_animation.isCompleted) {
      if (_showLabel == false) {
        setState(() {
          _showLabel = true;
        });
        await Future.delayed(const Duration(seconds: 4));
        setState(() {
          _showLabel = false;
        });
      } else {
        setState(() {
          _showLabel = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double progressWidth = MediaQuery.sizeOf(context).width - 45;
    double filledWidth = (progressWidth * _animation.value) / 100;
    return GestureDetector(
      onTap: _showPercentageLabel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedOpacity(
            opacity: _showLabel ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500), // Fade duration
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text(
                widget.points >= 400
                    ? "Έχεις ένα κουπόνι για 20% έκπτωση"
                    : 'Σε ${400 - widget.points} πόντους κερδίζεις έκπτωση',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top:
                    7.5, // Half the height of the circles to center-align the bar

                child: Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: progressWidth,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        Container(
                          width: filledWidth,
                          height: 10,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              colors: [
                                const Color.fromARGB(255, 87, 1, 1),
                                Colors.red.shade900,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  bool isActive = (_animation.value >= (index * 20));
                  return Column(
                    children: [
                      Container(
                        height: 25,
                        width: 25,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive
                              ? Color.fromARGB(255, (112 + index * 10),
                                  (13 + index), (6 + index))
                              : Colors.grey[800],
                          border: Border.all(
                            color: isActive
                                ? const Color.fromARGB(0, 0, 0, 0)
                                : const Color.fromARGB(255, 0, 0, 0),
                            width: 0,
                          ),
                        ),
                      ),
                      Text(
                        '${index * 20}%',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      )
                    ],
                  );
                }),
              ),
            ],
          )
        ],
      ),
    );
  }
}
