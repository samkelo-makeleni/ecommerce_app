import 'package:flutter/material.dart';

/// Example app state provider using Provider pattern
/// Use this as a template for managing app-wide state
class AppProvider extends ChangeNotifier {
  // Example: selected location
  String _selectedLocation = 'Pretoria';
  String get selectedLocation => _selectedLocation;

  void setLocation(String location) {
    _selectedLocation = location;
    notifyListeners();
  }

  // Example: search query
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Add more state properties and methods as needed
}
