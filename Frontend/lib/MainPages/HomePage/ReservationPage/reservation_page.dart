import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mypr/Providers/global_state_provider.dart';
import 'package:provider/provider.dart';

import '../../../Navigation/bottom_nav_bar.dart';
import '../../../Providers/booking_provider.dart';
import '../../../Providers/club_provider.dart';
import '../../../Providers/reservation_provider.dart';
import '../../../Providers/user_provider.dart';
import '../../../Widgets/club_card_widgets.dart';
import '../../../Widgets/reservation_page_widgets.dart';
import '../../../global_components.dart';
import '../../../routes/app_router.gr.dart';
import '../../../services/auth_service.dart';
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
  final AuthService _authService = AuthService(); // Create AuthService instance

  // State variables for managing the page
  bool isDiscountApplied = false; // Flag to check if discount is applied
  bool buttonIsVisible = true; // Flag to toggle the visibility of submit button

  // Catalogues for different types of services in the club
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

  // Controllers and keys for managing form inputs
  final TextEditingController _commentController = TextEditingController();
  final GlobalKey<NameTextFieldState> nameTextFieldKey =
      GlobalKey<NameTextFieldState>();
  final GlobalKey<CategoriesTextFieldState> categoriesTextFieldKey =
      GlobalKey<CategoriesTextFieldState>();
  final PointsService _pointsService =
      PointsService(); // Service for points management

  @override
  void initState() {
    super.initState();

    // Initialize the page after the build phase completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePage();
      context.read<BottomNavBarVisibility>().hide();
    });
  }

  /// Initializes the reservation page by setting the club's catalogues and resetting form data.
  void _initializePage() {
    final reservationProvider = context.read<ReservationProvider>();
    final userDetails = context.read<UserProvider>().userDetails;

    // Reset reservation data
    reservationProvider.resetInfo();
    reservationProvider.setInfo(2, widget.club.clubName); // Set club name
    reservationProvider.setInfo(0, userDetails.userID); // Set user ID

    final clubProvider = context.read<ClubProvider>();
    // Fetch and initialize catalogues for the selected club
    final catalogues =
        clubProvider.getAllCataloguesForClubWithID(widget.club.clubID);

    setState(() {
      regularCatalogue = catalogues[0];
      specialCatalogue = catalogues[1];
      premiumCatalogue = catalogues[2];

      // Update the max persons and calculate the total price for the reservation
      updateMaxPersons();
      calculatePrice();
    });

    // Set the user's name in the form if available
    if (reservationProvider.getInfo(1).isEmpty) {
      String initialName =
          formatName('${userDetails.firstName} ${userDetails.lastName}');
      reservationProvider.setInfo(1, initialName);
      nameTextFieldKey.currentState?.setNameText(initialName);
    }
  }

  /// Safely retracts points for the discount and updates the provider.
  Future<void> _retractPoints(int pointsToRetract) async {
    try {
      await _authService
          .refreshAccessToken(); // Ensure token is valid before retracting points
      await _pointsService.retractPoints(pointsToRetract);
    } catch (error) {
      print("❌Failed to retract points: $error");
    }
  }

  /// Updates the maximum number of persons allowed based on selected services (bottles).
  void updateMaxPersons() {
    final reservationProvider = context.read<ReservationProvider>();

    int maxPersons =
        (regularCatalogue.maxPersons * reservationProvider.getInfo(5) +
                specialCatalogue.maxPersons * reservationProvider.getInfo(6) +
                premiumCatalogue.maxPersons * reservationProvider.getInfo(7))
            .toInt();

    // Ensure at least one person is allowed for the reservation
    maxPersons = maxPersons > 0 ? maxPersons : 1;

    // Update max persons in the provider
    reservationProvider.setMaxPersons(maxPersons);

    // Adjust persons in the reservation if it exceeds the max
    if (reservationProvider.getInfo(3) > maxPersons) {
      reservationProvider.setInfo(3, maxPersons);
    }
  }

  /// Calculates the total price based on the selected services and applies any discount.
  void calculatePrice() {
    final reservationProvider = context.read<ReservationProvider>();

    double price = (reservationProvider.getInfo(5) *
            safeParse(regularCatalogue.price)) +
        (reservationProvider.getInfo(6) * safeParse(specialCatalogue.price)) +
        (reservationProvider.getInfo(7) * safeParse(premiumCatalogue.price));

    // Apply discount if applicable
    if (isDiscountApplied) {
      price *= (1 - (reservationProvider.getInfo(10) / 100));
    }

    // Update the calculated price in the provider
    reservationProvider.setInfo(4, price);
  }

  /// Refreshes the page to fetch the latest catalogues for the selected club.
  Future<void> _refresh() async {
    final clubProvider = context.read<ClubProvider>();

    try {
      // Fetch updated catalogues
      await clubProvider.fetchCatalogues(widget.club);
      final catalogues =
          clubProvider.getAllCataloguesForClubWithID(widget.club.clubID);

      if (regularCatalogue.maxPersons != catalogues[0].maxPersons ||
          regularCatalogue.price != catalogues[0].price ||
          specialCatalogue.maxPersons != catalogues[1].maxPersons ||
          specialCatalogue.price != catalogues[1].price ||
          premiumCatalogue.maxPersons != catalogues[2].maxPersons ||
          premiumCatalogue.price != catalogues[2].price) {
        _updateCatalogues(catalogues);
      }
    } catch (error) {
      // Log error without additional snack bars
      print("❌Failed to refresh catalogues: $error");
    }
  }

  void _updateCatalogues(List<CatalogueInfoStruct> catalogues) {
    setState(() {
      regularCatalogue = catalogues[0];
      specialCatalogue = catalogues[1];
      premiumCatalogue = catalogues[2];
      updateMaxPersons();
      calculatePrice();
    });
  }

  @override
  void dispose() {
    // Clean up the controllers to free up resources
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isAuthenticated =
        context.read<GlobalStateProvider>().isAuthenticated;
    return PopScope(
      canPop: buttonIsVisible,
      onPopInvokedWithResult: (didPop, result) {
        if (buttonIsVisible) {
          context.read<BottomNavBarVisibility>().show();
        }
      }, // Restrict pop action based on button visibility
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          appBar: _buildAppBar(
              context, widget.club.clubName, screenHeight, screenWidth),
          backgroundColor: const Color.fromARGB(218, 31, 31, 31),
          body: RefreshIndicator.adaptive(
            color: const Color(0xFF9C0C04),
            onRefresh: _refresh, // Handle refresh action
            child: ListView(
              children: [
                // Build page header with club name
                buildContent(isAuthenticated, screenHeight,
                    screenWidth), // Build form content and input fields
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, String clubName,
      double screenHeight, double screenWidth) {
    return AppBar(
        backgroundColor: const Color.fromARGB(0, 0, 0, 0),
        title: Text(
          clubName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () {
            if (buttonIsVisible) {
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          LikeButton(
            club: widget.club,
            big: true,
            screenHeight: screenHeight,
            screenWidth: screenWidth,
          ),
          SizedBox(width: screenWidth * 0.02)
        ]);
  }

  /// Builds the content section with form fields for reservation details.
  Widget buildContent(
      bool isAuthenticated, double screenHeight, double screenWidth) {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          buildClubImage(), // Display club image
          const SizedBox(height: 50),
          buildTitle('Φιάλες και Τιμές'), // Display packages
          buildPackageInfo(),
          const SizedBox(height: 40),
          isAuthenticated
              ? Column(
                  children: [
                    buildTitle('Κάνε κράτηση'), // Display booking form
                    const SizedBox(height: 50),
                    buildReservationForm(), const SizedBox(height: 120),
                  ],
                )
              : Column(
                  children: [
                    buildTitle(
                        'Ενδιαφέρεσαι για κράτηση;'), // Display booking form
                    const SizedBox(height: 50),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          AutoRouter.of(context)
                              .replaceAll([const SignUpRoute()]);
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 10,
                          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                          backgroundColor: const Color.fromARGB(
                              136, 173, 173, 173), // Text color
                          minimumSize: Size(screenWidth * 0.45,
                              screenHeight * 0.06), // Button size
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(
                              width: 4,
                              color:
                                  Color.fromARGB(255, 0, 0, 0), // Border color
                            ),
                          ),
                        ),
                        child: Text(
                          'Κάνε εγγραφή/Συνδέσου',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.028,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.1),
                  ],
                ), // Build reservation form
        ],
      ),
    );
  }

  /// Builds the club image or a placeholder in case of an error.
  Widget buildClubImage() {
    return Padding(
        padding: const EdgeInsets.all(15),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: SizedBox(
            width: 520,
            height:
                350, // Display the loaded image (either from the network or local storage)
            child: widget.club.localPhotoPath.isNotEmpty
                ? Image.file(
                    File(widget.club.localPhotoPath),
                    fit: BoxFit.fill,
                  ) // Load from local file
                : Image.network(
                    widget.club.clubPhoto,
                    fit: BoxFit.fill,
                  ),
          ),
        ));
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

  /// Builds the package information section with available services.
  Widget buildPackageInfo() {
    return Column(
      children: [
        const SizedBox(height: 25),
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

  /// Builds the reservation form with various input fields.
  Widget buildReservationForm() {
    return Column(
      //TODO add top/bottom padding of about 25 px
      children: [
        NameTextField(key: nameTextFieldKey),
        BookingDatePicker(
            days: widget.club.clubAvailability,
            unavailableDays: widget.club.clubNotAvailable),
        CategoriesTextField(
          key: categoriesTextFieldKey,
          regularCatalogue: regularCatalogue,
          specialCatalogue: specialCatalogue,
          premiumCatalogue: premiumCatalogue,
          onCountersChanged: () {
            updateMaxPersons(); // Update max persons based on selected services
            calculatePrice(); // Recalculate total price
          },
        ),
        const PersonsTextField(),
        CommentSection(
            commentController: _commentController), // Optional comment field
        buildDiscountCheckbox(), // Discount checkbox
        buildSubmitButton(), // Submit button
      ],
    );
  }

  /// Builds the discount checkbox if the user has enough points.
  Widget buildDiscountCheckbox() {
    final userDetails = context.read<UserProvider>().userDetails;
    return userDetails.points >= 20 && buttonIsVisible
        ? Row(
            children: [
              GestureDetector(
                onTap: () => _toggleDiscount(), // Toggle discount application
                child: Row(
                  children: [
                    Checkbox(
                      value: isDiscountApplied,
                      onChanged: (value) => _toggleDiscount(),
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
        : const SizedBox.shrink(); // Do not show if points are insufficient
  }

  /// Toggles the discount and recalculates the total price.
  void _toggleDiscount() {
    setState(() {
      isDiscountApplied = !isDiscountApplied;
      context
          .read<ReservationProvider>()
          .setInfo(10, isDiscountApplied ? 20 : 0);
      calculatePrice(); // Recalculate price with the discount
    });
  }

  /// Builds the submit button for the reservation form.
  Widget buildSubmitButton() {
    return buttonIsVisible
        ? Container(
            alignment: Alignment.center,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 10,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF9C0C04),
                ),
                onPressed: () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  _handleSubmit(); // Handle form submission
                },
                child: const Text(
                  'Κράτηση',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                )))
        : const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF9C0C04),
            ),
          );
  }

  /// Handles the form submission process, including validation and API calls.
  Future<void> _handleSubmit() async {
    String rawName = nameTextFieldKey.currentState?.nameController.text ?? '';
    String formattedName = formatName(rawName);
    if (formattedName.isNotEmpty) {
      context.read<ReservationProvider>().setInfo(1, formattedName);
    }

    if (!_validateForm()) {
      _showValidationError();
      return;
    }
    if (mounted) {
      // Show the confirmation dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return proceedConfirmationDialog();
        },
      );
    }
  }

  Widget proceedConfirmationDialog() {
    ReservationProvider reservationProvider =
        context.read<ReservationProvider>();
    printReservationInfo(reservationProvider.reservationInfo);
    void onConfirm() async {
      Navigator.of(context, rootNavigator: true).pop();
      setState(() {
        buttonIsVisible = false;
      });
      try {
        // Call the refreshAccessToken method on the instance
        await _authService
            .refreshAccessToken(); // Ensure token is valid before submission

        // Fetching catalogues, wrapped in a try-catch for error handling
        await ClubProvider().fetchCatalogues(widget.club);
      } catch (e) {
        print("❌Failed to refresh access token or fetch catalogues");
        setState(() {
          buttonIsVisible = true;
        });
        try {
          if (mounted) {
            floatingSnackBar(
                message:
                    'Υπήρξε κάποιο σφάλμα στην κράτησή. Παρακαλώ προσπάθησε ξανά ή επικοινώνησε μαζί μας',
                context: context,
                duration: const Duration(milliseconds: 1500));
          }
        } catch (e) {
          print("❌Failed to show SnackBar: $e");
        }

        // Log error or handle failure in a way without more snack bars
        print("❌Booking submission failed.");
        return;
      }

      // Retract points if a discount is applied
      if (isDiscountApplied) {
        await _retractPoints(20);
      }

      // Submit the reservation form
      bool success = await BookingService().submitForm(
        reservationProvider.getInfo(1),
        reservationProvider.getInfo(2),
        _generateFourBitString(),
        reservationProvider.getInfo(8),
        reservationProvider.getInfo(3).toString(),
        reservationProvider.getInfo(9),
      );
      _handleSubmissionResponse(success);
    }

    onCancel() {
      // Hide the dialog without navigating back
      Navigator.of(context, rootNavigator: true).pop();

      // Show the button and nav bar again
      setState(() {
        buttonIsVisible = true;
      });
    }

    String date = reservationProvider.reservationInfo[8];
    final price = reservationProvider.reservationInfo[4];

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
                'Επιβεβαίωση Κράτησης',
                style: TextStyle(
                  color: Color(0xFF9C0C04),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildInfoRow(
                  'Όνομα κράτησης:', reservationProvider.reservationInfo[1]),
              _buildInfoRow('Μαγαζί:', reservationProvider.reservationInfo[2]),
              _buildInfoRow('Αριθμός ατόμων:',
                  reservationProvider.reservationInfo[3].toString()),
              _buildInfoRow('Ημερομηνία:', formattedDate),
              _buildInfoRow('Συνολική Τιμή:', '$formattedPrice €'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: onCancel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Ακύρωση',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9C0C04),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Επιβεβαίωση',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
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

  /// Validates the form inputs before submission.
  bool _validateForm() {
    final RegExp namePattern =
        RegExp(r'^[\p{L}]+(\s+)[\p{L}]+$', unicode: true);
    final reservationProvider = context.read<ReservationProvider>();

    // Add comment to reservation list
    reservationProvider.setInfo(9, _commentController.text.trim());

    // Validate name and check if all required fields are filled
    bool isNameValid = namePattern.hasMatch(reservationProvider.getInfo(1));
    bool allFieldsFilled = reservationProvider.reservationInfo
            .sublist(0, 8)
            .every((element) => element != '' && element != -1) &&
        isNameValid;

    String fourBitString = _generateFourBitString();

    return allFieldsFilled &&
        reservationProvider.getInfo(4) > 0 &&
        reservationProvider.getInfo(8).isNotEmpty &&
        fourBitString.isNotEmpty &&
        fourBitString != '0000';
  }

  /// Shows an error message if the form validation fails.
  void _showValidationError() {
    final bool isNameValid = RegExp(r'^[\p{L}]+(\s+)[\p{L}]+$', unicode: true)
        .hasMatch(context.read<ReservationProvider>().getInfo(1));

    // Display a snack bar error message based on validation results
    floatingSnackBar(
        message: isNameValid
            ? 'Παρακαλώ συμπλήρωσε όλα τα πεδία'
            : 'Μόνο ονοματεπώνυμο στο όνομα κράτησης',
        context: context,
        duration: const Duration(milliseconds: 2000));

    setState(() {
      buttonIsVisible = true;
      // Show the nav bar again when button is visible
    });
  }

  Future<bool?> reservationReviewDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return const ReservationReview();
      },
    );
  }

  /// Handles the submission response and shows appropriate feedback.
  void _handleSubmissionResponse(bool success) async {
    if (success) {
      // Fetch bookings after a successful reservation
      if (mounted) {
        await context.read<BookingProvider>().fetchBookings(
            context.read<UserProvider>().userDetails,
            context.read<ClubProvider>());
      }

      if (mounted) {
        setState(() {
          buttonIsVisible = true; // Show the button again
        });
        // Show the confirmation dialog and wait for the result
        final bool? result = await reservationReviewDialog();

        // If the user confirmed (result == true), perform actions
        if (result == true) {
          if (mounted) {
            context.read<BottomNavBarVisibility>().show();
            Navigator.pop(context); // Navigate back to the previous page
          }
        }
      }
    } else {
      floatingSnackBar(
          message:
              'Υπήρξε κάποιο σφάλμα στην κράτησή. Παρακαλώ προσπάθησε ξανά ή επικοινώνησε μαζί μας',
          context: context);
      setState(() {
        buttonIsVisible = true; // Show the button again
      });
    }
  }

  /// Generates a four-bit string required for form submission.
  String _generateFourBitString() {
    final reservationProvider = context.read<ReservationProvider>();
    return '${reservationProvider.getInfo(5)}${reservationProvider.getInfo(6)}${reservationProvider.getInfo(7)}${reservationProvider.getInfo(10) ~/ 10}';
  }

  /// Safely parses a string to a double, returning 0.0 if the string is invalid.
  double safeParse(String value) {
    return double.tryParse(value) ?? 0.0;
  }
}
