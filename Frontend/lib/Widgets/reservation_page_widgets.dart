import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mypr/OtherPages/global_state.dart';
import 'package:provider/provider.dart';

class ConfirmationDialog extends StatelessWidget {
  final List<dynamic> reservationInfo;

  const ConfirmationDialog({super.key, required this.reservationInfo});

  @override
  Widget build(BuildContext context) {
    // Format the date to 'dd/MM'
    String formattedDate = '';
    if (reservationInfo[8].isNotEmpty) {
      DateTime date = DateTime.parse(reservationInfo[8]);
      formattedDate = DateFormat('dd/MM').format(date);
    }

    // Format the price to 2 decimal places
    String formattedPrice = reservationInfo[4].toStringAsFixed(2);

    return Center(
      child: Material(
        color: Colors.black.withOpacity(0.8),
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF9C0C04), width: 4),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ευχαριστούμε για την κράτηση!\nΘα λάβετε σύντομα email επιβεβαίωσης.',
                style: TextStyle(
                  color: Color(0xFF9C0C04),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildInfoRow('Όνομα κράτησης:', reservationInfo[1]),
              _buildInfoRow('Μαγαζί:', reservationInfo[2]),
              _buildInfoRow('Αριθμός ατόμων:', reservationInfo[3].toString()),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Φιάλες',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (reservationInfo[5] > 0)
                _buildInfoRow('      Απλή:', reservationInfo[5].toString()),
              if (reservationInfo[6] > 0)
                _buildInfoRow('      Special:', reservationInfo[6].toString()),
              if (reservationInfo[7] > 0)
                _buildInfoRow('      Premium:', reservationInfo[7].toString()),
              _buildInfoRow('Ημερομηνία:', formattedDate),
              if (reservationInfo[9] != '')
                _buildCommentSection(reservationInfo[9]),
              _buildInfoRow('Συνολική Τιμή:', '$formattedPrice €'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9C0C04),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Εντάξει',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
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
      ),
    );
  }

  Widget _buildCommentSection(String comment) {
    return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Σχόλια κράτησης:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._splitCommentIntoLines(
                      comment, 20), // Call the function here
                  const SizedBox(height: 5),
                ],
              )
            ]));
  }

  List<Widget> _splitCommentIntoLines(String comment, int maxLength) {
    List<Widget> lines = [];
    for (int i = 0; i < comment.length; i += maxLength) {
      String part = comment.substring(
          i, i + maxLength > comment.length ? comment.length : i + maxLength);
      lines.add(
        Text(
          part,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      );
    }
    return lines;
  }
}

class CommentSection extends StatelessWidget {
  final TextEditingController commentController;

  const CommentSection({
    super.key,
    required this.commentController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const Text(
          'Σχόλια (Προαιρετικό)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: commentController,
          maxLines: 4,
          inputFormatters: [NoEmojisTextInputFormatter()],
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.2),
            hintText: 'Γράψτε τα σχόλια σας εδώ...',
            hintStyle: const TextStyle(color: Colors.white54),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(15),
          ),
        ),
      ],
    );
  }
}

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

class NameTextField extends StatefulWidget {
  const NameTextField({super.key});

  @override
  State<NameTextField> createState() => NameTextFieldState();
}

