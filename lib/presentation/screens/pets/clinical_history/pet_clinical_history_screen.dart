import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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

/// Módulo de Historia Clínica dentro del perfil de la mascota.
/// Flujo: subir documentos -> IA analiza -> formulario editable -> guardar
/// -> timeline + tips + documento oficial.
class PetClinicalHistoryScreen extends StatefulWidget {
  const PetClinicalHistoryScreen({super.key, required this.pet});

  final Pet pet;

  @override
  State<PetClinicalHistoryScreen> createState() => _PetClinicalHistoryScreenState();
}

class _PetClinicalHistoryScreenState extends State<PetClinicalHistoryScreen> {
  static const _accent = AppColors.petProfile;
  static const _bg = Color(0xFFF0F4F4);
  static const _textDark = Color(0xFF1A1A2E);
  static const _textMuted = Color(0xFF6B7280);

  static const _allowedExtensions = ['jpg', 'jpeg', 'png', 'webp', 'gif', 'pdf'];

  bool _loading = true;
  bool _processing = false;
  String _processingMessage = 'Analizando documento...';
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
      setState(() {
        _record = results[0] as PetClinicalRecord;
        _tips = results[1] as List<PetClinicalTip>;
      });
    } catch (_) {
      if (!mounted) return;
      BaltoToast.error(context, 'No se pudo cargar la historia clínica.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _startProcessingMessages() {
    const messages = [
      'Analizando documento...',
      'Extrayendo información...',
      'Generando formulario...',
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
      BaltoToast.error(context, 'No se pudo abrir el selector de archivos.');
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
        final documentId = await sl<PetClinicalRepository>().registerSourceDocument(
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
        BaltoToast.warning(context, 'No se pudo subir ningún archivo.');
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
          builder: (_) => ClinicalEventFormScreen(pet: widget.pet, draft: draft),
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

  Future<void> _downloadDocument() async {
    final url = _record?.documentUrl;
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null || !await canLaunchUrl(uri)) {
      if (!mounted) return;
      BaltoToast.error(context, 'No se pudo abrir el documento.');
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Historia Clínica'),
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
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    children: [
                      _uploadCard(),
                      const SizedBox(height: 24),
                      _sectionTitle('Documento oficial'),
                      const SizedBox(height: 10),
                      _documentCard(),
                      const SizedBox(height: 24),
                      if (_tips.isNotEmpty) ...[
                        _sectionTitle('Tips generados por IA'),
                        const SizedBox(height: 10),
                        ClinicalTipsSection(tips: _tips),
                        const SizedBox(height: 24),
                      ],
                      _sectionTitle('Historial clínico'),
                      const SizedBox(height: 14),
                      ClinicalTimeline(events: _record?.events ?? []),
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
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _textDark),
      );

  Widget _uploadCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 4)),
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
                decoration: BoxDecoration(color: _accent.withValues(alpha: 0.10), shape: BoxShape.circle),
                child: const Icon(Icons.upload_file_rounded, size: 20, color: _accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Agregar documento médico',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark)),
                    const SizedBox(height: 2),
                    Text(
                      'PDF o imágenes. La IA extrae los datos automáticamente.',
                      style: const TextStyle(fontSize: 12, color: _textMuted),
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
              label: const Text('Subir historia clínica', style: TextStyle(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _documentCard() {
    final hasDocument = _record?.documentUrl != null && _record!.documentUrl!.isNotEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E4EC)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: _accent.withValues(alpha: 0.10), shape: BoxShape.circle),
            child: const Icon(Icons.picture_as_pdf_outlined, size: 20, color: _accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              hasDocument
                  ? 'Documento generado ${_formatDate(_record!.documentGeneratedAt!)}'
                  : 'Aún no se ha generado el documento.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: hasDocument ? FontWeight.w600 : FontWeight.w500,
                color: hasDocument ? _textDark : _textMuted,
              ),
            ),
          ),
          if (hasDocument)
            TextButton.icon(
              onPressed: _downloadDocument,
              icon: const Icon(Icons.download_rounded, size: 16),
              label: const Text('Descargar'),
              style: TextButton.styleFrom(foregroundColor: _accent),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) => 'el ${d.day}/${d.month}/${d.year}';

  Widget _processingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.45),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(strokeWidth: 3, color: _accent),
              ),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  _processingMessage,
                  key: ValueKey(_processingMessage),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
