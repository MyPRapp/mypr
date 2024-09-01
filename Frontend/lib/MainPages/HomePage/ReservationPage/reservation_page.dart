import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/Widgets/club_card_widgets.dart';
import 'package:mypr/Widgets/reservation_page_widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Providers/club_provider.dart';
import '../../../Providers/user_provider.dart';
import '../../../global_.components.dart';
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
  final GlobalKey<NameTextFieldState> nameTextFieldKey =
      GlobalKey<NameTextFieldState>();
  final GlobalKey<PersonsTextFieldState> personsTextFieldKey =
      GlobalKey<PersonsTextFieldState>();

  int? selectedPrice;
  int maxPersons = 0;
  bool isDiscountApplied = false;
  bool buttonIsVisible = true;

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
    updateMaxPersons();
    _loadInitialData();
    _toggleNavBarVisibility(); // Set initial visibility based on buttonIsVisible
  }

  Future<void> _loadInitialData() async {
    final userDetails = context.read<UserProvider>().userDetails;
    setState(() {
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
        0,
      ];
    });
  }

  int _currentPoints = 0;
  final PointsService _pointsService = PointsService();

  Future<void> _retractPoints(int pointsToRetract) async {
    try {
      int updatedPoints = await _pointsService.retractPoints(pointsToRetract);
      setState(() {
        _currentPoints = updatedPoints;
      });
      print(
          "$pointsToRetract points retracted successfully. Current points: $_currentPoints");
    } catch (error) {
      print("Failed to retract points: $error");
    }
  }

  void _toggleNavBarVisibility() {
    final bottomNavBarVisibility = context.read<BottomNavBarVisibility>();
    if (buttonIsVisible) {
      bottomNavBarVisibility.show();
    } else {
      bottomNavBarVisibility.hide();
    }
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
    print('Discount(%): ${reservationInfo[10]}');
  }

  void initializeCatalogues() {
    ClubProvider clubProvider = context.read<ClubProvider>();
    final catalogues = clubProvider.getCataloguesByClubID(widget.club.clubID);

    regularCatalogue =
        clubProvider.getCatalogue(catalogues, widget.club, 'Regular');
    specialCatalogue =
        clubProvider.getCatalogue(catalogues, widget.club, 'Single');
    if ((double.parse(specialCatalogue.price)).toInt() <=
        (double.parse(regularCatalogue.price)).toInt()) {
      specialCatalogue =
          clubProvider.getCatalogue(catalogues, widget.club, 'Special');
    }
    premiumCatalogue =
        clubProvider.getCatalogue(catalogues, widget.club, 'Premium');
  }

  void updateMaxPersons() {
    setState(() {
      maxPersons = regularCatalogue.maxPersons * counters['Απλή']! +
          specialCatalogue.maxPersons * counters['Special']! +
          premiumCatalogue.maxPersons * counters['Premium']!;
    });
  }

  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
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

  Future<void> _refresh() async {
    ClubProvider clubProvider = context.read<ClubProvider>();
    await clubProvider.fetchCatalogues(widget.club);
    initializeCatalogues();
    updateMaxPersons();
    setState(() {});
    print('Page refreshed');
  }

  Future<ImageProvider> _loadImage() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? base64Image = prefs.getString('club_image_${widget.club.clubID}');
      if (base64Image != null) {
        return MemoryImage(base64Decode(base64Image));
      }
      return NetworkImage(widget.club.clubPhoto);
    } catch (e) {
      return const AssetImage('assets/images/default_club_image.png');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: buttonIsVisible,
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
                buildContent(),
              ],
            ),
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
                    Navigator.pop(context);
                    AutoRouter.of(context).popUntilRoot();
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
    final userDetails = context.read<UserProvider>().userDetails;
    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: SizedBox(
                width: 520,
                height: 350,
                child: FutureBuilder<ImageProvider>(
                  future: _loadImage(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData) {
                      return Image(
                        image: snapshot.data!,
                        fit: BoxFit.fill,
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
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
              key: nameTextFieldKey,
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            height: 70,
            child: BookingDatePicker(
              onDateSelected: (selectedDate) {
                reservationInfo[8] = selectedDate.toString();
              },
              days: widget.club.clubAvailability,
            ),
          ),
          const SizedBox(height: 25),
          CategoriesTextField(
            regularCatalogue: regularCatalogue,
            specialCatalogue: specialCatalogue,
            premiumCatalogue: premiumCatalogue,
            counters: counters,
            onCountersChanged: () {
              updateMaxPersons();
              calculatePrice();
            },
            isDiscountApplied: isDiscountApplied,
            discount: reservationInfo[10],
          ),
          const SizedBox(height: 25),
          SizedBox(
            height: 70,
            child: PersonsTextField(
              key: personsTextFieldKey,
              maxPersons: maxPersons,
              counters: counters,
            ),
          ),
          CommentSection(
            commentController: _commentController,
          ),
          const SizedBox(height: 25),
          if (userDetails!.points >= 20)
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isDiscountApplied = !isDiscountApplied;
                      reservationInfo[10] = isDiscountApplied ? 20 : 0;
                      calculatePrice();

                      final categoriesTextFieldState = context
                          .findAncestorStateOfType<CategoriesTextFieldState>();
                      categoriesTextFieldState?.updateSelectedText();
                    });
                  },
                  child: Row(
                    children: [
                      Checkbox(
                        value: isDiscountApplied,
                        onChanged: (value) {
                          setState(() {
                            isDiscountApplied = value!;
                            reservationInfo[10] = isDiscountApplied ? 20 : 0;
                            calculatePrice();

                            final categoriesTextFieldState =
                                context.findAncestorStateOfType<
                                    CategoriesTextFieldState>();
                            categoriesTextFieldState?.updateSelectedText();
                          });
                        },
                        activeColor: const Color(0xFF9C0C04),
                      ),
                      const Text(
                        'Χρήση εκπτωτικού κουπονιού 20%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: 25),
          if (buttonIsVisible)
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

                  setState(() {
                    buttonIsVisible = false;
                    _toggleNavBarVisibility(); // Hide the nav bar when button is not visible
                  });

                  String rawName = nameTextFieldKey
                          .currentState?.nameController.text ??
                      '${userDetails?.firstName ?? ''} ${userDetails?.lastName ?? ''}';
                  String formattedName = formatName(rawName);

                  reservationInfo[0] = userDetails?.userID ?? -1;
                  reservationInfo[1] = formattedName;
                  reservationInfo[2] = widget.club.clubName;
                  reservationInfo[3] =
                      personsTextFieldKey.currentState?.persons ?? -1;
                  reservationInfo[5] = counters['Απλή'];
                  reservationInfo[6] = counters['Special'];
                  reservationInfo[7] = counters['Premium'];
                  reservationInfo[9] = _commentController.text;

                  if (isDiscountApplied) {
                    await _retractPoints(20);
                    reservationInfo[10] = 20;
                  } else {
                    reservationInfo[10] = 0;
                  }

                  calculatePrice();
                  String fourBitString =
                      '${reservationInfo[5]}${reservationInfo[6]}${reservationInfo[7]}${reservationInfo[10] ~/ 10}';

                  final RegExp namePattern =
                      RegExp(r'^[\p{L}]+(\s+)[\p{L}]+$', unicode: true);

                  bool isNameValid = namePattern.hasMatch(reservationInfo[1]);

                  bool allFieldsFilled = reservationInfo
                          .sublist(1, 8)
                          .every((element) => element != '' && element != -1) &&
                      isNameValid;

                  if (isNameValid) {
                    nameTextFieldKey.currentState?.nameController.text =
                        reservationInfo[1];
                  }

                  if (!allFieldsFilled) {
                    if (mounted) {
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
                  } else if (reservationInfo[4] == 0 ||
                      reservationInfo[8].isEmpty ||
                      fourBitString == '' ||
                      fourBitString[0] == '0000') {
                    if (mounted) {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(
                            content: Text('Παρακαλώ συμπληρώστε όλα τα πεδία'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                    }
                    setState(() {
                      buttonIsVisible = true;
                      _toggleNavBarVisibility(); // Show the nav bar when button is visible
                    });
                  } else {
                    bool success = await _bookingService.submitForm(
                      reservationInfo[1],
                      reservationInfo[2],
                      fourBitString,
                      reservationInfo[8],
                      reservationInfo[3].toString(),
                      reservationInfo[9],
                    );
                    print(fourBitString);
                    if (!mounted) return;

                    if (success) {
                      printReservationInfo(reservationInfo);
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return ConfirmationDialog(
                              reservationInfo: reservationInfo);
                        },
                      );
                    } else {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Υπήρξε κάποιο σφάλμα στην κράτησή σας. Παρακαλώ προσπαθήστε ξανά ή επικοινωνήστε μαζί μας.'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                    }
                    setState(() {
                      buttonIsVisible = true;
                      _toggleNavBarVisibility(); // Show the nav bar when button is visible
                    });
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
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}
