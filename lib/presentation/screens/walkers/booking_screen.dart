import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/widgets/balto_toast.dart';
import '../../../domain/entities/available_slot.dart';
import '../../../domain/entities/pet.dart';
import '../../../domain/entities/walker.dart';
import '../../bloc/walk_booking/walk_booking_cubit.dart';
import '../../bloc/walk_booking/walk_booking_state.dart';
import '../pets/create_pet_screen.dart';
import '../../bloc/profile/profile_cubit.dart';
import '../profile/edit_profile_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.walker});

  final Walker walker;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late final WalkBookingCubit _cubit;
  final TextEditingController _instructionsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cubit = sl<WalkBookingCubit>();
    _cubit.initialize(widget.walker.id);
  }

  @override
  void dispose() {
    _instructionsCtrl.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<WalkBookingCubit, WalkBookingState>(
        listener: (context, state) {
          if (state is WalkBookingSuccess) {
            BaltoToast.success(context, 'Walk booked successfully!');
            Navigator.of(context).pop();
          } else if (state is WalkBookingError) {
            BaltoToast.error(context, state.message);
          } else if (state is WalkBookingForm && state.hadConflict) {
            BaltoToast.warning(
              context,
              'That slot was just booked. Please choose another.',
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F6FA),
            appBar: AppBar(
              backgroundColor: const Color(0xFF1F2937),
              foregroundColor: Colors.white,
              elevation: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Book a Walk',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'with ${widget.walker.name}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
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
            bottomNavigationBar: state is WalkBookingForm
                ? _BookingFooter(
                    walker: widget.walker,
                    form: state,
                    onConfirm: _cubit.confirmBooking,
                  )
                : null,
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, WalkBookingState state) {
    if (state is WalkBookingLoading || state is WalkBookingInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is WalkBookingNoPets) {
      return _NoPetsView(
        onAddPet: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const CreatePetScreen()))
            .then((_) => _cubit.initialize(widget.walker.id)),
      );
    }

    if (state is WalkBookingSubmitting) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.navWalkers),
            SizedBox(height: 16),
            Text(
              'Confirming your booking…',
              style: TextStyle(color: Color(0xFF5A6473)),
            ),
          ],
        ),
      );
    }

    if (state is WalkBookingError) {
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
                onPressed: () => _cubit.initialize(widget.walker.id),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is WalkBookingForm) {
      return _FormBody(
        form: state,
        instructionsCtrl: _instructionsCtrl,
        cubit: _cubit,
        walkerName: widget.walker.name,
        walker: widget.walker,
        onAddPet: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const CreatePetScreen()))
            .then((_) => _cubit.initialize(widget.walker.id)),
      );
    }

    return const SizedBox.shrink();
  }
}

// ─── Form Body ────────────────────────────────────────────────────────────────

class _FormBody extends StatelessWidget {
  const _FormBody({
    required this.form,
    required this.instructionsCtrl,
    required this.cubit,
    required this.walkerName,
    required this.walker,
    required this.onAddPet,
  });

  final WalkBookingForm form;
  final TextEditingController instructionsCtrl;
  final WalkBookingCubit cubit;
  final String walkerName;
  final Walker walker;
  final VoidCallback onAddPet;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      children: [
        _PickupAddressCard(
          address: form.ownerAddress,
          city: form.ownerCity,
        ),
        const SizedBox(height: 24),
        _SectionTitle(title: 'Your Pet', subtitle: "Who's going for a walk?"),
        const SizedBox(height: 12),
        _PetSelector(
          pets: form.pets,
          selected: form.selectedPet,
          onSelect: cubit.selectPet,
          onAddPet: onAddPet,
        ),
        const SizedBox(height: 24),
        const _SectionTitle(title: 'Walk Details'),
        const SizedBox(height: 12),
        _DurationSelector(
          selected: form.selectedDuration,
          onSelect: cubit.selectDuration,
        ),
        const SizedBox(height: 12),
        _DateSelector(
          selected: form.selectedDate,
          onSelect: cubit.selectDate,
        ),
        const SizedBox(height: 24),
        const _SectionTitle(
          title: 'Available Slots',
          subtitle: 'Pick a start time for the walk',
        ),
        const SizedBox(height: 12),
        _SlotSelector(
          form: form,
          onSelect: cubit.selectSlot,
          onRefresh: cubit.refreshSlots,
        ),
        if (walker.maxDogs != null && walker.maxDogs! > 1) ...[
          const SizedBox(height: 24),
          _ExclusiveWalkToggle(
            isExclusive: form.isExclusive,
            onToggle: cubit.toggleExclusive,
          ),
        ],
        const SizedBox(height: 24),
        const _SectionTitle(
          title: 'Special Instructions',
          subtitle: 'Optional — gate code, dog behavior, etc.',
        ),
        const SizedBox(height: 12),
        TextField(
          controller: instructionsCtrl,
          onChanged: cubit.setInstructions,
          maxLines: 3,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: 'e.g. "Gate code is 1234. Max is friendly but pulls on leash."',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E4EC)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E4EC)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.navWalkers, width: 1.5),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
      ],
    );
  }
}

// ─── Exclusive Walk Toggle ────────────────────────────────────────────────────

class _ExclusiveWalkToggle extends StatelessWidget {
  const _ExclusiveWalkToggle({
    required this.isExclusive,
    required this.onToggle,
  });

