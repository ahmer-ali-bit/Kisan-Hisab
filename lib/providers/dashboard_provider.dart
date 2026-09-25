import 'dart:async';
import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../models/entry_model.dart';
import '../services/entry_service.dart';
import '../services/people_service.dart';
import '../utils/formatters.dart';

class ActivityItem {
  final String title;
  final String subtitle;
  final String time;
  final String type;

  ActivityItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.type,
  });
}

class DashboardProvider extends ChangeNotifier {
  double _toReceive = 0;
  double _toPay = 0;
  double _kapasTotalMann = 0;
  double _paaniTotalHours = 0;
  List<ActivityItem> _recentActivities = [];
  bool _isLoading = false;

  StreamSubscription? _peopleSub;
  StreamSubscription? _entriesSub;

  double get toReceive => _toReceive;
  double get toPay => _toPay;
  double get kapasTotalMann => _kapasTotalMann;
  double get paaniTotalHours => _paaniTotalHours;
  List<ActivityItem> get recentActivities => _recentActivities;
  bool get isLoading => _isLoading;

  void startListening() {
    _isLoading = true;
    notifyListeners();

    // 1. Listen to People for To Receive / To Pay totals
    _peopleSub?.cancel();
    _peopleSub = PeopleService.getPeopleStream().listen((people) {
      double rSum = 0;
      double pSum = 0;
      for (var p in people) {
        rSum += p.totalToReceive;
        pSum += p.totalToPay;
      }
      _toReceive = rSum;
      _toPay = pSum;
      _isLoading = false;
      notifyListeners();
    }, onError: (_) {
      _isLoading = false;
      notifyListeners();
    });

    // 2. Listen to Entries for Kapas, Paani stats & Recent Activity
    _entriesSub?.cancel();
    _entriesSub = EntryService.getEntriesStream().listen((entries) {
      double kapas = 0;
      double paani = 0;

      for (var e in entries) {
        if (e.type == EntryTypes.kapas) {
          kapas += (e.typeData['weight'] ?? 0).toDouble();
        } else if (e.type == EntryTypes.paani) {
          paani += (e.typeData['hours'] ?? 0).toDouble();
        }
      }

      _kapasTotalMann = kapas;
      _paaniTotalHours = paani;

      // Top 3 Recent Activities
      _recentActivities = entries.take(3).map((e) {
        return ActivityItem(
          title: _getEntryTitle(e),
          subtitle: e.personName ?? AppFormatters.currency(e.amount),
          time: AppFormatters.date(e.date),
          type: e.type,
        );
      }).toList();

      _isLoading = false;
      notifyListeners();
    }, onError: (_) {
      _isLoading = false;
      notifyListeners();
    });
  }

  String _getEntryTitle(EntryModel e) {
    switch (e.type) {
      case EntryTypes.kapas:
        return 'Kapas (${e.typeData['weight'] ?? 0} Mann)';
      case EntryTypes.paani:
        return 'Paani (${e.typeData['hours'] ?? 0} Hours)';
      case EntryTypes.mazdoori:
        return 'Mazdoori (${e.typeData['workType'] ?? ''})';
      case EntryTypes.expense:
        return 'Expense (${e.typeData['category'] ?? ''})';
      case EntryTypes.paymentReceive:
        return 'Received ${AppFormatters.currency(e.amount)}';
      case EntryTypes.paymentPay:
        return 'Paid ${AppFormatters.currency(e.amount)}';
      default:
        return 'Entry';
    }
  }

  void stopListening() {
    _peopleSub?.cancel();
    _entriesSub?.cancel();
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
