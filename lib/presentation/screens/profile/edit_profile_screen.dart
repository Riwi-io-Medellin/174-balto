import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/di/injection.dart';
import '../../../core/widgets/balto_toast.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/upload_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../bloc/profile/profile_cubit.dart';
import '../../bloc/profile/profile_state.dart';

// Antioquia municipalities with approximate lat/lng for GPS city detection
const _antioquiaCities = <String, (double, double)>{
  'Medellín':          (6.2442,  -75.5812),
  'Bello':             (6.3367,  -75.5553),
  'Itagüí':           (6.1849,  -75.5990),
  'Envigado':          (6.1738,  -75.5905),
  'Sabaneta':          (6.1508,  -75.6172),
  'La Estrella':       (6.1567,  -75.6439),
  'Caldas':            (6.0941,  -75.6373),
  'Copacabana':        (6.3499,  -75.5055),
  'Girardota':         (6.3779,  -75.4467),
  'Barbosa':           (6.4364,  -75.3309),
  'Rionegro':          (6.1543,  -75.3740),
  'Marinilla':         (6.1762,  -75.3312),
  'El Carmen de Viboral': (6.0879, -75.3418),
  'Guarne':            (6.2789,  -75.4421),
  'La Ceja':           (6.0299,  -75.4380),
  'La Unión':          (5.9759,  -75.3646),
  'El Retiro':         (6.0606,  -75.5085),
  'El Santuario':      (6.1363,  -75.2715),
  'El Peñol':          (6.2124,  -75.2364),
  'Guatapé':           (6.2327,  -75.1582),
  'Apartadó':          (7.8822,  -76.6283),
  'Turbo':             (8.0977,  -76.7325),
  'Carepa':            (7.7591,  -76.6565),
  'Chigorodó':         (7.6710,  -76.6826),
  'Necoclí':           (8.4224,  -76.7863),
  'Arboletes':         (8.8510,  -76.4270),
  'San Juan de Urabá': (8.7602,  -76.5300),
  'Caucasia':          (7.9893,  -75.1966),
  'El Bagre':          (7.5905,  -74.8098),
  'Nechí':             (8.0965,  -74.7729),
  'Zaragoza':          (7.4905,  -74.8700),
  'Yarumal':           (7.0009,  -75.4167),
  'Santa Rosa de Osos': (6.6462, -75.4639),
  'Don Matías':        (6.4981,  -75.4228),
  'Entrerríos':        (6.5547,  -75.4699),
  'San Pedro de los Milagros': (6.4773, -75.5755),
  'Angostura':         (6.8974,  -75.3485),
  'Valdivia':          (7.1874,  -75.4484),
  'Ituango':           (7.1670,  -75.7635),
  'Tarazá':            (7.5765,  -75.4030),
  'Santa Fe de Antioquia': (6.5544, -75.8290),
  'Sopetrán':          (6.5015,  -75.7468),
  'San Jerónimo':      (6.4757,  -75.7204),
  'Andes':             (5.6573,  -75.8797),
  'Jardín':            (5.5990,  -75.8202),
  'Jericó':            (5.7898,  -75.7880),
  'Ciudad Bolívar':    (5.8563,  -76.0177),
  'Urrao':             (6.3229,  -76.1323),
  'Puerto Berrío':     (6.4893,  -74.4028),
  'Puerto Triunfo':    (5.8724,  -74.5742),
  'Sonsón':            (5.7124,  -75.2981),
  'Amalfi':            (6.9157,  -75.0742),
  'Segovia':           (7.0783,  -74.7040),
  'Remedios':          (7.0259,  -74.6932),
  'Yolombó':           (6.5988,  -75.0165),
  'Maceo':             (6.5472,  -74.7777),
};

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
  String? _selectedCity;
  XFile? _pickedImage;
  bool _saving = false;
  bool _detectingCity = false;

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
    _selectedCity = _antioquiaCities.containsKey(user.location)
        ? user.location
        : null;
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

  Future<void> _detectCity() async {
    setState(() => _detectingCity = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          BaltoToast.error(context, 'Location permission is required to detect your city.');
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      );

      final nearest = _findNearestCity(position.latitude, position.longitude);
      if (mounted) setState(() => _selectedCity = nearest);
    } catch (e) {
      if (mounted) {
        BaltoToast.error(context, 'Could not detect location. Please select your city manually.');
      }
    } finally {
      if (mounted) setState(() => _detectingCity = false);
    }
  }

  String _findNearestCity(double lat, double lng) {
    String nearest = _antioquiaCities.keys.first;
    double minDist = double.infinity;
    for (final entry in _antioquiaCities.entries) {
      final (cityLat, cityLng) = entry.value;
      final dist = _squareDist(lat, lng, cityLat, cityLng);
      if (dist < minDist) {
        minDist = dist;
        nearest = entry.key;
      }
    }
    return nearest;
  }

  double _squareDist(double lat1, double lng1, double lat2, double lng2) {
    final dLat = lat1 - lat2;
    final dLng = (lng1 - lng2) * cos((lat1 + lat2) / 2 * pi / 180);
    return dLat * dLat + dLng * dLng;
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
        borderRadius: AppRadius.radius12,
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
    );
  }

  InputDecoration _dropdownDecoration({
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
        borderRadius: AppRadius.radius12,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.radius12,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.radius12,
        borderSide: BorderSide(color: AppColors.navWalks, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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

      final cityCoords = _selectedCity != null
          ? _antioquiaCities[_selectedCity!]
          : null;
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
        location: _selectedCity,
        photoUrl: photoUrl,
        latitude: cityCoords?.$1,
        longitude: cityCoords?.$2,
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
              borderRadius: AppRadius.radius20,
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
                Center(
                  child: Text(
                    'Edit Your Profile',
                    style: AppTextStyles.h1.copyWith(color: _textDark),
                  ),
                ),
                const SizedBox(height: 24),
                Center(child: _AvatarPicker(
                  pickedImage: _pickedImage,
                  photoUrl: currentPhotoUrl,
                  onTap: _pickImage,
                  primary: AppColors.navWalks,
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
                // ── Pickup Location Banner ─────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF5FF),
                    borderRadius: AppRadius.radius12,
                    border: Border.all(color: AppColors.navWalks.withValues(alpha: 0.25)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.directions_walk, size: 16, color: Color(0xFF3A80C2)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your address and city are shown to the walker as your dog\'s pickup location.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF3A80C2)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _fieldLabel('Street Address'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _addressCtrl,
                  style: const TextStyle(fontSize: 14, color: _textDark),
                  decoration: _decoration(
                    hint: 'e.g. Calle 10 #5-23, El Poblado',
                    icon: Icons.place_outlined,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _fieldLabel('City (Antioquia)')),
                    GestureDetector(
                      onTap: _detectingCity ? null : _detectCity,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.navWalks.withValues(alpha: 0.10),
                          borderRadius: AppRadius.radius8,
                        ),
                        child: _detectingCity
                            ? SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.navWalks),
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.my_location, size: 13, color: AppColors.navWalks),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Detect',
                                    style: AppTextStyles.captionStrong.copyWith(
                                      color: AppColors.navWalks,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCity,
                  isExpanded: true,
                  decoration: _dropdownDecoration(
                    hint: 'Select your city',
                    icon: Icons.location_on_outlined,
                  ),
                  style: const TextStyle(fontSize: 14, color: _textDark),
                  dropdownColor: Colors.white,
                  borderRadius: AppRadius.radius12,
                  items: _antioquiaCities.keys
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedCity = value),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navWalks,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.radius14,
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
