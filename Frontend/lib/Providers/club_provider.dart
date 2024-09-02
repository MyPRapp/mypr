import 'package:flutter/material.dart';

import '../global_components.dart';
import 'club_provider_helpers/club_fetcher.dart';
import 'club_provider_helpers/club_loader.dart';
import 'club_provider_helpers/club_manager.dart';
import 'club_provider_helpers/club_persistence.dart';

class ClubProvider with ChangeNotifier {
  final List<ClubInfoStruct> _clubs = [];
  final List<CatalogueInfoStruct> _catalogues = [];
  final List<int> _likedClubIDs = [];

  late final ClubManager _clubManager;
  late final ClubLoader _clubLoader;
  late final ClubPersistence _clubPersistence;
  late final ClubFetcher _clubFetcher;

  ClubProvider() {
    _clubManager =
        ClubManager(_clubs, _catalogues, _likedClubIDs, notifyListeners);

    _clubLoader =
        ClubLoader(_clubs, _catalogues, _likedClubIDs, notifyListeners);
    _clubPersistence =
        ClubPersistence(_clubs, _catalogues, _likedClubIDs, notifyListeners);
    _clubFetcher = ClubFetcher(_clubManager, _clubPersistence, notifyListeners);
  }

  Future<void> syncClubs() async {
    try {
      // Attempt to fetch clubs and catalogues from the network
      await _clubFetcher.fetchClubsAndCatalogues();
    } catch (e) {
      // If there's an error, load clubs and catalogues from local storage
      print('Error fetching club data, loading from preferences: $e');
      await _clubLoader.loadClubsFromPreferences();
      await _clubLoader.loadCataloguesFromPreferences();
    }

    // Load liked clubs from preferences regardless of the outcome
    await _clubLoader.loadLikedClubsFromPreferences();

    // Notify listeners that the data has been initialized
    notifyListeners();
  }

  Future<void> fetchClubsAndCatalogues() async {
    await _clubFetcher.fetchClubsAndCatalogues();
  }

  Future<void> fetchCatalogues(ClubInfoStruct club) async {
    await _clubFetcher.fetchCatalogues(club);
  }

  // Club Manager Functions
  List<ClubInfoStruct> get allClubs => _clubManager.allClubs;
  List<CatalogueInfoStruct> get allCatalogues => _clubManager.allCatalogues;
  List<ClubInfoStruct> get likedClubs => _clubManager.allLikedClubs;

  List<CatalogueInfoStruct> initializeCatalogues(int clubID) {
    return _clubManager.initializeCatalogues(clubID);
  }

  void addOrUpdateClub(ClubInfoStruct club) {
    _clubManager.addOrUpdateClub(club);
  }

  void removeClub(int clubID) {
    _clubManager.removeClub(clubID);
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

  // Liked Clubs Management
  void toggleLike(int clubID) {
    _clubManager.toggleLike(clubID);
    _clubPersistence.saveLikedClubsToPreferences();
  }

  bool isLiked(int clubID) {
    return _clubManager.isLiked(clubID);
  }

  Future<void> deleteAllLiked() async {
    await _clubManager.deleteAllLiked();
    await _clubPersistence.saveLikedClubsToPreferences();
  }

  // Persistence Functions
  Future<void> saveClubsToPreferences() async {
    await _clubPersistence.saveClubsToPreferences();
  }

  Future<void> saveCataloguesToPreferences() async {
    await _clubPersistence.saveCataloguesToPreferences();
  }

  Future<void> saveLikedClubsToPreferences() async {
    await _clubPersistence.saveLikedClubsToPreferences();
  }

  Future<void> saveImageToPreferences(String key, String base64Image) async {
    await _clubPersistence.saveImageToPreferences(key, base64Image);
  }

  Future<Image> loadImageFromPreferences(String key) async {
    return await _clubPersistence.loadImageFromPreferences(key);
  }

  // Utility / Helper Functions
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

  // Print Functions for Debugging
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
