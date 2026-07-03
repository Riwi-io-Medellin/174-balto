import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../domain/entities/business.dart';
import '../../../domain/entities/walker.dart';
import '../../bloc/business/business_cubit.dart';
import '../../bloc/business/business_state.dart';
import '../../bloc/walker/walker_cubit.dart';
import '../../bloc/walker/walker_state.dart';
import '../../screens/walkers/walker_profile_page.dart';
import 'business_profile_page.dart';
import '../../widgets/skeletons/services_skeleton.dart';
import 'widgets/business_card.dart';
import 'widgets/compact_walker_card.dart';
import 'widgets/service_category_chip.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key, this.initialFilter = 0});

  final int initialFilter;

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  late int _selectedFilter;
  late final WalkerCubit _walkerCubit;
  late final BusinessCubit _businessCubit;

  static const List<String> _filters = [
    'All',
    'Walkers',
    'Veterinaries',
    'Stores',
  ];

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
    _walkerCubit = sl<WalkerCubit>();
    _businessCubit = sl<BusinessCubit>();
    _walkerCubit.loadWalkers();
    _businessCubit.loadUserLocation().then((_) => _businessCubit.loadBusinesses());
  }

  @override
  void dispose() {
    _walkerCubit.close();
    _businessCubit.close();
    super.dispose();
  }

  List<Walker> _getWalkers(WalkerState state) {
    if (state is WalkerListLoaded) return state.walkers;
    if (state is WalkerLoadingMore) return state.walkers;
    return [];
  }

  List<Business> _getBusinesses(BusinessState state) {
    if (state is BusinessListLoaded) return state.businesses;
    return [];
  }

  List<Object> _buildItems(WalkerState walkerState, BusinessState businessState) {
    final walkers = _getWalkers(walkerState);
    final businesses = _getBusinesses(businessState);
    switch (_selectedFilter) {
      case 1:
        return List<Object>.from(walkers);
      case 2:
        return businesses.where((b) => b.isVeterinary).toList();
      case 3:
        return businesses.where((b) => b.isStore).toList();
      default:
        return [...walkers, ...businesses];
    }
  }

  void _openProfile(Business business) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BusinessProfilePage(business: business),
      ),
    );
  }

  void _openWalkerProfile(Walker walker) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WalkerProfilePage(walker: walker),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _walkerCubit),
        BlocProvider.value(value: _businessCubit),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 14),
                    _buildFilterRow(),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<WalkerCubit, WalkerState>(
                  builder: (context, walkerState) {
                    return BlocBuilder<BusinessCubit, BusinessState>(
                      builder: (context, businessState) {
                        final isLoading = walkerState is WalkerLoading ||
                            businessState is BusinessLoading;
                        if (isLoading) {
                          return const ServicesSkeleton();
                        }

                        final errorState = walkerState is WalkerError
                            ? walkerState
                            : (businessState is BusinessError
                                ? businessState
                                : null);
                        if (errorState != null) {
                          final message = errorState is WalkerError
                              ? errorState.message
                              : (errorState as BusinessError).message;
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.error_outline,
                                      size: 48, color: Colors.grey),
                                  const SizedBox(height: 12),
                                  Text(message,
                                      textAlign: TextAlign.center,
                                      style:
                                          const TextStyle(color: Colors.grey)),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      context.read<WalkerCubit>().loadWalkers();
                                      context
                                          .read<BusinessCubit>()
                                          .loadBusinesses();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.navWalkers,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final items = _buildItems(walkerState, businessState);

                        if (items.isEmpty) {
                          return const Center(
                            child: Text(
                              'No results found.',
                              style: TextStyle(color: Color(0xFF8A93A0)),
                            ),
                          );
                        }

                        return ListView.separated(
                          padding:
                              const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          itemCount: items.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 16),
                          itemBuilder: (_, i) {
                            final item = items[i];
                            if (item is Business) {
                              return BusinessCard(
                                business: item,
                                onTap: () => _openProfile(item),
                              );
                            }
                            if (item is Walker) {
                              return CompactWalkerCard(
                                walker: item,
                                onTap: () => _openWalkerProfile(item),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.navCoach.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.manage_search_rounded,
            size: 18,
            color: AppColors.navCoach,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Discover',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.search_rounded,
              color: Color(0xFF1F2937)),
          visualDensity: VisualDensity.compact,
        ),
        IconButton(
          onPressed: () {},
          icon:
              const Icon(Icons.tune_rounded, color: Color(0xFF1F2937)),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  Widget _buildFilterRow() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) => ServiceCategoryChip(
          label: _filters[i],
          isSelected: i == _selectedFilter,
          onTap: () => setState(() => _selectedFilter = i),
        ),
      ),
    );
  }
}
