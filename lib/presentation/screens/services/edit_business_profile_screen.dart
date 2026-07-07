import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/widgets/balto_toast.dart';
import '../../../domain/entities/business.dart';
import '../../../domain/repositories/business_repository.dart';
import '../../../domain/repositories/upload_repository.dart';
import '../../bloc/profile/profile_cubit.dart';
import '../../bloc/profile/profile_state.dart';
import 'business_market_items_screen.dart';

class EditBusinessProfileScreen extends StatefulWidget {
  const EditBusinessProfileScreen({super.key});

  @override
  State<EditBusinessProfileScreen> createState() =>
      _EditBusinessProfileScreenState();
}

class _EditBusinessProfileScreenState extends State<EditBusinessProfileScreen> {
  late final TextEditingController _instagramCtrl;
  late final TextEditingController _facebookCtrl;
  late final TextEditingController _descriptionCtrl;
  final _picker = ImagePicker();

  String? _businessId;
  String? _photoUrl;
  bool _sellsServices = false;
  bool _sellsProducts = false;
  List<BusinessDocumentItem> _gallery = [];

  bool _saving = false;
  bool _uploadingPhoto = false;
  bool _uploadingGalleryPhoto = false;
  bool _initialized = false;

  static const Color _bg = Color(0xFFF5F6FA);
  static const Color _textDark = Color(0xFF1F2937);
  static const Color _textMuted = Color(0xFF8A93A0);
  static const Color _green = AppColors.navWalkers;

