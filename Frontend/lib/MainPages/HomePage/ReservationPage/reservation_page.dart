import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/OtherPages/global_state.dart';
import 'package:mypr/Widgets/club_card_widgets.dart';
import 'package:mypr/Widgets/reservation_page_widgets.dart';
import 'package:mypr/routes/app_router.gr.dart';
import 'package:provider/provider.dart';

@RoutePage()
class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key, required this.club});
  final ClubInfoStruct club;

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  // Add a list to store the reservation information
  List<dynamic> reservationInfo = [-1, '', '', -1, -1, -1, -1, ''];

  // GlobalKeys to access the state of NameTextField and PersonsTextField
  final GlobalKey<NameTextFieldState> nameTextFieldKey =
      GlobalKey<NameTextFieldState>();
  final GlobalKey<PersonsTextFieldState> personsTextFieldKey =
      GlobalKey<PersonsTextFieldState>();

  int? selectedPrice; // Store the price from the CustomDropdownWithCounter
  int maxPersons = 0; // Track the maximum persons dynamically

  // Create the counters map in the parent widget
  Map<String, int> counters = {
    'Απλό': 0,
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
    reservationInfo = [userDetails?.userID ?? -1, '', '', -1, -1, -1, -1, ''];
  }

  void printReservationInfo(List<dynamic> reservationInfo) {
    print('Reservation Info:');
    print('UserID: ${reservationInfo[0]}');
    print('ReservationName: ${reservationInfo[1]}');
    print('ClubName: ${reservationInfo[2]}');
    print('Persons: ${reservationInfo[3]}');
    print('Regular: ${reservationInfo[4]}');
    print('Special: ${reservationInfo[5]}');
    print('Premium: ${reservationInfo[6]}');
    print('Date: ${reservationInfo[7]}');
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
      maxPersons = regularCatalogue.maxPersons * counters['Απλό']! +
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
          const Text(
            ' Φιάλες και Τιμές',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PackagesInfo(
            package: 'Απλό',
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
            child: PersonsTextField(
              key: personsTextFieldKey, // Assign the key to PersonsTextField
              maxPersons: maxPersons, // Pass the dynamically updated maxPersons
              counters: counters,
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            height: 270,
            child: CategoriesTextField(
              regularCatalogue: regularCatalogue,
              specialCatalogue: specialCatalogue,
              premiumCatalogue: premiumCatalogue,
              counters: counters, // Pass the map to the widget
              onCountersChanged:
                  updateMaxPersons, // Update maxPersons when counters change
            ),
          ),
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
              onPressed: () {
                final userDetails = context.read<UserProvider>().userDetails;
                // Update the reservationInfo list with the actual values
                reservationInfo[0] = userDetails?.userID;
                reservationInfo[1] =
                    nameTextFieldKey.currentState?.nameController.text ??
                        ''; // Name
                reservationInfo[2] = widget.club.clubName;
                reservationInfo[3] =
                    personsTextFieldKey.currentState?.persons ?? -1; // Persons
                reservationInfo[4] = counters['Απλό']; // Regular
                reservationInfo[5] = counters['Special']; // Special
                reservationInfo[6] = counters['Premium']; // Premium
                reservationInfo[7] = DateTime.now().toString(); // Date

                // Print the list to the terminal
                printReservationInfo(reservationInfo);
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
