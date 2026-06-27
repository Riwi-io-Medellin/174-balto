import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/balto_toast.dart';
import '../../../domain/entities/walker.dart';

class EditWalkerProfileScreen extends StatefulWidget {
  const EditWalkerProfileScreen({super.key, this.walker});

  final Walker? walker;

  @override
  State<EditWalkerProfileScreen> createState() =>
      _EditWalkerProfileScreenState();
}

class _EditWalkerProfileScreenState extends State<EditWalkerProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _yearsCtrl;
  late final TextEditingController _areaCtrl;

  late List<String> _specialties;
  late List<String> _galleryImages;

  @override
  void initState() {
    super.initState();
    final w = widget.walker;
    _nameCtrl = TextEditingController(text: w?.name ?? '');
    _bioCtrl = TextEditingController(
      text: w?.biography ?? w?.description ?? '',
    );
    _priceCtrl = TextEditingController(
      text: w?.pricePerWalk != null
          ? w!.pricePerWalk!.toStringAsFixed(0)
          : '',
    );
    _yearsCtrl = TextEditingController(
      text: (w != null && w.yearsOfExperience > 0)
          ? w.yearsOfExperience.toString()
          : '',
    );
    _areaCtrl = TextEditingController(text: w?.serviceArea ?? '');
    _specialties = List.from(w?.specialties ?? []);
    _galleryImages = List.from(w?.galleryImages ?? []);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _priceCtrl.dispose();
    _yearsCtrl.dispose();
    _areaCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    // Backend not yet connected — screen ready to wire up.
    BaltoToast.info(context, 'Changes saved locally (backend not connected yet).');
  }

  void _removeSpecialty(String s) => setState(() => _specialties.remove(s));

  void _addSpecialty() {
    final ctrl = TextEditingController();
    showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Specialty'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'e.g. Large Dogs',
            filled: true,
            fillColor: const Color(0xFFF5F6FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navWalkers,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    ).then((value) {
      if (!mounted) return;
      if (value != null && value.isNotEmpty) {
        setState(() => _specialties.add(value));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Color(0xFF1F2937),
          ),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              'Save',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.navWalkers,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Form(
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
              _buildBasicInfoFields(),
              const SizedBox(height: 28),
              _buildSectionTitle('Services & Pricing'),
              const SizedBox(height: 14),
              _buildServicesFields(),
              const SizedBox(height: 28),
              _buildSpecialtiesSection(),
              const SizedBox(height: 28),
              _buildGallerySection(),
              const SizedBox(height: 36),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Avatar ───────────────────────────────────────────────────────────────

  Widget _buildAvatarSection() {
    final avatarUrl = widget.walker?.avatarUrl ?? widget.walker?.imageUrl;
    return Column(
      children: [
        Center(
          child: Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: ClipOval(
                  child: avatarUrl != null
                      ? Image.network(
                          avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _avatarFallback(),
                        )
                      : _avatarFallback(),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE0E4EC),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      size: 14,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Tap to change profile picture',
          style: TextStyle(fontSize: 13, color: Color(0xFF8A93A0)),
        ),
      ],
    );
  }

  Widget _avatarFallback() {
    return Container(
      width: 100,
      height: 100,
      color: const Color(0xFFE8F5EE),
      child: const Icon(
        Icons.person_rounded,
        size: 48,
        color: Color(0xFFB0B8C1),
      ),
    );
  }

  // ─── Section title ────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1F2937),
      ),
    );
  }

  // ─── Basic Info ───────────────────────────────────────────────────────────

  Widget _buildBasicInfoFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Full Name'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameCtrl,
          decoration: _inputDecoration(hint: 'Sarah Jenkins'),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Name is required.' : null,
        ),
        const SizedBox(height: 16),
        _fieldLabel('Biography'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _bioCtrl,
          minLines: 4,
          maxLines: 6,
          decoration: _inputDecoration(
            hint:
                'Experienced dog walker with a passion for large breeds. I believe every dog deserves a safe, fun walk...',
          ),
        ),
      ],
    );
  }

  // ─── Services & Pricing ───────────────────────────────────────────────────

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
        _fieldLabel('Service Area'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _areaCtrl,
          decoration:
              _inputDecoration(hint: 'Downtown, Westside, North Hills'),
        ),
      ],
    );
  }

  // ─── Specialties ──────────────────────────────────────────────────────────

  Widget _buildSpecialtiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildSectionTitle('Specialties'),
            const Spacer(),
            TextButton.icon(
              onPressed: _addSpecialty,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.navWalkers,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_specialties.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'No specialties added yet.',
              style: TextStyle(fontSize: 13, color: Color(0xFF8A93A0)),
            ),
          )
        else
          ..._specialties.map(
            (s) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E4EC)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.pets_rounded,
                    size: 16,
                    color: AppColors.navWalkers,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      s,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _removeSpecialty(s),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Color(0xFF8A93A0),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ─── Gallery ──────────────────────────────────────────────────────────────

  Widget _buildGallerySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Photo Gallery'),
        const SizedBox(height: 14),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ..._galleryImages.map(
                (url) => Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(right: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: const Color(0xFFF0F2F5),
                        child: const Icon(
                          Icons.image_outlined,
                          color: Color(0xFFB0B8C1),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F2F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFDDE1EA),
                      width: 1.5,
                    ),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 28,
                        color: Color(0xFF8A93A0),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Add Photo',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF8A93A0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Save Button ──────────────────────────────────────────────────────────

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navProfile.withValues(alpha: 0.25),
          foregroundColor: const Color(0xFF1F2937),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
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
        color: Color(0xFF5A6473),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFB0B8C1), fontSize: 14),
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
        borderSide: BorderSide(color: AppColors.navWalkers, width: 1.5),
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