  @override
  void initState() {
    super.initState();
    _instagramCtrl = TextEditingController();
    _facebookCtrl = TextEditingController();
    _descriptionCtrl = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    try {
      final state = context.read<ProfileCubit>().state;
      if (state is! ProfileLoaded) return;
      final b = state.businessProfile;
      if (b == null || !b.isVerified) {
        if (!mounted) return;
        BaltoToast.warning(context, 'Business profile not available.');
        Navigator.of(context).pop();
        return;
      }
      _businessId = b.id;
      _instagramCtrl.text = b.instagramUrl ?? '';
      _facebookCtrl.text = b.facebookUrl ?? '';
      _descriptionCtrl.text = b.description ?? '';
      _photoUrl = b.photoUrl;
      _sellsServices = b.sellsServices;
      _sellsProducts = b.sellsProducts;

      final gallery = await sl<BusinessRepository>().getBusinessDocuments(
        b.id,
      );
      if (!mounted) return;
      setState(() {
        _gallery = gallery.where((d) => d.documentType == 'gallery').toList();
        _initialized = true;
      });
    } catch (_) {
      if (!mounted) return;
      BaltoToast.error(context, 'Failed to load profile.');
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _instagramCtrl.dispose();
    _facebookCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickMainPhoto() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) return;
    setState(() => _uploadingPhoto = true);
    try {
      final url = await sl<UploadRepository>().uploadImage(image.path);
      if (!mounted) return;
      setState(() => _photoUrl = url);
    } catch (_) {
      if (!mounted) return;
      BaltoToast.error(context, 'Failed to upload photo.');
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _addGalleryPhoto() async {
    if (_businessId == null) return;
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) return;
    setState(() => _uploadingGalleryPhoto = true);
    try {
      await sl<BusinessRepository>().addGalleryPhoto(
        businessId: _businessId!,
        imagePath: image.path,
      );
      final gallery = await sl<BusinessRepository>().getBusinessDocuments(
        _businessId!,
      );
      if (!mounted) return;
      setState(
        () => _gallery = gallery
            .where((d) => d.documentType == 'gallery')
            .toList(),
      );
    } catch (_) {
      if (!mounted) return;
      BaltoToast.error(context, 'Failed to upload photo.');
    } finally {
      if (mounted) setState(() => _uploadingGalleryPhoto = false);
    }
  }

  Future<void> _deleteGalleryPhoto(BusinessDocumentItem photo) async {
    if (_businessId == null) return;
    try {
      await sl<BusinessRepository>().deleteBusinessDocument(
        businessId: _businessId!,
        documentId: photo.id,
      );
      if (!mounted) return;
      setState(() => _gallery.removeWhere((d) => d.id == photo.id));
    } catch (_) {
      if (!mounted) return;
      BaltoToast.error(context, 'Failed to delete photo.');
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await sl<BusinessRepository>().updateMyBusiness(
        instagramUrl: _instagramCtrl.text.trim(),
        facebookUrl: _facebookCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        photoUrl: _photoUrl ?? '',
        sellsServices: _sellsServices,
        sellsProducts: _sellsProducts,
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
        title: const Text(
          'Edit Business',
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
          ? SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMainPhoto(),
                  const SizedBox(height: 32),
                  _sectionTitle('About'),
                  const SizedBox(height: 16),
                  _fieldLabel('Description'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionCtrl,
                    maxLines: 4,
                    maxLength: 500,
                    decoration: _inputDecoration(
                      hint: 'Tell customers about your business…',
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildGallerySection(),
                  const SizedBox(height: 28),
                  _sectionTitle('Market'),
                  const SizedBox(height: 4),
                  const Text(
                    'Turn these on to sell services and/or products from your profile.',
                    style: TextStyle(fontSize: 12, color: _textMuted),
                  ),
                  const SizedBox(height: 12),
                  _buildMarketToggle(
                    title: 'Sell services',
                    subtitle: 'e.g. grooming, consultations, boarding',
                    value: _sellsServices,
                    onChanged: (v) => setState(() => _sellsServices = v),
                  ),
                  const SizedBox(height: 10),
                  _buildMarketToggle(
                    title: 'Sell products',
                    subtitle: 'e.g. food, accessories, medication',
                    value: _sellsProducts,
                    onChanged: (v) => setState(() => _sellsProducts = v),
                  ),
                  if ((_sellsServices || _sellsProducts) &&
                      _businessId != null) ...[
                    const SizedBox(height: 14),
                    _buildManageMarketButton(),
                  ],
                  const SizedBox(height: 28),
                  _sectionTitle('Social Links'),
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

  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w800,
      color: _textDark,
    ),
  );

  Widget _buildMainPhoto() {
    return Column(
      children: [
        Center(
          child: GestureDetector(
            onTap: _uploadingPhoto ? null : _pickMainPhoto,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    width: 100,
                    height: 100,
                    color: _green.withValues(alpha: 0.12),
                    child: _photoUrl != null && _photoUrl!.isNotEmpty
                        ? Image.network(
                            _photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.storefront_rounded,
                              size: 48,
                              color: _green,
                            ),
                          )
                        : const Icon(
                            Icons.storefront_rounded,
                            size: 48,
                            color: _green,
                          ),
                  ),
                ),
                if (_uploadingPhoto)
                  const Positioned.fill(
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _green,
                      ),
                    ),
                  )
                else
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: _green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Tap to change your profile photo',
          style: TextStyle(fontSize: 13, color: _textMuted),
        ),
      ],
    );
  }

  Widget _buildGallerySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Gallery'),
        const SizedBox(height: 8),
        SizedBox(
          height: 88,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ..._gallery.map(
                (photo) => Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          photo.fileUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            width: 80,
                            height: 80,
                            color: const Color(0xFFE9ECF1),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _deleteGalleryPhoto(photo),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: _uploadingGalleryPhoto ? null : _addGalleryPhoto,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0E4EC)),
                  ),
                  child: _uploadingGalleryPhoto
                      ? const Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : const Icon(
                          Icons.add_a_photo_rounded,
                          color: _textMuted,
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMarketToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E4EC)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: _textMuted),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeThumbColor: _green),
        ],
      ),
    );
  }

  Widget _buildManageMarketButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  BusinessMarketItemsScreen(businessId: _businessId!),
            ),
          );
        },
        icon: const Icon(Icons.storefront_rounded, size: 18),
        label: const Text('Manage services & products'),
        style: OutlinedButton.styleFrom(
          foregroundColor: _green,
          side: const BorderSide(color: _green),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

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
}
