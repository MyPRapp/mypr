import 'package:flutter/material.dart';

class ClubInfo {
  bool liked;
  String clubName;

  ClubInfo({required this.liked, required this.clubName});
}

class GlobalState extends ChangeNotifier {
  final List<ClubInfo> _clubInfoList = [];

  List<ClubInfo> get clubInfoList => _clubInfoList;

  void addClubInfo(bool liked, String clubName) {
    final index = _clubInfoList.indexWhere((club) => club.clubName == clubName);
    if (index != -1) {
      // Update the liked value of the existing club
      _clubInfoList[index].liked = liked;
    } else {
      // Add new club info
      _clubInfoList.add(ClubInfo(liked: liked, clubName: clubName));
    }
    notifyListeners();
  }
}
