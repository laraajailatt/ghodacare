import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_ghoda/constants/app_constants.dart';
import 'package:app_ghoda/screens/splash_screen.dart';
import 'package:app_ghoda/screens/onboarding_screen.dart';
import 'package:app_ghoda/screens/home_screen.dart';
import 'package:app_ghoda/screens/auth/login_screen.dart';
import 'package:app_ghoda/screens/bloodwork/add_bloodwork_screen.dart';
import 'package:app_ghoda/screens/bloodwork/bloodwork_list_screen.dart';
import 'package:app_ghoda/screens/bloodwork/bloodwork_detail_screen.dart';
import 'package:app_ghoda/utils/shared_pref_util.dart';
import 'package:app_ghoda/providers/theme_provider.dart';
import 'package:app_ghoda/providers/language_provider.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        '/add_bloodwork': (context) => const AddBloodworkScreen(),
        '/bloodwork_list': (context) => const BloodworkListScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/bloodwork_detail') {
          final bloodworkId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => BloodworkDetailScreen(bloodworkId: bloodworkId),
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
    // Wait for splash screen duration
    await Future.delayed(AppConstants.splashDuration);

    if (!mounted) return;

    // Check login status and welcome screen status
    final isLoggedIn = await SharedPrefUtil.isUserLoggedIn();
    final hasSeenWelcome = await SharedPrefUtil.hasSeenWelcomeScreen();

    if (!mounted) return;

    if (isLoggedIn) {
      // User is logged in, go directly to home screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (hasSeenWelcome) {
      // User has seen welcome screen but not logged in, go to login screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      // First time user, show onboarding
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();  // Show splash screen while checking
  }
}
