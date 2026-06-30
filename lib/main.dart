import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'presentation/bloc/theme/theme_cubit.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/home/home_page.dart';
import 'presentation/screens/profile/profile_screen.dart';
import 'presentation/screens/services/services_page.dart';
import 'presentation/screens/walks/walks_page.dart';
import 'presentation/screens/coach/coach_screen.dart';
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
    return BlocProvider<ThemeCubit>(
      create: (_) => sl<ThemeCubit>(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (_, themeMode) => MaterialApp(
          title: 'Balto',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          home: isLoggedIn ? const MainShell() : const LoginScreen(),
        ),
      ),
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
      body: _buildBody(),
      bottomNavigationBar: BaltoBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
