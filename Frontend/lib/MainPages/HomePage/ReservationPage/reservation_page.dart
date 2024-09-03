import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Providers/booking_provider.dart';
import '../../../Providers/club_provider.dart';
import '../../../Providers/reservation_provider.dart';
import '../../../Providers/user_provider.dart';
import '../../../Widgets/club_card_widgets.dart';
import '../../../Widgets/reservation_page_widgets.dart';
import '../../../global_components.dart';
import '../../../services/booking_service.dart';
import '../../../services/points_service.dart';

@RoutePage()
class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key, required this.club});
  final ClubInfoStruct club;

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  // State variables for the reservation page
  bool isDiscountApplied = false;
  bool buttonIsVisible = true;

  // Catalogues for different types of services
  CatalogueInfoStruct regularCatalogue = CatalogueInfoStruct(
    clubID: -1,
    serviceType: 'Regular',
    price: '0',
    maxPersons: 0,
  );

  CatalogueInfoStruct specialCatalogue = CatalogueInfoStruct(
    clubID: -1,
    serviceType: 'Special',
    price: '0',
    maxPersons: 0,
  );

  CatalogueInfoStruct premiumCatalogue = CatalogueInfoStruct(
    clubID: -1,
    serviceType: 'Premium',
    price: '0',
    maxPersons: 0,
  );

  // Controllers and keys for managing state
  final TextEditingController _commentController = TextEditingController();
  final GlobalKey<NameTextFieldState> nameTextFieldKey =
      GlobalKey<NameTextFieldState>();
  final GlobalKey<CategoriesTextFieldState> categoriesTextFieldKey =
      GlobalKey<CategoriesTextFieldState>();
  final PointsService _pointsService = PointsService();

  @override
  void initState() {
    super.initState();

    // Initialize the page after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePage();
    });
  }

  /// Initializes the page with the club's catalogues and resets any previous data.
  void _initializePage() {
    final reservationProvider = context.read<ReservationProvider>();
    reservationProvider.resetInfo();
    reservationProvider.setInfo(2, widget.club.clubName);
    final userDetails = context.read<UserProvider>().userDetails;
    reservationProvider.setInfo(0, userDetails?.userID);

    // Initialize catalogues for the current club
    final clubProvider = context.read<ClubProvider>();
    final catalogues = clubProvider.initializeCatalogues(widget.club.clubID);

    setState(() {
      regularCatalogue = catalogues[0];
      specialCatalogue = catalogues[1];
      premiumCatalogue = catalogues[2];
      updateMaxPersons();
      calculatePrice();
    });

    // Set the initial name and surname using the new setNameText method
    if (userDetails != null && reservationProvider.getInfo(1).isEmpty) {
      String initialName = '${userDetails.firstName} ${userDetails.lastName}';
      reservationProvider.setInfo(1, formatName(initialName));
      nameTextFieldKey.currentState?.setNameText(formatName(initialName));
    }
  }

  /// Safely retracts points for the discount and updates the provider.
  Future<void> _retractPoints(int pointsToRetract) async {
    try {
      await _pointsService.retractPoints(pointsToRetract);
    } catch (error) {
      print("Failed to retract points: $error");
    }
  }

  /// Updates the maximum number of persons based on the selected bottles.
  void updateMaxPersons() {
    final reservationProvider = context.read<ReservationProvider>();

    int maxPersons =
        (regularCatalogue.maxPersons * reservationProvider.getInfo(5) +
                specialCatalogue.maxPersons * reservationProvider.getInfo(6) +
                premiumCatalogue.maxPersons * reservationProvider.getInfo(7))
            .toInt();

    maxPersons = maxPersons > 0 ? maxPersons : 1;

    reservationProvider.setMaxPersons(maxPersons);

    if (reservationProvider.getInfo(3) > maxPersons) {
      reservationProvider.setInfo(3, maxPersons);
    }
  }

  /// Calculates the total price based on the selected services and applies any discounts.
  void calculatePrice() {
    final reservationProvider = context.read<ReservationProvider>();

    double price = (reservationProvider.getInfo(5) *
            safeParse(regularCatalogue.price)) +
        (reservationProvider.getInfo(6) * safeParse(specialCatalogue.price)) +
        (reservationProvider.getInfo(7) * safeParse(premiumCatalogue.price));

    if (isDiscountApplied) {
      price *= (1 - (reservationProvider.getInfo(10) / 100));
    }

    reservationProvider.setInfo(4, price);
  }

  /// Converts a string to a double safely, returning 0.0 if the string is not a valid number.
  double safeParse(String value) {
    return double.tryParse(value) ?? 0.0;
  }

  /// Refreshes the page and updates the catalogues.
  Future<void> _refresh() async {
    final clubProvider = context.read<ClubProvider>();
    await clubProvider.fetchCatalogues(widget.club);
    final catalogues = clubProvider.initializeCatalogues(widget.club.clubID);

    if (mounted) {
      setState(() {
        regularCatalogue = catalogues[0];
        specialCatalogue = catalogues[1];
        premiumCatalogue = catalogues[2];
        updateMaxPersons();
        calculatePrice();
      });
    }
  }

  /// Toggles the visibility of the bottom navigation bar.
  void _toggleNavBarVisibility() {
    final bottomNavBarVisibility = context.read<BottomNavBarVisibility>();
    if (buttonIsVisible) {
      bottomNavBarVisibility.show();
    } else {
      bottomNavBarVisibility.hide();
    }
  }

  @override
  void dispose() {
    // Dispose of controllers to free up resources
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reservationProvider = context.read<ReservationProvider>();
    final userDetails = context.read<UserProvider>().userDetails;
    return PopScope(
      canPop: reservationProvider.getInfo(3) > 0,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/otherPhotos/Untitled_Artwork.png'),
                fit: BoxFit.fill,
              ),
            ),
            child: ListView(
              children: [
                buildHeader(context),
                buildContent(context, reservationProvider, userDetails),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the header section of the page with the club name and back button.
  Widget buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
                child: IconButton(
                  onPressed: () {
                    if (buttonIsVisible) {
                      AutoRouter.of(context).back();
                    }
                  },
                  icon: const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
              ),
              Text(
                widget.club.clubName,
                style: const TextStyle(
                  color: Color(0xFF9C0C04),
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Container(
              alignment: Alignment.centerRight,
              child: LikeButton(club: widget.club, big: true),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the main content of the page, including forms and input fields.
  Widget buildContent(BuildContext context,
      ReservationProvider reservationProvider, UserInfoStruct? userDetails) {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          buildClubImage(),
          const SizedBox(height: 50),
          buildTitle('Φιάλες και Τιμές'),
          buildPackageInfo(),
          const SizedBox(height: 40),
          buildTitle('Κάνε κράτηση'),
          const SizedBox(height: 50),
          buildReservationForm(context, reservationProvider, userDetails),
        ],
      ),
    );
  }

  /// Builds the club image with a placeholder in case of an error.
  Widget buildClubImage() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: SizedBox(
          width: 520,
          height: 350,
          child: FutureBuilder<ImageProvider>(
            future: loadClubPhoto(widget.club.clubID, widget.club.clubPhoto),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return Image(image: snapshot.data!, fit: BoxFit.fill);
                } else if (snapshot.hasError) {
                  return const Image(
                    image: AssetImage('assets/images/default_club_image.png'),
                    fit: BoxFit.fill,
                  );
                }
              }
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }

  /// Builds a section title.
  Widget buildTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  /// Builds the package information section.
  Widget buildPackageInfo() {
    return Column(
      children: [
        PackagesInfo(
          package: 'Απλή',
          maxPersons: regularCatalogue.maxPersons,
          minPrice: safeParse(regularCatalogue.price).toInt(),
        ),
        PackagesInfo(
          package: 'Special',
          maxPersons: specialCatalogue.maxPersons,
          minPrice: safeParse(specialCatalogue.price).toInt(),
        ),
        PackagesInfo(
          package: 'Premium',
          maxPersons: premiumCatalogue.maxPersons,
          minPrice: safeParse(premiumCatalogue.price).toInt(),
        ),
      ],
    );
  }

  /// Builds the reservation form, including name, date, categories, and persons input.
  Widget buildReservationForm(BuildContext context,
      ReservationProvider reservationProvider, UserInfoStruct? userDetails) {
    return Column(
      children: [
        SizedBox(
          height: 70,
          child: NameTextField(key: nameTextFieldKey),
        ),
        const SizedBox(height: 25),
        SizedBox(
          height: 70,
          child: BookingDatePicker(
            onDateSelected: (selectedDate) {
              reservationProvider.setInfo(8, selectedDate.toString());
            },
            days: widget.club.clubAvailability,
          ),
        ),
        const SizedBox(height: 25),
        CategoriesTextField(
          key: categoriesTextFieldKey,
          regularCatalogue: regularCatalogue,
          specialCatalogue: specialCatalogue,
          premiumCatalogue: premiumCatalogue,
          onCountersChanged: () {
            updateMaxPersons();
            calculatePrice();
          },
          isDiscountApplied: isDiscountApplied,
          discount: reservationProvider.getInfo(10),
        ),
        const SizedBox(height: 25),
        const SizedBox(
          height: 70,
          child: PersonsTextField(),
        ),
        CommentSection(commentController: _commentController),
        const SizedBox(height: 25),
        buildDiscountCheckbox(context, reservationProvider, userDetails!),
        const SizedBox(height: 25),
        if (buttonIsVisible) buildSubmitButton(context, reservationProvider),
        const SizedBox(height: 120),
      ],
    );
  }

  /// Builds the checkbox for applying a discount if the user has enough points.
  Widget buildDiscountCheckbox(BuildContext context,
      ReservationProvider reservationProvider, UserInfoStruct userDetails) {
    return userDetails.points >= 20
        ? Row(
            children: [
              GestureDetector(
                onTap: () => _toggleDiscount(reservationProvider),
                child: Row(
                  children: [
                    Checkbox(
                      value: isDiscountApplied,
                      onChanged: (value) =>
                          _toggleDiscount(reservationProvider),
                      activeColor: const Color(0xFF9C0C04),
                    ),
                    const Text(
                      'Χρήση εκπτωτικού κουπονιού 20%',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ],
          )
        : const SizedBox.shrink();
  }

  /// Toggles the discount and updates the price accordingly.
  void _toggleDiscount(ReservationProvider reservationProvider) {
    setState(() {
      isDiscountApplied = !isDiscountApplied;
      reservationProvider.setInfo(10, isDiscountApplied ? 20 : 0);
      calculatePrice();
    });
  }

  /// Builds the submit button for the reservation form.
  Widget buildSubmitButton(
      BuildContext context, ReservationProvider reservationProvider) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF9C0C04),
        ),
        onPressed: () async => _handleSubmit(context, reservationProvider),
        child: const Text(
          'Κράτηση',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// Handles the form submission process, including validation and API calls.
  Future<void> _handleSubmit(
      BuildContext context, ReservationProvider reservationProvider) async {
    // Hide the button while processing the submission
    setState(() {
      buttonIsVisible = false;
      _toggleNavBarVisibility();
    });

    // Get the raw name and format it
    String rawName = nameTextFieldKey.currentState?.nameController.text ?? '';
    String formattedName = formatName(rawName);

    // Update the provider with the formatted name
    reservationProvider.setInfo(1, formattedName);

    // Validate the form inputs
    if (!_validateForm(reservationProvider, formattedName)) {
      _showValidationError(context, reservationProvider, formattedName);
      return;
    }

    // Show the confirmation dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ProceedConfirmationDialog(
          reservationInfo: reservationProvider.reservationInfo,
          onConfirm: () async {
            Navigator.of(context).pop(); // Close the dialog

            // Retract points if a discount is applied
            if (isDiscountApplied) {
              await _retractPoints(20);
              if (!mounted) return;
            }
            // printReservationInfo(reservationProvider.reservationInfo);
            // Submit the reservation form
            bool success = await BookingService().submitForm(
              reservationProvider.getInfo(1),
              reservationProvider.getInfo(2),
              _generateFourBitString(reservationProvider),
              reservationProvider.getInfo(8),
              reservationProvider.getInfo(3).toString(),
              reservationProvider.getInfo(9),
            );

            if (!mounted) return;

            // ignore: use_build_context_synchronously
            _handleSubmissionResponse(context, success, reservationProvider);
          },
          onCancel: () {
            Navigator.of(context).pop(); // Close the dialog
            // Show the button and nav bar again
            setState(() {
              buttonIsVisible = true;
              _toggleNavBarVisibility();
            });
          },
        );
      },
    );
  }

  /// Validates the form inputs before submission.
  bool _validateForm(
      ReservationProvider reservationProvider, String formattedName) {
    final RegExp namePattern =
        RegExp(r'^[\p{L}]+(\s+)[\p{L}]+$', unicode: true);

    bool isNameValid = namePattern.hasMatch(formattedName);
    bool allFieldsFilled = reservationProvider.reservationInfo
            .sublist(1, 8)
            .every((element) => element != '' && element != -1) &&
        isNameValid;

    String fourBitString = _generateFourBitString(reservationProvider);
    printReservationInfo(reservationProvider.reservationInfo);
    return allFieldsFilled &&
        reservationProvider.getInfo(4) > 0 &&
        reservationProvider.getInfo(8).isNotEmpty &&
        fourBitString.isNotEmpty &&
        fourBitString != '0000';
  }

  /// Shows a validation error message if the form inputs are invalid.
  void _showValidationError(BuildContext context,
      ReservationProvider reservationProvider, String formattedName) {
    final bool isNameValid = RegExp(r'^[\p{L}]+(\s+)[\p{L}]+$', unicode: true)
        .hasMatch(formattedName);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            isNameValid
                ? 'Παρακαλώ συμπληρώστε όλα τα πεδία'
                : 'Μόνο ονοματεπώνυμο στο όνομα κράτησης',
          ),
          duration: const Duration(seconds: 2),
        ),
      );

    setState(() {
      buttonIsVisible = true;
      _toggleNavBarVisibility(); // Show the nav bar when button is visible
    });
  }

  /// Handles the submission response and displays appropriate feedback.
  void _handleSubmissionResponse(BuildContext context, bool success,
      ReservationProvider reservationProvider) async {
    if (!mounted) return; // Ensure the widget is still mounted

    if (success) {
      // Fetch bookings after a successful reservation
      await context.read<BookingProvider>().fetchBookings(context);

      if (!mounted) return; // Check again before showing the dialog

      // Show the confirmation dialog
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          if (!mounted) {
            return Container(); // Prevent showing the dialog if unmounted
          }
          return ConfirmationDialog(
            reservationInfo: reservationProvider.reservationInfo,
          );
        },
      );
    }
    //else {
    //   try {
    //     ScaffoldMessenger.of(context)
    //       ..hideCurrentSnackBar()
    //       ..showSnackBar(
    //         const SnackBar(
    //           content: Text(
    //             'Υπήρξε κάποιο σφάλμα στην κράτησή σας. Παρακαλώ προσπαθήστε ξανά ή επικοινωνήστε μαζί μας.',
    //           ),
    //           duration: Duration(seconds: 3),
    //         ),
    //       );
    //   } catch (e) {
    //     print("Failed to show SnackBar: $e");
    //   }
    // }

    if (mounted) {
      setState(() {
        buttonIsVisible = true;
        _toggleNavBarVisibility(); // Show the nav bar when button is visible
      });
    }
  }

  /// Generates the four-bit string required for the form submission.
  String _generateFourBitString(ReservationProvider reservationProvider) {
    return '${reservationProvider.getInfo(5)}${reservationProvider.getInfo(6)}${reservationProvider.getInfo(7)}${reservationProvider.getInfo(10) ~/ 10}';
  }
}