  final bool isExclusive;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isExclusive
              ? const Color(0xFFFFF8EC)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isExclusive
                ? const Color(0xFFFFD97A)
                : const Color(0xFFE0E4EC),
            width: isExclusive ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isExclusive
                    ? const Color(0xFFFFD97A).withValues(alpha: 0.3)
                    : const Color(0xFFE0E4EC),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shield_rounded,
                size: 20,
                color: isExclusive
                    ? const Color(0xFFB87300)
                    : const Color(0xFF8A93A0),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Priority (Solo) Walk',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isExclusive
                          ? const Color(0xFFB87300)
                          : const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Your dog walks alone — recommended for energetic or reactive dogs. +50% fare.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8A93A0),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Switch(
              value: isExclusive,
              onChanged: (_) => onToggle(),
              activeTrackColor: const Color(0xFFB87300),
              activeThumbColor: Colors.white,
            ),
          ],
        ),
      ),
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
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
          if (i == pets.length) {
            return _AddPetCard(onTap: onAddPet);
          }
          final pet = pets[i];
          final isSelected = selected?.id == pet.id;
          return _PetCard(
            pet: pet,
            isSelected: isSelected,
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 80,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.navWalkers.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? AppColors.navWalkers : const Color(0xFFE0E4EC),
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
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.navWalkers
                    : const Color(0xFF1F2937),
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
          color: Color(0xFFE8F5EE),
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE0E4EC),
            style: BorderStyle.solid,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline_rounded,
                size: 28, color: Color(0xFFB0B8C1)),
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
  const _DurationSelector({
    required this.selected,
    required this.onSelect,
  });

  final int selected;
  final ValueChanged<int> onSelect;

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
                  color:
                      isSelected ? AppColors.navWalkers : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.navWalkers
                        : const Color(0xFFE0E4EC),
                  ),
                ),
                child: Center(
                  child: Text(
                    '$min min',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
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

  String _label() {
    if (selected == null) return 'Pick a date';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(selected!.year, selected!.month, selected!.day);
    if (d == today) return 'Today';
    if (d == today.add(const Duration(days: 1))) return 'Tomorrow';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
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
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.navWalkers,
              ),
            ),
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E4EC)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 18,
              color: AppColors.navWalkers,
            ),
            const SizedBox(width: 12),
            Text(
              _label(),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFB0B8C1),
            ),
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

  final WalkBookingForm form;
  final ValueChanged<AvailableSlot> onSelect;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    if (form.isLoadingSlots) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.navWalkers,
          ),
        ),
      );
    }

    if (form.slotsError != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF5A6473),
                ),
              ),
            ),
            TextButton(
              onPressed: onRefresh,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (form.availableSlots.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E4EC)),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.event_busy_rounded,
              size: 36,
              color: Color(0xFFB0B8C1),
            ),
            const SizedBox(height: 10),
            const Text(
              'No slots available for this date.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5A6473),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
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
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.navWalkers : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? AppColors.navWalkers
                    : const Color(0xFFE0E4EC),
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
                color:
                    isSelected ? Colors.white : const Color(0xFF1F2937),
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
  const _BookingFooter({
    required this.walker,
    required this.form,
    required this.onConfirm,
  });

  final Walker walker;
  final WalkBookingForm form;
  final VoidCallback onConfirm;

  ({String total, bool hasSurcharge}) get _priceInfo {
    final rate = walker.pricePerWalk;
    if (rate == null) return (total: '', hasSurcharge: false);
    final hours = form.selectedDuration / 60;
    final base = rate * hours;
    final total = form.isExclusive ? base * 1.5 : base;
    return (
      total: '\$${total.toStringAsFixed(0)}',
      hasSurcharge: form.isExclusive,
    );
  }

  @override
  Widget build(BuildContext context) {
    final price = _priceInfo;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            if (price.total.isNotEmpty) ...[
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    price.total,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    price.hasSurcharge
                        ? 'est. ${form.selectedDuration} min · solo +50%'
                        : 'est. ${form.selectedDuration} min',
                    style: TextStyle(
                      fontSize: 12,
                      color: price.hasSurcharge
                          ? const Color(0xFFB87300)
                          : const Color(0xFF8A93A0),
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
                  backgroundColor: AppColors.navWalkers,
                  disabledBackgroundColor: const Color(0xFFE0E4EC),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  form.canConfirm
                      ? 'Confirm Booking'
                      : 'Select a pet and slot',
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

// ─── Pickup Address Card ──────────────────────────────────────────────────────

class _PickupAddressCard extends StatelessWidget {
  const _PickupAddressCard({this.address, this.city});

  final String? address;
  final String? city;

  bool get _hasAddress =>
      (address != null && address!.isNotEmpty) ||
      (city != null && city!.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    if (_hasAddress) {
      final lines = [
        if (address != null && address!.isNotEmpty) address!,
        if (city != null && city!.isNotEmpty) city!,
      ];
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE0E4EC)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.navWalkers.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.place_rounded,
                size: 18,
                color: AppColors.navWalkers,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pickup address',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lines.join(', '),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF5A6473),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => sl<ProfileCubit>()..load(),
                    child: const EditProfileScreen(),
                  ),
                ),
              ),
              child: const Text(
                'Edit',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.navWalkers,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8EC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD97A)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 20,
            color: Color(0xFFB87300),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No pickup address set',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Add your address so the walker knows where to pick up your dog.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF5A6473)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const EditProfileScreen(),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFB87300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Set address',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── No Pets View ─────────────────────────────────────────────────────────────

class _NoPetsView extends StatelessWidget {
  const _NoPetsView({required this.onAddPet});

  final VoidCallback onAddPet;

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
                color: AppColors.navWalkers.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.pets_rounded,
                size: 40,
                color: AppColors.navWalkers,
              ),
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
              'Add your first pet to start booking walks.',
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
                backgroundColor: AppColors.navWalkers,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Add a Pet',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
