import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PulsingBorder extends StatefulWidget {
  final Widget child;

  const PulsingBorder({super.key, required this.child});

  @override
  PulsingBorderState createState() => PulsingBorderState();
}

class PulsingBorderState extends State<PulsingBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.red.withOpacity(_controller.value), // Grey or Red
              width: 2.0,
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

class FadingGradientLine extends StatelessWidget {
  final bool isHorizontal;

  const FadingGradientLine({super.key, this.isHorizontal = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isHorizontal ? double.infinity : 4,
      height: isHorizontal ? 4 : double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.withOpacity(0.0),
            Colors.red.withOpacity(0.8),
            Colors.red.withOpacity(0.0),
          ],
          begin: isHorizontal ? Alignment.centerLeft : Alignment.topCenter,
          end: isHorizontal ? Alignment.centerRight : Alignment.bottomCenter,
        ),
      ),
    );
  }
}

class GlowingPulseDot extends StatefulWidget {
  const GlowingPulseDot({super.key});

  @override
  GlowingPulseDotState createState() => GlowingPulseDotState();
}

class GlowingPulseDotState extends State<GlowingPulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: _animation.value,
            child: Container(
              width: 10.w,
              height: 10.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red, // Use grey or red depending on your theme
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.5), // Glow effect
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class RotatingIconButton extends StatefulWidget {
  final IconData icon;

  const RotatingIconButton({super.key, this.icon = Icons.play_arrow});

  @override
  RotatingIconButtonState createState() => RotatingIconButtonState();
}

class RotatingIconButtonState extends State<RotatingIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _rotateIcon() {
    if (_controller.isDismissed) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _rotateIcon,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2.0 * 3.1416, // Full circle rotation
            child: Icon(
              widget.icon,
              color: Colors.red, // or grey depending on your theme
              size: 40.0,
            ),
          );
        },
      ),
    );
  }
}

class SlidingSwitch extends StatefulWidget {
  const SlidingSwitch({super.key});

  @override
  SlidingSwitchState createState() => SlidingSwitchState();
}

class SlidingSwitchState extends State<SlidingSwitch> {
  bool isOn = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isOn = !isOn;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 40.0,
        width: 10.w,
        decoration: BoxDecoration(
          color: isOn
              ? Colors.red
              : Colors.grey[800], // Switch between red and grey
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeIn,
              left: isOn ? 10.0 : 0.0,
              right: isOn ? 0.0 : 10.0,
              child: Container(
                height: 40.0,
                width: 10.w,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RippleButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const RippleButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.red.withOpacity(0.4),
        highlightColor: Colors.red.withOpacity(0.2),
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: Colors.red, // or grey for different themes
              width: 2.0,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white, // Adjust text color based on the theme
                fontSize: 16.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ExpandingCard extends StatefulWidget {
  final String title;
  final String description;

  const ExpandingCard(
      {super.key, required this.title, required this.description});

  @override
  ExpandingCardState createState() => ExpandingCardState();
}

class ExpandingCardState extends State<ExpandingCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: isExpanded ? 150.0 : 80.0,
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.grey[900], // or black/red based on the theme
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              spreadRadius: 2.0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ),
            ),
            if (isExpanded) const SizedBox(height: 10.0),
            if (isExpanded)
              Text(
                widget.description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14.0,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ColorPickerRing extends StatefulWidget {
  const ColorPickerRing({super.key});

  @override
  ColorPickerRingState createState() => ColorPickerRingState();
}

class ColorPickerRingState extends State<ColorPickerRing> {
  double hueValue = 0.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          hueValue += details.delta.dx;
          if (hueValue > 360) hueValue = 360;
          if (hueValue < 0) hueValue = 0;
        });
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(
            colors: [
              Colors.red,
              Colors.red.shade700,
              Colors.grey,
              Colors.grey.shade700,
            ],
          ),
        ),
        child: Center(
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: HSVColor.fromAHSV(1, hueValue, 1, 1).toColor(),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
