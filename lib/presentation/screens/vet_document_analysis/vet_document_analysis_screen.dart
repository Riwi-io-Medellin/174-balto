import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/utils/vet_document_validators.dart';
import '../../../core/widgets/balto_toast.dart';
import '../../../domain/entities/pet.dart';
import '../../../domain/entities/pet_clinical_record.dart';
import '../../../domain/entities/pet_health_context.dart';
import '../../../domain/repositories/pet_clinical_repository.dart';
import '../../bloc/vet_document_analysis/vet_document_analysis_cubit.dart';
import '../../bloc/vet_document_analysis/vet_document_analysis_state.dart';
import '../pets/clinical_history/pet_clinical_history_screen.dart';
import 'widgets/analysis_result_view.dart';

const _requiredDisclaimer =
    'This is not a veterinary diagnosis, treatment plan, or substitute for professional veterinary care. Please consult a licensed veterinarian for medical decisions.';

class VetDocumentAnalysisScreen extends StatelessWidget {
  const VetDocumentAnalysisScreen({super.key, this.pet});

  final Pet? pet;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VetDocumentAnalysisCubit>(
      create: (_) => sl<VetDocumentAnalysisCubit>(),
      child: _VetDocumentAnalysisView(pet: pet),
    );
  }
}

class _VetDocumentAnalysisView extends StatefulWidget {
  const _VetDocumentAnalysisView({this.pet});

  final Pet? pet;

  @override
  State<_VetDocumentAnalysisView> createState() => _VetDocumentAnalysisViewState();
}

class _VetDocumentAnalysisViewState extends State<_VetDocumentAnalysisView> {
  static const Color _primary = AppColors.aiCoach;
  static const Color _bg = Color(0xFFF5F7FA);
  static const Color _textDark = Color(0xFF1A1A2E);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _inputFill = Color(0xFFEEF3F3);

  static const _speciesList = ['Dog', 'Cat', 'Bird', 'Rabbit', 'Other'];
  static const _sexOptions = ['Male', 'Female', 'Unknown'];
  static const _documentTypes = [
    'Blood test',
    'Ultrasound',
    'PCR / Lab report',
    'Prescription',
    'Other',
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _breedCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _symptomsCtrl = TextEditingController();
  final _picker = ImagePicker();

  String? _selectedSpecies;
  String? _selectedSex;
  String? _selectedDocumentType;

  PetClinicalRecord? _clinicalRecord;

  @override
  void initState() {
    super.initState();
    final pet = widget.pet;
    if (pet != null) {
      _nameCtrl.text = pet.name;
      _breedCtrl.text = pet.breed ?? '';
      if (pet.weight != null) _weightCtrl.text = pet.weight!.toStringAsFixed(1);
      if (pet.birthDate != null) {
        _ageCtrl.text = (DateTime.now().year - pet.birthDate!.year).toString();
      }
      if (pet.species != null && _speciesList.contains(pet.species)) {
        _selectedSpecies = pet.species;
      }
      _selectedSex = _normalizeSex(pet.sex);
      _loadClinicalRecord();
    }
  }

  Future<void> _loadClinicalRecord() async {
    final pet = widget.pet;
    if (pet == null) return;
    try {
      final record = await sl<PetClinicalRepository>().getRecord(pet.id);
      if (!mounted) return;
      setState(() => _clinicalRecord = record);
    } catch (_) {
      // No clinical record yet, or the fetch failed — the card just won't show a link.
    }
  }

  Future<void> _downloadDocument() async {
    final url = _clinicalRecord?.documentUrl;
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null || !await canLaunchUrl(uri)) {
      if (!mounted) return;
      BaltoToast.error(context, 'Could not open the document.');
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openClinicalHistory() async {
    final pet = widget.pet;
    if (pet == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PetClinicalHistoryScreen(pet: pet)),
    );
    if (!mounted) return;
    _loadClinicalRecord();
  }

  // pet.sex is free text (set via the Clinical History form), so it may be
  // "Male", "male", "M", "Macho", etc. rather than one of our fixed options.
  String? _normalizeSex(String? sex) {
    if (sex == null) return null;
    if (_sexOptions.contains(sex)) return sex;
    final normalized = sex.trim().toLowerCase();
    if (normalized.startsWith('m')) return 'Male';
    if (normalized.startsWith('f') || normalized.startsWith('h')) return 'Female';
    return null;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _breedCtrl.dispose();
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _symptomsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await _picker.pickImage(source: source, imageQuality: 85);
    if (image == null || !mounted) return;
    final size = await File(image.path).length();
    if (!mounted) return;
    context.read<VetDocumentAnalysisCubit>().addFile(
          PickedFileInfo(path: image.path, name: image.name, sizeBytes: size),
        );
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    final file = result?.files.firstOrNull;
    if (file == null || file.path == null || !mounted) return;
    context.read<VetDocumentAnalysisCubit>().addFile(
          PickedFileInfo(path: file.path!, name: file.name, sizeBytes: file.size),
        );
  }

  void _showFileSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                borderRadius: BorderRadius.circular(2),
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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final pet = widget.pet;
    if (pet == null) {
      BaltoToast.error(context, 'No pet selected for this analysis.');
      return;
    }
    final ageText = _ageCtrl.text.trim();
    final weightText = _weightCtrl.text.trim();
    final context0 = PetHealthContext(
      petId: pet.id,
      name: _nameCtrl.text.trim(),
      species: _selectedSpecies ?? '',
      breed: _breedCtrl.text.trim().isEmpty ? null : _breedCtrl.text.trim(),
      age: ageText.isEmpty ? null : int.tryParse(ageText),
      sex: _selectedSex,
      weightKg: weightText.isEmpty ? null : double.tryParse(weightText),
      symptoms: _symptomsCtrl.text.trim().isEmpty ? null : _symptomsCtrl.text.trim(),
      documentType: _selectedDocumentType,
    );
    context.read<VetDocumentAnalysisCubit>().submit(context0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Health Document Analysis'),
        backgroundColor: Colors.white,
        foregroundColor: _textDark,
        elevation: 0,
      ),
      body: BlocConsumer<VetDocumentAnalysisCubit, VetDocumentAnalysisState>(
        listener: (context, state) {
          if (state is VetDocumentAnalysisError) {
            BaltoToast.error(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is VetDocumentAnalysisLoaded) {
            return _buildResults(context, state);
          }
          return _buildForm(context, state);
        },
      ),
    );
  }

