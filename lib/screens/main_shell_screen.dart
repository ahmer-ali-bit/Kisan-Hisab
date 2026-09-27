import 'package:flutter/material.dart';
import '../widgets/common/bottom_nav_bar.dart';
import 'dashboard/dashboard_screen.dart';
import 'people/people_list_screen.dart';
import 'history/history_screen.dart';
import 'reports/reports_dashboard_screen.dart';

class MainShellScreen extends StatefulWidget {
  final int initialTab;

  const MainShellScreen({super.key, this.initialTab = 0});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  void _onNavTapped(int index) {
    // Index 2 = Add Entry (center "+" button), opens as a separate screen
    if (index == 2) {
      Navigator.pushNamed(context, '/select-entry-type');
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _mapIndex(_currentIndex),
        children: const [
          DashboardScreen(), // tab 0
          PeopleListScreen(), // tab 1
          SizedBox(), // tab 2 placeholder (never shown, "+" opens overlay)
          HistoryScreen(), // tab 3
          ReportsDashboardScreen(), // tab 4
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTapped,
      ),
    );
  }

  /// Maps nav indices to IndexedStack child indices.
  /// Nav: 0=Home, 1=People, 2=Add(skip), 3=History, 4=Reports
  /// Stack: 0=Home, 1=People, 2=placeholder, 3=History, 4=Reports
  int _mapIndex(int navIndex) {
    return navIndex;
  }
}
