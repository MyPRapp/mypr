import 'package:flutter/material.dart';

class PackagesInfo extends StatelessWidget {
  const PackagesInfo({
    super.key,
    required this.package,
    required this.maxPersons,
    required this.minPrice,
  });

  final String package;
  final int maxPersons;
  final int minPrice;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Card(
        color: const Color(0xFF9c0c04),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      package,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$maxPersons άτομα',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$minPrice €',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String errorText;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Color(0xFF9C0C04)),
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Color.fromARGB(76, 156, 12, 4),
              width: 4,
            ),
            borderRadius: BorderRadius.all(Radius.circular(8))),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF9C0C04), width: 4),
            borderRadius: BorderRadius.all(Radius.circular(8))),
        errorBorder: const OutlineInputBorder(
            borderSide:
                BorderSide(color: Color.fromARGB(76, 156, 12, 4), width: 4),
            borderRadius: BorderRadius.all(Radius.circular(8))),
        focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF9C0C04), width: 4),
            borderRadius: BorderRadius.all(Radius.circular(8))),
      ),
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return errorText;
        }
        return null;
      },
    );
  }
}

class CustomInputDecoration {
  static InputDecoration getDecoration({
    required void Function() increment,
    required void Function() decrement,
    required String hintText,
    required bool isCounterValid,
  }) {
    return InputDecoration(
      suffix: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: decrement,
            icon: const Icon(Icons.remove, color: Colors.white),
          ),
          IconButton(
            onPressed: increment,
            icon: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white, fontSize: 16),
      labelText: 'Αριθμός ατόμων',
      labelStyle: const TextStyle(color: Color(0xFF9C0C04)),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(
          color: Color.fromARGB(76, 156, 12, 4),
          width: 4,
        ),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF9C0C04), width: 4),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(
          color: Color.fromARGB(76, 156, 12, 4),
          width: 4,
        ),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF9C0C04), width: 4),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      errorText: isCounterValid ? null : 'Εισάγετε αριθμό ατόμων',
    );
  }
}
