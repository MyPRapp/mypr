import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/OtherPages/global_state.dart';
import 'package:mypr/Widgets/club_card_widgets.dart';
import 'package:mypr/Widgets/reservation_page_widgets.dart';
import 'package:mypr/routes/app_router.gr.dart';
import 'package:provider/provider.dart';

import '../../../services/booking_service.dart';

@RoutePage()
class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key, required this.club});
  final ClubInfoStruct club;

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  // Add a list to store the reservation information
  List<dynamic> reservationInfo = [
    -1,
    '',
    '',
    -1,
    0.0,
    -1,
    -1,
    -1,
    '',
    '',
    0,
  ];

  final BookingService _bookingService = BookingService();
  // GlobalKeys to access the state of NameTextField and PersonsTextField
  final GlobalKey<NameTextFieldState> nameTextFieldKey =
      GlobalKey<NameTextFieldState>();
  final GlobalKey<PersonsTextFieldState> personsTextFieldKey =
      GlobalKey<PersonsTextFieldState>();

  int? selectedPrice; // Store the price from the CustomDropdownWithCounter
  int maxPersons = 0; // Track the maximum persons dynamically
  bool isDiscountApplied = false; // Track discount checkbox state

  // Create the counters map in the parent widget
  Map<String, int> counters = {
    'Απλή': 0,
    'Special': 0,
    'Premium': 0,
  };

  late CatalogueInfoStruct regularCatalogue;
  late CatalogueInfoStruct specialCatalogue;
  late CatalogueInfoStruct premiumCatalogue;

  @override
  void initState() {
    super.initState();
    initializeCatalogues();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BottomNavBarVisibility>().hide();
    });
    updateMaxPersons(); // Initialize maxPersons

    // Initialize the list with default values
    final userDetails = context.read<UserProvider>().userDetails;
    reservationInfo = [
      userDetails?.userID ?? -1,
      '',
      '',
      -1,
      0.0,
      -1,
      -1,
      -1,
      '',
      '',
      20, // Default discount value
    ];
  }

  void printReservationInfo(List<dynamic> reservationInfo) {
    print('Reservation Info:');
    print('UserID: ${reservationInfo[0]}');
    print('ReservationName: ${reservationInfo[1]}');
    print('ClubName: ${reservationInfo[2]}');
    print('Persons: ${reservationInfo[3]}');
    print('Price: ${reservationInfo[4]}');
    print('Regular: ${reservationInfo[5]}');
    print('Special: ${reservationInfo[6]}');
    print('Premium: ${reservationInfo[7]}');
    print('Date: ${reservationInfo[8]}');
    print('Comment: ${reservationInfo[9]}');
    print('Discount: ${reservationInfo[10]}'); // Print the discount value
  }

  // Initialize catalogues outside the build method
  void initializeCatalogues() {
    ClubProvider clubProvider = context.read<ClubProvider>();
    final catalogues = clubProvider.getCataloguesByClubID(widget.club.clubID);

    regularCatalogue =
        clubProvider.getRegularCatalogue(catalogues, widget.club, 'Regular');
    specialCatalogue =
        clubProvider.getRegularCatalogue(catalogues, widget.club, 'Special');
    premiumCatalogue =
        clubProvider.getRegularCatalogue(catalogues, widget.club, 'Premium');
  }

  // Method to calculate and update the maximum persons allowed
  void updateMaxPersons() {
    setState(() {
      maxPersons = regularCatalogue.maxPersons * counters['Απλή']! +
          specialCatalogue.maxPersons * counters['Special']! +
          premiumCatalogue.maxPersons * counters['Premium']!;
    });
  }

  // Function to handle back button press
  void onBackPressed(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BottomNavBarVisibility>().show();
    });
  }

  // Add a TextEditingController for the comment section
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    // Dispose the controller when the widget is disposed
    _commentController.dispose();
    super.dispose();
  }

  void calculatePrice() {
    double price = (counters['Απλή']! * double.parse(regularCatalogue.price)) +
        (counters['Special']! * double.parse(specialCatalogue.price)) +
        (counters['Premium']! * double.parse(premiumCatalogue.price));

    if (isDiscountApplied) {
      price = price * (1 - (reservationInfo[10] / 100));
    }

    setState(() {
      reservationInfo[4] = price;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (bool isPopInvoked) {
        onBackPressed(context);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/otherPhotos/Untitled_Artwork.png'),
              fit: BoxFit.fill,
            ),
          ),
          child: ListView(
            children: [
              buildHeader(context),
              buildContent(),
            ],
          ),
        ),
      ),
    );
  }

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
                    onBackPressed(context);
                    AutoRouter.of(context).push(const HomeRoute());
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
                child: LikeButton(
                  club: widget.club,
                  big: true,
                )),
          ),
        ],
      ),
    );
  }

  Widget buildContent() {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image(
                image: AssetImage(
                  'assets/clubPhotos/${widget.club.clubName}.jpg',
                ),
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 50),
          const Text(
            ' Φιάλες και Τιμές',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PackagesInfo(
            package: 'Απλή',
            maxPersons: regularCatalogue.maxPersons,
            minPrice: double.parse(regularCatalogue.price).toInt(),
          ),
          PackagesInfo(
            package: 'Special',
            maxPersons: specialCatalogue.maxPersons,
            minPrice: double.parse(specialCatalogue.price).toInt(),
          ),
          PackagesInfo(
            package: 'Premium',
            maxPersons: premiumCatalogue.maxPersons,
            minPrice: double.parse(premiumCatalogue.price).toInt(),
          ),
          const SizedBox(height: 40),
          const Text(
            ' Κάνε κράτηση',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 50),
          SizedBox(
            height: 70,
            child: NameTextField(
              key: nameTextFieldKey, // Assign the key to NameTextField
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            height: 70,
            child: BookingDatePicker(
              onDateSelected: (selectedDate) {
                reservationInfo[8] = selectedDate.toString();
              },
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            height: 70,
            child: PersonsTextField(
              key: personsTextFieldKey, // Assign the key to PersonsTextField
              maxPersons: maxPersons, // Pass the dynamically updated maxPersons
              counters: counters,
            ),
          ),
          const SizedBox(height: 25),
          CategoriesTextField(
            regularCatalogue: regularCatalogue,
            specialCatalogue: specialCatalogue,
            premiumCatalogue: premiumCatalogue,
            counters: counters, // Pass the map to the widget
            onCountersChanged: () {
              updateMaxPersons();
              calculatePrice();
            },
            isDiscountApplied: isDiscountApplied, // Pass the discount state
            discount: reservationInfo[10], // Pass the discount value
          ),
          CommentSection(
            commentController: _commentController,
          ),
          const SizedBox(height: 25),
          if (reservationInfo[10] >
              0) // Show only if discount is greater than 0
            Row(
              children: [
                Checkbox(
                  value: isDiscountApplied,
                  onChanged: (value) {
                    setState(() {
                      isDiscountApplied = value!;
                      calculatePrice(); // Recalculate price with discount
                    });
                  },
                  activeColor: const Color(0xFF9C0C04),
                ),
                Text(
                  'Χρήση εκπτωτικού κουπονιού ${reservationInfo[10]}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 25),
          Container(
            alignment: Alignment.center,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF9C0C04),
              ),
              onPressed: () async {
                final userDetails = context.read<UserProvider>().userDetails;

                // Update the reservationInfo list with the actual values
                reservationInfo[0] = userDetails?.userID ?? -1;
                reservationInfo[1] =
                    nameTextFieldKey.currentState?.nameController.text ??
                        ''; // Name
                reservationInfo[2] = widget.club.clubName;
                reservationInfo[3] =
                    personsTextFieldKey.currentState?.persons ?? -1; // Persons
                reservationInfo[5] = counters['Απλή'];
                reservationInfo[6] = counters['Special'];
                reservationInfo[7] = counters['Premium'];
                reservationInfo[9] = _commentController.text; // Comment

                // Calculate the total price
                calculatePrice();

                // Check if all required fields are filled
                bool allFieldsFilled = reservationInfo
                    .sublist(1, 8)
                    .every((element) => element != '' && element != -1);

                if (reservationInfo[4] == 0 || reservationInfo[8].isEmpty) {
                  // If the price is zero or the date is not set, show the SnackBar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Παρακαλώ συμπληρώστε όλα τα πεδία'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                } else if (allFieldsFilled) {
                  // Submit the booking only if all fields are filled and valid
                  bool success = await _bookingService.submitForm(
                    reservationInfo[2], // Club name
                    'Regular', // Adjust this as needed based on selected packages
                    reservationInfo[8], // Date
                    reservationInfo[3].toString(), // Number of persons
                  );

                  if (!mounted) return; // Check if the widget is still mounted

                  if (success) {
                    printReservationInfo(reservationInfo);
                    // Show the confirmation dialog
                    showDialog(
                      context: context,
                      barrierDismissible:
                          false, // Prevent closing by tapping outside
                      builder: (BuildContext context) {
                        return ConfirmationDialog(
                            reservationInfo: reservationInfo);
                      },
                    );
                  } else {
                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Υπήρξε κάποιο σφάλμα στην κράτησή σας. Παρακαλώ προσπαθήστε ξανά ή επικοινωνήστε μαζί μας.'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                } else {
                  if (!mounted) return; // Check if the widget is still mounted
                  // Show error message for incomplete fields
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Παρακαλώ συμπληρώστε όλα τα πεδία'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              child: const Text(
                'Κράτηση',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