  Widget _buildResults(BuildContext context, VetDocumentAnalysisLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnalysisResultView(result: state.result),
          if (widget.pet != null) ...[
            const SizedBox(height: 24),
            _clinicalDocumentCard(),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () => context.read<VetDocumentAnalysisCubit>().reset(),
              style: OutlinedButton.styleFrom(
                foregroundColor: _primary,
                side: const BorderSide(color: _primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Analyze Another Document'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context, VetDocumentAnalysisState state) {
    final files = state is VetDocumentAnalysisInitial
        ? state.files
        : state is VetDocumentAnalysisError
            ? state.files
            : const <PickedFileInfo>[];
    final isBusy = state is VetDocumentAnalysisUploading || state is VetDocumentAnalysisAnalyzing;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _disclaimerNotice(),
            if (widget.pet != null) ...[
              const SizedBox(height: 16),
              _clinicalDocumentCard(),
            ],
            const SizedBox(height: 20),
            _fieldLabel('Documents'),
            const SizedBox(height: 8),
            ...files.asMap().entries.map((e) => _fileTile(context, e.key, e.value)),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _showFileSourceSheet,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add photo or PDF'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _primary,
                side: const BorderSide(color: _primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 0),
              ),
            ),
            const SizedBox(height: 24),
            _fieldLabel('Pet Name'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameCtrl,
              decoration: _decoration(hint: 'Pet name', icon: Icons.pets),
              validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            _fieldLabel('Species'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedSpecies,
              isExpanded: true,
              decoration: _decoration(hint: 'Select species', icon: Icons.category_outlined),
              items: _speciesList.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (value) => setState(() => _selectedSpecies = value),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            _fieldLabel('Breed (optional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _breedCtrl,
              decoration: _decoration(hint: 'e.g. Labrador Retriever', icon: Icons.style_outlined),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Age (optional)'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _ageCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: _decoration(hint: 'Years', icon: Icons.cake_outlined),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Weight kg (optional)'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _weightCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                        decoration: _decoration(hint: 'e.g. 12.5', icon: Icons.monitor_weight_outlined),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _fieldLabel('Sex (optional)'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedSex,
              isExpanded: true,
              decoration: _decoration(hint: 'Select sex', icon: Icons.wc_outlined),
              items: _sexOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (value) => setState(() => _selectedSex = value),
            ),
            const SizedBox(height: 20),
            _fieldLabel('Document Type (optional)'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedDocumentType,
              isExpanded: true,
              decoration: _decoration(hint: 'Select document type', icon: Icons.description_outlined),
              items: _documentTypes.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (value) => setState(() => _selectedDocumentType = value),
            ),
            const SizedBox(height: 20),
            _fieldLabel('Symptoms / Reason (optional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _symptomsCtrl,
              maxLines: 3,
              decoration: _decoration(hint: 'What prompted this document?', icon: Icons.notes_outlined),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: isBusy ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: isBusy
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Text(state is VetDocumentAnalysisUploading ? 'Uploading...' : 'Analyzing...'),
                        ],
                      )
                    : const Text('Analyze Document', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _fileTile(BuildContext context, int index, PickedFileInfo file) {
    final isPdf = file.extension == 'pdf';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(isPdf ? Icons.picture_as_pdf_rounded : Icons.image_rounded, color: _primary),
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
            onPressed: () => context.read<VetDocumentAnalysisCubit>().removeFile(index),
          ),
        ],
      ),
    );
  }

  Widget _clinicalDocumentCard() {
    final hasDocument = _clinicalRecord?.documentUrl != null &&
        _clinicalRecord!.documentUrl!.isNotEmpty;
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
            decoration: BoxDecoration(color: _primary.withValues(alpha: 0.10), shape: BoxShape.circle),
            child: Icon(
              hasDocument ? Icons.picture_as_pdf_outlined : Icons.folder_shared_outlined,
              size: 20,
              color: _primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              hasDocument
                  ? 'Official clinical history document available.'
                  : 'No official clinical history document yet.',
              style: const TextStyle(fontSize: 13, color: _textDark),
            ),
          ),
          if (hasDocument)
            TextButton.icon(
              onPressed: _downloadDocument,
              icon: const Icon(Icons.download_rounded, size: 16),
              label: const Text('Download'),
              style: TextButton.styleFrom(foregroundColor: _primary),
            )
          else
            TextButton(
              onPressed: _openClinicalHistory,
              style: TextButton.styleFrom(foregroundColor: _primary),
              child: const Text('Open history'),
            ),
        ],
      ),
    );
  }

  Widget _disclaimerNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8A84C).withValues(alpha: 0.5)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFFB07D00)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              _requiredDisclaimer,
              style: TextStyle(fontSize: 12.5, color: Color(0xFF6B4E00), height: 1.4),
            ),
          ),
        ],
      ),
    );
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
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark),
    );
  }
}
