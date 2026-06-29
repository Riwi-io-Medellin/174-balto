import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/di/injection.dart';
import '../../../core/widgets/balto_toast.dart';
import '../../../domain/entities/pet.dart';
import '../../../domain/repositories/pet_repository.dart';
import '../../../domain/repositories/upload_repository.dart';
import '../../bloc/profile/profile_cubit.dart';

class EditPetScreen extends StatefulWidget {
  const EditPetScreen({super.key, required this.pet});

  final Pet pet;

  @override
  State<EditPetScreen> createState() => _EditPetScreenState();
}

class _EditPetScreenState extends State<EditPetScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.pet.name);
  late final _speciesCtrl = TextEditingController(text: widget.pet.species ?? '');
  late final _breedCtrl = TextEditingController(text: widget.pet.breed ?? '');
  late final _weightCtrl = TextEditingController(
    text: widget.pet.weight != null ? widget.pet.weight!.toStringAsFixed(1) : '',
  );
  late final _descriptionCtrl = TextEditingController(text: widget.pet.description ?? '');
  final _picker = ImagePicker();

  DateTime? _birthDate;
  String? _existingPhotoUrl;
  XFile? _pickedImage;
  bool _saving = false;

  static const Color _primary = Color(0xFF3A80C2);
  static const Color _bg = Color(0xFFF0F4F4);
  static const Color _inputFill = Color(0xFFEEF3F3);
  static const Color _textDark = Color(0xFF1A1A2E);
  static const Color _textMuted = Color(0xFF6B7280);

  static const _speciesSuggestions = [
    'Dog', 'Cat', 'Bird', 'Rabbit', 'Fish',
    'Hamster', 'Turtle', 'Guinea Pig', 'Parrot', 'Snake',
  ];

  static const _breedSuggestions = <String, List<String>>{
    'Dog': ['Golden Retriever', 'Labrador', 'Bulldog', 'Poodle', 'German Shepherd', 'Beagle', 'Husky', 'Chihuahua', 'Rottweiler', 'Dachshund'],
    'Cat': ['Persian', 'Siamese', 'Maine Coon', 'British Shorthair', 'Bengal', 'Ragdoll', 'Abyssinian', 'Sphynx'],
    'Bird': ['Canary', 'Parakeet', 'Cockatiel', 'African Grey', 'Lovebird', 'Macaw'],
    'Rabbit': ['Holland Lop', 'Lionhead', 'Mini Rex', 'Dutch', 'Angora'],
    'Hamster': ['Syrian', 'Dwarf', 'Roborovski'],
    'Guinea Pig': ['American', 'Peruvian', 'Teddy', 'Silkie'],
  };

  @override
  void initState() {
    super.initState();
    _birthDate = widget.pet.birthDate;
    _existingPhotoUrl = widget.pet.photoUrl;
    _speciesCtrl.addListener(() => setState(() {}));
    _breedCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _speciesCtrl.dispose();
    _breedCtrl.dispose();
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now().subtract(const Duration(days: 365)),
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
      String? photoUrl = _existingPhotoUrl;
      if (_pickedImage != null) {
        photoUrl = await sl<UploadRepository>().uploadImage(_pickedImage!.path);
      }

      final weightText = _weightCtrl.text.trim();
      final weight = weightText.isNotEmpty ? double.tryParse(weightText) : null;

      await sl<PetRepository>().update(
        widget.pet.id,
        name: _nameCtrl.text.trim(),
        species: _speciesCtrl.text.trim().isEmpty ? null : _speciesCtrl.text.trim(),
        breed: _breedCtrl.text.trim().isEmpty ? null : _breedCtrl.text.trim(),
        birthDate: _birthDate,
        description: _descriptionCtrl.text.trim().isEmpty ? null : _descriptionCtrl.text.trim(),
        photoUrl: photoUrl,
        weight: weight,
      );

      await context.read<ProfileCubit>().load();

      if (!mounted) return;
      BaltoToast.success(context, 'Pet updated successfully.');
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
        title: Text('Edit ${widget.pet.name}'),
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
                const SizedBox(height: 4),
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
                _buildSuggestionField(
                  label: 'Species',
                  controller: _speciesCtrl,
                  hint: 'e.g. Dog, Cat or type your own',
                  icon: Icons.category_outlined,
                  suggestions: _speciesSuggestions,
                  onChipTap: (s) => setState(() {
                    _speciesCtrl.text = s;
                    _speciesCtrl.selection = TextSelection.fromPosition(
                      TextPosition(offset: s.length),
                    );
                    _breedCtrl.clear();
                  }),
                ),
                const SizedBox(height: 20),
                _buildSuggestionField(
                  label: 'Breed',
                  controller: _breedCtrl,
                  hint: 'e.g. Golden Retriever or type your own',
                  icon: Icons.style_outlined,
                  suggestions: _breedSuggestions[_speciesCtrl.text] ?? const [],
                  onChipTap: (s) => setState(() {
                    _breedCtrl.text = s;
                    _breedCtrl.selection = TextSelection.fromPosition(
                      TextPosition(offset: s.length),
                    );
                  }),
                ),
                const SizedBox(height: 20),
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
                            'Save Changes',
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

  Widget _buildSuggestionField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required List<String> suggestions,
    required void Function(String) onChipTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: const TextStyle(fontSize: 14, color: _textDark),
          decoration: _decoration(hint: hint, icon: icon),
        ),
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: suggestions.map((s) {
              final selected = controller.text == s;
              return GestureDetector(
                onTap: () => onChipTap(s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? _primary.withValues(alpha: 0.12) : _inputFill,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? _primary : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    s,
                    style: TextStyle(
                      fontSize: 12,
                      color: selected ? _primary : _textMuted,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildPhotoPicker() {
    final hasNewImage = _pickedImage != null;
    final hasExistingUrl = _existingPhotoUrl != null && _existingPhotoUrl!.isNotEmpty;

    return Column(
      children: [
        if (hasNewImage)
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
        else if (hasExistingUrl)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  _existingPhotoUrl!,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPhotoPlaceholder(),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: _overlayButton(Icons.edit),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => setState(() => _existingPhotoUrl = null),
                      child: _overlayButton(Icons.close),
                    ),
                  ],
                ),
              ),
            ],
          )
        else
          GestureDetector(
            onTap: _pickImage,
            child: _buildPhotoPlaceholder(),
          ),
      ],
    );
  }

  Widget _overlayButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 16, color: Colors.white),
    );
  }

  Widget _buildPhotoPlaceholder() {
    return Container(
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
