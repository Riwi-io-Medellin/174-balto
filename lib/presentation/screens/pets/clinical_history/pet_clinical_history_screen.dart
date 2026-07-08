import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/vet_document_validators.dart';
import '../../../../core/widgets/balto_toast.dart';
import '../../../../domain/entities/pet.dart';
import '../../../../domain/entities/pet_clinical_draft.dart';
import '../../../../domain/entities/pet_clinical_record.dart';
import '../../../../domain/entities/pet_health_context.dart';
import '../../../../domain/entities/vet_document_analysis.dart';
import '../../../../domain/repositories/pet_clinical_repository.dart';
import '../../../../domain/repositories/upload_repository.dart';
import '../../../../domain/repositories/vet_document_analysis_repository.dart';
import 'widgets/clinical_event_form_screen.dart';
import 'widgets/clinical_timeline.dart';
import 'widgets/clinical_tips_section.dart';

/// Clinical History module within the pet's profile.
/// Flow: upload documents -> AI extracts a structured draft and produces an
/// advisory health read -> editable form (with the AI insight shown inline)
/// -> save -> timeline + tips.
class PetClinicalHistoryScreen extends StatefulWidget {
  const PetClinicalHistoryScreen({super.key, required this.pet});

  final Pet pet;

  @override
  State<PetClinicalHistoryScreen> createState() =>
      _PetClinicalHistoryScreenState();
}

class _PetClinicalHistoryScreenState extends State<PetClinicalHistoryScreen> {
  static const _accent = AppColors.petProfile;
  static const _bg = Color(0xFFF0F4F4);
  static const _textDark = Color(0xFF1A1A2E);
  static const _textMuted = Color(0xFF6B7280);

