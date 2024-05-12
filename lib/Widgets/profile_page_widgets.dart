import 'package:flutter/material.dart';

class ProfileOptions extends StatelessWidget {
  const ProfileOptions(
      {super.key, required this.label, required this.widgetIcon});

  final String label;
  final ImageIcon widgetIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 10,
      ),
      margin: const EdgeInsets.only(left: 20, right: 20),
      decoration: BoxDecoration(
          border: Border.all(
              color: const Color(
                0xFF9c0c04,
              ),
              width: 5),
          borderRadius: const BorderRadius.all(Radius.circular(5))),
      child: Row(
        children: [
          widgetIcon,
          Text(
            label,
            style: const TextStyle(
                fontSize: 20,
                color: Color(0xFF9c0c04),
                fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}