class NameTextFieldState extends State<NameTextField> {
  late TextEditingController nameController;
  late FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    final userDetails = context.read<UserProvider>().userDetails;
    nameController = TextEditingController(
      text: '${userDetails?.firstName ?? ''} ${userDetails?.lastName ?? ''}',
    );
    focusNode = FocusNode();
  }

  void _handleTap() {
    focusNode.requestFocus();
    Timer(const Duration(milliseconds: 250), () {
      focusNode.unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AbsorbPointer(
        absorbing: true, // Prevent the user from interacting with the TextField
        child: TextField(
          controller: nameController,
          focusNode: focusNode,
          readOnly: true, // Make the TextField non-editable
          decoration: const InputDecoration(
            labelText: 'Όνομα κράτησης',
            labelStyle: TextStyle(color: Color(0xFF9C0C04)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0x4C9C0C04), width: 4),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF9C0C04), width: 4),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    focusNode.dispose();
    super.dispose();
  }
}

class PersonsTextField extends StatefulWidget {
  final int maxPersons; // Accept maxPersons as an argument
  final Map<String, int> counters; // Passed from ReservationPage
  const PersonsTextField({
    super.key,
    required this.maxPersons,
    required this.counters,
  });

  @override
  PersonsTextFieldState createState() => PersonsTextFieldState();
}

class PersonsTextFieldState extends State<PersonsTextField> {
  int persons = 1; // Initialize your persons value to the minimum of 1
  TextEditingController personsController = TextEditingController();
  FocusNode textFieldFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    personsController.text = persons.toString();
    textFieldFocusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(PersonsTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Adjust persons to ensure it's between 1 and maxPersons
    if (widget.maxPersons < persons) {
      setState(() {
        persons = widget.maxPersons > 0 ? widget.maxPersons : 1;
        personsController.text = persons.toString();
      });
    }
  }

  void _handleFocusChange() {
    if (!textFieldFocusNode.hasFocus && persons > widget.maxPersons) {
      setState(() {
        persons = widget.maxPersons > 0 ? widget.maxPersons : 1;
        personsController.text = persons.toString();
      });
    }
  }

  void increment() {
    if (persons < widget.maxPersons) {
      setState(() {
        persons++;
        personsController.text = persons.toString();
        textFieldFocusNode.requestFocus();
      });
    } else {
      if (widget.counters['Απλή'] == 0 &&
          widget.counters['Special'] == 0 &&
          widget.counters['Premium'] == 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'Παρακαλώ επιλέξτε ένα πακέτο',
          ),
          duration: Duration(seconds: 3),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Μέγιστος αριθμός ατόμων! Για διαφορετικό πακέτο επικοινωνήστε μαζί μας',
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void decrement() {
    if (persons > 1) {
      setState(() {
        persons--;
        personsController.text = persons.toString();
        textFieldFocusNode.requestFocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        focusNode: textFieldFocusNode,
        readOnly: true,
        controller: personsController,
        decoration: InputDecoration(
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
          labelText: 'Αριθμός ατόμων',
          labelStyle: const TextStyle(color: Color(0xFF9C0C04)),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0x4C9C0C04), width: 4),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF9C0C04), width: 4),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    personsController.dispose();
    textFieldFocusNode.removeListener(_handleFocusChange);
    textFieldFocusNode.dispose();
    super.dispose();
  }
}

class CategoriesTextField extends StatefulWidget {
  final CatalogueInfoStruct regularCatalogue;
  final CatalogueInfoStruct specialCatalogue;
  final CatalogueInfoStruct premiumCatalogue;
  final Map<String, int> counters;
  final VoidCallback onCountersChanged;
  final bool isDiscountApplied;
  final int discount;

  const CategoriesTextField({
    super.key,
    required this.regularCatalogue,
    required this.specialCatalogue,
    required this.premiumCatalogue,
    required this.counters,
    required this.onCountersChanged,
    required this.isDiscountApplied,
    required this.discount,
  });

  @override
  CategoriesTextFieldState createState() => CategoriesTextFieldState();
}

class CategoriesTextFieldState extends State<CategoriesTextField>
    with SingleTickerProviderStateMixin {
  int price = 0;
  String selectedText = '';
  TextEditingController priceController = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _heightFactor;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _heightFactor = _controller.drive(CurveTween(curve: Curves.easeInOut));
    updateSelectedText();
  }

  @override
  void didUpdateWidget(CategoriesTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDiscountApplied != widget.isDiscountApplied ||
        oldWidget.discount != widget.discount) {
      updateSelectedText();
    }
  }

  void toggleDropdown() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void increment(String category) {
    setState(() {
      if (widget.counters[category]! < 9) {
        int incrementValue = _getCategoryPrice(category);
        widget.counters[category] = (widget.counters[category] ?? 0) + 1;
        price += incrementValue;
        updateSelectedText();
        widget.onCountersChanged();
      } else {
        // Show SnackBar when the limit is reached
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Για παραπάνω φιάλες παρακαλώ επικοινωνήστε μαζί μας'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    });
  }

  void decrement(String category) {
    setState(() {
      if (widget.counters[category]! > 0) {
        int decrementValue = _getCategoryPrice(category);
        widget.counters[category] = widget.counters[category]! - 1;
        price -= decrementValue;
        updateSelectedText();
        widget.onCountersChanged();
      }
    });
  }

  int _getCategoryPrice(String category) {
    switch (category) {
      case 'Απλή':
        return double.parse(widget.regularCatalogue.price).toInt();
      case 'Special':
        return double.parse(widget.specialCatalogue.price).toInt();
      case 'Premium':
        return double.parse(widget.premiumCatalogue.price).toInt();
      default:
        return 0;
    }
  }

  void updateSelectedText() {
    double finalPrice = price.toDouble();
    if (widget.isDiscountApplied) {
      finalPrice = finalPrice * (1 - (widget.discount / 100));
    }

    if (finalPrice > 0) {
      selectedText = 'Τιμή: ${finalPrice.toStringAsFixed(2)} €';
    } else {
      selectedText = '';
    }
    priceController.text = selectedText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: toggleDropdown,
          child: InputDecorator(
            isFocused: _isExpanded,
            decoration: const InputDecoration(
              suffixIcon: Icon(
                Icons.arrow_drop_down,
                color: Color(0xFF9C0C04),
              ),
              labelText: 'Φιάλες',
              labelStyle: TextStyle(color: Color(0xFF9C0C04)),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color.fromARGB(76, 156, 12, 4),
                  width: 4,
                ),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF9C0C04), width: 4),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color.fromARGB(76, 156, 12, 4),
                  width: 4,
                ),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF9C0C04), width: 4),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
            child: Text(
              selectedText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Visibility(
          visible: _isExpanded,
          child: ClipRect(
            child: SizeTransition(
              sizeFactor: _heightFactor,
              axisAlignment: -1.0,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF9C0C04), width: 4),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: widget.counters.keys.map((key) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              key,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => decrement(key),
                                  icon: const Icon(Icons.remove,
                                      color: Colors.white),
                                ),
                                Text(
                                  widget.counters[key].toString(),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                                IconButton(
                                  onPressed: () => increment(key),
                                  icon: const Icon(Icons.add,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    priceController.dispose();
    super.dispose();
  }
}

class BookingDatePicker extends StatefulWidget {
  const BookingDatePicker({super.key, required this.onDateSelected});

  final ValueChanged<DateTime> onDateSelected;

  @override
  State<BookingDatePicker> createState() => _BookingDatePickerState();
}

class _BookingDatePickerState extends State<BookingDatePicker> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2025),
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: Color(0xFF9C0C04),
                  onPrimary: Colors.white,
                  surface: Colors.black,
                  onSurface: Colors.white,
                ),
                dialogBackgroundColor: Colors.black,
              ),
              child: child!,
            );
          },
        );

        if (pickedDate != null) {
          setState(() {
            _selectedDate = pickedDate;
          });
          widget.onDateSelected(_selectedDate!);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Ημερομηνία κράτησης',
          labelStyle: TextStyle(color: Color(0xFF9C0C04)),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0x4C9C0C04), width: 4),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF9C0C04), width: 4),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        child: Text(
          _selectedDate != null
              ? DateFormat('dd MMMM, yyyy').format(_selectedDate!)
              : 'Επιλέξτε ημερομηνία',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
