import 'dart:async';
import 'package:flutter/material.dart';
import '../models/rate_model.dart';
import '../services/rate_service.dart';

class RateProvider extends ChangeNotifier {
  List<RateModel> _rates = [];
  bool _isLoading = false;
  String? _error;
  String _selectedType = 'kapas'; // Default tab
  StreamSubscription? _subscription;

  List<RateModel> get rates => _rates;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedType => _selectedType;

  // Tab change handler
  void setType(String type) {
    if (_selectedType == type) return;
    _selectedType = type;
    startListening();
  }

  // Start listening to stream
  void startListening() {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = RateService.getRatesStream(_selectedType).listen(
      (list) {
        _rates = list;
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

  // Add Rate
  Future<bool> addRate(RateModel rate) async {
    try {
      _error = null;
      await RateService.addRate(rate);
      return true;
    } catch (e) {
      debugPrint('ADD RATE ERROR: $e');
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete Rate
  Future<bool> deleteRate(String id) async {
    try {
      _error = null;
      await RateService.deleteRate(id);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
