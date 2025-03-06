import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mypr/Providers/global_state_provider.dart';
import 'package:mypr/services/booking_service.dart';
import 'package:provider/provider.dart';

import '../../../Globals/classes.dart';
import '../../../Globals/constants.dart';
import '../../../Globals/global_components.dart';
import '../../../Navigation/bottom_nav_bar.dart';
import '../../../Providers/booking_provider.dart';
import '../../../Providers/club_provider.dart';
import '../../../Providers/reservation_provider.dart';
import '../../../Providers/user_provider.dart';
import '../../../Widgets/club_card_widgets.dart';
import '../../../Widgets/reservation_page_widgets.dart';
import '../../../services/auth_service.dart';

@RoutePage()
class ReservationPage extends StatefulWidget {
  const ReservationPage(
      {super.key, required this.club, required this.catalogues});
  final ClubInfoStruct club;
  final List<CatalogueInfoStruct> catalogues;

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  // State variables for managing the page
  bool isDiscountApplied = false; // Flag to check if discount is applied
  bool buttonIsVisible = true; // Flag to toggle the visibility of submit button
  final ScrollController _scrollController = ScrollController();

  // Controllers and keys for managing form inputs
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final GlobalKey<CategoriesTextFieldState> categoriesTextFieldKey =
      GlobalKey<CategoriesTextFieldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePage();
      if (context.read<GlobalStateProvider>().hasCheckedAppVersion == false) {
        checkAppVersion(context);
      }
      context.read<BottomNavBarVisibility>().hide();
    });
  }

