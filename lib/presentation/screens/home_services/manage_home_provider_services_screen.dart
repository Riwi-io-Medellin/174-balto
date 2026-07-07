import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/di/injection.dart';
import '../../../core/widgets/balto_toast.dart';
import '../../../domain/entities/home_provider_service_item.dart';
import '../../../domain/entities/home_service_type.dart';
import '../../../domain/repositories/home_service_profile_repository.dart';
import '../../bloc/home_provider_services/home_provider_services_cubit.dart';
import '../../bloc/home_provider_services/home_provider_services_state.dart';

class ManageHomeProviderServicesScreen extends StatefulWidget {
  const ManageHomeProviderServicesScreen({super.key});

  @override
  State<ManageHomeProviderServicesScreen> createState() =>
      _ManageHomeProviderServicesScreenState();
}

class _ManageHomeProviderServicesScreenState
    extends State<ManageHomeProviderServicesScreen> {
  static const Color _accent = AppColors.homeServices;
  static const Color _textDark = Color(0xFF1F2937);
  static const Color _textMid = Color(0xFF5A6473);
  static const Color _textMuted = Color(0xFF8A93A0);

  late final HomeProviderServicesCubit _cubit;
  String? _providerId;
  bool _loadingProvider = true;

  @override
  void initState() {
    super.initState();
    _cubit = sl<HomeProviderServicesCubit>();
    _init();
  }

  Future<void> _init() async {
    try {
      final profile = await sl<HomeServiceProfileRepository>().getMyProfile();
      if (profile == null) {
        if (!mounted) return;
        BaltoToast.warning(context, 'Provider profile not found.');
        Navigator.of(context).pop();
        return;
      }
      _providerId = profile.id;
      await _cubit.load(profile.id);
    } catch (_) {
      if (!mounted) return;
      BaltoToast.error(context, 'Failed to load provider profile.');
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _loadingProvider = false);
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _showAddOrEditSheet({HomeProviderServiceItem? existing}) async {
    final types = _cubit.cachedTypes;
    if (types.isEmpty) {
      BaltoToast.warning(context, 'No service types available.');
      return;
    }

    HomeServiceType? selectedType = existing != null
        ? types.firstWhere(
            (t) => t.id == existing.serviceTypeId,
            orElse: () => types.first,
          )
        : types.first;
    final priceCtrl =
        TextEditingController(text: existing?.price?.toStringAsFixed(0) ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    String priceUnit = existing?.priceUnit ?? 'flat';
    bool isActive = existing?.isActive ?? true;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.r24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    existing == null ? 'Add Service' : 'Edit Service',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (existing == null) ...[
                    Text('Service Type', style: AppTextStyles.label.copyWith(color: _textMid)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<HomeServiceType>(
                      initialValue: selectedType,
                      items: types
                          .map((t) => DropdownMenuItem(
                                value: t,
                                child: Text(t.name),
                              ))
                          .toList(),
                      onChanged: (v) => setSheetState(() => selectedType = v),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.radius12,
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  Text('Price', style: AppTextStyles.label.copyWith(color: _textMid)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'e.g. 40',
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.radius12,
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('Price Unit', style: AppTextStyles.label.copyWith(color: _textMid)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['flat', 'hourly', 'per_visit'].map((u) {
                      final selected = priceUnit == u;
                      return ChoiceChip(
                        label: Text(u),
                        selected: selected,
                        selectedColor: _accent.withValues(alpha: 0.15),
                        labelStyle: TextStyle(
                          color: selected ? _accent : _textMid,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (_) => setSheetState(() => priceUnit = u),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  Text('Description (optional)', style: AppTextStyles.label.copyWith(color: _textMid)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descCtrl,
                    minLines: 2,
                    maxLines: 3,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.radius12,
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                  ),
                  if (existing != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text('Active', style: AppTextStyles.label.copyWith(color: _textMid)),
                        const Spacer(),
                        Switch(
                          value: isActive,
                          activeTrackColor: _accent,
                          onChanged: (v) => setSheetState(() => isActive = v),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.radius12,
                        ),
                      ),
                      onPressed: () async {
                        final price = double.tryParse(priceCtrl.text.trim());
                        Navigator.of(sheetContext).pop();
                        if (existing == null) {
                          await _cubit.addService(
                            serviceTypeId: selectedType!.id,
                            price: price,
                            priceUnit: priceUnit,
                            description: descCtrl.text.trim(),
                          );
                        } else {
                          await _cubit.updateService(
                            serviceId: existing.id,
                            price: price,
                            priceUnit: priceUnit,
                            description: descCtrl.text.trim(),
                            isActive: isActive,
                          );
                        }
                      },
                      child: Text(existing == null ? 'Add Service' : 'Save Changes'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: _textDark),
        ),
        title: Text(
          'Manage Services',
          style: AppTextStyles.h3.copyWith(color: _textDark),
        ),
        centerTitle: true,
      ),
      floatingActionButton: _providerId == null
          ? null
          : FloatingActionButton(
              backgroundColor: _accent,
              foregroundColor: Colors.white,
              onPressed: () => _showAddOrEditSheet(),
              child: const Icon(Icons.add_rounded),
            ),
      body: _loadingProvider
          ? const Center(child: CircularProgressIndicator())
          : BlocProvider.value(
              value: _cubit,
              child: BlocBuilder<HomeProviderServicesCubit, HomeProviderServicesState>(
                builder: (context, state) {
                  if (state is HomeProviderServicesLoading ||
                      state is HomeProviderServicesInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is HomeProviderServicesError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                size: 48, color: Color(0xFF8A93A0)),
                            const SizedBox(height: 16),
                            Text(state.message,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: _textMid)),
                          ],
                        ),
                      ),
                    );
                  }
                  if (state is HomeProviderServicesLoaded) {
                    if (state.services.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.design_services_outlined,
                                  size: 48, color: Color(0xFFB0B8C1)),
                              const SizedBox(height: 16),
                              const Text(
                                'No services yet. Tap + to add one.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: _textMuted),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                      itemCount: state.services.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _ServiceCard(
                        service: state.services[i],
                        onTap: () =>
                            _showAddOrEditSheet(existing: state.services[i]),
                        onDelete: () => _cubit.deleteService(state.services[i].id),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.service,
    required this.onTap,
    required this.onDelete,
  });

  final HomeProviderServiceItem service;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  static const Color _accent = AppColors.homeServices;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.radius14,
          border: Border.all(color: const Color(0xFFE0E4EC)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.design_services_rounded,
                  color: _accent, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          service.serviceTypeName,
                          style: AppTextStyles.bodyBold.copyWith(color: const Color(0xFF1F2937)),
                        ),
                      ),
                      if (!service.isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E4EC),
                            borderRadius: AppRadius.radius20,
                          ),
                          child: const Text(
                            'Inactive',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF5A6473)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.priceLabel,
                    style: AppTextStyles.label.copyWith(color: _accent),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF0ED),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    size: 16, color: Color(0xFFD05A24)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
