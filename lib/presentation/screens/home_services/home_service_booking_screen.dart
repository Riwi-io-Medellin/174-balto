import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_shadows.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/di/injection.dart';
import '../../../core/widgets/balto_toast.dart';
import '../../../domain/entities/available_slot.dart';
import '../../../domain/entities/home_provider_service_item.dart';
import '../../../domain/entities/home_service_provider.dart';
import '../../../domain/entities/pet.dart';
import '../../bloc/home_service_booking/home_service_booking_cubit.dart';
import '../../bloc/home_service_booking/home_service_booking_state.dart';
import '../pets/create_pet_screen.dart';

class HomeServiceBookingScreen extends StatefulWidget {
  const HomeServiceBookingScreen({super.key, required this.provider});

  final HomeServiceProvider provider;

  @override
  State<HomeServiceBookingScreen> createState() =>
      _HomeServiceBookingScreenState();
}

class _HomeServiceBookingScreenState extends State<HomeServiceBookingScreen> {
  late final HomeServiceBookingCubit _cubit;
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _instructionsCtrl = TextEditingController();

  static const _accent = AppColors.homeServices;

  @override
  void initState() {
    super.initState();
    _cubit = sl<HomeServiceBookingCubit>();
    _cubit.initialize(widget.provider.id, widget.provider.services);
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _instructionsCtrl.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<HomeServiceBookingCubit, HomeServiceBookingState>(
        listener: (context, state) {
          if (state is HomeServiceBookingSuccess) {
            BaltoToast.success(context, 'Service booked successfully!');
            Navigator.of(context).pop();
          } else if (state is HomeServiceBookingError) {
            BaltoToast.error(context, state.message);
          } else if (state is HomeServiceBookingForm && state.hadConflict) {
            BaltoToast.warning(
              context,
              'That slot was just booked. Please choose another.',
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: const Color(0xFF1F2937),
              foregroundColor: Colors.white,
              elevation: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Book a Service',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'with ${widget.provider.name}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFB0B8C1),
                    ),
                  ),
                ],
              ),
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ),
            body: _buildBody(context, state),
            bottomNavigationBar: state is HomeServiceBookingForm
                ? _BookingFooter(form: state, onConfirm: _cubit.confirmBooking)
                : null,
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, HomeServiceBookingState state) {
    if (state is HomeServiceBookingLoading ||
        state is HomeServiceBookingInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is HomeServiceBookingNoPets) {
      return _NoPetsView(
        onAddPet: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const CreatePetScreen()))
            .then(
              (_) => _cubit.initialize(
                widget.provider.id,
                widget.provider.services,
              ),
            ),
      );
    }

    if (state is HomeServiceBookingSubmitting) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: _accent),
            SizedBox(height: 16),
            Text(
              'Confirming your booking…',
              style: TextStyle(color: Color(0xFF5A6473)),
            ),
          ],
        ),
      );
    }

    if (state is HomeServiceBookingError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Color(0xFFB0B8C1),
              ),
              const SizedBox(height: 16),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF5A6473)),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _cubit.initialize(
                  widget.provider.id,
                  widget.provider.services,
                ),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is HomeServiceBookingForm) {
      return _FormBody(
        form: state,
        addressCtrl: _addressCtrl,
        instructionsCtrl: _instructionsCtrl,
        cubit: _cubit,
        onAddPet: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const CreatePetScreen()))
            .then(
              (_) => _cubit.initialize(
                widget.provider.id,
                widget.provider.services,
              ),
            ),
      );
    }

    return const SizedBox.shrink();
  }
}

// ─── Form Body ────────────────────────────────────────────────────────────────

class _FormBody extends StatelessWidget {
  const _FormBody({
    required this.form,
    required this.addressCtrl,
    required this.instructionsCtrl,
    required this.cubit,
    required this.onAddPet,
  });

  final HomeServiceBookingForm form;
  final TextEditingController addressCtrl;
  final TextEditingController instructionsCtrl;
  final HomeServiceBookingCubit cubit;
  final VoidCallback onAddPet;

