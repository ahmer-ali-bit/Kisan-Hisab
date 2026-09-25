import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kisan_hisab/providers/dashboard_provider.dart';
import 'package:kisan_hisab/providers/entry_provider.dart';
import 'package:kisan_hisab/providers/people_provider.dart';
import 'package:kisan_hisab/providers/rate_provider.dart';
import 'package:kisan_hisab/screens/dashboard/dashboard_screen.dart';
import 'package:kisan_hisab/screens/entries/select_entry_type_screen.dart';
import 'package:kisan_hisab/screens/history/history_screen.dart';
import 'package:kisan_hisab/screens/pending/pending_screen.dart';
import 'package:kisan_hisab/screens/people/people_list_screen.dart';
import 'package:kisan_hisab/screens/rates/rate_management_screen.dart';
import 'package:kisan_hisab/screens/reports/reports_dashboard_screen.dart';
import 'package:kisan_hisab/screens/settings/about_screen.dart';
import 'package:kisan_hisab/screens/settings/backup_restore_screen.dart';
import 'package:kisan_hisab/screens/settings/security_screen.dart';
import 'package:kisan_hisab/screens/settings/settings_scren.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'config/theme.dart';
import 'config/constants.dart';
import 'providers/auth_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/pin_setup_screen.dart';
import 'screens/auth/pin_login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const KisanHisabApp());
}

class KisanHisabApp extends StatelessWidget {
  const KisanHisabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => PeopleProvider()),
        ChangeNotifierProvider(create: (_) => RateProvider()),
        ChangeNotifierProvider(create: (_) => EntryProvider()),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        routes: {
          '/pin-setup': (_) => const PinSetupScreen(),
          '/pin-login': (_) => const PinLoginScreen(),
          '/dashboard': (_) => const DashboardScreen(),
          '/people': (_) => const PeopleListScreen(),
          '/rate-management': (_) => const RateManagementScreen(),
          '/select-entry-type': (_) => const SelectEntryTypeScreen(),
          '/history': (_) => const HistoryScreen(),
          '/pending': (_) => const PendingScreen(),
          '/reports': (_) => const ReportsDashboardScreen(),
          '/settings': (_) => const SettingsScreen(),
          '/security': (_) => const SecurityScreen(),
          '/about': (_) => const AboutScreen(),
          '/backup-restore': (_) => const BackupRestoreScreen(),
        },
      ),
    );
  }
}
