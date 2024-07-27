import 'package:flutter/material.dart';

class ProfileOptions extends StatelessWidget {
  const ProfileOptions(
      {super.key, required this.label, required this.widgetIcon});

  final String label;
  final ImageIcon widgetIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      margin: const EdgeInsets.only(left: 50, right: 50),
      decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF9c0c04), width: 7),
          borderRadius: const BorderRadius.all(Radius.circular(5))),
      child: Row(children: [
        SizedBox(height: 40, child: widgetIcon),
        Text(label,
            style: const TextStyle(
                fontSize: 20,
                color: Color(0xFF9c0c04),
                fontWeight: FontWeight.bold))
      ]),
    );
  }
}
