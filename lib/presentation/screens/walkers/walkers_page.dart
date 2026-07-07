import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/di/injection.dart';
import '../../../domain/entities/walker.dart';
import '../../bloc/walker/walker_cubit.dart';
import '../../bloc/walker/walker_state.dart';
import '../walkers/walker_profile_page.dart';
import 'become_walker_screen.dart';
import '../../widgets/balto_header.dart';
import '../../widgets/balto_screen_scaffold.dart';
import '../../widgets/skeletons/walkers_skeleton.dart';
import '../../widgets/states/empty_state_view.dart';
import '../../widgets/states/error_state_view.dart';
import 'widgets/walker_card.dart';
import 'widgets/walker_filter_chip.dart';
import 'widgets/walkers_search_bar.dart';

class WalkersPage extends StatefulWidget {
  const WalkersPage({super.key});

  @override
  State<WalkersPage> createState() => _WalkersPageState();
}

class _WalkersPageState extends State<WalkersPage> {
  late final WalkerCubit _cubit;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _cubit = sl<WalkerCubit>();
    _scrollController.addListener(_onScroll);
    _cubit.loadWalkers();
    _initLocation();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _cubit.loadMoreWalkers();
    }
  }

  // Fire-and-forget: only feeds later pagination/search, must not block the
  // initial list (GPS can be slow or never resolve).
  Future<void> _initLocation() async {
    final hasPermission = await _requestLocationPermission();
    if (!hasPermission) return;
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 6),
        ),
      );
      _cubit.setLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (_) {
      // Location unavailable — proceed with the default location.
    }
  }

  Future<bool> _requestLocationPermission() async {
    var serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    return permission != LocationPermission.deniedForever;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BaltoScreenScaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const BecomeWalkerScreen())),
          backgroundColor: AppColors.navWalkers,
          foregroundColor: Colors.white,
          elevation: 4,
          child: const Icon(Icons.add_rounded),
        ),
        header: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BaltoHeader.iconTitle(
              icon: Icons.pets_rounded,
              iconColor: AppColors.navWalkers,
              title: 'Community Walkers',
              actions: [
                BaltoHeaderAction(icon: Icons.search_rounded, onPressed: () {}),
                BaltoHeaderAction(icon: Icons.tune_rounded, onPressed: () {}),
              ],
            ),
            const SizedBox(height: 16),
            const WalkersSearchBar(),
            const SizedBox(height: 14),
            _buildFilterRow(),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Available Now', style: AppTextStyles.h3),
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildWalkerList()),
          ],
        ),
      ),
    );
  }

  Widget _buildWalkerList() {
    return BlocBuilder<WalkerCubit, WalkerState>(
      builder: (context, state) {
        if (state is WalkerLoading) {
          return const WalkersSkeleton();
        }
        if (state is WalkerError) {
          return ErrorStateView(
            icon: Icons.cloud_off_rounded,
            message: state.message,
            accentColor: AppColors.navWalkers,
            onRetry: _cubit.loadWalkers,
          );
        }

        List<Walker> walkers = const [];
        bool isLoadingMore = false;

        if (state is WalkerListLoaded) {
          walkers = state.walkers;
        } else if (state is WalkerLoadingMore) {
          walkers = state.walkers;
          isLoadingMore = true;
        } else {
          return const SizedBox.shrink();
        }

        if (walkers.isEmpty) {
          return EmptyStateView(
            icon: Icons.search_off_rounded,
            title: 'No walkers found in your area.',
            action: TextButton(
              onPressed: _cubit.loadWalkers,
              child: const Text('Try again'),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _cubit.loadWalkers,
          color: AppColors.navWalkers,
          child: ListView.separated(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            itemCount: walkers.length + (isLoadingMore ? 1 : 0),
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (_, i) {
              if (i == walkers.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.navWalkers,
                    ),
                  ),
                );
              }
              final walker = walkers[i];
              return WalkerCard(
                walker: walker,
                onViewProfile: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => WalkerProfilePage(walker: walker),
                  ),
                ),
                onBookWalk: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Booking coming soon!')),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFilterRow() {
    const filters = ['Nearby', 'Top Rated', 'Available Today'];
    return BlocBuilder<WalkerCubit, WalkerState>(
      builder: (context, state) {
        final selected = state is WalkerListLoaded
            ? state.selectedFilter
            : state is WalkerLoadingMore
            ? state.selectedFilter
            : 0;
        return SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filters.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) => WalkerFilterChip(
              label: filters[i],
              isSelected: i == selected,
              onTap: () => _cubit.applyFilter(i),
            ),
          ),
        );
      },
    );
  }
}
