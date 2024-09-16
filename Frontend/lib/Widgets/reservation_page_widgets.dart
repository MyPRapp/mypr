import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../Providers/reservation_provider.dart';
import '../Providers/user_provider.dart';
import '../global_components.dart';

class ReservationReview extends StatelessWidget {
  const ReservationReview({super.key});

  @override
  Widget build(BuildContext context) {
    List<dynamic> reservationInfo =
        context.read<ReservationProvider>().reservationInfo;
    // Format the date and price
    String date = context.read<ReservationProvider>().reservationInfo[8];
    final price = context.read<ReservationProvider>().reservationInfo[4];

    final formattedDate = _formatDate(date);
    final formattedPrice = price.toStringAsFixed(2);

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
                'Ευχαριστούμε για την κράτηση!\nΘα λάβεις σύντομα email επιβεβαίωσης.',
                style: TextStyle(
                  color: Color(0xFF9C0C04),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildInfoRow('Όνομα κράτησης:',
                  context.read<ReservationProvider>().reservationInfo[1]),
              _buildInfoRow('Μαγαζί:', reservationInfo[2]),
              _buildInfoRow('Αριθμός ατόμων:', reservationInfo[3].toString()),
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
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
              if (reservationInfo[9].isNotEmpty)
                _buildCommentSection(reservationInfo[9]),
              _buildInfoRow('Συνολική Τιμή:', '$formattedPrice €'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Close the confirmation dialog and return `true` as a result
                  Navigator.pop(context,
                      true); // Notify ReservationPage that the button was pressed
                },
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

  String _formatDate(String date) {
    if (date.isNotEmpty) {
      return DateFormat('dd/MM').format(DateTime.parse(date));
    }
    return '';
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
            children: _splitCommentIntoLines(comment, 20),
          ),
        ],
      ),
    );
  }

  List<Widget> _splitCommentIntoLines(String comment, int maxLength) {
    return List<Widget>.generate(
      (comment.length / maxLength).ceil(),
      (i) => Text(
        comment.substring(i * maxLength,
            (i * maxLength + maxLength).clamp(0, comment.length)),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
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
          maxLength: 200,
          maxLines: 4,
          inputFormatters: [
            AllowSpacesNoEmojisTextInputFormatter(),
            MaxLinesAndLengthFormatter(maxLines: 4, maxLength: 200),
          ],
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.2),
            hintText: 'Γράψε τα σχόλια σου εδώ...',
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

class MaxLinesAndLengthFormatter extends TextInputFormatter {
  final int maxLines;
  final int maxLength;

  MaxLinesAndLengthFormatter({required this.maxLines, required this.maxLength});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Limit by character count
    if (newValue.text.length > maxLength) {
      return oldValue;
    }

    // Limit by line count
    int lines = '\n'.allMatches(newValue.text).length + 1;
    if (lines > maxLines) {
      return oldValue;
    }

    return newValue;
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
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Card(
        color: const Color(0xFF9c0c04),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPackageDetails(),
              _buildPriceDetails(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackageDetails() {
    return Expanded(
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
    );
  }

  Widget _buildPriceDetails() {
    return Expanded(
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
  late ReservationProvider reservationProvider;

  @override
  void initState() {
    super.initState();

    // Access the provider
    reservationProvider = context.read<ReservationProvider>();

    // Initialize the text controller with the user's name from the provider
    final userDetails = context.read<UserProvider>().userDetails;
    String initialName =
        '${userDetails?.firstName ?? ''} ${userDetails?.lastName ?? ''}';

    // Set the initial name in the provider if not already set
    if (reservationProvider.getInfo(1).isEmpty) {
      // Directly set the provider's info without calling setState
      WidgetsBinding.instance.addPostFrameCallback((_) {
        reservationProvider.setInfo(1, formatName(initialName));
        nameController.text = formatName(initialName);
      });
    }

    nameController = TextEditingController(
      text: reservationProvider.getInfo(1),
    );

    focusNode = FocusNode();

    // Listen to focus changes and update the provider when focus is lost
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        _updateReservationProvider();
      }
    });

    // Listen to changes in the reservation info for the name (index 1)
    reservationProvider.addListener(_updateTextController);
  }

  /// Method to set the text in the TextField
  void setNameText(String name) {
    nameController.text = name;
    _updateReservationProvider();
  }

  @override
  void dispose() {
    nameController.dispose();
    focusNode.dispose();
    reservationProvider.removeListener(_updateTextController);
    super.dispose();
  }

  void _updateReservationProvider() {
    // Update the provider with the formatted name when the focus is lost
    String formattedName = formatName(nameController.text);
    if (formattedName.isEmpty) {
      final userDetails = context.read<UserProvider>().userDetails;
      formattedName =
          '${userDetails?.firstName ?? ''} ${userDetails?.lastName ?? ''}';
    }
    reservationProvider.setInfo(1, formattedName);
    nameController.text = formattedName;
  }

  void _updateTextController() {
    // Update the text controller if the name in the provider changes externally
    String currentName = reservationProvider.getInfo(1);
    if (nameController.text != currentName) {
      nameController.text = currentName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: nameController,
      focusNode: focusNode,
      inputFormatters: [AllowSpacesNoEmojisTextInputFormatter()],
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
    );
  }
}

class PersonsTextField extends StatelessWidget {
  const PersonsTextField({super.key});

  @override
  Widget build(BuildContext context) {
    final reservationProvider = Provider.of<ReservationProvider>(context);
    final maxPersons = reservationProvider.maxPersons;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        readOnly: true,
        controller: TextEditingController(
            text: reservationProvider
                .getInfo(3)
                .toString()), // Persons at index 3
        decoration: InputDecoration(
          suffix: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRemoveButton(reservationProvider),
              _buildAddButton(reservationProvider, maxPersons, context),
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

  Widget _buildRemoveButton(ReservationProvider reservationProvider) {
    return IconButton(
      onPressed: () {
        int persons = reservationProvider.getInfo(3);
        if (persons > 1) {
          reservationProvider.setInfo(3, persons - 1);
        }
      },
      icon: const Icon(Icons.remove, color: Colors.white),
    );
  }

  Widget _buildAddButton(ReservationProvider reservationProvider,
      int maxPersons, BuildContext context) {
    return IconButton(
      onPressed: () {
        if (_validateBeforeAdding(reservationProvider, context)) {
          int persons = reservationProvider.getInfo(3);
          if (persons < maxPersons) {
            reservationProvider.setInfo(3, persons + 1);
          } else if (persons == maxPersons) {
            floatingSnackBar(
                message:
                    'Μέγιστος αριθμός ατόμων. Για διαφορετικό πακέτο επικοινώνησε μαζί μας.',
                context: context,
                duration: const Duration(milliseconds: 3000));
          }
        }
      },
      icon: const Icon(Icons.add, color: Colors.white),
    );
  }

  bool _validateBeforeAdding(
      ReservationProvider reservationProvider, BuildContext context) {
    if (reservationProvider.getInfo(5) == 0 &&
        reservationProvider.getInfo(6) == 0 &&
        reservationProvider.getInfo(7) == 0) {
      floatingSnackBar(
          message: 'Παρακαλώ επίλεξε φιάλη πρώτα',
          context: context,
          duration: const Duration(milliseconds: 3000));
      return false;
    }
    return true;
  }
}

class CategoriesTextField extends StatefulWidget {
  final CatalogueInfoStruct regularCatalogue;
  final CatalogueInfoStruct specialCatalogue;
  final CatalogueInfoStruct premiumCatalogue;
  final VoidCallback onCountersChanged;

  const CategoriesTextField({
    super.key,
    required this.regularCatalogue,
    required this.specialCatalogue,
    required this.premiumCatalogue,
    required this.onCountersChanged,
  });

  @override
  CategoriesTextFieldState createState() => CategoriesTextFieldState();
}

class CategoriesTextFieldState extends State<CategoriesTextField>
    with SingleTickerProviderStateMixin {
  late TextEditingController priceController;
  late AnimationController _controller;
  late Animation<double> _heightFactor;
  late ReservationProvider reservationProvider;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    priceController = TextEditingController();

    // Set up the animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _heightFactor = _controller.drive(CurveTween(curve: Curves.easeInOut));

    // Access the provider directly and store it
    reservationProvider = context.read<ReservationProvider>();

    // Listen to changes in reservationInfo[4] (price) and update the text controller
    reservationProvider.addListener(_updatePriceText);
    _updatePriceText(); // Initial update
  }

  @override
  void dispose() {
    // Safely remove the listener before calling super.dispose
    reservationProvider.removeListener(_updatePriceText);
    _controller.dispose();
    priceController.dispose();
    super.dispose();
  }

  void _updatePriceText() {
    if (mounted) {
      double price = reservationProvider.getInfo(4);
      int discount = reservationProvider.getInfo(10);
      if (discount <= 0) {
        setState(() {
          priceController.text = '${price.toStringAsFixed(2)} €';
        });
      } else {
        setState(() {
          priceController.text =
              '${(price / (1 - (discount / 100))).toStringAsFixed(2)} €';
        });
      }
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

  void increment(int index) {
    if (reservationProvider.reservationInfo[index] < 9) {
      setState(() {
        reservationProvider.reservationInfo[index]++;
        widget.onCountersChanged();
      });
    } else {
      floatingSnackBar(
          message: 'Για παραπάνω φιάλες παρακαλώ επικοινώνησε μαζί μας.',
          context: context,
          duration: const Duration(milliseconds: 3000));
    }
  }

  void decrement(int index) {
    if (reservationProvider.reservationInfo[index] > 0) {
      setState(() {
        reservationProvider.reservationInfo[index]--;
        widget.onCountersChanged();
      });
    }
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
            ),
            child: priceText(),
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
                    children: [
                      buildCounterRow('Απλή', 5),
                      buildCounterRow('Special', 6),
                      buildCounterRow('Premium', 7),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildCounterRow(String label, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => decrement(index),
                icon: const Icon(Icons.remove, color: Colors.white),
              ),
              Text(
                reservationProvider.reservationInfo[index].toString(),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              IconButton(
                onPressed: () => increment(index),
                icon: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget priceText() {
    if (reservationProvider.getInfo(4) > 0) {
      return Row(
        children: [
          const Text(
            'Τιμή: ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          reservationProvider.getInfo(10) <= 0
              ? Text(
                  priceController.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                )
              : Row(
                  children: [
                    Text(
                      priceController.text,
                      style: const TextStyle(
                          color: Color(0xFF9C0C04),
                          decoration: TextDecoration.lineThrough,
                          decorationColor: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.w800),
                    ),
                    Text(
                      ' ${reservationProvider.getInfo(4).toStringAsFixed(2)} €',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                )
        ],
      );
    } else {
      return Text(
        'Τιμή: ${priceController.text}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      );
    }
  }
}

class BookingDatePicker extends StatefulWidget {
  const BookingDatePicker(
      {super.key, required this.days, required this.unavailableDays});

  final String days;
  final String unavailableDays;

  @override
  State<BookingDatePicker> createState() => _BookingDatePickerState();
}

class _BookingDatePickerState extends State<BookingDatePicker> {
  DateTime? _selectedDate;

  bool _isDayOpen(DateTime date) {
    int dayIndex = date.weekday - 1; // Monday = 0, Sunday = 6

    // Ensure that `days` has a valid value for each day (if not, consider it closed)
    if (widget.days.isEmpty || dayIndex >= widget.days.length) {
      return false; // If no info about the day, mark as unavailable
    }

    // Check if the day is open (represented as '1')
    return widget.days[dayIndex] == '1';
  }

  bool _isDateUnavailable(DateTime date) {
    // Clean the unavailableDays string by removing any extra characters (spaces, parentheses)
    String cleanedUnavailableDays = widget.unavailableDays
        .replaceAll(RegExp(r'[() ]'), '') // Remove parentheses and spaces
        .replaceAll(' ', ''); // Ensure no stray spaces

    // If there are no unavailable days, return false
    if (cleanedUnavailableDays.isEmpty) {
      return false;
    }

    // Split the cleaned string into pairs of "month,day"
    List<String> unavailablePairs = cleanedUnavailableDays.split(',');

    // Ensure we have pairs of month and day
    if (unavailablePairs.length % 2 != 0) {
      print(
          'Invalid unavailableDays format: Each month must be paired with a day.');
      return false;
    }

    // Iterate over pairs (every two values: month, day)
    for (int i = 0; i < unavailablePairs.length; i += 2) {
      try {
        int unavailableDay = int.parse(unavailablePairs[i]);
        int unavailableMonth = int.parse(unavailablePairs[i + 1]);

        // If the date matches the unavailable day, return true
        if (date.day == unavailableDay && date.month == unavailableMonth) {
          return true;
        }
      } catch (e) {
        print(
            'Invalid unavailableDays data: Unable to parse month/day at index $i');
        return false;
      }
    }

    return false;
  }

  bool _isDaySelectable(DateTime date) {
    // Check if the day is open and not marked as unavailable
    return _isDayOpen(date) && !_isDateUnavailable(date);
  }

  DateTime _findNextOpenDay(DateTime date) {
    // Ensure the initial date is an open and available day
    while (!_isDaySelectable(date)) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        print(widget.unavailableDays);
        final now = DateTime.now();
        final lastDate = now.add(const Duration(days: 30));

        // Find the next open day if today is closed or unavailable
        final initialDate = _selectedDate ?? _findNextOpenDay(now);

        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: now,
          lastDate: lastDate,
          selectableDayPredicate:
              _isDaySelectable, // Only allow selectable days
          locale: const Locale('el', 'GR'), // Set the locale to Greek
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
                textTheme: const TextTheme(
                  bodySmall: TextStyle(
                    fontSize: 16, // Adjust font size to make year smaller
                  ),
                ),
              ),
              child: child!,
            );
          },
        );

        if (pickedDate != null) {
          setState(() {
            _selectedDate = pickedDate;
          });

          if (context.mounted) {
            // Update the selected date in the ReservationProvider
            context
                .read<ReservationProvider>()
                .setInfo(8, _selectedDate.toString());
          }
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
              ? DateFormat('dd MMMM, yyyy', 'el')
                  .format(_selectedDate!) // Greek format
              : 'Επίλεξε ημερομηνία',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
