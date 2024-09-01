import 'package:flutter/material.dart';

class GlobalStateProvider with ChangeNotifier {
  static final GlobalStateProvider _instance = GlobalStateProvider._internal();
  String _validatedIp = '192.168.1.9';
  bool _dataLoaded = false;

  GlobalStateProvider._internal();

  factory GlobalStateProvider() {
    return _instance;
  }

  String get validatedIp => _validatedIp;

  set validatedIp(String value) {
    _validatedIp = value;
    notifyListeners();
  }

  bool get dataLoaded => _dataLoaded;

  void setDataLoaded(bool value) {
    _dataLoaded = value;
    notifyListeners();
  }
}