  static const _accent = AppColors.homeServices;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      children: [
        const _SectionTitle(
          title: 'Service',
          subtitle: 'Which service would you like?',
        ),
        const SizedBox(height: 12),
        _ServiceSelector(
          services: form.services,
          selected: form.selectedService,
          onSelect: cubit.selectService,
        ),
        const SizedBox(height: 24),
        const _SectionTitle(
          title: 'Your Pet',
          subtitle: 'Who is this service for?',
        ),
        const SizedBox(height: 12),
        _PetSelector(
          pets: form.pets,
          selected: form.selectedPet,
          onSelect: cubit.selectPet,
          onAddPet: onAddPet,
        ),
        const SizedBox(height: 24),
        const _SectionTitle(title: 'Service Details'),
        const SizedBox(height: 12),
        _DurationSelector(
          selected: form.selectedDuration,
          onSelect: cubit.selectDuration,
        ),
        const SizedBox(height: 12),
        _DateSelector(selected: form.selectedDate, onSelect: cubit.selectDate),
        const SizedBox(height: 24),
        const _SectionTitle(
          title: 'Available Slots',
          subtitle: 'Pick a start time',
        ),
        const SizedBox(height: 12),
        _SlotSelector(
          form: form,
          onSelect: cubit.selectSlot,
          onRefresh: cubit.refreshSlots,
        ),
        const SizedBox(height: 24),
        const _SectionTitle(
          title: 'Service Address',
          subtitle: 'Where should the provider go?',
        ),
        const SizedBox(height: 12),
        TextField(
          controller: addressCtrl,
          onChanged: cubit.setServiceAddress,
          decoration: InputDecoration(
            hintText: 'e.g. Calle 10 #20-30, Apt 501',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: AppRadius.radius12,
              borderSide: const BorderSide(color: Color(0xFFE0E4EC)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.radius12,
              borderSide: const BorderSide(color: Color(0xFFE0E4EC)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.radius12,
              borderSide: const BorderSide(color: _accent, width: 1.5),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
        const SizedBox(height: 24),
        const _SectionTitle(
          title: 'Special Instructions',
          subtitle: 'Optional',
        ),
        const SizedBox(height: 12),
        TextField(
          controller: instructionsCtrl,
          onChanged: cubit.setInstructions,
          maxLines: 3,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: 'e.g. "Gate code is 1234. Pet is friendly."',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: AppRadius.radius12,
              borderSide: const BorderSide(color: Color(0xFFE0E4EC)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.radius12,
              borderSide: const BorderSide(color: Color(0xFFE0E4EC)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.radius12,
              borderSide: const BorderSide(color: _accent, width: 1.5),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
      ],
    );
  }
}

// ─── Service Selector ─────────────────────────────────────────────────────────

class _ServiceSelector extends StatelessWidget {
  const _ServiceSelector({
    required this.services,
    required this.selected,
    required this.onSelect,
  });

  final List<HomeProviderServiceItem> services;
  final HomeProviderServiceItem? selected;
  final ValueChanged<HomeProviderServiceItem> onSelect;

  static const _accent = AppColors.homeServices;

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return const Text(
        'This provider has no active services.',
        style: TextStyle(color: Color(0xFF8A93A0)),
      );
    }
    return Column(
      children: services.map((s) {
        final isSelected = selected?.id == s.id;
        return GestureDetector(
          onTap: () => onSelect(s),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSelected
                  ? _accent.withValues(alpha: 0.08)
                  : Colors.white,
              borderRadius: AppRadius.radius12,
              border: Border.all(
                color: isSelected ? _accent : const Color(0xFFE0E4EC),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    s.serviceTypeName,
                    style: AppTextStyles.bodyBold.copyWith(
                      color: isSelected ? _accent : const Color(0xFF1F2937),
                    ),
                  ),
                ),
                Text(
                  s.priceLabel,
                  style: AppTextStyles.label.copyWith(
                    color: isSelected ? _accent : const Color(0xFF5A6473),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Section Title ────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.titleSmall.copyWith(
            color: const Color(0xFF1F2937),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: const TextStyle(fontSize: 13, color: Color(0xFF8A93A0)),
          ),
        ],
      ],
    );
  }
}

// ─── Pet Selector ─────────────────────────────────────────────────────────────

class _PetSelector extends StatelessWidget {
  const _PetSelector({
    required this.pets,
    required this.selected,
    required this.onSelect,
    required this.onAddPet,
  });

  final List<Pet> pets;
  final Pet? selected;
  final ValueChanged<Pet> onSelect;
  final VoidCallback onAddPet;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: pets.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          if (i == pets.length) return _AddPetCard(onTap: onAddPet);
          final pet = pets[i];
          return _PetCard(
            pet: pet,
            isSelected: selected?.id == pet.id,
            onTap: () => onSelect(pet),
          );
        },
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  const _PetCard({
    required this.pet,
    required this.isSelected,
    required this.onTap,
  });

  final Pet pet;
  final bool isSelected;
  final VoidCallback onTap;

  static const _accent = AppColors.homeServices;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 80,
        decoration: BoxDecoration(
          color: isSelected ? _accent.withValues(alpha: 0.08) : Colors.white,
          borderRadius: AppRadius.radius16,
          border: Border.all(
            color: isSelected ? _accent : const Color(0xFFE0E4EC),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PetAvatar(photoUrl: pet.photoUrl, size: 42),
            const SizedBox(height: 6),
            Text(
              pet.name,
              style: AppTextStyles.micro.copyWith(
                color: isSelected ? _accent : const Color(0xFF1F2937),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _PetAvatar extends StatelessWidget {
  const _PetAvatar({required this.photoUrl, required this.size});

  final String? photoUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          photoUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _fallback(size),
        ),
      );
    }
    return _fallback(size);
  }

  Widget _fallback(double s) => Container(
    width: s,
    height: s,
    decoration: const BoxDecoration(
      color: Color(0xFFFBEAF1),
      shape: BoxShape.circle,
    ),
    child: const Icon(Icons.pets_rounded, size: 22, color: Color(0xFFB0B8C1)),
  );
}

class _AddPetCard extends StatelessWidget {
  const _AddPetCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.radius16,
          border: Border.all(color: const Color(0xFFE0E4EC)),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline_rounded,
              size: 28,
              color: Color(0xFFB0B8C1),
            ),
            SizedBox(height: 6),
            Text(
              'Add pet',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF8A93A0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Duration Selector ────────────────────────────────────────────────────────

class _DurationSelector extends StatelessWidget {
  const _DurationSelector({required this.selected, required this.onSelect});

  final int selected;
  final ValueChanged<int> onSelect;

  static const _accent = AppColors.homeServices;

  @override
  Widget build(BuildContext context) {
    const options = [30, 60, 90];
    return Row(
      children: options.map((min) {
        final isSelected = selected == min;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelect(min),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected ? _accent : Colors.white,
                  borderRadius: AppRadius.radius12,
                  border: Border.all(
                    color: isSelected ? _accent : const Color(0xFFE0E4EC),
                  ),
                ),
                child: Center(
                  child: Text(
                    '$min min',
                    style: AppTextStyles.bodyBold.copyWith(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF5A6473),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Date Selector ────────────────────────────────────────────────────────────

class _DateSelector extends StatelessWidget {
  const _DateSelector({required this.selected, required this.onSelect});

  final DateTime? selected;
  final ValueChanged<DateTime> onSelect;

  static const _accent = AppColors.homeServices;

  String _label() {
    if (selected == null) return 'Pick a date';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(selected!.year, selected!.month, selected!.day);
    if (d == today) return 'Today';
    if (d == today.add(const Duration(days: 1))) return 'Tomorrow';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[selected!.month - 1]} ${selected!.day}, ${selected!.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: selected ?? now,
          firstDate: now,
          lastDate: now.add(const Duration(days: 60)),
          builder: (ctx, child) => Theme(
            data: Theme.of(
              ctx,
            ).copyWith(colorScheme: const ColorScheme.light(primary: _accent)),
            child: child!,
          ),
        );
        if (picked != null) onSelect(picked);
      },
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.radius12,
          border: Border.all(color: const Color(0xFFE0E4EC)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, size: 18, color: _accent),
            const SizedBox(width: 12),
            Text(
              _label(),
              style: AppTextStyles.bodyStrong.copyWith(
                color: const Color(0xFF1F2937),
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFB0B8C1)),
          ],
        ),
      ),
    );
  }
}

// ─── Slot Selector ────────────────────────────────────────────────────────────

class _SlotSelector extends StatelessWidget {
  const _SlotSelector({
    required this.form,
    required this.onSelect,
    required this.onRefresh,
  });

  final HomeServiceBookingForm form;
  final ValueChanged<AvailableSlot> onSelect;
  final VoidCallback onRefresh;

  static const _accent = AppColors.homeServices;

  @override
  Widget build(BuildContext context) {
    if (form.isLoadingSlots) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: _accent),
        ),
      );
    }

    if (form.slotsError != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.radius12,
          border: Border.all(color: const Color(0xFFE0E4EC)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.alert,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                form.slotsError!,
                style: const TextStyle(fontSize: 13, color: Color(0xFF5A6473)),
              ),
            ),
            TextButton(onPressed: onRefresh, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (form.availableSlots.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.radius12,
          border: Border.all(color: const Color(0xFFE0E4EC)),
        ),
        child: const Column(
          children: [
            Icon(Icons.event_busy_rounded, size: 36, color: Color(0xFFB0B8C1)),
            SizedBox(height: 10),
            Text(
              'No slots available for this date.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5A6473),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Try another date or duration.',
              style: TextStyle(fontSize: 13, color: Color(0xFF8A93A0)),
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: form.availableSlots.map((slot) {
        final isSelected = form.selectedSlot == slot;
        return GestureDetector(
          onTap: () => onSelect(slot),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? _accent : Colors.white,
              borderRadius: AppRadius.radius10,
              border: Border.all(
                color: isSelected ? _accent : const Color(0xFFE0E4EC),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              _formatTime(slot.start),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    final hour = local.hour;
    final minute = local.minute;
    final period = hour < 12 ? 'AM' : 'PM';
    final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }
}

// ─── Booking Footer ───────────────────────────────────────────────────────────

class _BookingFooter extends StatelessWidget {
  const _BookingFooter({required this.form, required this.onConfirm});

  final HomeServiceBookingForm form;
  final VoidCallback onConfirm;

  static const _accent = AppColors.homeServices;

  @override
  Widget build(BuildContext context) {
    final price = form.selectedService?.priceLabel ?? '';
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: AppShadows.sheet,
        ),
        child: Row(
          children: [
            if (price.isNotEmpty) ...[
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    'est. ${form.selectedDuration} min',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8A93A0),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: ElevatedButton(
                onPressed: form.canConfirm ? onConfirm : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  disabledBackgroundColor: const Color(0xFFE0E4EC),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.radius14,
                  ),
                ),
                child: Text(
                  form.canConfirm
                      ? 'Confirm Booking'
                      : 'Select a service, pet and slot',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── No Pets View ─────────────────────────────────────────────────────────────

class _NoPetsView extends StatelessWidget {
  const _NoPetsView({required this.onAddPet});

  final VoidCallback onAddPet;

  static const _accent = AppColors.homeServices;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pets_rounded, size: 40, color: _accent),
            ),
            const SizedBox(height: 20),
            const Text(
              'No pets yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first pet to start booking services.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF8A93A0),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAddPet,
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.radius14),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Add a Pet',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
