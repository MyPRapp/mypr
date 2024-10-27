import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mypr/Globals/constants.dart';

class FadeText extends StatelessWidget {
  const FadeText(this.isVisible, this.text, {super.key});

  final bool isVisible;
  final String text;

  @override
  Widget build(BuildContext context) {
    return
        // AnimatedOpacity for fading effect
        AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(seconds: 1), // Fade duration
      child: Text(
        text,
        style: TextStyle(
            color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w600),
      ),
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
    double screenWidth = ScreenUtil().screenWidth;
    return Column(
      children: [
        Container(
          width: screenWidth * 0.15,
          height: 50.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color.fromARGB(255, 0, 0, 0), appRedColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: SingleChildScrollView(
            controller: scrollController, // Use the scroll controller
            physics: const BouncingScrollPhysics(),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15.h),
                child: Text(
                  '$points', // Fixed number to display
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
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
        borderRadius: BorderRadius.circular(10.r),
      ),
      backgroundColor: Colors.grey[900],
      child: Padding(
        padding: EdgeInsets.all(MediaQuery.sizeOf(context).width * 0.03),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "ΠΡΟΦΙΛ",
              style: TextStyle(
                color: appRedColor,
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 20.h),
            Divider(
              color: Colors.grey,
              thickness: 1.sp,
            ),
            SizedBox(height: 10.h),
            ProfileInfoRow(label: "Ονοματεπώνυμο", value: name),
            SizedBox(height: 10.h),
            ProfileInfoRow(label: "Email", value: email),
            SizedBox(height: 10.h),
            ProfileInfoRow(label: "Τηλέφωνο", value: phone),
            SizedBox(height: 20.h),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF9C0C04),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Κλείσιμο",
                style: TextStyle(fontSize: 14.sp),
              ),
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
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 10.h),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
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
  final bool isVisible;
  final bool restartAnimation;

  const GradientProgressBar(
      {super.key,
      required this.points,
      required this.isVisible,
      required this.restartAnimation});

  @override
  GradientProgressBarState createState() => GradientProgressBarState();
}

class GradientProgressBarState extends State<GradientProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool restartAnimation = false;
  bool _showLabel = false;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(
            begin: 0, end: widget.points <= 2000 ? widget.points / 20 : 100)
        .animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ))
      ..addListener(() async {
        if (mounted) {
          setState(() {});
        }
        if (_animation.isCompleted && mounted) {
          setState(() {
            _showLabel = true;
          });
          await Future.delayed(const Duration(seconds: 4));
          if (mounted) {
            setState(() {
              _showLabel = false;
            });
          }
        }
      });

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant GradientProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points != widget.points || widget.restartAnimation) {
      _animation = Tween<double>(
        begin: 0,
        end: widget.points <= 2000 ? widget.points / 20 : 100,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ))
        ..addListener(() {
          if (mounted) {
            setState(() {});
          }
        });

      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = ScreenUtil().screenWidth;
    double progressWidth = 280.w;
    double filledWidth = (progressWidth * _animation.value) / 100;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: progressWidth,
                          height: 7.5.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        Container(
                          width: filledWidth,
                          height: 7.5.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 85, 1, 1),
                                Color.fromARGB(255, 194, 5, 5),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  width: progressWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      bool isActive = (_animation.value >= (index * 20));
                      return Container(
                        height: 15.h,
                        width: 12.5.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive
                              ? Color.fromARGB(
                                  255, (80 + index * 20), (13), (6))
                              : Colors.grey[800],
                          border: Border.all(
                            color: isActive
                                ? const Color.fromARGB(0, 0, 0, 0)
                                : const Color.fromARGB(255, 0, 0, 0),
                            width: 1.sp,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(
              left: (screenWidth - progressWidth) / 2,
              right: (screenWidth - progressWidth) / 2.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(6, (index) {
              return Text(
                textAlign: TextAlign.center,
                '${index * 20}%',
                style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600),
              );
            }),
          ),
        ),
        SizedBox(height: 12.h),
        FadeText(
          (_showLabel || widget.isVisible) && _animation.isCompleted,
          widget.points >= 400
              ? "Έχεις ένα κουπόνι για 20% έκπτωση"
              : 'Σε ${400 - widget.points} πόντους κερδίζεις έκπτωση',
        ),
      ],
    );
  }
}
