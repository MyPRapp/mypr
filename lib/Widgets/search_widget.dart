import 'package:flutter/material.dart';

class SearchWidget extends StatelessWidget {
  const SearchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: TextField(
        //enabled: false,
        style: const TextStyle(
            color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
        cursorColor: Colors.black,
        cursorHeight: 25,
        cursorWidth: 2,
        decoration: InputDecoration(
            isCollapsed: true,
            contentPadding: const EdgeInsets.all(8),
            filled: true,
            hintText: 'Αναζήτηση',
            hintStyle: const TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            )),
      ),
    );
  }
}
