import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/di/injection.dart';
import '../../../core/widgets/balto_toast.dart';
import '../../../domain/repositories/business_repository.dart';
import '../../bloc/profile/profile_cubit.dart';
import '../../bloc/profile/profile_state.dart';

class EditBusinessProfileScreen extends StatefulWidget {
  const EditBusinessProfileScreen({super.key});

  @override
  State<EditBusinessProfileScreen> createState() =>
      _EditBusinessProfileScreenState();
}

class _EditBusinessProfileScreenState extends State<EditBusinessProfileScreen> {
  late final TextEditingController _instagramCtrl;
  late final TextEditingController _facebookCtrl;

  bool _saving = false;
  bool _initialized = false;

  static const Color _bg = AppColors.background;
  static const Color _textDark = Color(0xFF1F2937);
  static const Color _textMuted = Color(0xFF8A93A0);
  static const Color _green = AppColors.navWalkers;

  @override
  void initState() {
    super.initState();
    _instagramCtrl = TextEditingController();
    _facebookCtrl = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final state = context.read<ProfileCubit>().state;
        if (state is ProfileLoaded) {
          final b = state.businessProfile;
          if (b == null || !b.isVerified) {
            if (!mounted) return;
            BaltoToast.warning(context, 'Business profile not available.');
            Navigator.of(context).pop();
            return;
          }
          _instagramCtrl.text = b.instagramUrl ?? '';
          _facebookCtrl.text = b.facebookUrl ?? '';
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
    _instagramCtrl.dispose();
    _facebookCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await sl<BusinessRepository>().updateMyBusiness(
        instagramUrl: _instagramCtrl.text.trim(),
        facebookUrl: _facebookCtrl.text.trim(),
      );

      if (!mounted) return;
      await context.read<ProfileCubit>().load();

      if (!mounted) return;
      BaltoToast.success(context, 'Business updated successfully.');
      Navigator.of(context).pop();
    } on BusinessFailure catch (e) {
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
        title: Text(
          'Edit Business',
          style: AppTextStyles.h3.copyWith(color: _textDark),
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
          ? SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIconHeader(),
                  const SizedBox(height: 32),
                  const Text(
                    'Social Links',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'These are the only fields a business can update from the app.',
                    style: TextStyle(fontSize: 12, color: _textMuted),
                  ),
                  const SizedBox(height: 16),
                  _fieldLabel('Instagram URL'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _instagramCtrl,
                    keyboardType: TextInputType.url,
                    decoration: _inputDecoration(
                      hint: 'https://instagram.com/yourbusiness',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _fieldLabel('Facebook URL'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _facebookCtrl,
                    keyboardType: TextInputType.url,
                    decoration: _inputDecoration(
                      hint: 'https://facebook.com/yourbusiness',
                    ),
                  ),
                  const SizedBox(height: 36),
                  _buildSaveButton(),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildIconHeader() {
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
            child: const Icon(
              Icons.storefront_rounded,
              size: 48,
              color: _green,
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Update how customers find you online',
          style: TextStyle(fontSize: 13, color: _textMuted),
        ),
      ],
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.label.copyWith(color: const Color(0xFF5A6473)),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _textMuted, fontSize: 14),
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
        borderSide: const BorderSide(color: _green, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

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
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radius14),
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
}
