import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../global_components.dart';
import 'club_provider_helpers/club_fetcher.dart';
import 'club_provider_helpers/club_loader.dart';
import 'club_provider_helpers/club_manager.dart';
import 'club_provider_helpers/club_saver.dart';

class ClubProvider with ChangeNotifier {
  final List<ClubInfoStruct> _clubs = [];
  final List<CatalogueInfoStruct> _catalogues = [];
  final List<int> _likedClubIDs = [];

  late final ClubManager _clubManager;
  late final ClubLoader _clubLoader;
  late final ClubSaver _clubSaver;
  late final ClubFetcher _clubFetcher;

  ClubProvider() {
    _clubManager =
        ClubManager(_clubs, _catalogues, _likedClubIDs, notifyListeners);
    _clubLoader = ClubLoader(
      _clubs,
      _catalogues,
      _likedClubIDs,
    );
    _clubSaver = ClubSaver(_clubs, _catalogues, _likedClubIDs);
    _clubFetcher = ClubFetcher(
      _clubManager,
      _clubSaver,
    );
  }

  // Syncs clubs from the server, loads from file if fetch fails
  Future<void> syncClubs() async {
    try {
      await _clubFetcher.fetchClubsAndCatalogues(); // Fetch from server
    } catch (e) {
      // Load from local files if fetch fails (offline mode)
      final directory = await getApplicationDocumentsDirectory();
      print("Directory path: ${directory.path}");

      await _clubLoader.loadClubsFromFile();
      await _clubLoader.loadCataloguesFromFile();
    }
    await _clubLoader.loadLikedClubsFromPreferences(); // Load liked clubs
    notifyListeners();
  }

  // Loading club photo with offline-first approach
  Future<ImageProvider?> loadImageFromFileOrNetwork(
      int clubID, String clubPhotoUrl) async {
    Uint8List? imageBytes = await loadClubPhotoFromFile(clubID);

    if (imageBytes != null) {
      return MemoryImage(imageBytes); // Load image from local storage
    } else {
      try {
        // Try fetching from the network (if online)
        return CachedNetworkImageProvider(clubPhotoUrl);
      } catch (e) {
        // If no internet, return a default placeholder
        return const AssetImage('assets/images/default_club_image.png');
      }
    }
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
  }

  Future<void> loadCataloguesFromFile() async {
    await _clubLoader.loadCataloguesFromFile();
  }

  Future<void> loadLikedClubsFromPreferences() async {
    await _clubLoader.loadLikedClubsFromPreferences();
  }

  // Load club photo from the file system
  Future<Uint8List?> loadClubPhotoFromFile(int clubID) async {
    return await _clubLoader.loadClubPhotoFromFile(clubID);
  }

  //// Club Manager Functions
  List<ClubInfoStruct> get allClubs => _clubManager.allClubs;
  List<CatalogueInfoStruct> get allCatalogues => _clubManager.allCatalogues;
  List<ClubInfoStruct> get likedClubs => _clubManager.allLikedClubs;

  List<CatalogueInfoStruct> getAllCatalogues(int clubID) {
    return _clubManager.getAllCatalogues(clubID);
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

  //// Liked Clubs Management (Stored in SharedPreferences)
  void toggleLike(int clubID) {
    _clubManager.toggleLike(clubID);
    _clubSaver.saveLikedClubsToPreferences(); // Save to SharedPreferences
  }

  bool isLiked(int clubID) {
    return _clubManager.isLiked(clubID);
  }

  Future<void> deleteAllLiked() async {
    await _clubManager.deleteAllLiked();
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

  Future<void> saveLikedClubsToPreferences() async {
    await _clubSaver
        .saveLikedClubsToPreferences(); // Save liked clubs in SharedPreferences
  }

  Future<void> saveClubPhotoToFile(int clubID, Uint8List photoBytes) async {
    await _clubSaver.saveClubPhotoToFile(clubID, photoBytes);
  }

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
