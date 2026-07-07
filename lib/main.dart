import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/di/injection.dart';
import 'core/services/push_notification_service.dart';
import 'core/storage/token_storage.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/home/home_page.dart';
import 'presentation/screens/profile/profile_screen.dart';
import 'presentation/screens/services/services_page.dart';
import 'presentation/screens/walks/walks_page.dart';
import 'presentation/screens/coach/coach_screen.dart';
import 'presentation/widgets/bottom_nav/balto_bottom_nav_bar.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  setupDependencies();
  final tokenStorage = sl<TokenStorage>();
  final rememberMe = await tokenStorage.readRememberMe();
  if (rememberMe != true) {
    await tokenStorage.clear();
  }
  final token = await tokenStorage.readAccessToken();

  runApp(BaltoApp(isLoggedIn: token != null));

  // Deferred past the first frame: neither the login screen nor the home
  // shell reads any push-related state to render, and this can involve an
  // iOS permission dialog plus a backend round-trip — no reason to make
  // startup wait on it.
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final pushService = sl<PushNotificationService>();
    await pushService.initialize(navigatorKey: navigatorKey);
    if (token != null) await pushService.registerCurrentToken();
  });
}

class BaltoApp extends StatelessWidget {
  const BaltoApp({super.key, required this.isLoggedIn});

  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3A80C2)),
      useMaterial3: true,
    );
    return MaterialApp(
      title: 'Balto',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        textTheme: GoogleFonts.interTextTheme(
          base.textTheme,
        ).apply(fontFamilyFallback: const ['Ubuntu', 'Roboto']),
        primaryTextTheme: GoogleFonts.interTextTheme(
          base.primaryTextTheme,
        ).apply(fontFamilyFallback: const ['Ubuntu', 'Roboto']),
      ),
      home: isLoggedIn ? const MainShell() : const LoginScreen(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  int _servicesFilter = 0;

  void _openServices(int filter) {
    setState(() {
      _servicesFilter = filter;
      _currentIndex = 2;
    });
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return HomeScreen(onOpenServices: _openServices);
      case 1:
        return const WalksPage();
      case 2:
        return ServicesPage(
          key: ValueKey(_servicesFilter),
          initialFilter: _servicesFilter,
        );
      case 3:
        return const CoachScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: _buildBody(),
      bottomNavigationBar: BaltoBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
