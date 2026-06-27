import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../bloc/profile/profile_cubit.dart';
import '../../bloc/profile/profile_state.dart';
import 'widgets/daily_tip_card.dart';
import 'widgets/greeting_header.dart';
import 'widgets/pet_hero_card.dart';
import 'widgets/quick_care_grid.dart';
import 'widgets/walk_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileCubit>(
      create: (_) => sl<ProfileCubit>()..load(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  static const String _kDailyTip =
      'Did you know that Border Collies need more attention to burn energy and be happy?';

  static const List<WalkEntry> _walks = [
    WalkEntry(
      title: 'Current walk · Riverside',
      subtitle: 'Today, 6:30 PM · ~30 min',
      isActive: true,
    ),
    WalkEntry(
      title: 'Morning loop · Park',
      subtitle: 'Today, 8:00 AM · 45 min',
    ),
    WalkEntry(
      title: 'Evening loop · Neighborhood',
      subtitle: 'Yesterday, 7:00 PM · 30 min',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        body: SafeArea(
          child: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              final firstName =
                  state is ProfileLoaded ? state.user.firstName : 'there';
              final photoUrl =
                  state is ProfileLoaded ? state.user.photoUrl : null;
              final pet = state is ProfileLoaded && state.pets.isNotEmpty
                  ? state.pets.first
                  : null;

              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        GreetingHeader(
                          firstName: firstName,
                          photoUrl: photoUrl,
                          onNotificationTap: () {},
                        ),
                        const SizedBox(height: 20),
                        PetHeroCard(pet: pet, onTap: () {}),
                        const SizedBox(height: 16),
                        const DailyTipCard(tip: _kDailyTip),
                        const SizedBox(height: 26),
                        _SectionTitle('Walks'),
                        const SizedBox(height: 12),
                        ..._walks.map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: WalkCard(entry: e, onTap: () {}),
                          ),
                        ),
                        const SizedBox(height: 26),
                        _SectionTitle('Quick care'),
                        const SizedBox(height: 12),
                        const QuickCareGrid(),
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1F2937),
      ),
    );
  }
}
