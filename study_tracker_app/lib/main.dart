import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/storage_service.dart';
import 'providers/app_provider.dart';
import 'theme/app_theme.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = StorageService();
  await storage.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(storage),
      child: const StudyTrackerApp(),
    ),
  );
}

class StudyTrackerApp extends StatelessWidget {
  const StudyTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: Consumer<AppProvider>(
        builder: (context, provider, _) {
          if (provider.isFirstLaunch || provider.profile == null) {
            return const ProfileSetupScreen();
          }
          return const MainNavigation();
        },
      ),
    );
  }
}
