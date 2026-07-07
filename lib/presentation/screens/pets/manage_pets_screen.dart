import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/di/injection.dart';
import '../../../core/widgets/balto_toast.dart';
import '../../../domain/entities/pet.dart';
import '../../../domain/entities/vet_document_analysis.dart';
import '../../../domain/repositories/pet_repository.dart';
import '../../bloc/profile/profile_cubit.dart';
import '../../bloc/profile/profile_state.dart';
import '../pet_tag/scan_nfc_tag_screen.dart';
import 'create_pet_screen.dart';
import 'edit_pet_screen.dart';
import 'pet_detail_screen.dart';

class ManagePetsScreen extends StatelessWidget {
  const ManagePetsScreen({super.key});

  static const Color _bg = Color(0xFFF0F4F4);
  static const Color _textDark = Color(0xFF1A1A2E);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _bgPurple = Color(0xFFF0EAFB);
  static const Color _red = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Manage Pets'),
        backgroundColor: Colors.white,
        foregroundColor: _textDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.nfc_rounded),
            tooltip: 'Scan Pet Tag',
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ScanNfcTagScreen())),
          ),
        ],
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final pets = state is ProfileLoaded ? state.pets : <Pet>[];

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (pets.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.radius16,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.pets,
                        size: 48,
                        color: AppColors.petProfile.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No pets registered yet',
                        style: TextStyle(fontSize: 15, color: _textMuted),
                      ),
                    ],
                  ),
                )
              else
                ...pets.map(
                  (pet) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildDismissibleCard(context, pet),
                  ),
                ),
              const SizedBox(height: 12),
              _buildAddButton(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDismissibleCard(BuildContext context, Pet pet) {
    return Dismissible(
      key: ValueKey(pet.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Pet'),
            content: Text('Remove ${pet.name}? This cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: TextButton.styleFrom(foregroundColor: _red),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        return confirmed == true;
      },
      onDismissed: (_) async {
        try {
          await sl<PetRepository>().delete(pet.id);
          if (!context.mounted) return;
          await context.read<ProfileCubit>().load();
          if (!context.mounted) return;
          BaltoToast.success(context, '${pet.name} removed.');
        } catch (e) {
          if (!context.mounted) return;
          BaltoToast.error(context, 'Error: ${e.toString()}');
        }
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: _red,
          borderRadius: AppRadius.radius14,
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      child: _buildPetCard(context, pet),
    );
  }

  Widget _buildPetCard(BuildContext context, Pet pet) {
    final age = pet.birthDate != null
        ? '${DateTime.now().year - pet.birthDate!.year} yr'
        : null;

    final chips = <String>[
      if (pet.species != null) pet.species!,
      if (pet.breed != null) pet.breed!,
      ?age,
      if (pet.weight != null) '${pet.weight!.toStringAsFixed(1)} kg',
    ];
    final healthIndicator = _healthIndicator(pet);

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<ProfileCubit>(),
            child: PetDetailScreen(petId: pet.id),
          ),
        ),
      ),
      borderRadius: AppRadius.radius14,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.radius14,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildAvatar(pet),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          pet.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _textDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (healthIndicator != null) ...[
                        const SizedBox(width: 6),
                        healthIndicator,
                      ],
                    ],
                  ),
                  if (chips.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      chips.join(' · '),
                      style: const TextStyle(fontSize: 12, color: _textMuted),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              color: AppColors.navCoach,
              visualDensity: VisualDensity.compact,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<ProfileCubit>(),
                    child: EditPetScreen(pet: pet),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _healthIndicator(Pet pet) {
    if (pet.latestHealthUrgency == null) return null;
    final level = UrgencyLevel.fromJson(pet.latestHealthUrgency!);
    if (level == UrgencyLevel.routine) return null;

    final color = switch (level) {
      UrgencyLevel.scheduleVetVisit => const Color(0xFFE8A84C),
      UrgencyLevel.urgent => const Color(0xFFD05A24),
      UrgencyLevel.emergency => const Color(0xFFD32F2F),
      UrgencyLevel.routine => AppColors.petProfile,
    };
    final icon = switch (level) {
      UrgencyLevel.scheduleVetVisit => Icons.event_note_rounded,
      UrgencyLevel.urgent => Icons.warning_rounded,
      UrgencyLevel.emergency => Icons.emergency_rounded,
      UrgencyLevel.routine => Icons.favorite_rounded,
    };
    return Icon(icon, size: 16, color: color);
  }

  Widget _buildAvatar(Pet pet) {
    if (pet.photoUrl != null && pet.photoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: AppRadius.radius12,
        child: Image.network(
          pet.photoUrl!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildInitialsAvatar(pet.name),
        ),
      );
    }
    return _buildInitialsAvatar(pet.name);
  }

  Widget _buildInitialsAvatar(String name) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.petProfile.withValues(alpha: 0.12),
        borderRadius: AppRadius.radius12,
      ),
      child: Center(
        child: Text(
          name[0].toUpperCase(),
          style: AppTextStyles.h2.copyWith(color: AppColors.petProfile),
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<ProfileCubit>(),
            child: const CreatePetScreen(),
          ),
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _bgPurple,
          borderRadius: AppRadius.radius14,
          border: Border.all(
            color: AppColors.navCoach.withValues(alpha: 0.30),
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          '+ Add New Pet',
          style: AppTextStyles.bodyBold.copyWith(color: AppColors.navCoach),
        ),
      ),
    );
  }
}