// List of catalogues for different types of services in the club
  List<CatalogueInfoStruct> localCatalogues = [
    createCatalogue('Regular'),
    createCatalogue('Special'),
    createCatalogue('Premium'),
  ];

  /// Initializes the reservation page by setting the club's catalogues and resetting form data.
  void _initializePage() {
    final reservationProvider = context.read<ReservationProvider>();
    UserInfoStruct userDetails = context.read<UserProvider>().userDetails;

    // Reset reservation data
    reservationProvider.resetReservation();
    reservationProvider.updateReservation(
        clubName: widget.club.clubName); // Set club name

    if (context.read<GlobalStateProvider>().isAuthenticated) {
      if (userDetails.userID > 0) {
        reservationProvider.updateReservation(
            userID: userDetails.userID); // Set user ID
        String initialName =
            formatName('${userDetails.firstName} ${userDetails.lastName}');
        reservationProvider.updateReservation(reservationName: initialName);
        setState(() {
          _nameController.text = initialName;
        });
      } else {
        setState(() {
          context.read<UserProvider>().fetchUserDetailsFromServer();
          reservationProvider.updateReservation(
              userID: userDetails.userID); // Set user ID
          String initialName =
              formatName('${userDetails.firstName} ${userDetails.lastName}');
          reservationProvider.updateReservation(reservationName: initialName);
          _nameController.text = initialName;
        });
      }
    }

    // Fetch and initialize catalogues for the selected club
    final catalogues = context
        .read<ClubProvider>()
        .getAllCataloguesForClubWithID(widget.club.clubID);

    setState(() {
      localCatalogues[0] = catalogues[0];
      localCatalogues[1] = catalogues[1];
      localCatalogues[2] = catalogues[2];

      // Update the max persons and calculate the total price for the reservation
      updateMaxPersons();
      calculatePrice();
    });
  }

  /// Updates the maximum number of persons allowed based on selected services (bottles).
  void updateMaxPersons() {
    final reservationProvider = context.read<ReservationProvider>();

    int maxPersons = (localCatalogues[0].maxPersons *
                reservationProvider.reservation.regularBottles +
            localCatalogues[1].maxPersons *
                reservationProvider.reservation.specialBottles +
            localCatalogues[2].maxPersons *
                reservationProvider.reservation.premiumBottles)
        .toInt();

    // Ensure at least one person is allowed for the reservation
    maxPersons = maxPersons > 0 ? maxPersons : 1;

    // Update max persons in the provider
    reservationProvider.setMaxPersons(maxPersons);

    // Adjust persons in the reservation if it exceeds the max
    if (reservationProvider.reservation.numberOfPersons > maxPersons) {
      reservationProvider.updateReservation(numPersons: maxPersons);
    }
  }

  /// Calculates the total price based on the selected services and applies any discount.
  void calculatePrice() {
    final reservationProvider = context.read<ReservationProvider>();
    int regularBottles = reservationProvider.reservation.regularBottles;
    int specialBottles = reservationProvider.reservation.specialBottles;
    int premiumBottles = reservationProvider.reservation.premiumBottles;

    double price = (regularBottles * safeParse(localCatalogues[0].price)) +
        (specialBottles * safeParse(localCatalogues[1].price)) +
        (premiumBottles * safeParse(localCatalogues[2].price));

    // Apply discount if applicable
    if (isDiscountApplied) {
      if (regularBottles >= 1) {
        price -= (safeParse(localCatalogues[0].price) *
                reservationProvider.reservation.discountPercentage) /
            100;
      } else if (specialBottles >= 1) {
        price -= (safeParse(localCatalogues[1].price) *
                reservationProvider.reservation.discountPercentage) /
            100;
      } else if (premiumBottles >= 1) {
        price -= (safeParse(localCatalogues[2].price) *
                reservationProvider.reservation.discountPercentage) /
            100;
      }
    }

    // Update the calculated price in the provider
    reservationProvider.updateReservation(totalPrice: price);
  }

  /// Refreshes the page to fetch the latest catalogues for the selected club.
  Future<void> _refresh() async {
    context.read<GlobalStateProvider>().refreshReservationPage = false;
    final clubProvider = context.read<ClubProvider>();
    try {
      // Fetch updated catalogues
      await clubProvider.fetchClub(widget.club.clubID);
      await clubProvider.fetchCatalogues(widget.club);

      final catalogues =
          clubProvider.getAllCataloguesForClubWithID(widget.club.clubID);

      _updateCatalogues(catalogues);
      successPrint('${widget.club.clubName} is up to date');
      if (mounted && context.read<GlobalStateProvider>().isAuthenticated) {
        setState(() {
          context.read<UserProvider>().fetchUserDetailsFromServer();
        });
      }
    } catch (error) {
      // Log error without additional snack bars
      errorPrint("Failed to refresh catalogues: $error");
    }
  }

  void _updateCatalogues(List<CatalogueInfoStruct> catalogues) {
    setState(() {
      localCatalogues[0] = catalogues[0];
      localCatalogues[1] = catalogues[1];
      localCatalogues[2] = catalogues[2];
      updateMaxPersons();
      calculatePrice();
    });
  }

  @override
  void dispose() {
    // Clean up the controllers to free up resources
    _nameController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isAuthenticated =
        context.watch<GlobalStateProvider>().isAuthenticated;
    final bool hasVerifiedEmail =
        context.watch<GlobalStateProvider>().hasVerifiedEmail;
    if (context.watch<GlobalStateProvider>().refreshReservationPage == true) {
      _refresh();
    }
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
          appBar: _buildAppBar(context, widget.club.clubName),
          backgroundColor: const Color.fromARGB(255, 39, 39, 39),
          body: RefreshIndicator.adaptive(
            color: appRedColor,
            onRefresh: _refresh, // Handle refresh action
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black, Color.fromARGB(255, 39, 39, 39)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ListView(
                    controller: _scrollController,
                    children: [
                      buildContent(isAuthenticated, hasVerifiedEmail),
                      if (isAuthenticated) ...[
                        SizedBox(height: 20.h),
                        buildDiscountCheckbox(), // Discount checkbox
                        SizedBox(height: 20.h),
                        buildSubmitButton(hasVerifiedEmail), // Submit button
                        SizedBox(height: 80.h),
                      ]
                    ],
                  ),
                ),
                if (!hasVerifiedEmail && isAuthenticated)
                  EmailConfirmationNotification(
                    text:
                        'Για να προχωρήσεις σε κράτηση παρακαλώ επιβεβαίωσε το email σου',
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, String clubName) {
    return AppBar(
        toolbarHeight: 60.h,
        leadingWidth: 50.w,
        iconTheme: IconThemeData(
          color: Colors.white,
          size: 30.sp,
        ),
        titleTextStyle: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20.sp),
        centerTitle: false,
        backgroundColor: Colors.black,
        title: Text(
          clubName,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
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
          ),
          SizedBox(width: 5.w)
        ]);
  }

  /// Builds the content section with form fields for reservation details.
  Widget buildContent(bool isAuthenticated, bool hasVerifiedEmail) {
    return Container(
      padding: EdgeInsets.only(left: 25.w, right: 25.w),
      child: Column(
        children: [
          if (!hasVerifiedEmail &&
              isAuthenticated) //top 'resend-email' banner is visible
            SizedBox(height: 60.h),
          SizedBox(height: 20.h),
          buildClubImage(), // Display club image
          SizedBox(height: 40.h),
          WorkingDays(schedule: widget.club.clubAvailableDays),
          SizedBox(height: 15.h),
          LocationWidget(locationName: widget.club.clubLocation),

          isAuthenticated
              ? Column(
                  children: [
                    AlertsList(alerts: widget.club.clubInfo),
                    SizedBox(height: 60.h),
                    buildTitle('Κάνε κράτηση'), // Display booking form
                    SizedBox(height: 10.h),
                    buildReservationForm(),
                  ],
                )
              : Column(
                  children: [
                    SizedBox(height: 60.h),
                    buildTitle('Ενδιαφέρεσαι για κράτηση;'),
                    SizedBox(height: 30.h),
                    BuildSignInOrRegisterButton(context: context),
                    SizedBox(height: 100.h),
                  ],
                ), // Build reservation form
        ],
      ),
    );
  }

  /// Builds the club image or a placeholder in case of an error.
  Widget buildClubImage() {
    return ClipRRect(
        borderRadius: BorderRadius.circular(15.r),
        child: SizedBox(
            height: 250.h,
            width: ScreenUtil().screenWidth,
            child: widget.club.localPhotoPath.isNotEmpty
                ? Image(
                    fit: BoxFit.fill,
                    image: FileImage(File(widget.club.localPhotoPath)),
                    errorBuilder: (BuildContext context, Object error,
                        StackTrace? stackTrace) {
                      // If loading from the file fails, attempt to load from the network
                      return loadNetworkImage();
                    },
                  )
                : loadNetworkImage()));
  }

  Widget loadNetworkImage() {
    if (widget.club.clubPhoto.isNotEmpty) {
      return Image.network(
        widget.club.clubPhoto,
        fit: BoxFit.fill,
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(
              color: appRedColor,
              backgroundColor: Colors.black,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) {
          // If loading from the network fails, show the loading indicator
          return const Center(
            child: CircularProgressIndicator(
              color: appRedColor,
              backgroundColor: Colors.black,
              strokeWidth: 2,
            ),
          );
        },
      );
    } else {
      // If there's no image path, just show a loading indicator
      return const Center(
        child: CircularProgressIndicator(
          color: appRedColor,
          backgroundColor: Colors.black,
          strokeWidth: 2,
        ),
      );
    }
  }

  /// Builds the reservation form with various input fields.
  Widget buildReservationForm() {
    int getDayOfWeekFromDateString(String dateString) {
      if (dateString.isEmpty || dateString == "") {
        return -1;
      }
      // Parse the string to a DateTime object
      DateTime date = DateTime.parse(dateString);

      // Get the weekday (1 = Monday, 7 = Sunday)
      int weekday = date.weekday;

      // Return the weekday as 1 (Monday) to 7 (Sunday)
      return weekday;
    }

    int day = getDayOfWeekFromDateString(
        context.watch<ReservationProvider>().reservation.reservationDate);
    bool showLabel = day >= 0 &&
        day <= 7 &&
        context.watch<ReservationProvider>().reservation.totalPrice > 0;

    return Column(
      children: [
        NameTextField(nameController: _nameController),
        SizedBox(height: 20.h),
        BookingDatePicker(
            days: widget.club.clubAvailableDays,
            unavailableDays: widget.club.clubNotAvailable),
        SizedBox(height: 20.h),
        CategoriesTextField(
          key: categoriesTextFieldKey,
          regularCatalogue: localCatalogues[0],
          specialCatalogue: localCatalogues[1],
          premiumCatalogue: localCatalogues[2],
          onCountersChanged: () {
            updateMaxPersons(); // Update max persons based on selected services
            calculatePrice(); // Recalculate total price
          },
        ),
        SizedBox(height: 20.h),
        const PersonsTextField(),
        SizedBox(height: 20.h),
        CommentSection(
            commentController: _commentController), // Optional comment field
        if (showLabel)
          Text(
            day == 7 // Sunday
                ? 'Από την κράτηση σου θα κερδίσεις 100 πόντους'
                : day == 6 // Saturday
                    ? 'Από την κράτηση σου θα κερδίσεις 50 πόντους'
                    : day == 5 // Friday
                        ? 'Από την κράτηση σου θα κερδίσεις 75 πόντους'
                        : 'Από την κράτηση σου θα κερδίσεις 150 πόντους', // All the rest
            style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500),
          )
      ],
    );
  }

  /// Builds the discount checkbox if the user has enough points.
  Widget buildDiscountCheckbox() {
    return context.read<UserProvider>().userDetails.points >= 400 &&
            buttonIsVisible
        ? GestureDetector(
            onTap: () => _toggleDiscount(), // Toggle discount application
            child: Row(
              children: [
                SizedBox(width: 20.w),
                Transform.scale(
                  scale: 0.8.sp,
                  child: Checkbox(
                    value: isDiscountApplied,
                    onChanged: (value) => _toggleDiscount(),
                    activeColor: appRedColor,
                  ),
                ),
                SizedBox(width: 5.w),
                Text(
                  'Χρήση εκπτωτικού κουπονιού 20%',
                  style: TextStyle(color: Colors.white, fontSize: 15.sp),
                ),
                IconButton(
                    onPressed: () {
                      showFloatingSnackBar(
                          "Η έκπτωση εφαρμόζεται στην πρώτη φιάλη της κράτησης",
                          Duration(seconds: 4),
                          context);
                    },
                    icon: const Icon(Icons.info_outline),
                    color: const Color.fromARGB(255, 88, 88, 88),
                    iconSize: 18.sp),
              ],
            ),
          )
        : const SizedBox.shrink(); // Do not show if points are insufficient
  }

  /// Toggles the discount and recalculates the total price.
  void _toggleDiscount() {
    setState(() {
      isDiscountApplied = !isDiscountApplied;
      context
          .read<ReservationProvider>()
          .updateReservation(discountPercentage: isDiscountApplied ? 20 : 0);
      calculatePrice(); // Recalculate price with the discount
    });
  }

  /// Builds the submit button for the reservation form.
  Widget buildSubmitButton(bool hasVerifiedEmail) {
    return buttonIsVisible
        ? Container(
            alignment: Alignment.center,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 10,
                  padding:
                      EdgeInsets.symmetric(horizontal: 30.w, vertical: 15.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                  backgroundColor: appRedColor,
                ),
                onPressed: () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  _handleSubmit(hasVerifiedEmail); // Handle form submission
                },
                child: Text(
                  'Κράτηση',
                  style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 20.sp),
                )))
        : const Center(
            child: CircularProgressIndicator(
              color: appRedColor,
            ),
          );
  }

  /// Handles the form submission process, including validation and API calls.
  Future<void> _handleSubmit(bool hasVerifiedEmail) async {
    if (!hasVerifiedEmail) {
      showFloatingSnackBar('Παρακαλώ επιβεβαίωσε πρώτα το email σου',
          const Duration(milliseconds: 4000), context);
      return;
    }

    String phone = context.read<UserProvider>().userDetails.phone;

    if (phone.length != 10 || !phone.startsWith('69')) {
      if (!phoneOtpService.canSend) {
        if (phoneOtpService.awaitMinutes == 1) {
          showFloatingSnackBar(
              'Ξαναδοκίμασε σε 1 λεπτό', Duration(seconds: 4), context);
        } else {
          showFloatingSnackBar(
              'Ξαναδοκίμασε σε ${phoneOtpService.awaitMinutes} λεπτά',
              Duration(seconds: 4),
              context);
        }
      } else {
        var isPhoneValid = await showFillPhoneDialog(context);
        if (isPhoneValid.isSuccess) {
          var phone = isPhoneValid.phone;
          if (phone.length == 10 && phone.startsWith('69')) {
            int result = await changePhoneOnServerOnly(phone);
            if (result == 0) {
              if (mounted) {
                context.read<UserProvider>().fetchUserDetailsFromServer();
                context.read<GlobalStateProvider>().refreshProfilePage = true;

                showFloatingSnackBar(
                    'Επιτυχής προσθήκη κινητού', Duration(seconds: 4), context);
              }
            } else {
              if (result == 2) {
                if (mounted) {
                  showFloatingSnackBar(
                      'Αυτός ο αριμός τηλεφώνου χρησιμοποιείται ήδη',
                      Duration(seconds: 4),
                      context);
                }
              }
            }
          } else {
            if (mounted) {
              showFloatingSnackBar(
                  'Υπήρξε κάποιο πρόβλημα. Προσπάθησε ξανά σε λίγο',
                  Duration(seconds: 4),
                  context);
            }
          }
        }
      }
      return;
    }

    String rawName = _nameController.text;
    String formattedName = formatName(rawName);
    if (formattedName.isNotEmpty) {
      context
          .read<ReservationProvider>()
          .updateReservation(reservationName: formattedName);
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
    void onConfirm() async {
      Navigator.of(context, rootNavigator: true).pop();
      setState(() {
        buttonIsVisible = false;
      });
      try {
        // Call the refreshAccessToken method on the instance
        await refreshAccessToken(); // Ensure token is valid before submission

        // Fetching catalogues, wrapped in a try-catch for error handling
        if (mounted) {
          await context.read<ClubProvider>().fetchCatalogues(widget.club);
        }
      } catch (e) {
        setState(() {
          buttonIsVisible = true;
        });
        if (mounted) {
          showFloatingSnackBar(
              'Υπήρξε κάποιο σφάλμα στην κράτησή. Παρακαλώ προσπάθησε ξανά ή επικοινώνησε μαζί μας',
              const Duration(milliseconds: 2000),
              context);
        }

        // Log error or handle failure in a way without more snack bars
        // print("❌Booking submission failed.");
        return;
      }

      // Submit the reservation form
      bool success = await submitForm(
        reservationProvider.reservation.reservationName,
        reservationProvider.reservation.clubName,
        _generateFourBitString(),
        reservationProvider.reservation.reservationDate,
        reservationProvider.reservation.numberOfPersons.toString(),
        reservationProvider.reservation.comment,
      );
      // Retract points if a discount is applied
      if (isDiscountApplied && success) {
        await retractPoints(400);
      }
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

    String date = reservationProvider.reservation.reservationDate;
    final price = reservationProvider.reservation.totalPrice;

    final formattedDate = formatDate(date);
    final formattedPrice = price.toStringAsFixed(2);

    return Center(
      child: Material(
        // ignore: deprecated_member_use
        color: Colors.black.withOpacity(0.8),
        child: Container(
          padding: EdgeInsets.all(15.sp),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: appRedColor, width: 4),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Επιβεβαίωση Κράτησης',
                style: TextStyle(
                  color: appRedColor,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15.h),
              buildInfoRow('Όνομα κράτησης:',
                  reservationProvider.reservation.reservationName),
              buildInfoRow('Μαγαζί:', reservationProvider.reservation.clubName),
              buildInfoRow('Άτομα:',
                  reservationProvider.reservation.numberOfPersons.toString()),
              buildInfoRow('Ημερομηνία:', formattedDate),
              buildInfoRow('Συνολική Τιμή:', '$formattedPrice €'),
              SizedBox(height: 15.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: onCancel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 67, 67, 67),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(5.sp),
                      child: Text(
                        'Ακύρωση',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appRedColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(5.sp),
                      child: Text(
                        'Επιβεβαίωση',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                        ),
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

  /// Validates the form inputs before submission.
  bool _validateForm() {
    final RegExp namePattern =
        RegExp(r'^[\p{L}]+(\s+)[\p{L}]+$', unicode: true);
    final reservationProvider = context.read<ReservationProvider>();

    // Add comment to reservation list
    reservationProvider.updateReservation(
        comment: _commentController.text.trim());

    // Validate name and check if all required fields are filled
    bool isNameValid =
        namePattern.hasMatch(reservationProvider.reservation.reservationName);
    bool allFieldsFilled = reservationProvider.reservation.userID != -1 &&
        reservationProvider.reservation.reservationName.isNotEmpty &&
        reservationProvider.reservation.clubName.isNotEmpty &&
        reservationProvider.reservation.numberOfPersons > 0 &&
        reservationProvider.reservation.totalPrice > 0 &&
        reservationProvider.reservation.regularBottles >= 0 &&
        reservationProvider.reservation.specialBottles >= 0 &&
        reservationProvider.reservation.premiumBottles >= 0 &&
        reservationProvider.reservation.reservationDate.isNotEmpty &&
        isNameValid; // Assuming this is a separate validation check

    String fourBitString = _generateFourBitString();

    return allFieldsFilled &&
        fourBitString.isNotEmpty &&
        fourBitString != '0000';
  }

  /// Shows an error message if the form validation fails.
  void _showValidationError() {
    final bool isNameValid = RegExp(r'^[\p{L}]+(\s+)[\p{L}]+$', unicode: true)
        .hasMatch(
            context.read<ReservationProvider>().reservation.reservationName);

    showFloatingSnackBar(
        isNameValid
            ? 'Παρακαλώ συμπλήρωσε όλα τα πεδία'
            : 'Μόνο ονοματεπώνυμο στο όνομα κράτησης',
        const Duration(milliseconds: 2000),
        context);

    setState(() {
      buttonIsVisible = true;
      // Show the nav bar again when button is visible
    });
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
        if (mounted) {
          context.read<UserProvider>().fetchUserDetailsFromServer();
          context.read<GlobalStateProvider>().refreshProfilePage = true;
        }
        // If the user confirmed (result == true), perform actions
        if (result == true) {
          if (mounted) {
            context.read<BottomNavBarVisibility>().show();
            Navigator.pop(context); // Navigate back to the previous page
          }
        }
      }
    } else {
      showFloatingSnackBar(
          'Υπήρξε κάποιο σφάλμα στην κράτησή. Παρακαλώ προσπάθησε ξανά ή επικοινώνησε μαζί μας',
          const Duration(milliseconds: 2000),
          context);
      setState(() {
        buttonIsVisible = true; // Show the button again
      });
    }
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

  /// Generates a four-bit string required for form submission.
  String _generateFourBitString() {
    final reservation = context.read<ReservationProvider>().reservation;
    return '${reservation.regularBottles}${reservation.specialBottles}${reservation.premiumBottles}${reservation.discountPercentage ~/ 10}';
  }
}
