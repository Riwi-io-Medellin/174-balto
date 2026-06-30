import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/widgets/balto_toast.dart';
import '../../../domain/entities/pet.dart';
import '../../../domain/repositories/pet_repository.dart';
import '../../bloc/profile/profile_cubit.dart';
import '../../bloc/profile/profile_state.dart';
import 'edit_pet_screen.dart';

class PetDetailScreen extends StatelessWidget {
  const PetDetailScreen({super.key, required this.petId});

  final String petId;

  static const _green = AppColors.petProfile;
  static const _greenBg = Color(0xFFE8F8F2);
  static const _textMid = Color(0xFF5A6473);
  static const _textMuted = Color(0xFF8A93A0);
  static const _red = Color(0xFFE5544B);
  static const _redBg = Color(0xFFFEECE8);

  Pet? _findPet(BuildContext context) {
    final state = context.read<ProfileCubit>().state;
    if (state is ProfileLoaded) {
      try {
        return state.pets.firstWhere((p) => p.id == petId);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> _confirmDelete(BuildContext context, Pet pet) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Pet', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Remove ${pet.name} from your pets?\nThis cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: _textMid)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await sl<PetRepository>().delete(pet.id);
      await context.read<ProfileCubit>().load();
      if (!context.mounted) return;
      BaltoToast.success(context, '${pet.name} removed.');
      Navigator.of(context).pop();
    } catch (e) {
      if (!context.mounted) return;
      BaltoToast.error(context, 'Error: ${e.toString()}');
    }
  }

  int _calcAge(DateTime? birthDate) {
    if (birthDate == null) return -1;
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  List<Widget> _buildDetailRows(Pet pet) {
    final rows = <Widget>[];

    if (pet.species != null) {
      rows.add(_DetailRow(
        icon: Icons.category_rounded,
        iconColor: _green,
        iconBg: _greenBg,
        label: 'Species',
        value: pet.species!,
      ));
    }
    if (pet.breed != null) {
      rows.add(_DetailRow(
        icon: Icons.style_rounded,
        iconColor: AppColors.dashboard,
        iconBg: const Color(0xFFEAF2FB),
        label: 'Breed',
        value: pet.breed!,
      ));
    }
    if (pet.birthDate != null) {
      rows.add(_DetailRow(
        icon: Icons.cake_rounded,
        iconColor: AppColors.alert,
        iconBg: const Color(0xFFFFF1E6),
        label: 'Birthday',
        value: _formatDate(pet.birthDate!),
      ));
    }
    if (pet.weight != null) {
      rows.add(_DetailRow(
        icon: Icons.monitor_weight_rounded,
        iconColor: AppColors.coreBrand,
        iconBg: const Color(0xFFECF2F2),
        label: 'Weight',
        value: '${pet.weight!.toStringAsFixed(1)} kg',
      ));
    }

    if (rows.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('No details added yet.', style: TextStyle(color: _textMuted)),
        ),
      ];
    }

    final result = <Widget>[];
    for (int i = 0; i < rows.length; i++) {
      result.add(rows[i]);
      if (i < rows.length - 1) {
        result.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Divider(height: 1, color: Color(0xFFF1F3F6)),
        ));
      }
    }
    return result;
  }

  Widget _buildHeroBg(Pet pet) {
    if (pet.photoUrl != null && pet.photoUrl!.isNotEmpty) {
      return Image.network(
        pet.photoUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _gradientBg(pet),
      );
    }
    return _gradientBg(pet);
  }

  Widget _gradientBg(Pet pet) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF22C07A), Color(0xFF1BAA71), Color(0xFF148F5E)],
        ),
      ),
      child: Center(
        child: Text(
          pet.name[0].toUpperCase(),
          style: const TextStyle(
            fontSize: 100,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1,
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(left: 4),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: _textMuted,
        letterSpacing: 1.0,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final pet = _findPet(context);
    if (pet == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final age = _calcAge(pet.birthDate);
    final ageLabel = age >= 0 ? (age == 1 ? '1 yr' : '$age yrs') : '—';
    final weightLabel = pet.weight != null
        ? '${pet.weight!.toStringAsFixed(1)} kg'
        : '—';
    final speciesLabel = pet.species ?? '—';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // ── Hero ──
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: _green,
            foregroundColor: Colors.white,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            actions: [
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<ProfileCubit>(),
                      child: EditPetScreen(pet: pet),
                    ),
                  ),
                ),
                child: Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit_rounded, size: 18, color: Colors.white),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _buildHeroBg(pet),
                  // bottom gradient for text legibility
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.35, 1.0],
                        colors: [Colors.transparent, Color(0xDD148F5E)],
                      ),
                    ),
                  ),
                  // name + breed badge
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          pet.name,
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                        if (pet.breed != null) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.20),
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.40),
                              ),
                            ),
                            child: Text(
                              pet.breed!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Quick Stats ──
                  Row(
                    children: [
                      _StatCard(
                        icon: Icons.cake_rounded,
                        label: 'Age',
                        value: ageLabel,
                        color: _green,
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        icon: Icons.monitor_weight_rounded,
                        label: 'Weight',
                        value: weightLabel,
                        color: AppColors.dashboard,
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        icon: Icons.pets_rounded,
                        label: 'Species',
                        value: speciesLabel,
                        color: AppColors.coreBrand,
                      ),
                    ],
                  ),

                  // ── Profile Details ──
                  const SizedBox(height: 24),
                  _sectionLabel('PROFILE'),
                  const SizedBox(height: 8),
                  _Card(children: _buildDetailRows(pet)),

                  // ── About ──
                  if (pet.description != null && pet.description!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _sectionLabel('ABOUT'),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        pet.description!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: _textMid,
                          height: 1.65,
                        ),
                      ),
                    ),
                  ],

                  // ── Registered ──
                  const SizedBox(height: 24),
                  _sectionLabel('ACCOUNT'),
                  const SizedBox(height: 8),
                  _Card(
                    children: [
                      _DetailRow(
                        icon: Icons.calendar_today_rounded,
                        iconColor: AppColors.dashboard,
                        iconBg: const Color(0xFFEAF2FB),
                        label: 'Registered',
                        value: _formatDate(pet.createdAt),
                      ),
                    ],
                  ),

                  // ── Danger Zone ──
                  const SizedBox(height: 24),
                  _sectionLabel('DANGER ZONE'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _confirmDelete(context, pet),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _redBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _red.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _red.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.delete_forever_rounded,
                              color: _red,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Remove Pet',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: _red,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'This action cannot be undone.',
                                  style: TextStyle(fontSize: 12, color: _textMuted),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: _red, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF8A93A0)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Color(0xFF5A6473)),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }
}
