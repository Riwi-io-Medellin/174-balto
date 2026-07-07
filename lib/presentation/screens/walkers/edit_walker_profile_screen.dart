import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/widgets/balto_toast.dart';
import '../../../domain/entities/walker_profile.dart';
import '../../../domain/repositories/walker_profile_repository.dart';
import '../../bloc/profile/profile_cubit.dart';
import '../../bloc/profile/profile_state.dart';

class EditWalkerProfileScreen extends StatefulWidget {
  const EditWalkerProfileScreen({super.key});

  @override
  State<EditWalkerProfileScreen> createState() =>
      _EditWalkerProfileScreenState();
}

class _EditWalkerProfileScreenState extends State<EditWalkerProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _bioCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _yearsCtrl;
  late final TextEditingController _radiusCtrl;
  late final TextEditingController _maxDogsCtrl;

  bool _isAcceptingBookings = true;
  bool _saving = false;
  bool _initialized = false;

  static const Color _bg = Color(0xFFF5F6FA);
  static const Color _textDark = Color(0xFF1F2937);
  static const Color _textMid = Color(0xFF5A6473);
  static const Color _textMuted = Color(0xFF8A93A0);
  static const Color _green = AppColors.navWalkers;

  @override
  void initState() {
    super.initState();
    _bioCtrl = TextEditingController();
    _priceCtrl = TextEditingController();
    _yearsCtrl = TextEditingController();
    _radiusCtrl = TextEditingController();
    _maxDogsCtrl = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final state = context.read<ProfileCubit>().state;
        if (state is ProfileLoaded) {
          final wp = state.walkerProfile;
          if (wp == null || wp.status != WalkerStatus.approved) {
            if (!mounted) return;
            BaltoToast.warning(context, 'Walker profile not available.');
            Navigator.of(context).pop();
            return;
          }
          _bioCtrl.text = wp.bio ?? '';
          _priceCtrl.text = wp.hourlyRate != null
              ? wp.hourlyRate!.toStringAsFixed(0)
              : '';
          _yearsCtrl.text = wp.yearsOfExperience != null
              ? wp.yearsOfExperience.toString()
              : '';
          _radiusCtrl.text = wp.serviceRadiusKm != null
              ? wp.serviceRadiusKm.toString()
              : '';
          _maxDogsCtrl.text = wp.maxDogs != null ? wp.maxDogs.toString() : '';
          _isAcceptingBookings = wp.isAcceptingBookings;
          setState(() => _initialized = true);
        }
      } catch (_) {
        if (!mounted) return;
        BaltoToast.error(context, 'Failed to load profile.');
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _bioCtrl.dispose();
    _priceCtrl.dispose();
    _yearsCtrl.dispose();
    _radiusCtrl.dispose();
    _maxDogsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);
    try {
      await sl<WalkerProfileRepository>().updateMyProfile(
        bio: _bioCtrl.text.trim(),
        hourlyRate: double.tryParse(_priceCtrl.text.trim()),
        serviceRadiusKm: double.tryParse(_radiusCtrl.text.trim()),
        yearsOfExperience: int.tryParse(_yearsCtrl.text.trim()),
        isAcceptingBookings: _isAcceptingBookings,
        maxDogs: int.tryParse(_maxDogsCtrl.text.trim()),
      );

      if (!mounted) return;
      await context.read<ProfileCubit>().load();

      if (!mounted) return;
      BaltoToast.success(context, 'Profile updated successfully.');
      Navigator.of(context).pop();
    } on WalkerProfileFailure catch (e) {
      if (!mounted) return;
      BaltoToast.error(context, e.message);
    } catch (e) {
      if (!mounted) return;
      BaltoToast.error(context, 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: _textDark,
          ),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(
              'Save',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _saving ? _textMuted : _green,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _initialized
          ? Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAvatarSection(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Basic Information'),
                    const SizedBox(height: 14),
                    _buildBioField(),
                    const SizedBox(height: 28),
                    _buildSectionTitle('Services & Pricing'),
                    const SizedBox(height: 14),
                    _buildServicesFields(),
                    const SizedBox(height: 24),
                    _buildAcceptingBookingsToggle(),
                    const SizedBox(height: 36),
                    _buildSaveButton(),
                  ],
                ),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  // ─── Avatar ───────────────────────────────────────────────────────────────

  Widget _buildAvatarSection() {
    return Column(
      children: [
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded, size: 48, color: _green),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Edit your walker profile details below',
          style: TextStyle(fontSize: 13, color: _textMuted),
        ),
      ],
    );
  }

  // ─── Section title ────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: _textDark,
      ),
    );
  }

  // ─── Bio ──────────────────────────────────────────────────────────────────

  Widget _buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Biography'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _bioCtrl,
          minLines: 4,
          maxLines: 6,
          decoration: _inputDecoration(
            hint: 'Experienced dog walker with a passion for large breeds...',
          ),
        ),
      ],
    );
  }

  // ─── Services & Pricing ────────────────────────────────────────────────────

  Widget _buildServicesFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('Price per Walk (\$)'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(hint: '25'),
                    validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      final n = double.tryParse(v);
                      if (n == null || n <= 0) return 'Invalid.';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('Years Experience'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _yearsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(hint: '5'),
                    validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      final n = int.tryParse(v);
                      if (n == null || n < 0) return 'Invalid.';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _fieldLabel('Service Radius (km)'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _radiusCtrl,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration(hint: '10'),
          validator: (v) {
            if (v == null || v.isEmpty) return null;
            final n = double.tryParse(v);
            if (n == null || n <= 0) return 'Invalid.';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _fieldLabel('Max Dogs per Walk'),
        const SizedBox(height: 4),
        const Text(
          'Owners booking with a priority (solo) walk will be charged a 50% surcharge.',
          style: TextStyle(fontSize: 12, color: _textMuted),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _maxDogsCtrl,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration(hint: '3'),
          validator: (v) {
            if (v == null || v.isEmpty) return null;
            final n = int.tryParse(v);
            if (n == null || n < 1) return 'Must be at least 1.';
            return null;
          },
        ),
      ],
    );
  }

  // ─── Accepting Bookings Toggle ────────────────────────────────────────────

  Widget _buildAcceptingBookingsToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E4EC)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.schedule_rounded, size: 20, color: _green),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Accepting Bookings',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Make your profile visible to pet owners',
                  style: TextStyle(fontSize: 12, color: _textMuted),
                ),
              ],
            ),
          ),
          Switch(
            value: _isAcceptingBookings,
            activeTrackColor: _green,
            activeThumbColor: Colors.white,
            onChanged: (v) => setState(() => _isAcceptingBookings = v),
          ),
        ],
      ),
    );
  }

  // ─── Save Button ──────────────────────────────────────────────────────────

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _saving ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          disabledBackgroundColor: _green.withValues(alpha: 0.45),
        ),
        child: _saving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Save Changes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: _textMid,
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _textMuted, fontSize: 14),
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
        borderSide: const BorderSide(color: _green, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD05A24)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD05A24), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
