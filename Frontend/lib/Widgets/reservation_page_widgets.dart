import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mypr/Globals/constants.dart';
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
          padding: EdgeInsets.all(15.sp),
          margin: EdgeInsets.symmetric(horizontal: 25.w),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(color: appRedColor, width: 4),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ευχαριστούμε για την κράτηση!\nΘα λάβεις σύντομα email επιβεβαίωσης.',
                style: TextStyle(
                  color: appRedColor,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.h),
              buildInfoRow('Όνομα κράτησης:',
                  context.read<ReservationProvider>().reservationInfo[1]),
              buildInfoRow('Μαγαζί:', reservationInfo[2]),
              buildInfoRow('Άτομα:', reservationInfo[3].toString()),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.015),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Φιάλες',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                  ),
                ),
              ),
              if (reservationInfo[5] > 0)
                buildInfoRow('      Απλές:', reservationInfo[5].toString()),
              if (reservationInfo[6] > 0)
                buildInfoRow('      Special:', reservationInfo[6].toString()),
              if (reservationInfo[7] > 0)
                buildInfoRow('      Premium:', reservationInfo[7].toString()),
              buildInfoRow('Ημερομηνία:', formattedDate),
              if (reservationInfo[9].isNotEmpty)
                _buildCommentSection(reservationInfo[9]),
              buildInfoRow('Συνολική Τιμή:', '$formattedPrice €'),
              SizedBox(height: 4.h),
              ElevatedButton(
                onPressed: () {
                  // Close the confirmation dialog and return `true` as a result
                  Navigator.pop(context,
                      true); // Notify ReservationPage that the button was pressed
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: appRedColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Εντάξει',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
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
      padding: EdgeInsets.only(top: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Σχόλια κράτησης:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
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
        style: TextStyle(
          color: Colors.white,
          fontSize: 14.sp,
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
        Text(
          'Σχόλια (Προαιρετικό)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 10.h),
        TextField(
          controller: commentController,
          maxLength: 200,
          maxLines: 4,
          inputFormatters: [
            AllowSpacesNoEmojisTextInputFormatter(),
            MaxLinesAndLengthFormatter(maxLines: 4, maxLength: 200),
          ],
          style: TextStyle(color: Colors.white, fontSize: 13.sp),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.2),
            hintText: 'Γράψε τα σχόλια σου εδώ...',
            hintStyle: TextStyle(color: Colors.white54, fontSize: 13.sp),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.all(10.sp),
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

// class PackagesInfo extends StatelessWidget {
//   const PackagesInfo({
//     super.key,
//     required this.package,
//     required this.maxPersons,
//     required this.minPrice,
//   });

//   final String package;
//   final int maxPersons;
//   final int minPrice;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 15.h),
//       child: Card(
//         color: const Color.fromARGB(179, 85, 85, 85),
//         elevation: 10,
//         child: Padding(
//           padding: EdgeInsets.all(10.sp),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _buildPackageDetails(),
//               _buildPriceDetails(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// Widget _buildPackageDetails() {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       Text(
//         widget.package,
//         style: TextStyle(
//           fontSize: 18.sp,
//           fontWeight: FontWeight.w700,
//           color: Colors.black,
//         ),
//       ),
//       SizedBox(height: 5.sp),
//       Text(
//         '${widget.maxPersons} άτομα',
//         style: TextStyle(
//           fontSize: 16.sp,
//           fontWeight: FontWeight.w500,
//           color: Colors.black,
//         ),
//       ),
//     ],
//   );
// }

// Widget _buildPriceDetails() {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.end,
//     children: [
//       Text(
//         '${widget.minPrice} €',
//         style: TextStyle(
//           fontSize: 18.sp,
//           fontWeight: FontWeight.w700,
//           color: Colors.black,
//         ),
//       ),
//     ],
//   );
// }

class PackagesInfo extends StatefulWidget {
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
  PackagesInfoState createState() => PackagesInfoState();
}

class PackagesInfoState extends State<PackagesInfo> {
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
        duration: const Duration(milliseconds: 600),
        height: isExpanded ? 100.h : 60.h,
        width: double.infinity,
        curve: Curves.easeInOut,
        padding: EdgeInsets.only(top: 10.sp, left: 10.sp, right: 10.sp),
        decoration: BoxDecoration(
          color: const Color.fromARGB(179, 85, 85, 85), // Dark grey background
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.sp,
              spreadRadius: 2.sp,
            ),
          ],
        ),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.package,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  size: 25.sp,
                  color: const Color.fromARGB(255, 0, 0, 0),
                )
              ],
            ),
            SizedBox(height: 5.h),
            // Delay rendering of expanded content
            if (isExpanded)
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        '${widget.maxPersons} άτομα', // Display max persons
                        style: TextStyle(
                            color: const Color.fromARGB(255, 17, 17, 17),
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.only(right: 5.sp),
                        child: Text(
                          '${widget.minPrice} €', // Display price
                          style: TextStyle(
                              color: const Color.fromARGB(255, 17, 17, 17),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
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
    return TextField(
      controller: widget.nameController,
      focusNode: focusNode,
      inputFormatters: [AllowSpacesNoEmojisTextInputFormatter()],
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(10.sp),
        labelText: 'Όνομα κράτησης',
        labelStyle: TextStyle(color: appRedColor, fontSize: 14.sp),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0x4C9C0C04), width: 4),
          borderRadius: BorderRadius.all(Radius.circular(8.r)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: appRedColor, width: 4),
          borderRadius: BorderRadius.all(Radius.circular(8.r)),
        ),
      ),
      style: TextStyle(color: Colors.white, fontSize: 14.sp),
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

    return TextField(
      focusNode: _focusNode,
      readOnly: true,
      controller: TextEditingController(
          text:
              '  ${reservationProvider.getInfo(3).toString()}'), // Persons at index 3
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(10.sp),
        suffix: SizedBox(
          height: 30.h,
          width: 50.w, // Reduce width here
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min, // Let Row take minimum width needed
            children: [
              Flexible(child: _buildRemoveButton(reservationProvider)),
              SizedBox(height: 30.h, width: 5.w),
              Flexible(
                  child: _buildAddButton(
                      reservationProvider, maxPersons, context)),
            ],
          ),
        ),
        labelText: 'Αριθμός ατόμων',
        labelStyle: TextStyle(color: appRedColor, fontSize: 14.sp),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0x4C9C0C04), width: 4),
          borderRadius: BorderRadius.all(Radius.circular(8.r)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: appRedColor, width: 4),
          borderRadius: BorderRadius.all(Radius.circular(8.r)),
        ),
      ),
      style: TextStyle(color: Colors.white, fontSize: 14.sp),
    );
  }

  Widget _buildRemoveButton(ReservationProvider reservationProvider) {
    return SizedBox(
      height: 30.h, // Reduce height for buttons

      child: IconButton(
        onPressed: () async {
          _focusNode.requestFocus();
          int persons = reservationProvider.getInfo(3);
          if (persons > 1) {
            reservationProvider.setInfo(3, persons - 1);
          }
          await Future.delayed(const Duration(milliseconds: 2500));
          _focusNode.unfocus();
        },
        icon: Icon(Icons.remove, color: Colors.white, size: 15.sp),
      ),
    );
  }

  Widget _buildAddButton(ReservationProvider reservationProvider,
      int maxPersons, BuildContext context) {
    return SizedBox(
      height: 30.h, // Reduce height for buttons
      child: IconButton(
        onPressed: () async {
          _focusNode.requestFocus();
          if (_validateBeforeAdding(reservationProvider, context)) {
            int persons = reservationProvider.getInfo(3);
            if (persons < maxPersons) {
              reservationProvider.setInfo(3, persons + 1);
            } else if (persons == maxPersons) {
              showFloatingSnackBar(
                  'Μέγιστος αριθμός ατόμων. Για διαφορετικό πακέτο επικοινώνησε μαζί μας.',
                  const Duration(milliseconds: 3000),
                  context);
            }
            await Future.delayed(const Duration(milliseconds: 2500));
            _focusNode.unfocus();
          } else {
            await Future.delayed(const Duration(milliseconds: 1000));
            _focusNode.unfocus();
          }
        },
        icon: Icon(Icons.add, color: Colors.white, size: 15.sp),
      ),
    );
  }

  bool _validateBeforeAdding(
      ReservationProvider reservationProvider, BuildContext context) {
    if (reservationProvider.getInfo(5) == 0 &&
        reservationProvider.getInfo(6) == 0 &&
        reservationProvider.getInfo(7) == 0) {
      showFloatingSnackBar('Παρακαλώ επίλεξε φιάλη πρώτα',
          const Duration(milliseconds: 4000), context);
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
      showFloatingSnackBar(
          'Για παραπάνω φιάλες παρακαλώ επικοινώνησε μαζί μας.',
          const Duration(milliseconds: 4000),
          context);
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
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10.sp),
              suffixIcon: Padding(
                padding: EdgeInsets.only(right: 5.w),
                child: Icon(
                  Icons.arrow_drop_down,
                  color: appRedColor,
                  size: 20.sp,
                ),
              ),
              labelText: 'Φιάλες',
              labelStyle: TextStyle(color: appRedColor, fontSize: 14.sp),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color.fromARGB(76, 156, 12, 4),
                  width: 4,
                ),
                borderRadius: BorderRadius.all(Radius.circular(8.r)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: appRedColor, width: 4),
                borderRadius: BorderRadius.all(Radius.circular(8.r)),
              ),
            ),
            child: priceText(),
          ),
        ),
        Visibility(
          visible: _isExpanded,
          child: Padding(
            padding: EdgeInsets.only(top: 15.h, bottom: 5.h),
            child: ClipRect(
              child: SizeTransition(
                sizeFactor: _heightFactor,
                axisAlignment: -1.0,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: appRedColor, width: 4),
                    borderRadius: BorderRadius.circular(8.r),
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
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 14.sp),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => decrement(index),
                icon: Icon(Icons.remove, color: Colors.white, size: 18.sp),
              ),
              Text(
                reservationProvider.reservationInfo[index].toString(),
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
              ),
              IconButton(
                onPressed: () => increment(index),
                icon: Icon(Icons.add, color: Colors.white, size: 18.sp),
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
          Text(
            'Τιμή: ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
            ),
          ),
          reservationProvider.getInfo(10) <= 0
              ? Text(
                  priceController.text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                  ),
                )
              : Row(
                  children: [
                    Text(
                      priceController.text,
                      style: TextStyle(
                          color: appRedColor,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: Colors.red,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800),
                    ),
                    Text(
                      ' ${reservationProvider.getInfo(4).toStringAsFixed(2)} €',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                )
        ],
      );
    } else {
      return Text(
        'Τιμή: ${priceController.text}',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14.sp,
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
      // print(
      //     '❌Invalid unavailableDays format: Each month must be paired with a day.');
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
        // print(
        //     '❌Invalid unavailableDays data: Unable to parse month/day at index $i');
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
        DateTime lowerLimit = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          22, // Sets hour to 10 PM
          0, // Sets minute to 0
          0, // Sets second to 0
        );
        if (DateTime.now().hour >= 22) {
          lowerLimit = lowerLimit.add(const Duration(days: 1));
        }
        final now = lowerLimit;
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
            return Transform.scale(
              scale: 0.8.sp,
              child: Theme(
                data: ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: appRedColor,
                    onPrimary: Colors.white,
                    surface: Colors.black,
                    onSurface: Colors.white,
                  ),
                  dialogBackgroundColor: Colors.black,
                  textTheme: TextTheme(
                    bodySmall: TextStyle(
                      fontSize: 14.sp, // Adjust font size to make year smaller
                    ),
                  ),
                ),
                child: child!,
              ),
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
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(10.sp),
          labelText: 'Ημερομηνία κράτησης',
          labelStyle: TextStyle(color: appRedColor, fontSize: 14.sp),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0x4C9C0C04), width: 4),
            borderRadius: BorderRadius.all(Radius.circular(8.r)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: appRedColor, width: 4),
            borderRadius: BorderRadius.all(Radius.circular(8.r)),
          ),
        ),
        child: Text(
          _selectedDate != null
              ? DateFormat('dd MMMM, yyyy', 'el')
                  .format(_selectedDate!) // Greek format
              : 'Επίλεξε ημερομηνία',
          style: TextStyle(color: Colors.white, fontSize: 14.sp),
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
    padding: EdgeInsets.only(top: 8.h),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15.sp,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
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
    // print("❌Failed to retract points: $error");
    await Future.delayed(const Duration(seconds: 5));
    retractPoints(pointsToRetract);
  }
}

