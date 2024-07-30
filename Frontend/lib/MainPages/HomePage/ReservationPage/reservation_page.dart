import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/Widgets/reservation_page_widgets.dart';

@RoutePage()
class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key, required this.clubName});

  final String clubName;

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _personsController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final FocusNode _peopleFocusNode = FocusNode();

  int _counter = 0;
  double _fieldHeight = 50;
  double _customFieldHeight = 50;
  bool _isCounterValid = true;

  void _incrementCounter() {
    setState(() {
      _counter++;
      _personsController.text = _counter.toString();
      _isCounterValid = true; // Reset the counter validation state
    });
  }

  void _decrementCounter() {
    setState(() {
      if (_counter > 0) {
        _counter--;
      }
      _personsController.text = _counter > 0 ? _counter.toString() : '';
      _isCounterValid = _counter > 0;
      if (_counter > 0) {
        _peopleFocusNode.requestFocus();
      } else {
        _customFieldHeight = _personsController.text.isEmpty ? 70 : 50;
        _peopleFocusNode.unfocus();
      }
    });
  }

  void _validateAndSubmit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    setState(() {
      _fieldHeight = _nameController.text.isEmpty ? 70 : 50;
      _customFieldHeight = _personsController.text.isEmpty ? 70 : 50;
      _isCounterValid = _counter > 0;
    });

    if (isValid && _isCounterValid) {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text('Η κράτηση επιβεβαιώθηκε'),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clubName),
        backgroundColor: const Color(0xFF9c0c04),
      ),
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/clubPhotos/Untitled_Artwork.png'),
              fit: BoxFit.fill,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15),
          child: ListView(children: [
            Padding(
              padding: const EdgeInsets.all(35),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image(
                  image: AssetImage('assets/clubPhotos/${widget.clubName}.jpg'),
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
            const PackagesInfo(
              package: 'Απλό',
              maxPersons: 6,
              minPrice: 110,
            ),
            const PackagesInfo(
              package: 'Special',
              maxPersons: 5,
              minPrice: 180,
            ),
            const PackagesInfo(
              package: 'Premium',
              maxPersons: 5,
              minPrice: 300,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 40, bottom: 20),
              child: Text(
                ' Κάνε κράτηση',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: SizedBox(
                      height: _fieldHeight,
                      child: CustomTextFormField(
                        controller: _nameController,
                        labelText: 'Όνομα κράτησης',
                        errorText: 'Εισάγετε όνομα κράτησης',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: SizedBox(
                      height: _fieldHeight,
                      child: CustomTextFormField(
                        controller: _dateController,
                        labelText: 'Ημερομηνία',
                        errorText: 'Εισάγετε ημερομηνία',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: SizedBox(
                      height: _customFieldHeight,
                      child: TextFormField(
                        readOnly: true,
                        controller: _personsController,
                        focusNode: _peopleFocusNode,
                        style: const TextStyle(color: Colors.white),
                        decoration: CustomInputDecoration.getDecoration(
                          increment: _incrementCounter,
                          decrement: _decrementCounter,
                          hintText: '$_counter',
                          isCounterValid: _isCounterValid,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: SizedBox(
                      height: _fieldHeight,
                      child: CustomTextFormField(
                        controller: _categoryController,
                        labelText: 'Κατηγορία',
                        errorText: 'Εισάγετε Κατηγορία',
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 25, bottom: 75),
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
                      onPressed: _validateAndSubmit,
                      child: const Text(
                        'Κράτηση',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}