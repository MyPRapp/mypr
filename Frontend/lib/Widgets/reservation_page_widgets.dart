import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Globals/global_components.dart';
import '../Globals/structs.dart';
import '../Providers/reservation_provider.dart';
import '../Providers/user_provider.dart';
import '../services/auth_service.dart';
import '../services/points_service.dart';

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
              buildInfoRow('Όνομα κράτησης:',
                  context.read<ReservationProvider>().reservationInfo[1]),
              buildInfoRow('Μαγαζί:', reservationInfo[2]),
              buildInfoRow('Αριθμός ατόμων:', reservationInfo[3].toString()),
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
                buildInfoRow('      Απλή:', reservationInfo[5].toString()),
              if (reservationInfo[6] > 0)
                buildInfoRow('      Special:', reservationInfo[6].toString()),
              if (reservationInfo[7] > 0)
                buildInfoRow('      Premium:', reservationInfo[7].toString()),
              buildInfoRow('Ημερομηνία:', formattedDate),
              if (reservationInfo[9].isNotEmpty)
                _buildCommentSection(reservationInfo[9]),
              buildInfoRow('Συνολική Τιμή:', '$formattedPrice €'),
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
        color: const Color.fromARGB(179, 85, 85, 85),
        elevation: 10,
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
  const NameTextField({super.key, required this.nameController});
  final TextEditingController nameController;

  @override
  State<NameTextField> createState() => NameTextFieldState();
}

class NameTextFieldState extends State<NameTextField> {
  late FocusNode focusNode;

  @override
  void initState() {
    super.initState();

    focusNode = FocusNode();

    // Listen to focus changes and update the provider when focus is lost
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        _updateReservationProvider();
      }
    });
  }

  void _updateReservationProvider() {
    // Update the provider with the formatted name when the focus is lost
    String formattedName = formatName(widget.nameController.text);
    if (formattedName.isEmpty) {
      final userDetails = context.read<UserProvider>().userDetails;
      formattedName = '${userDetails.firstName} ${userDetails.lastName}';
    }
    context.read<ReservationProvider>().setInfo(1, formattedName);
    widget.nameController.text = formattedName;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: TextField(
        controller: widget.nameController,
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
      ),
    );
  }

  @override
  void dispose() {
    // Remove the listener when the widget is disposed
    focusNode.dispose();
    super.dispose();
  }
}

class PersonsTextField extends StatefulWidget {
  const PersonsTextField({super.key});

  @override
  State<PersonsTextField> createState() => _PersonsTextFieldState();
}

