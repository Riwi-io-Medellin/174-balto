import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/widgets/balto_toast.dart';
import '../../../domain/entities/home_service_provider_profile.dart';
import '../../../domain/repositories/home_service_profile_repository.dart';
import '../../bloc/profile/profile_cubit.dart';

class EditHomeServiceProviderProfileScreen extends StatefulWidget {
  const EditHomeServiceProviderProfileScreen({super.key});

  @override
  State<EditHomeServiceProviderProfileScreen> createState() =>
      _EditHomeServiceProviderProfileScreenState();
}

class _EditHomeServiceProviderProfileScreenState
    extends State<EditHomeServiceProviderProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _bioCtrl;
  late final TextEditingController _yearsCtrl;
  late final TextEditingController _maxConcurrentCtrl;
  late final TextEditingController _baseLocationCtrl;

  bool _isAcceptingBookings = true;
  bool _saving = false;
  bool _initialized = false;

  static const Color _bg = Color(0xFFF5F6FA);
  static const Color _textDark = Color(0xFF1F2937);
  static const Color _textMid = Color(0xFF5A6473);
  static const Color _textMuted = Color(0xFF8A93A0);
  static const Color _accent = AppColors.homeServices;

  @override
  void initState() {
    super.initState();
    _bioCtrl = TextEditingController();
    _yearsCtrl = TextEditingController();
    _maxConcurrentCtrl = TextEditingController();
    _baseLocationCtrl = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    try {
      final pp = await sl<HomeServiceProfileRepository>().getMyProfile();
      if (pp == null || pp.status != HomeServiceProviderStatus.approved) {
        if (!mounted) return;
        BaltoToast.warning(context, 'Provider profile not available.');
        Navigator.of(context).pop();
        return;
      }
      _bioCtrl.text = pp.bio ?? '';
      _yearsCtrl.text = pp.yearsOfExperience != null
          ? pp.yearsOfExperience.toString()
          : '';
      _maxConcurrentCtrl.text = pp.maxConcurrentBookings.toString();
      _baseLocationCtrl.text = pp.baseLocation ?? '';
      _isAcceptingBookings = pp.isAcceptingBookings;
      if (!mounted) return;
      setState(() => _initialized = true);
    } catch (_) {
      if (!mounted) return;
      BaltoToast.error(context, 'Failed to load profile.');
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _bioCtrl.dispose();
    _yearsCtrl.dispose();
    _maxConcurrentCtrl.dispose();
    _baseLocationCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);
    try {
      await sl<HomeServiceProfileRepository>().updateMyProfile(
        bio: _bioCtrl.text.trim(),
        yearsOfExperience: int.tryParse(_yearsCtrl.text.trim()),
        isAcceptingBookings: _isAcceptingBookings,
        maxConcurrentBookings: int.tryParse(_maxConcurrentCtrl.text.trim()),
        baseLocation: _baseLocationCtrl.text.trim(),
      );

      if (!mounted) return;
      await context.read<ProfileCubit>().load();

      if (!mounted) return;
      BaltoToast.success(context, 'Profile updated successfully.');
      Navigator.of(context).pop();
    } on HomeServiceProfileFailure catch (e) {
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
                color: _saving ? _textMuted : _accent,
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
                    _buildSectionTitle('Service Settings'),
                    const SizedBox(height: 14),
                    _buildServiceFields(),
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
              color: _accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.home_repair_service_rounded,
              size: 48,
              color: _accent,
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Edit your home service provider profile below',
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
            hint:
                'Certified veterinarian with 8 years of home-visit experience...',
          ),
        ),
      ],
    );
  }

  // ─── Service settings ───────────────────────────────────────────────────────

  Widget _buildServiceFields() {
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
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('Max Concurrent Bookings'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _maxConcurrentCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(hint: '1'),
                    validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      final n = int.tryParse(v);
                      if (n == null || n < 1) return 'Must be at least 1.';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _fieldLabel('Base Location'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _baseLocationCtrl,
          decoration: _inputDecoration(hint: 'e.g. Downtown, Westside'),
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
              color: _accent.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.schedule_rounded, size: 20, color: _accent),
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
            activeTrackColor: _accent,
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
          backgroundColor: _accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          disabledBackgroundColor: _accent.withValues(alpha: 0.45),
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
        borderSide: const BorderSide(color: _accent, width: 1.5),
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