class LocationWidget extends StatefulWidget {
  final String locationName;

  const LocationWidget({super.key, required this.locationName});

  @override
  State<LocationWidget> createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  bool _isPressed = false;

  Future<void> _openLocation() async {
    final Uri googleMapsUri =
        Uri.parse('comgooglemaps://?q=${widget.locationName}');
    final Uri appleMapsUri =
        Uri.parse('http://maps.apple.com/?q=${widget.locationName}');
    final Uri browserUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${widget.locationName}');

    try {
      if (await canLaunchUrl(googleMapsUri)) {
        await launchUrl(googleMapsUri);
      } else if (await canLaunchUrl(appleMapsUri)) {
        await launchUrl(appleMapsUri);
      } else {
        await launchUrl(browserUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // print("Could not open maps: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _openLocation, // Handle the tap
      onHighlightChanged: (isPressed) {
        // This changes the state on tap to update color
        setState(() {
          _isPressed = isPressed;
        });
      },
      borderRadius: BorderRadius.circular(
          12.r), // Ensures ripple effect follows the shape
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.5.w),
        child: Container(
          padding: EdgeInsets.all(10.sp),
          decoration: BoxDecoration(
            color: _isPressed
                ? const Color.fromARGB(255, 49, 49, 49) // Change color on tap
                : const Color.fromARGB(255, 68, 68, 68),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Icon(Icons.location_on, color: Colors.white, size: 18.sp),
              SizedBox(width: 5.w),
              Text(
                widget.locationName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Icon(Icons.keyboard_arrow_right,
                  color: Colors.white, size: 18.sp),
            ],
          ),
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

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.5.w),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          bool isOpen = schedule[index] == '1';
          return Text(
            days[index],
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: isOpen
                  ? const Color.fromARGB(255, 255, 255, 255)
                  : const Color.fromARGB(255, 59, 59, 59),
            ),
          );
        }),
      ),
    );
  }
}
