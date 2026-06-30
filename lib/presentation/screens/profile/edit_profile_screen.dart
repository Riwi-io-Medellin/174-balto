import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/di/injection.dart';
import '../../../core/widgets/balto_toast.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/upload_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../bloc/profile/profile_cubit.dart';
import '../../bloc/profile/profile_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _idNumberCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _locationCtrl;
  XFile? _pickedImage;
  bool _saving = false;

  static const Color _primary = Color(0xFF3A80C2);
  static const Color _bg = Color(0xFFF0F4F4);
  static const Color _inputFill = Color(0xFFEEF3F3);
  static const Color _textDark = Color(0xFF1A1A2E);
  static const Color _textMuted = Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    final user = _getUser();
    _firstNameCtrl = TextEditingController(text: user.firstName);
    _lastNameCtrl = TextEditingController(text: user.lastName);
    _idNumberCtrl = TextEditingController(text: user.idNumber);
    _phoneCtrl = TextEditingController(text: user.phone);
    _addressCtrl = TextEditingController(text: user.address ?? '');
    _locationCtrl = TextEditingController(text: user.location ?? '');
  }

  User _getUser() {
    final state = context.read<ProfileCubit>().state;
    if (state is ProfileLoaded) return state.user;
    throw StateError('Profile not loaded');
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _idNumberCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (image != null) setState(() => _pickedImage = image);
  }

  InputDecoration _decoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _textMuted, fontSize: 14),
      prefixIcon: Icon(icon, color: _textMuted, size: 20),
      filled: true,
      fillColor: _inputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final state = context.read<ProfileCubit>().state;
      if (state is! ProfileLoaded) return;

      String? photoUrl = state.user.photoUrl;
      if (_pickedImage != null) {
        photoUrl = await sl<UploadRepository>().uploadImage(_pickedImage!.path);
      }

      await sl<UserRepository>().update(
        id: state.user.id,
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        idNumber: _idNumberCtrl.text.trim(),
        idType: state.user.idType,
        phone: _phoneCtrl.text.trim(),
        phoneExtra: null,
        address: _addressCtrl.text.trim().isEmpty
            ? null
            : _addressCtrl.text.trim(),
        location: _locationCtrl.text.trim().isEmpty
            ? null
            : _locationCtrl.text.trim(),
        photoUrl: photoUrl,
      );

      if (!mounted) return;
      await context.read<ProfileCubit>().load();

      if (!mounted) return;
      BaltoToast.success(context, 'Profile updated successfully.');
      Navigator.of(context).pop();
    } on UploadFailure catch (e) {
      if (!mounted) return;
      BaltoToast.error(context, 'Photo upload failed: ${e.message}');
    } catch (e) {
      if (!mounted) return;
      BaltoToast.error(context, 'Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<ProfileCubit>().state;
    if (state is! ProfileLoaded) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentPhotoUrl = state.user.photoUrl;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.white,
        foregroundColor: _textDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Edit Your Profile',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _textDark,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(child: _AvatarPicker(
                  pickedImage: _pickedImage,
                  photoUrl: currentPhotoUrl,
                  onTap: _pickImage,
                  primary: _primary,
                )),
                const SizedBox(height: 28),
                _fieldLabel('First Name'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _firstNameCtrl,
                  style: const TextStyle(fontSize: 14, color: _textDark),
                  decoration: _decoration(
                    hint: 'First name',
                    icon: Icons.person_outline,
                  ),
                  validator: (v) =>
                      v?.trim().isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: 20),
                _fieldLabel('Last Name'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _lastNameCtrl,
                  style: const TextStyle(fontSize: 14, color: _textDark),
                  decoration: _decoration(
                    hint: 'Last name',
                    icon: Icons.person_outline,
                  ),
                  validator: (v) =>
                      v?.trim().isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: 20),
                _fieldLabel('ID Number'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _idNumberCtrl,
                  style: const TextStyle(fontSize: 14, color: _textDark),
                  decoration: _decoration(
                    hint: 'ID number',
                    icon: Icons.badge_outlined,
                  ),
                  validator: (v) =>
                      v?.trim().isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: 20),
                _fieldLabel('Phone'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontSize: 14, color: _textDark),
                  decoration: _decoration(
                    hint: 'Phone number',
                    icon: Icons.phone_outlined,
                  ),
                  validator: (v) =>
                      v?.trim().isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: 20),
                _fieldLabel('Address'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _addressCtrl,
                  style: const TextStyle(fontSize: 14, color: _textDark),
                  decoration: _decoration(
                    hint: 'Your address',
                    icon: Icons.place_outlined,
                  ),
                ),
                const SizedBox(height: 20),
                _fieldLabel('Location'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _locationCtrl,
                  style: const TextStyle(fontSize: 14, color: _textDark),
                  decoration: _decoration(
                    hint: 'City / Region',
                    icon: Icons.location_on_outlined,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _textDark,
      ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({
    required this.pickedImage,
    required this.photoUrl,
    required this.onTap,
    required this.primary,
  });

  final XFile? pickedImage;
  final String? photoUrl;
  final VoidCallback onTap;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    ImageProvider? bg;
    if (pickedImage != null) {
      bg = FileImage(File(pickedImage!.path));
    } else if (photoUrl != null) {
      bg = NetworkImage(photoUrl!);
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: const Color(0xFFEEF3F3),
            backgroundImage: bg,
            child: bg == null
                ? const Icon(Icons.person, size: 48, color: Color(0xFF6B7280))
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
