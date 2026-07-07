import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/di/injection.dart';
import '../../../core/widgets/balto_toast.dart';
import '../../../domain/entities/home_provider_certification.dart';
import '../../../domain/entities/home_provider_document.dart';
import '../../../domain/entities/home_provider_gallery_photo.dart';
import '../../../domain/entities/home_provider_specialty.dart';
import '../../../domain/repositories/home_provider_assets_repository.dart';
import '../../../domain/repositories/home_service_profile_repository.dart';
import '../../../domain/repositories/upload_repository.dart';

class HomeProviderGalleryDocumentsScreen extends StatefulWidget {
  const HomeProviderGalleryDocumentsScreen({super.key});

  @override
  State<HomeProviderGalleryDocumentsScreen> createState() =>
      _HomeProviderGalleryDocumentsScreenState();
}

class _HomeProviderGalleryDocumentsScreenState
    extends State<HomeProviderGalleryDocumentsScreen>
    with SingleTickerProviderStateMixin {
  static const Color _accent = AppColors.homeServices;
  static const Color _textDark = Color(0xFF1F2937);
  static const Color _textMuted = Color(0xFF8A93A0);

  late final TabController _tabController;
  final _picker = ImagePicker();

  String? _providerId;
  bool _loading = true;

  List<HomeProviderGalleryPhoto> _gallery = [];
  List<HomeProviderDocument> _documents = [];
  List<HomeProviderCertification> _certifications = [];
  List<HomeProviderSpecialty> _specialties = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _init();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      final profile = await sl<HomeServiceProfileRepository>().getMyProfile();
      if (profile == null) {
        if (!mounted) return;
        BaltoToast.warning(context, 'Provider profile not found.');
        Navigator.of(context).pop();
        return;
      }
      _providerId = profile.id;
      await _reloadAll();
    } catch (_) {
      if (!mounted) return;
      BaltoToast.error(context, 'Failed to load provider profile.');
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _reloadAll() async {
    if (_providerId == null) return;
    final assets = sl<HomeProviderAssetsRepository>();
    final results = await Future.wait([
      assets.getGallery(_providerId!),
      assets.getDocuments(_providerId!),
      assets.getCertifications(_providerId!),
      assets.getSpecialties(_providerId!),
    ]);
    if (!mounted) return;
    setState(() {
      _gallery = results[0] as List<HomeProviderGalleryPhoto>;
      _documents = results[1] as List<HomeProviderDocument>;
      _certifications = results[2] as List<HomeProviderCertification>;
      _specialties = results[3] as List<HomeProviderSpecialty>;
    });
  }

  Future<void> _addPhoto() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) return;
    try {
      final url = await sl<UploadRepository>().uploadImage(image.path);
      await sl<HomeProviderAssetsRepository>().addMyPhoto(url);
      await _reloadAll();
    } catch (_) {
      if (!mounted) return;
      BaltoToast.error(context, 'Failed to upload photo.');
    }
  }

  Future<void> _addDocument() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) return;
    try {
      final url = await sl<UploadRepository>().uploadImage(image.path);
      await sl<HomeProviderAssetsRepository>().addMyDocument(
        documentType: 'general',
        fileUrl: url,
      );
      await _reloadAll();
    } catch (_) {
      if (!mounted) return;
      BaltoToast.error(context, 'Failed to upload document.');
    }
  }

  Future<void> _addCertification() async {
    final titleCtrl = TextEditingController();
    final orgCtrl = TextEditingController();
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.r24),
        ),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Certification',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                hintText: 'Title (e.g. Veterinary License)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: orgCtrl,
              decoration: const InputDecoration(
                hintText: 'Issuing organization (optional)',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.radius12,
                  ),
                ),
                onPressed: () => Navigator.of(sheetContext).pop(true),
                child: const Text('Add'),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && titleCtrl.text.trim().isNotEmpty) {
      try {
        await sl<HomeProviderAssetsRepository>().addMyCertification(
          title: titleCtrl.text.trim(),
          issuingOrganization: orgCtrl.text.trim().isEmpty
              ? null
              : orgCtrl.text.trim(),
        );
        await _reloadAll();
      } catch (_) {
        if (!mounted) return;
        BaltoToast.error(context, 'Failed to add certification.');
      }
    }
  }

  Future<void> _addSpecialty() async {
    final ctrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Specialty'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'e.g. large_breed_dogs'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (confirmed == true && ctrl.text.trim().isNotEmpty) {
      try {
        await sl<HomeProviderAssetsRepository>().addMySpecialty(
          ctrl.text.trim(),
        );
        await _reloadAll();
      } catch (_) {
        if (!mounted) return;
        BaltoToast.error(context, 'Failed to add specialty.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
          'Gallery & Documents',
          style: AppTextStyles.h3.copyWith(color: _textDark),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: _accent,
          unselectedLabelColor: _textMuted,
          indicatorColor: _accent,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          tabs: const [
            Tab(text: 'Gallery'),
            Tab(text: 'Documents'),
            Tab(text: 'Certs'),
            Tab(text: 'Specialties'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildGalleryTab(),
                _buildDocumentsTab(),
                _buildCertificationsTab(),
                _buildSpecialtiesTab(),
              ],
            ),
    );
  }

  Widget _buildGalleryTab() {
    return Stack(
      children: [
        _gallery.isEmpty
            ? _emptyState(Icons.photo_library_outlined, 'No photos yet')
            : GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _gallery.length,
                itemBuilder: (_, i) {
                  final photo = _gallery[i];
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: AppRadius.radius14,
                        child: Image.network(
                          photo.photoUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (_, _, _) =>
                              Container(color: const Color(0xFFE8F5EE)),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () async {
                            await sl<HomeProviderAssetsRepository>()
                                .deleteMyPhoto(photo.id);
                            await _reloadAll();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            heroTag: 'add_photo',
            backgroundColor: _accent,
            foregroundColor: Colors.white,
            onPressed: _addPhoto,
            child: const Icon(Icons.add_a_photo_rounded),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsTab() {
    return Stack(
      children: [
        _documents.isEmpty
            ? _emptyState(Icons.description_outlined, 'No documents yet')
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
                itemCount: _documents.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final doc = _documents[i];
                  return _listRow(
                    icon: Icons.description_rounded,
                    title: doc.documentType,
                    onDelete: () async {
                      await sl<HomeProviderAssetsRepository>().deleteMyDocument(
                        doc.id,
                      );
                      await _reloadAll();
                    },
                  );
                },
              ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            heroTag: 'add_document',
            backgroundColor: _accent,
            foregroundColor: Colors.white,
            onPressed: _addDocument,
            child: const Icon(Icons.upload_file_rounded),
          ),
        ),
      ],
    );
  }

  Widget _buildCertificationsTab() {
    return Stack(
      children: [
        _certifications.isEmpty
            ? _emptyState(
                Icons.workspace_premium_outlined,
                'No certifications yet',
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
                itemCount: _certifications.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final cert = _certifications[i];
                  return _listRow(
                    icon: Icons.workspace_premium_rounded,
                    title: cert.title,
                    subtitle: cert.issuingOrganization,
                    onDelete: () async {
                      await sl<HomeProviderAssetsRepository>()
                          .deleteMyCertification(cert.id);
                      await _reloadAll();
                    },
                  );
                },
              ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            heroTag: 'add_cert',
            backgroundColor: _accent,
            foregroundColor: Colors.white,
            onPressed: _addCertification,
            child: const Icon(Icons.add_rounded),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialtiesTab() {
    return Stack(
      children: [
        _specialties.isEmpty
            ? _emptyState(Icons.label_outline_rounded, 'No specialties yet')
            : Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _specialties
                      .map(
                        (s) => Chip(
                          label: Text(s.specialty),
                          backgroundColor: _accent.withValues(alpha: 0.10),
                          labelStyle: const TextStyle(
                            color: _accent,
                            fontWeight: FontWeight.w600,
                          ),
                          deleteIcon: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: _accent,
                          ),
                          onDeleted: () async {
                            await sl<HomeProviderAssetsRepository>()
                                .deleteMySpecialty(s.id);
                            await _reloadAll();
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            heroTag: 'add_specialty',
            backgroundColor: _accent,
            foregroundColor: Colors.white,
            onPressed: _addSpecialty,
            child: const Icon(Icons.add_rounded),
          ),
        ),
      ],
    );
  }

  Widget _emptyState(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: const Color(0xFFB0B8C1)),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: _textMuted)),
        ],
      ),
    );
  }

  Widget _listRow({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onDelete,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radius14,
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
            child: Icon(icon, size: 18, color: _accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyBold.copyWith(color: _textDark),
                ),
                if (subtitle != null && subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: _textMuted),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF0ED),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 14,
                color: Color(0xFFD05A24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
