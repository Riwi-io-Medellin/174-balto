import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/di/injection.dart';
import 'core/storage/token_storage.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/home/home_page.dart';
import 'presentation/screens/profile/profile_screen.dart';
import 'presentation/screens/services/services_page.dart';
import 'presentation/screens/walks/walks_page.dart';
import 'presentation/widgets/bottom_nav/balto_bottom_nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  final tokenStorage = sl<TokenStorage>();
  final rememberMe = await tokenStorage.readRememberMe();
  if (rememberMe != true) {
    await tokenStorage.clear();
  }
  final token = await tokenStorage.readAccessToken();
  runApp(BaltoApp(isLoggedIn: token != null));
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
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
          fontFamilyFallback: const ['Ubuntu', 'Roboto'],
        ),
        primaryTextTheme: GoogleFonts.interTextTheme(base.primaryTextTheme)
            .apply(fontFamilyFallback: const ['Ubuntu', 'Roboto']),
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

  static const List<String> _pageTitles = [
    'Home',
    'Walks',
    'Walkers',
    'Coach',
    'Profile',
  ];

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return const WalksPage();
      case 2:
        return const ServicesPage();
      case 4:
        return const ProfileScreen();
      default:
        return Center(
          child: Text(
            _pageTitles[_currentIndex],
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        );
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
