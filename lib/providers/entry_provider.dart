import 'dart:async';
import 'package:flutter/material.dart';
import '../models/entry_model.dart';
import '../models/rate_model.dart';
import '../services/entry_service.dart';

class EntryProvider extends ChangeNotifier {
  List<EntryModel> _entries = [];
  List<EntryModel> _trash = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _subscription;
  StreamSubscription? _trashSubscription;

  List<EntryModel> get entries => _entries;
  List<EntryModel> get trash => _trash;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Start listening to active entries
  void startListening() {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = EntryService.getEntriesStream().listen(
      (list) {
        _entries = list;
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

  // Start listening to trash
  void startListeningTrash() {
    _trashSubscription?.cancel();
    _trashSubscription = EntryService.getTrashStream().listen(
      (list) {
        _trash = list;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('TRASH STREAM ERROR: $e');
        _error = e.toString();
        _trash = [];
        notifyListeners();
      },
    );
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _trashSubscription?.cancel();
    _trashSubscription = null;
  }

  // Add Entry
  Future<bool> addEntry(EntryModel entry) async {
    try {
      _error = null;
      await EntryService.addEntry(entry);
      return true;
    } catch (e) {
      debugPrint('ADD ENTRY ERROR: $e');
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update Entry
  Future<bool> updateEntry(EntryModel oldEntry, EntryModel newEntry) async {
    try {
      _error = null;
      await EntryService.updateEntry(oldEntry, newEntry);
      return true;
    } catch (e) {
      debugPrint('UPDATE ENTRY ERROR: $e');
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Soft Delete
  Future<bool> deleteEntry(EntryModel entry) async {
    try {
      _error = null;
      await EntryService.softDeleteEntry(entry);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Restore from Trash
  Future<bool> restoreEntry(EntryModel entry) async {
    try {
      _error = null;
      await EntryService.restoreEntry(entry);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Permanent Delete
  Future<bool> permanentDelete(String id) async {
    try {
      _error = null;
      await EntryService.permanentDelete(id);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Fetch latest rate for entry date
  Future<RateModel?> getLatestRate(String type, DateTime date) async {
    try {
      return await EntryService.getLatestRate(type, date);
    } catch (e) {
      debugPrint('GET RATE ERROR: $e');
      return null;
    }
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