  bool _loading = true;
  bool _processing = false;
  String _processingMessage = 'Analyzing document...';
  PetClinicalRecord? _record;
  List<PetClinicalTip> _tips = [];
  Timer? _processingTimer;
  final List<PickedFileInfo> _pickedFiles = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _processingTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        sl<PetClinicalRepository>().getRecord(widget.pet.id),
        sl<PetClinicalRepository>().getTips(widget.pet.id),
      ]);
      if (!mounted) return;
      final record = results[0] as PetClinicalRecord;
      // Sort once here instead of on every ClinicalTimeline build.
      record.events.sort((a, b) => b.eventDate.compareTo(a.eventDate));
      setState(() {
        _record = record;
        _tips = results[1] as List<PetClinicalTip>;
      });
    } catch (_) {
      if (!mounted) return;
      BaltoToast.error(context, 'Could not load the clinical history.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _startProcessingMessages() {
    const messages = [
      'Analyzing document...',
      'Extracting information...',
      'Generating form...',
    ];
    var i = 0;
    setState(() {
      _processing = true;
      _processingMessage = messages.first;
    });
    _processingTimer?.cancel();
    _processingTimer = Timer.periodic(const Duration(milliseconds: 1400), (_) {
      i = (i + 1) % messages.length;
      if (mounted) setState(() => _processingMessage = messages[i]);
    });
  }

  void _stopProcessingMessages() {
    _processingTimer?.cancel();
    if (mounted) setState(() => _processing = false);
  }

  /// Best-effort advisory read of the uploaded documents — never blocks or
  /// fails the structured extraction/save flow.
  Future<VetDocumentAnalysisResult?> _tryAnalyze(
    PetHealthContext context,
    List<String> fileUrls,
  ) async {
    if (!validatePetContext(context).isValid) return null;
    try {
      return await sl<VetDocumentAnalysisRepository>().analyze(
        context: context,
        fileUrls: fileUrls,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image;
    try {
      image = await ImagePicker().pickImage(source: source, imageQuality: 85);
    } catch (_) {
      if (!mounted) return;
      BaltoToast.error(context, 'Could not open the camera/gallery.');
      return;
    }
    if (image == null || !mounted) return;
    final size = await File(image.path).length();
    if (!mounted) return;
    setState(() {
      _pickedFiles.add(
        PickedFileInfo(path: image!.path, name: image.name, sizeBytes: size),
      );
    });
  }

  Future<void> _pickPdf() async {
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
    } catch (_) {
      if (!mounted) return;
      BaltoToast.error(context, 'Could not open the file picker.');
      return;
    }
    final file = result?.files.firstOrNull;
    if (file == null || file.path == null || !mounted) return;
    setState(() {
      _pickedFiles.add(
        PickedFileInfo(
          path: file.path!,
          name: file.name,
          sizeBytes: file.size,
        ),
      );
    });
  }

  void _removeFile(int index) => setState(() => _pickedFiles.removeAt(index));

  void _showFileSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.r20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: AppRadius.radius2,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_rounded),
              title: const Text('Choose a PDF'),
              onTap: () {
                Navigator.pop(ctx);
                _pickPdf();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _analyzeDocuments() async {
    final filesValidation = validateFiles(_pickedFiles);
    if (!filesValidation.isValid) {
      BaltoToast.warning(context, filesValidation.error!);
      return;
    }
    final pickedFiles = List<PickedFileInfo>.from(_pickedFiles);

    _startProcessingMessages();
    try {
      final documentIds = <String>[];
      final fileUrls = <String>[];
      for (final file in pickedFiles) {
        final url = await sl<UploadRepository>().uploadFile(
          file.path,
          file.name,
        );
        fileUrls.add(url);
        final documentId = await sl<PetClinicalRepository>()
            .registerSourceDocument(
              petId: widget.pet.id,
              fileUrl: url,
              fileName: file.name,
              fileType: file.extension,
            );
        documentIds.add(documentId);
      }

      if (documentIds.isEmpty) {
        _stopProcessingMessages();
        if (!mounted) return;
        BaltoToast.warning(context, 'Could not upload any file.');
        return;
      }

      final petContext = PetHealthContext(
        petId: widget.pet.id,
        name: widget.pet.name,
        species: widget.pet.species ?? '',
        breed: widget.pet.breed,
        age: widget.pet.birthDate != null
            ? DateTime.now().year - widget.pet.birthDate!.year
            : null,
        sex: widget.pet.sex,
        weightKg: widget.pet.weight,
      );

      final results = await Future.wait([
        sl<PetClinicalRepository>().runExtraction(
          petId: widget.pet.id,
          documentIds: documentIds,
        ),
        _tryAnalyze(petContext, fileUrls),
      ]);
      final draft = results[0] as ClinicalExtractionDraft;
      final analysis = results[1] as VetDocumentAnalysisResult?;
      _stopProcessingMessages();
      if (!mounted) return;

      final saved = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => ClinicalEventFormScreen(
            pet: widget.pet,
            draft: draft,
            analysis: analysis,
          ),
        ),
      );
      if (saved == true) {
        setState(() => _pickedFiles.clear());
        await _load();
      }
    } on PetClinicalFailure catch (e) {
      _stopProcessingMessages();
      if (!mounted) return;
      BaltoToast.error(context, e.message);
    } catch (e) {
      _stopProcessingMessages();
      if (!mounted) return;
      BaltoToast.error(context, 'Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Clinical History'),
        backgroundColor: Colors.white,
        foregroundColor: _textDark,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _accent))
          : Stack(
              children: [
                RefreshIndicator(
                  color: _accent,
                  onRefresh: _load,
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _uploadCard(),
                            const SizedBox(height: 24),
                            if (_tips.isNotEmpty) ...[
                              _sectionTitle('AI-generated tips'),
                              const SizedBox(height: 10),
                              ClinicalTipsSection(tips: _tips),
                              const SizedBox(height: 24),
                            ],
                            _sectionTitle('Clinical history log'),
                            const SizedBox(height: 14),
                          ]),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        sliver: ClinicalTimeline(events: _record?.events ?? []),
                      ),
                    ],
                  ),
                ),
                if (_processing) _processingOverlay(),
              ],
            ),
    );
  }

  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w800,
      color: _textDark,
    ),
  );

  Widget _uploadCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radius18,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.upload_file_rounded,
                  size: 20,
                  color: _accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add medical documents',
                      style: AppTextStyles.bodyBold.copyWith(color: _textDark),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'PDF or images, several at once. AI extracts the data automatically.',
                      style: TextStyle(fontSize: 12, color: _textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_pickedFiles.isNotEmpty) ...[
            const SizedBox(height: 16),
            ..._pickedFiles.asMap().entries.map(
              (e) => _fileTile(e.key, e.value),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _processing ? null : _showFileSourceSheet,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Add photo or PDF',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _accent,
                side: const BorderSide(color: _accent),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.radius14),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _processing || _pickedFiles.isEmpty
                  ? null
                  : _analyzeDocuments,
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text(
                'Analyze Documents',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.radius14),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fileTile(int index, PickedFileInfo file) {
    final isPdf = file.extension == 'pdf';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: AppRadius.radius12,
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(
            isPdf ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
            color: _accent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              file.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: _textDark),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: _processing ? null : () => _removeFile(index),
          ),
        ],
      ),
    );
  }

  Widget _processingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.45),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.radius20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: _accent,
                ),
              ),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  _processingMessage,
                  key: ValueKey(_processingMessage),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
