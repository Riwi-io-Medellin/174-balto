import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/di/injection.dart';
import '../../../core/widgets/balto_toast.dart';
import '../../../domain/repositories/home_service_profile_repository.dart';
import '../../bloc/profile/profile_cubit.dart';

class BecomeHomeServiceProviderScreen extends StatefulWidget {
  const BecomeHomeServiceProviderScreen({super.key, this.isReapply = false});

  /// true when the user was previously rejected and is re-submitting.
  final bool isReapply;

  @override
  State<BecomeHomeServiceProviderScreen> createState() =>
      _BecomeHomeServiceProviderScreenState();
}

class _BecomeHomeServiceProviderScreenState
    extends State<BecomeHomeServiceProviderScreen> {
  final _picker = ImagePicker();
  XFile? _pickedDocument;
  bool _submitting = false;

  final _baseLocationCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  static const Color _accent = AppColors.homeServices;
  static const Color _bg = AppColors.background;
  static const Color _textDark = Color(0xFF1F2937);
  static const Color _textMid = Color(0xFF5A6473);
  static const Color _textMuted = Color(0xFF8A93A0);

  @override
  void dispose() {
    _baseLocationCtrl.dispose();
    _experienceCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null) setState(() => _pickedDocument = image);
  }

  Future<void> _submit() async {
    if (_pickedDocument == null) {
      BaltoToast.warning(
        context,
        'Please select your identity document first.',
      );
      return;
    }
    final baseLocation = _baseLocationCtrl.text.trim();
    if (baseLocation.isEmpty) {
      BaltoToast.warning(context, 'Please enter your base location.');
      return;
    }
    final experience = _experienceCtrl.text.trim();
    if (experience.isEmpty) {
      BaltoToast.warning(context, 'Please describe your experience.');
      return;
    }

    setState(() => _submitting = true);
    try {
      await sl<HomeServiceProfileRepository>().apply(
        documentImagePath: _pickedDocument!.path,
        baseLocation: baseLocation,
        experience: experience,
        description: _descriptionCtrl.text.trim(),
      );

      if (!mounted) return;
      await context.read<ProfileCubit>().load();

      if (!mounted) return;
      BaltoToast.success(
        context,
        widget.isReapply
            ? 'Application re-submitted successfully!'
            : 'Application approved! You\'re now a home service provider.',
      );
      Navigator.of(context).pop();
    } on HomeServiceProfileFailure catch (e) {
      if (!mounted) return;
      BaltoToast.error(context, e.message);
    } catch (e) {
      if (!mounted) return;
      BaltoToast.error(
        context,
        'Something went wrong. Please try again.',
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _textDark,
        ),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
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
          widget.isReapply
              ? 'Re-submit Application'
              : 'Become a Home Service Provider',
          style: AppTextStyles.h3.copyWith(color: _textDark),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroCard(),
            const SizedBox(height: 28),
            _buildSectionTitle('Profile Information'),
            const SizedBox(height: 16),
            _fieldLabel('Base Location *'),
            TextField(
              controller: _baseLocationCtrl,
              decoration: _inputDecoration(
                hint: 'e.g. Downtown, Westside',
              ),
            ),
            const SizedBox(height: 16),
            _fieldLabel('Experience *'),
            TextField(
              controller: _experienceCtrl,
              minLines: 3,
              maxLines: 5,
              decoration: _inputDecoration(
                hint:
                    'Describe your professional experience (vet, grooming, training, etc.)...',
              ),
            ),
            const SizedBox(height: 16),
            _fieldLabel('Description (optional)'),
            TextField(
              controller: _descriptionCtrl,
              minLines: 2,
              maxLines: 4,
              decoration: _inputDecoration(
                hint: 'A short bio to show potential clients...',
              ),
            ),
            const SizedBox(height: 28),
            _buildSectionTitle('Identity Document'),
            const SizedBox(height: 6),
            const Text(
              'Upload a clear photo of a valid government-issued ID (national ID, passport, or driver\'s license).',
              style: TextStyle(fontSize: 13, color: _textMid, height: 1.5),
            ),
            const SizedBox(height: 16),
            _buildDocumentPicker(),
            const SizedBox(height: 32),
            _buildRequirementsList(),
            const SizedBox(height: 36),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  // ─── Hero Card ────────────────────────────────────────────────────────────

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radius20,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.home_repair_service_rounded,
              size: 32,
              color: _accent,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            widget.isReapply
                ? 'Re-submit Your Document'
                : 'Join Our Home Services Network',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            widget.isReapply
                ? 'Your previous document was not accepted. Upload a new, clear photo to try again.'
                : 'Offer vet, grooming, sitting, training and more — directly at your clients\' homes.',
            style: const TextStyle(
              fontSize: 13,
              color: _textMid,
              height: 1.55,
            ),
            textAlign: TextAlign.center,
          ),
          if (!widget.isReapply) ...[
            const SizedBox(height: 20),
            const Divider(color: Color(0xFFF1F3F6)),
            const SizedBox(height: 16),
            _buildBenefitsRow(),
          ],
        ],
      ),
    );
  }

  Widget _buildBenefitsRow() {
    return Row(
      children: [
        _buildBenefit(Icons.category_rounded, 'Multiple\nServices'),
        _buildBenefit(Icons.payments_outlined, 'Flexible\nPricing'),
        _buildBenefit(Icons.verified_rounded, 'Verified\nBadge'),
      ],
    );
  }

  Widget _buildBenefit(IconData icon, String label) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: _accent),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.micro.copyWith(color: _textMid, height: 1.4),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── Section Title ────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: _textDark,
      ),
    );
  }

  // ─── Document Picker ──────────────────────────────────────────────────────

  Widget _buildDocumentPicker() {
    if (_pickedDocument != null) {
      return _buildDocumentPreview();
    }
    return GestureDetector(
      onTap: _submitting ? null : _pickDocument,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.radius16,
          border: Border.all(
            color: const Color(0xFFDDE1EA),
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.upload_file_rounded,
                size: 26,
                color: _accent,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Tap to select document',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'JPG, PNG — max 10 MB',
              style: TextStyle(fontSize: 12, color: _textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentPreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: AppRadius.radius16,
          child: Image.file(
            File(_pickedDocument!.path),
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: GestureDetector(
            onTap: _submitting ? null : _pickDocument,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: AppRadius.radiusPill,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.edit_rounded, size: 14, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    'Change',
                    style: AppTextStyles.captionStrong.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _accent,
              borderRadius: AppRadius.radiusPill,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 13,
                  color: Colors.white,
                ),
                SizedBox(width: 5),
                Text(
                  'Document selected',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Requirements ─────────────────────────────────────────────────────────

  Widget _buildRequirementsList() {
    const items = [
      (Icons.light_mode_rounded, 'Photo must be well-lit and in focus'),
      (Icons.crop_free_rounded, 'All four corners of the ID must be visible'),
      (
        Icons.person_rounded,
        'Name and photo on the ID must match your profile'
      ),
      (
        Icons.security_rounded,
        'Document will only be used for identity verification'
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radius16,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Photo requirements',
            style: AppTextStyles.bodyBold.copyWith(color: _textDark),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _accent.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.$1, size: 14, color: _accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        item.$2,
                        style: const TextStyle(
                          fontSize: 13,
                          color: _textMid,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Submit Button ────────────────────────────────────────────────────────

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _submitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radius14,
          ),
          disabledBackgroundColor: _accent.withValues(alpha: 0.45),
        ),
        child: _submitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                widget.isReapply
                    ? 'Re-submit Document'
                    : 'Submit Application',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
