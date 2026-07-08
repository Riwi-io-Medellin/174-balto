import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/constants/app_colors.dart';
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

  bool firebaseAvailable = false;
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    firebaseAvailable = true;
  } catch (_) {
    // Firebase no disponible en Linux desktop
  }

  setupDependencies();
  final tokenStorage = sl<TokenStorage>();
  // Session survives process death (OS backgrounding/kill, back-button
  // minimize) regardless of "remember me" — that flag only controls
  // whether login pre-fills, it must never wipe a still-valid refresh
  // token on cold start.
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
    const seed = Color(0xFF3A80C2);
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: seed),
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
    );
    final textTheme = GoogleFonts.interTextTheme(
      base.textTheme,
    ).apply(fontFamilyFallback: const ['Ubuntu', 'Roboto']);
    return MaterialApp(
      title: 'Balto',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        textTheme: textTheme,
        primaryTextTheme: GoogleFonts.interTextTheme(
          base.primaryTextTheme,
        ).apply(fontFamilyFallback: const ['Ubuntu', 'Roboto']),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          iconTheme: IconThemeData(color: AppColors.textPrimary, size: 20),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.navWalks,
            foregroundColor: AppColors.surface,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppColors.buttonRadius),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.inputFill,
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppColors.inputRadius),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppColors.inputRadius),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppColors.inputRadius),
            borderSide: const BorderSide(color: AppColors.navWalks, width: 1.5),
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppColors.cardRadius),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        ),
      ),
      home: isLoggedIn ? const MainShell() : const LoginScreen(),
      builder: (context, child) {
        // Single source of truth for the status bar icon style across every
        // screen. Previously only the one screen with a real `Scaffold.appBar`
        // got this inferred implicitly, leaving the rest at the mercy of
        // whatever the previously visited screen left behind.
        final mediaQuery = MediaQuery.of(context);
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          child: MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: mediaQuery.textScaler.clamp(
                minScaleFactor: 0.9,
                maxScaleFactor: 1.3,
              ),
            ),
            child: child!,
          ),
        );
      },
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
      backgroundColor: AppColors.background,
      body: _buildBody(),
      bottomNavigationBar: BaltoBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