class _PersonsTextFieldState extends State<PersonsTextField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    final reservationProvider = Provider.of<ReservationProvider>(context);
    final maxPersons = reservationProvider.maxPersons;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        focusNode: _focusNode,
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
      onPressed: () async {
        _focusNode.requestFocus();
        int persons = reservationProvider.getInfo(3);
        if (persons > 1) {
          reservationProvider.setInfo(3, persons - 1);
        }
        await Future.delayed(const Duration(milliseconds: 2500));
        _focusNode.unfocus();
      },
      icon: const Icon(Icons.remove, color: Colors.white),
    );
  }

  Widget _buildAddButton(ReservationProvider reservationProvider,
      int maxPersons, BuildContext context) {
    return IconButton(
      onPressed: () async {
        _focusNode.requestFocus();
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
          await Future.delayed(const Duration(milliseconds: 2500));
          _focusNode.unfocus();
        } else {
          await Future.delayed(const Duration(milliseconds: 1000));
          _focusNode.unfocus();
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

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    _focusNode.dispose();

    super.dispose();
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
      int regularBottles = reservationProvider.getInfo(5);
      int specialBottles = reservationProvider.getInfo(6);
      int premiumBottles = reservationProvider.getInfo(7);

      if (discount > 0) {
        if (regularBottles >= 1) {
          price += (safeParse(widget.regularCatalogue.price) * discount) / 100;
        } else if (specialBottles >= 1) {
          price += (safeParse(widget.specialCatalogue.price) * discount) / 100;
        } else if (premiumBottles >= 1) {
          price += (safeParse(widget.premiumCatalogue.price) * discount) / 100;
        }
      }
      setState(() {
        priceController.text = '${(price).toStringAsFixed(2)} €';
      });
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
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            toggleDropdown();
          },
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
        Padding(
          padding: const EdgeInsets.only(bottom: 25),
          child: Visibility(
            visible: _isExpanded,
            child: ClipRect(
              child: SizeTransition(
                sizeFactor: _heightFactor,
                axisAlignment: -1.0,
                child: Container(
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: const Color(0xFF9C0C04), width: 4),
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
          '❌Invalid unavailableDays format: Each month must be paired with a day.');
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
            '❌Invalid unavailableDays data: Unable to parse month/day at index $i');
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
        FocusManager.instance.primaryFocus?.unfocus();
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
      child: Padding(
        padding: const EdgeInsets.only(bottom: 25),
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
      ),
    );
  }
}

CatalogueInfoStruct createCatalogue(String serviceType) {
  return CatalogueInfoStruct(
    clubID: -1,
    serviceType: serviceType,
    price: '0',
    maxPersons: 0,
  );
}

String formatDate(String date) {
  if (date.isNotEmpty) {
    return DateFormat('dd/MM').format(DateTime.parse(date));
  }
  return '';
}

/// Safely parses a string to a double, returning 0.0 if the string is invalid.
double safeParse(String value) {
  return double.tryParse(value) ?? 0.0;
}

Widget buildInfoRow(String label, String value) {
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
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

/// Safely retracts points for the discount and updates the provider.
Future<void> retractPoints(int pointsToRetract) async {
  try {
    await AuthService()
        .refreshAccessToken(); // Ensure token is valid before retracting points
    await PointsService().retractPoints(pointsToRetract);
  } catch (error) {
    print("❌Failed to retract points: $error");
  }
}

class LocationWidget extends StatelessWidget {
  final String locationName;

  const LocationWidget({super.key, required this.locationName});

  Future<void> _openLocation() async {
    final Uri googleMapsUri = Uri.parse('comgooglemaps://?q=$locationName');
    final Uri appleMapsUri =
        Uri.parse('http://maps.apple.com/?q=$locationName');
    final Uri browserUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$locationName');

    try {
      if (await canLaunchUrl(googleMapsUri)) {
        await launchUrl(googleMapsUri);
      } else if (await canLaunchUrl(appleMapsUri)) {
        await launchUrl(appleMapsUri);
      } else {
        await launchUrl(browserUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print("Could not open maps: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openLocation,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 68, 68, 68),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.white),
            const SizedBox(width: 8.0),
            Text(
              locationName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkingDays extends StatelessWidget {
  final String schedule; // Example: "1101010"

  const WorkingDays({super.key, required this.schedule})
      : assert(
            schedule.length == 7, 'Schedule string must be 7 characters long.');

  @override
  Widget build(BuildContext context) {
    // Greek letters for days of the week starting from Monday
    final List<String> days = ['Δ', 'T', 'T', 'Π', 'Π', 'Σ', 'Κ'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        bool isOpen = schedule[index] == '1';
        return Text(
          days[index],
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: isOpen ? FontWeight.bold : FontWeight.w600,
            color: isOpen ? Colors.grey : Colors.black,
          ),
        );
      }),
    );
  }
}

class EmailConfirmationNotification extends StatelessWidget {
  final VoidCallback onResendEmail;

  const EmailConfirmationNotification({super.key, required this.onResendEmail});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            color: const Color.fromARGB(255, 255, 187, 0),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Για να προχωρήσεις σε κράτηση παρακαλώ επιβεβαίωσε το email σου',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onResendEmail,
                  child: const Text(
                    'Επαναποστολή',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
