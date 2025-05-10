import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase
import 'package:ghodacare/constants/app_constants.dart';
import 'package:ghodacare/screens/splash_screen.dart';
import 'package:ghodacare/screens/home_screen.dart';
import 'package:ghodacare/screens/auth/login_screen.dart';
import 'package:ghodacare/screens/bloodwork/add_bloodwork_screen.dart';
import 'package:ghodacare/screens/bloodwork/bloodwork_detail_screen.dart';
import 'package:ghodacare/screens/health/health_metrics_screen.dart';
import 'package:ghodacare/screens/health/add_health_metrics_screen.dart';
import 'package:ghodacare/screens/medications/medications_screen.dart';
import 'package:ghodacare/screens/medications/add_medication_screen.dart';
import 'package:ghodacare/screens/wellness/wellness_screen.dart';
import 'package:ghodacare/providers/theme_provider.dart';
import 'package:ghodacare/providers/language_provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Authentication

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const GhodaCareApp(),
    );
  }
}

class GhodaCareApp extends StatelessWidget {
  const GhodaCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return MaterialApp(
      title: AppConstants.appName,
      theme: themeProvider.themeData,
      locale: languageProvider.locale,
      debugShowCheckedModeBanner: false,
      home: const InitialScreen(),
      routes: {
        '/home': (context) => const HomeScreen(selectedIndex: 0),
        '/dashboard': (context) => const HomeScreen(selectedIndex: 1),
        '/wellness': (context) => const WellnessScreen(),
        '/profile': (context) => const HomeScreen(selectedIndex: 3),
        '/health_metrics': (context) => const HealthMetricsScreen(),
        '/add_health_metrics': (context) => const AddHealthMetricsScreen(),
        '/medications': (context) => const MedicationsScreen(),
        '/add_medication': (context) => const AddMedicationScreen(),
        '/add_bloodwork': (context) => const AddBloodworkScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/bloodwork_detail') {
          final bloodworkId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) =>
                BloodworkDetailScreen(bloodworkId: bloodworkId),
          );
        }
        return null;
      },
    );
  }
}

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    super.initState();
    _checkInitialRoute();
  }

  Future<void> _checkInitialRoute() async {
    await Future.delayed(AppConstants.splashDuration);

    if (!mounted) return;

    final isLoggedIn = await _checkUserLoggedIn();

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  Future<bool> _checkUserLoggedIn() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    return currentUser != null;
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen(); // Show splash screen while checking
  }
}
