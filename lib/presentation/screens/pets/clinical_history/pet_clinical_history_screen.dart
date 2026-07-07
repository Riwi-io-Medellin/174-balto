import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/balto_toast.dart';
import '../../../../domain/entities/pet.dart';
import '../../../../domain/entities/pet_clinical_record.dart';
import '../../../../domain/repositories/pet_clinical_repository.dart';
import '../../../../domain/repositories/upload_repository.dart';
import 'widgets/clinical_event_form_screen.dart';
import 'widgets/clinical_timeline.dart';
import 'widgets/clinical_tips_section.dart';

/// Clinical History module within the pet's profile.
/// Flow: upload documents -> AI analyzes -> editable form -> save
/// -> timeline + tips. The generated official document can be downloaded
/// from the Health Document Analysis screen.
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

  static const _allowedExtensions = [
    'jpg',
    'jpeg',
    'png',
    'webp',
    'gif',
    'pdf',
  ];

  bool _loading = true;
  bool _processing = false;
  String _processingMessage = 'Analyzing document...';
  PetClinicalRecord? _record;
  List<PetClinicalTip> _tips = [];
  Timer? _processingTimer;

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

  Future<void> _uploadDocuments() async {
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: _allowedExtensions,
      );
    } catch (_) {
      if (!mounted) return;
      BaltoToast.error(context, 'Could not open the file picker.');
      return;
    }
    if (result == null || result.files.isEmpty) return;

    _startProcessingMessages();
    try {
      final documentIds = <String>[];
      for (final file in result.files) {
        final path = file.path;
        if (path == null) continue;
        final extension = (file.extension ?? '').toLowerCase();
        final url = await sl<UploadRepository>().uploadFile(path, file.name);
        final documentId = await sl<PetClinicalRepository>()
            .registerSourceDocument(
              petId: widget.pet.id,
              fileUrl: url,
              fileName: file.name,
              fileType: extension,
            );
        documentIds.add(documentId);
      }

      if (documentIds.isEmpty) {
        _stopProcessingMessages();
        if (!mounted) return;
        BaltoToast.warning(context, 'Could not upload any file.');
        return;
      }

      final draft = await sl<PetClinicalRepository>().runExtraction(
        petId: widget.pet.id,
        documentIds: documentIds,
      );
      _stopProcessingMessages();
      if (!mounted) return;

      final saved = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) =>
              ClinicalEventFormScreen(pet: widget.pet, draft: draft),
        ),
      );
      if (saved == true) await _load();
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
        borderRadius: BorderRadius.circular(18),
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add a medical document',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'PDF or images. AI extracts the data automatically.',
                      style: TextStyle(fontSize: 12, color: _textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _processing ? null : _uploadDocuments,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Upload clinical history',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
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
            borderRadius: BorderRadius.circular(20),
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
