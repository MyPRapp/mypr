// ignore_for_file: library_private_types_in_public_api

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
  const GlowingPulseDot({super.key, required this.height});

  final double height;

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
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1, end: 1.4).animate(_controller);
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
              width: 12.5.w,
              height: widget.height,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red, // Use grey or red depending on your theme
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.7), // Glow effect
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

class AnimatedButton extends StatefulWidget {
  const AnimatedButton({super.key});

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller!, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller?.forward(),
      onTapUp: (_) => _controller?.reverse(),
      onTapCancel: () => _controller?.reverse(),
      child: ScaleTransition(
        scale: _animation,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
          ),
          child: Text('Tap Me',
              style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

class InteractiveProgressBar extends StatefulWidget {
  const InteractiveProgressBar({super.key});

  @override
  _InteractiveProgressBarState createState() => _InteractiveProgressBarState();
}

class _InteractiveProgressBarState extends State<InteractiveProgressBar> {
  double _progress = 0.0;

  void _updateProgress(double newProgress) {
    setState(() {
      _progress = newProgress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        double newProgress =
            details.localPosition.dx / MediaQuery.of(context).size.width;
        newProgress = newProgress.clamp(0.0, 1.0);
        _updateProgress(newProgress);
      },
      child: Container(
        width: double.infinity,
        height: 10,
        decoration: BoxDecoration(
            color: Colors.grey[300], borderRadius: BorderRadius.circular(5)),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: MediaQuery.of(context).size.width * _progress,
            decoration: BoxDecoration(
                color: Colors.blue, borderRadius: BorderRadius.circular(5)),
          ),
        ),
      ),
    );
  }
}

class AnimatedIconWidget extends StatefulWidget {
  const AnimatedIconWidget({super.key});

  @override
  _AnimatedIconWidgetState createState() => _AnimatedIconWidgetState();
}

class _AnimatedIconWidgetState extends State<AnimatedIconWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 40,
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_close,
        progress: _controller,
      ),
      onPressed: () {
        setState(() {
          _controller.isCompleted
              ? _controller.reverse()
              : _controller.forward();
        });
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class PulsingGlow extends StatefulWidget {
  const PulsingGlow({super.key});

  @override
  _PulsingGlowState createState() => _PulsingGlowState();
}

class _PulsingGlowState extends State<PulsingGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1))
          ..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.8, end: 1.2)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue.withOpacity(0.7),
          boxShadow: [
            BoxShadow(color: Colors.blueAccent, blurRadius: 10, spreadRadius: 5)
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class RotatingIcon extends StatefulWidget {
  const RotatingIcon({super.key});

  @override
  _RotatingIconState createState() => _RotatingIconState();
}

class _RotatingIconState extends State<RotatingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2))
          ..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Icon(Icons.refresh, size: 40, color: Colors.deepPurple),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class BouncingButton extends StatefulWidget {
  const BouncingButton({super.key});

  @override
  _BouncingButtonState createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<BouncingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _animation = Tween<double>(begin: 1.0, end: 1.2)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _animation,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('Press Me',
              style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class HeartbeatIcon extends StatefulWidget {
  const HeartbeatIcon({super.key});

  @override
  _HeartbeatIconState createState() => _HeartbeatIconState();
}

class _HeartbeatIconState extends State<HeartbeatIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..repeat(reverse: true);
    _animation = Tween<double>(begin: 1.0, end: 1.2)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Icon(Icons.favorite, color: Colors.red, size: 40),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class ExpandingCircle extends StatefulWidget {
  const ExpandingCircle({super.key});

  @override
  _ExpandingCircleState createState() => _ExpandingCircleState();
}

class _ExpandingCircleState extends State<ExpandingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2))
          ..repeat(reverse: true);
    _animation = Tween<double>(begin: 50, end: 70)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: _animation.value,
          height: _animation.value,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class FlashingText extends StatefulWidget {
  const FlashingText({super.key});

  @override
  _FlashingTextState createState() => _FlashingTextState();
}

class _FlashingTextState extends State<FlashingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800))
          ..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Text(
        'Flashing Text',
        style: TextStyle(
            color: Colors.yellow, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class SlidingBox extends StatefulWidget {
  const SlidingBox({super.key});

  @override
  _SlidingBoxState createState() => _SlidingBoxState();
}

class _SlidingBoxState extends State<SlidingBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1))
          ..repeat(reverse: true);
    _animation = Tween<Offset>(begin: Offset(-0.1, 0), end: Offset(0.1, 0))
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: Container(
        width: 40,
        height: 40,
        color: Colors.purple,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class RotatingGradientCircle extends StatefulWidget {
  const RotatingGradientCircle({super.key});

  @override
  _RotatingGradientCircleState createState() => _RotatingGradientCircleState();
}

class _RotatingGradientCircleState extends State<RotatingGradientCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 5))
          ..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.pink, Colors.purple, Colors.cyan],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class BouncingBall extends StatefulWidget {
  const BouncingBall({super.key});

  @override
  _BouncingBallState createState() => _BouncingBallState();
}

class _BouncingBallState extends State<BouncingBall>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800))
          ..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 10)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_animation.value),
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class ColorChangingBox extends StatefulWidget {
  const ColorChangingBox({super.key});

  @override
  _ColorChangingBoxState createState() => _ColorChangingBoxState();
}

class _ColorChangingBoxState extends State<ColorChangingBox> {
  Color _boxColor = Colors.blue;

  void _changeColor() {
    setState(() {
      _boxColor = _boxColor == Colors.blue ? Colors.red : Colors.blue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _changeColor,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: 60,
        height: 60,
        color: _boxColor,
      ),
    );
  }
}

class RotatingStar extends StatefulWidget {
  const RotatingStar({super.key});

  @override
  _RotatingStarState createState() => _RotatingStarState();
}

class _RotatingStarState extends State<RotatingStar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
  }

  void _rotateStar() {
    if (_controller.isAnimating) return;
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _rotateStar,
      child: RotationTransition(
        turns: _controller,
        child: Icon(
          Icons.star,
          color: Colors.yellow,
          size: 40,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class PulsingHeart extends StatefulWidget {
  const PulsingHeart({super.key});

  @override
  _PulsingHeartState createState() => _PulsingHeartState();
}

class _PulsingHeartState extends State<PulsingHeart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 1.0, end: 1.5).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  void _pulseHeart() {
    _controller.forward().then((_) => _controller.reverse());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _pulseHeart,
      child: ScaleTransition(
        scale: _animation,
        child: Icon(
          Icons.favorite,
          color: Colors.pink,
          size: 40,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
