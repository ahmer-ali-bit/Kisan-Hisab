import 'dart:async';
import 'package:flutter/material.dart';
import '../models/person_model.dart';
import '../services/people_service.dart';

class PeopleProvider extends ChangeNotifier {
  List<PersonModel> _people = [];
  List<PersonModel> _filtered = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  StreamSubscription? _subscription;

  List<PersonModel> get people => _filtered;
  List<PersonModel> get allPeople => _people;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  int get count => _people.length;

  // Start listening
  void startListening() {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = PeopleService.getPeopleStream().listen(
      (list) {
        _people = list;
        _applyFilter();
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    _filtered = PeopleService.filterPeople(_people, _searchQuery);
  }

  // Add
  Future<bool> addPerson(PersonModel person) async {
    try {
      _error = null;
      await PeopleService.addPerson(person);
      return true;
    } catch (e) {
      debugPrint('ADD PERSON ERROR: $e');
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update
  Future<bool> updatePerson(PersonModel person) async {
    try {
      _error = null;
      await PeopleService.updatePerson(person);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete
  Future<bool> deletePerson(String id) async {
    try {
      _error = null;
      await PeopleService.deletePerson(id);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  PersonModel? getById(String id) {
    try {
      return _people.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
