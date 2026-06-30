import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/di/injection.dart';
import '../../../core/widgets/balto_toast.dart';
import '../../../domain/repositories/pet_repository.dart';
import '../../../domain/repositories/upload_repository.dart';
import '../../bloc/profile/profile_cubit.dart';

class CreatePetScreen extends StatefulWidget {
  const CreatePetScreen({super.key});

  @override
  State<CreatePetScreen> createState() => _CreatePetScreenState();
}

class _CreatePetScreenState extends State<CreatePetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _picker = ImagePicker();
  DateTime? _birthDate;
  XFile? _pickedImage;
  bool _saving = false;
  String? _selectedSpecies;
  String? _selectedBreed;

  static const Color _primary = Color(0xFF3A80C2);
  static const Color _bg = Color(0xFFF0F4F4);
  static const Color _inputFill = Color(0xFFEEF3F3);
  static const Color _textDark = Color(0xFF1A1A2E);
  static const Color _textMuted = Color(0xFF6B7280);

  static const _speciesList = [
    'Dog', 'Cat', 'Rabbit', 'Hamster', 'Guinea Pig', 'Ferret',
    'Bird', 'Fish', 'Turtle', 'Snake', 'Chinchilla', 'Parrot',
  ];

  static const _breedOptions = <String, List<String>>{
    'Dog': [
      'Mixed-breed',
      'Labrador Retriever', 'Golden Retriever', 'French Bulldog', 'Bulldog',
      'Poodle', 'Beagle', 'Rottweiler', 'German Shepherd', 'Yorkshire Terrier',
      'Dachshund', 'Husky', 'Boxer', 'Chihuahua', 'Shih Tzu',
      'Doberman', 'Border Collie', 'Pomeranian', 'Maltese', 'Schnauzer',
      'Cocker Spaniel', 'Great Dane',
    ],
    'Cat': [
      'Mixed-breed',
      'Persian', 'Siamese', 'Maine Coon', 'Ragdoll', 'Bengal',
      'British Shorthair', 'Abyssinian', 'Sphynx', 'Russian Blue',
      'Scottish Fold', 'Birman', 'American Shorthair',
      'Norwegian Forest Cat', 'Burmese', 'Turkish Angora',
    ],
  };

  @override
  void dispose() {
    _nameCtrl.dispose();
    _weightCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  InputDecoration _decoration({required String hint, required IconData icon}) {
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

  InputDecoration _dropdownDecoration({required String hint, required IconData icon}) {
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
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
    );
    if (image != null) setState(() => _pickedImage = image);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      String? photoUrl;
      if (_pickedImage != null) {
        photoUrl = await sl<UploadRepository>().uploadImage(_pickedImage!.path);
      }

      final weightText = _weightCtrl.text.trim();
      final weight = weightText.isNotEmpty ? double.tryParse(weightText) : null;

      await sl<PetRepository>().create(
        name: _nameCtrl.text.trim(),
        species: _selectedSpecies,
        breed: _selectedBreed,
        birthDate: _birthDate,
        description: _descriptionCtrl.text.trim().isEmpty ? null : _descriptionCtrl.text.trim(),
        photoUrl: photoUrl,
        weight: weight,
      );

      await context.read<ProfileCubit>().load();

      if (!mounted) return;
      BaltoToast.success(context, 'Pet added successfully.');
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      BaltoToast.error(context, 'Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Add New Pet'),
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
                    'Register Your Pet',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _textDark,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildPhotoPicker(),
                const SizedBox(height: 20),
                _fieldLabel('Name'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameCtrl,
                  style: const TextStyle(fontSize: 14, color: _textDark),
                  decoration: _decoration(hint: 'Pet name', icon: Icons.pets),
                  validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: 20),
                _buildSpeciesDropdown(),
                const SizedBox(height: 20),
                if (_breedOptions.containsKey(_selectedSpecies)) ...[
                  _buildBreedDropdown(),
                  const SizedBox(height: 20),
                ],
                _fieldLabel('Birth Date'),
                const SizedBox(height: 8),
                TextFormField(
                  readOnly: true,
                  style: const TextStyle(fontSize: 14, color: _textDark),
                  decoration: _decoration(
                    hint: _birthDate != null
                        ? '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'
                        : 'Tap to select',
                    icon: Icons.calendar_today_outlined,
                  ).copyWith(
                    suffixIcon: _birthDate != null
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => setState(() => _birthDate = null),
                          )
                        : null,
                  ),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 20),
                _fieldLabel('Weight (kg)'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _weightCtrl,
                  style: const TextStyle(fontSize: 14, color: _textDark),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  decoration: _decoration(
                    hint: 'e.g. 12.5',
                    icon: Icons.monitor_weight_outlined,
                  ),
                ),
                const SizedBox(height: 20),
                _fieldLabel('Description'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionCtrl,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 14, color: _textDark),
                  decoration: _decoration(
                    hint: 'Any notes about your pet',
                    icon: Icons.notes_outlined,
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
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Add Pet',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

  Widget _buildSpeciesDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Species'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedSpecies,
          isExpanded: true,
          decoration: _dropdownDecoration(
            hint: 'Select species',
            icon: Icons.category_outlined,
          ),
          style: const TextStyle(fontSize: 14, color: _textDark),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          items: _speciesList
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (value) => setState(() {
            _selectedSpecies = value;
            _selectedBreed = null;
          }),
        ),
      ],
    );
  }

  Widget _buildBreedDropdown() {
    final breeds = _breedOptions[_selectedSpecies] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Breed'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedBreed,
          isExpanded: true,
          decoration: _dropdownDecoration(
            hint: 'Select breed',
            icon: Icons.style_outlined,
          ),
          style: const TextStyle(fontSize: 14, color: _textDark),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          items: breeds
              .map((b) => DropdownMenuItem(value: b, child: Text(b)))
              .toList(),
          onChanged: (value) => setState(() => _selectedBreed = value),
        ),
      ],
    );
  }

  Widget _buildPhotoPicker() {
    return Column(
      children: [
        if (_pickedImage != null)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(_pickedImage!.path),
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => setState(() => _pickedImage = null),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          )
        else
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: _inputFill,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _primary.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined, size: 32, color: _primary),
                  const SizedBox(height: 8),
                  Text(
                    'Add Photo',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
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
