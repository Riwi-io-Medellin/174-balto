import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/widgets/balto_toast.dart';
import '../../../domain/repositories/business_repository.dart';
import '../../bloc/profile/profile_cubit.dart';

class BecomeBusinessScreen extends StatefulWidget {
  const BecomeBusinessScreen({super.key, this.isReapply = false});

  /// true when the previous registration was rejected and this is a re-submit.
  final bool isReapply;

  @override
  State<BecomeBusinessScreen> createState() => _BecomeBusinessScreenState();
}

class _BecomeBusinessScreenState extends State<BecomeBusinessScreen> {
  final _picker = ImagePicker();
  XFile? _pickedDocument;
  bool _submitting = false;

  final _nameCtrl = TextEditingController();
  final _nitCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  String _type = 'veterinary';
  static const _types = [
    'veterinary',
    'grooming',
    'shelter',
    'petshop',
    'other',
  ];

  static const Color _green = AppColors.navWalkers;
  static const Color _bg = Color(0xFFF5F6FA);
  static const Color _textDark = Color(0xFF1F2937);
  static const Color _textMid = Color(0xFF5A6473);
  static const Color _textMuted = Color(0xFF8A93A0);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nitCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _addressCtrl.dispose();
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
      BaltoToast.warning(context, 'Please select your NIT document first.');
      return;
    }
    final name = _nameCtrl.text.trim();
    final nit = _nitCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    if (name.isEmpty || nit.isEmpty || email.isEmpty || phone.isEmpty) {
      BaltoToast.warning(context, 'Please fill in all required fields.');
      return;
    }

    setState(() => _submitting = true);
    try {
      await sl<BusinessRepository>().apply(
        name: name,
        nit: nit,
        email: email,
        phone: phone,
        documentImagePath: _pickedDocument!.path,
        type: _type,
        location: _locationCtrl.text.trim().isEmpty
            ? null
            : _locationCtrl.text.trim(),
        address: _addressCtrl.text.trim().isEmpty
            ? null
            : _addressCtrl.text.trim(),
      );

      if (!mounted) return;
      await context.read<ProfileCubit>().load();

      if (!mounted) return;
      BaltoToast.success(
        context,
        widget.isReapply
            ? 'Application re-submitted successfully!'
            : 'Business registered! We\'ll review your NIT document shortly.',
      );
      Navigator.of(context).pop();
    } on BusinessFailure catch (e) {
      if (!mounted) return;
      BaltoToast.error(context, e.message);
    } catch (e) {
      if (!mounted) return;
      BaltoToast.error(context, 'Something went wrong. Please try again.');
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
          widget.isReapply ? 'Re-submit Application' : 'Register a Business',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
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
            _buildSectionTitle('Business Information'),
            const SizedBox(height: 16),
            _fieldLabel('Business Type *'),
            _buildTypeSelector(),
            const SizedBox(height: 16),
            _fieldLabel('Business Name *'),
            TextField(
              controller: _nameCtrl,
              decoration: _inputDecoration(hint: 'e.g. Happy Paws Vet Clinic'),
            ),
            const SizedBox(height: 16),
            _fieldLabel('NIT *'),
            TextField(
              controller: _nitCtrl,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration(hint: '900123456-7'),
            ),
            const SizedBox(height: 16),
            _fieldLabel('Email *'),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration(hint: 'contact@business.com'),
            ),
            const SizedBox(height: 16),
            _fieldLabel('Phone *'),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration(hint: '3001234567'),
            ),
            const SizedBox(height: 16),
            _fieldLabel('Location (optional)'),
            TextField(
              controller: _locationCtrl,
              decoration: _inputDecoration(hint: 'e.g. Medellín'),
            ),
            const SizedBox(height: 16),
            _fieldLabel('Address (optional)'),
            TextField(
              controller: _addressCtrl,
              decoration: _inputDecoration(hint: 'Street and number'),
            ),
            const SizedBox(height: 28),
            _buildSectionTitle('NIT Document'),
            const SizedBox(height: 6),
            const Text(
              'Upload a clear photo of the NIT registration certificate (RUT).',
              style: TextStyle(fontSize: 13, color: _textMid, height: 1.5),
            ),
            const SizedBox(height: 16),
            _buildDocumentPicker(),
            const SizedBox(height: 36),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
              color: _green.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.storefront_rounded,
              size: 32,
              color: _green,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            widget.isReapply
                ? 'Re-submit Your Document'
                : 'List Your Business on Balto',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'Reach pet owners near you. Verification usually takes 24–48 hours.',
            style: TextStyle(fontSize: 13, color: _textMid, height: 1.4),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

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

  Widget _buildTypeSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _types.map((t) {
        final selected = t == _type;
        return GestureDetector(
          onTap: () => setState(() => _type = t),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: selected ? _green : Colors.white,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(
                color: selected ? _green : const Color(0xFFE0E4EC),
              ),
            ),
            child: Text(
              t[0].toUpperCase() + t.substring(1),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : _textMid,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDocumentPicker() {
    if (_pickedDocument != null) return _buildDocumentPreview();
    return GestureDetector(
      onTap: _submitting ? null : _pickDocument,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDDE1EA), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _green.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.upload_file_rounded,
                size: 26,
                color: _green,
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
          borderRadius: BorderRadius.circular(16),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(99),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_rounded, size: 14, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'Change',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _submitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          disabledBackgroundColor: _green.withValues(alpha: 0.45),
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
                widget.isReapply ? 'Re-submit Document' : 'Submit Registration',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
