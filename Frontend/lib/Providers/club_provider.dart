import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../global_components.dart';
import 'club_provider_helpers/club_fetcher.dart';
import 'club_provider_helpers/club_loader.dart';
import 'club_provider_helpers/club_manager.dart';
import 'club_provider_helpers/club_saver.dart';

class ClubProvider with ChangeNotifier {
  final List<ClubInfoStruct> _clubs = [];
  final List<CatalogueInfoStruct> _catalogues = [];

  late final ClubManager _clubManager;
  late final ClubLoader _clubLoader;
  late final ClubSaver _clubSaver;
  late final ClubFetcher _clubFetcher;

  ClubProvider() {
    _clubManager = ClubManager(_clubs, _catalogues);
    _clubLoader = ClubLoader(_clubs, _catalogues);
    _clubSaver = ClubSaver(_clubs, _catalogues);
    _clubFetcher = ClubFetcher(_clubManager, _clubSaver);
  }

  // GETTERS
  List<ClubInfoStruct> get allClubs => _clubs;
  List<CatalogueInfoStruct> get allCatalogues => _catalogues;

  // Syncs clubs from the server, loads from file if fetch fails
  Future<void> syncClubs() async {
    print('\x1B[33m------------SYNCING CLUBS------------');
    try {
      await fetchClubsAndCatalogues(); // Fetch from server
    } catch (e) {
      await loadClubsFromFile();
      await loadCataloguesFromFile();
    }
    // await loadLikedClubsFromPreferences(); // Load liked clubs
    print('\x1B[32m------------SYNCED CLUBS------------');
  }

  //// Fetch From Server Functions
  Future<void> fetchClubsAndCatalogues() async {
    await _clubFetcher.fetchClubsAndCatalogues();
  }

  // Fetches catalogues of a single club
  Future<void> fetchCatalogues(ClubInfoStruct club) async {
    await _clubFetcher.fetchCatalogues(club);
  }

  // Fetches one club by its ID
  Future<void> fetchClub(int clubID) async {
    await _clubFetcher.fetchClub(clubID);
  }

  //// Load From File Functions (Replaces SharedPreferences)
  Future<void> loadClubsFromFile() async {
    await _clubLoader.loadClubsFromFile();
    notifyListeners();
  }

  Future<void> loadCataloguesFromFile() async {
    await _clubLoader.loadCataloguesFromFile();
    notifyListeners();
  }

  // Load club photo from the file system
  Future<Uint8List?> loadClubPhotoFromFile(int clubID) async {
    return await _clubLoader.loadClubPhotoFromFile(clubID);
  }

  //// Club Manager Functions
  List<CatalogueInfoStruct> getAllCataloguesForClubWithID(int clubID) {
    return _clubManager.getAllCataloguesForClubWithID(clubID);
  }

  void addOrUpdateClub(ClubInfoStruct club) {
    _clubManager.addOrUpdateClub(club);
  }

  void removeClubWithClubCatalogues(int clubID) {
    _clubManager.removeClubWithClubCatalogues(clubID);
  }

  void addOrUpdateCatalogue(CatalogueInfoStruct catalogue) {
    _clubManager.addOrUpdateCatalogue(catalogue);
  }

  CatalogueInfoStruct getCatalogue(ClubInfoStruct club, String serviceType) {
    return _clubManager.getCatalogue(club, serviceType);
  }

  List<CatalogueInfoStruct> getCataloguesByClubID(int clubID) {
    return _clubManager.getCataloguesByClubID(clubID);
  }

  //// Saving To File Functions
  Future<void> saveClubsToFile() async {
    await _clubSaver
        .saveClubsToFile(); // Save club data to the device directory
  }

  Future<void> saveCataloguesToFile() async {
    await _clubSaver
        .saveCataloguesToFile(); // Save catalogues to the device directory
  }

  // Future<void> saveClubPhotoToFile(int clubID, Uint8List photoBytes) async {
  //   await _clubSaver.saveClubPhotoToFile(clubID, photoBytes);
  // }

  //// Utility / Helper Functions
  String getClubAvailability(String clubName) {
    return _clubManager.getClubAvailability(clubName);
  }

  ClubInfoStruct getClubByID(int clubID) {
    return _clubManager.getClubByID(clubID);
  }

  ClubInfoStruct getClubByName(String clubName) {
    return _clubManager.getClubByName(clubName);
  }

  int getClubIDByName(String clubName) {
    return _clubManager.getClubIDByName(clubName);
  }

  String getClubNameByID(int clubID) {
    return _clubManager.getClubNameByID(clubID);
  }

  //// Print Functions for Debugging
  void printAllClubs() {
    _clubManager.printAllClubs();
  }

  void printAllClubIDsAndNames() {
    _clubManager.printAllClubIDsAndNames();
  }

  void printClub(ClubInfoStruct club) {
    _clubManager.printClub(club);
  }

  void printClubWithID(int id) {
    _clubManager.printClubWithID(id);
  }

  void printClubWithName(String clubName) {
    _clubManager.printClubWithName(clubName);
  }

  void printAllCatalogues() {
    _clubManager.printAllCatalogues();
  }

  void printCatalogue(CatalogueInfoStruct catalogue) {
    _clubManager.printCatalogue(catalogue);
  }
}
