import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/widgets/balto_toast.dart';
import '../../../../../domain/entities/pet.dart';
import '../../../../../domain/entities/pet_clinical_draft.dart';
import '../../../../../domain/entities/pet_clinical_event.dart';
import '../../../../../domain/repositories/pet_clinical_repository.dart';
import 'medication_editor.dart';

/// Full, editable clinical history form.
/// The user always has the final say: no field is locked.
class ClinicalEventFormScreen extends StatefulWidget {
  const ClinicalEventFormScreen({
    super.key,
    required this.pet,
    required this.draft,
  });

  final Pet pet;
  final ClinicalExtractionDraft draft;

  @override
  State<ClinicalEventFormScreen> createState() => _ClinicalEventFormScreenState();
}

class _ClinicalEventFormScreenState extends State<ClinicalEventFormScreen> {
  static const _accent = AppColors.petProfile;
  static const _bg = Color(0xFFF0F4F4);
  static const _textDark = Color(0xFF1A1A2E);
  static const _textMuted = Color(0xFF6B7280);
  static const _inputFill = Color(0xFFEEF3F3);

  late ClinicalExtractionDraft _draft;
  bool _saving = false;

  // Pet profile
  late final _sexCtrl = TextEditingController(text: _draft.petProfile.sex ?? '');
  late final _colorCtrl = TextEditingController(text: _draft.petProfile.color ?? '');
  late final _idCtrl = TextEditingController(text: _draft.petProfile.identificationNumber ?? '');
  late final _microchipCtrl = TextEditingController(text: _draft.petProfile.microchipNumber ?? '');
  late final _profileWeightCtrl =
      TextEditingController(text: _draft.petProfile.weight?.toString() ?? '');

  // History
  late final _allergiesCtrl = TextEditingController(text: _draft.clinicalRecord.allergies ?? '');
  late final _chronicCtrl =
      TextEditingController(text: _draft.clinicalRecord.chronicConditions ?? '');
  late final _dietCtrl =
      TextEditingController(text: _draft.clinicalRecord.dietaryRestrictions ?? '');

  // Visit / event
  late final _clinicCtrl = TextEditingController(text: _draft.event.clinicName ?? '');
  late final _vetCtrl = TextEditingController(text: _draft.event.veterinarianName ?? '');
  late final _reasonCtrl = TextEditingController(text: _draft.event.reason ?? '');

  // Clinical exam
  late final _signsCtrl = TextEditingController(text: _draft.event.clinicalSigns ?? '');
  late final _tempCtrl = TextEditingController(text: _draft.event.temperature?.toString() ?? '');
  late final _hrCtrl = TextEditingController(text: _draft.event.heartRate?.toString() ?? '');
  late final _rrCtrl = TextEditingController(text: _draft.event.respiratoryRate?.toString() ?? '');
  late final _eventWeightCtrl =
      TextEditingController(text: _draft.event.weight?.toString() ?? '');
  late final _bodyConditionCtrl =
      TextEditingController(text: _draft.event.bodyCondition ?? '');
  late final _findingsCtrl = TextEditingController(text: _draft.event.findings ?? '');

  // Diagnosis and exams
  late final _diagnosisCtrl = TextEditingController(text: _draft.event.diagnosis ?? '');
  late final _examsCtrl = TextEditingController(text: _draft.event.examsPerformed ?? '');
  late final _examResultsCtrl = TextEditingController(text: _draft.event.examResults ?? '');

  // Treatment and follow-up
  late final _proceduresCtrl = TextEditingController(text: _draft.event.procedures ?? '');
  late final _recommendationsCtrl =
      TextEditingController(text: _draft.event.recommendations ?? '');
  late final _observationsCtrl = TextEditingController(text: _draft.event.observations ?? '');

  @override
  void initState() {
    super.initState();
    _draft = widget.draft;
  }

  @override
  void dispose() {
    for (final c in [
      _sexCtrl, _colorCtrl, _idCtrl, _microchipCtrl, _profileWeightCtrl,
      _allergiesCtrl, _chronicCtrl, _dietCtrl,
      _clinicCtrl, _vetCtrl, _reasonCtrl,
      _signsCtrl, _tempCtrl, _hrCtrl, _rrCtrl, _eventWeightCtrl, _bodyConditionCtrl, _findingsCtrl,
      _diagnosisCtrl, _examsCtrl, _examResultsCtrl,
      _proceduresCtrl, _recommendationsCtrl, _observationsCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _syncControllersIntoDraft() {
    _draft.petProfile
      ..sex = _sexCtrl.text.trim().isEmpty ? null : _sexCtrl.text.trim()
      ..color = _colorCtrl.text.trim().isEmpty ? null : _colorCtrl.text.trim()
      ..identificationNumber = _idCtrl.text.trim().isEmpty ? null : _idCtrl.text.trim()
      ..microchipNumber = _microchipCtrl.text.trim().isEmpty ? null : _microchipCtrl.text.trim()
      ..weight = double.tryParse(_profileWeightCtrl.text.trim());

    _draft.clinicalRecord
      ..allergies = _allergiesCtrl.text.trim().isEmpty ? null : _allergiesCtrl.text.trim()
      ..chronicConditions = _chronicCtrl.text.trim().isEmpty ? null : _chronicCtrl.text.trim()
      ..dietaryRestrictions = _dietCtrl.text.trim().isEmpty ? null : _dietCtrl.text.trim();

    _draft.event
      ..clinicName = _clinicCtrl.text.trim().isEmpty ? null : _clinicCtrl.text.trim()
      ..veterinarianName = _vetCtrl.text.trim().isEmpty ? null : _vetCtrl.text.trim()
      ..reason = _reasonCtrl.text.trim().isEmpty ? null : _reasonCtrl.text.trim()
      ..clinicalSigns = _signsCtrl.text.trim().isEmpty ? null : _signsCtrl.text.trim()
      ..temperature = double.tryParse(_tempCtrl.text.trim())
      ..heartRate = int.tryParse(_hrCtrl.text.trim())
      ..respiratoryRate = int.tryParse(_rrCtrl.text.trim())
      ..weight = double.tryParse(_eventWeightCtrl.text.trim())
      ..bodyCondition = _bodyConditionCtrl.text.trim().isEmpty ? null : _bodyConditionCtrl.text.trim()
      ..findings = _findingsCtrl.text.trim().isEmpty ? null : _findingsCtrl.text.trim()
      ..diagnosis = _diagnosisCtrl.text.trim().isEmpty ? null : _diagnosisCtrl.text.trim()
      ..examsPerformed = _examsCtrl.text.trim().isEmpty ? null : _examsCtrl.text.trim()
      ..examResults = _examResultsCtrl.text.trim().isEmpty ? null : _examResultsCtrl.text.trim()
      ..procedures = _proceduresCtrl.text.trim().isEmpty ? null : _proceduresCtrl.text.trim()
      ..recommendations =
          _recommendationsCtrl.text.trim().isEmpty ? null : _recommendationsCtrl.text.trim()
      ..observations = _observationsCtrl.text.trim().isEmpty ? null : _observationsCtrl.text.trim();
  }

  Future<void> _pickEventDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _draft.event.eventDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _draft.event.eventDate = picked);
  }

  Future<void> _pickNextControlDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _draft.event.nextControlDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _draft.event.nextControlDate = picked);
  }

  Future<void> _save() async {
    _syncControllersIntoDraft();
    setState(() => _saving = true);
    try {
      await sl<PetClinicalRepository>().confirmEvent(petId: widget.pet.id, draft: _draft);
      if (!mounted) return;
      BaltoToast.success(context, 'Clinical history saved.');
      Navigator.of(context).pop(true);
    } on PetClinicalFailure catch (e) {
      if (!mounted) return;
      BaltoToast.error(context, e.message);
    } catch (e) {
      if (!mounted) return;
      BaltoToast.error(context, 'Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _cancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('The reviewed information will not be saved.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Keep editing')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFD05A24)),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) Navigator.of(context).pop(false);
  }

  InputDecoration _decoration(String hint, {IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _textMuted, fontSize: 13),
      prefixIcon: icon != null ? Icon(icon, color: _textMuted, size: 18) : null,
      filled: true,
      fillColor: _inputFill,
      isDense: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
    );
  }

  Widget _field(TextEditingController ctrl, String label, {IconData? icon, int maxLines = 1, TextInputType? keyboardType, List<TextInputFormatter>? formatters}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: formatters,
        style: const TextStyle(fontSize: 14, color: _textDark),
        decoration: _decoration(label, icon: icon),
      ),
    );
  }

  Widget _dateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
    IconData icon = Icons.calendar_today_outlined,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: AbsorbPointer(
          child: TextFormField(
            readOnly: true,
            style: const TextStyle(fontSize: 14, color: _textDark),
            decoration: _decoration(
              value != null ? '${value.day}/${value.month}/${value.year}' : label,
              icon: icon,
            ),
          ),
        ),
      ),
    );
  }

  Widget _section({required String title, required IconData icon, required List<Widget> children, bool initiallyExpanded = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 3)),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          collapsedShape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: _accent.withValues(alpha: 0.10), shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: _accent),
          ),
          title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark)),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: children,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Review clinical history'),
        backgroundColor: Colors.white,
        foregroundColor: _textDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _saving ? null : _cancel,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: const Color(0xFFE8F5EE),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: _accent),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Review and edit everything before saving. No field is locked.',
                      style: TextStyle(fontSize: 12, color: _accent, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                children: [
                  _section(
                    title: 'Pet details',
                    icon: Icons.pets_rounded,
                    initiallyExpanded: true,
                    children: [
                      _field(_sexCtrl, 'Sex (male/female)'),
                      _field(_colorCtrl, 'Color'),
                      _field(_idCtrl, 'Identification number'),
                      _field(_microchipCtrl, 'Microchip'),
                      _field(_profileWeightCtrl, 'Weight (kg)',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          formatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))]),
                    ],
                  ),
                  _section(
                    title: 'Medical history',
                    icon: Icons.history_edu_rounded,
                    children: [
                      _field(_allergiesCtrl, 'Allergies', maxLines: 2),
                      _field(_chronicCtrl, 'Chronic conditions', maxLines: 2),
                      _field(_dietCtrl, 'Dietary restrictions', maxLines: 2),
                    ],
                  ),
                  _section(
                    title: 'Visit',
                    icon: Icons.event_note_rounded,
                    initiallyExpanded: true,
                    children: [
                      _eventTypeDropdown(),
                      const SizedBox(height: 12),
                      _dateField(
                        label: 'Visit date',
                        value: _draft.event.eventDate,
                        onTap: _pickEventDate,
                      ),
                      _field(_clinicCtrl, 'Clinic', icon: Icons.local_hospital_outlined),
                      _field(_vetCtrl, 'Veterinarian', icon: Icons.badge_outlined),
                      _field(_reasonCtrl, 'Reason for the visit', maxLines: 2),
                    ],
                  ),
                  _section(
                    title: 'Clinical exam',
                    icon: Icons.monitor_heart_outlined,
                    children: [
                      _field(_signsCtrl, 'Clinical signs', maxLines: 2),
                      Row(children: [
                        Expanded(
                            child: _field(_tempCtrl, 'Temperature (°C)',
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                formatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}'))])),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _field(_hrCtrl, 'Heart rate',
                                keyboardType: TextInputType.number,
                                formatters: [FilteringTextInputFormatter.digitsOnly])),
                      ]),
                      Row(children: [
                        Expanded(
                            child: _field(_rrCtrl, 'Respiratory rate',
                                keyboardType: TextInputType.number,
                                formatters: [FilteringTextInputFormatter.digitsOnly])),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _field(_eventWeightCtrl, 'Current weight (kg)',
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                formatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))])),
                      ]),
                      _field(_bodyConditionCtrl, 'Body condition'),
                      _field(_findingsCtrl, 'Relevant findings', maxLines: 2),
                    ],
                  ),
                  _section(
                    title: 'Diagnosis and exams',
                    icon: Icons.biotech_outlined,
                    children: [
                      _field(_diagnosisCtrl, 'Diagnosis', maxLines: 2),
                      _field(_examsCtrl, 'Exams performed', maxLines: 2),
                      _field(_examResultsCtrl, 'Results', maxLines: 2),
                    ],
                  ),
                  _section(
                    title: 'Treatment',
                    icon: Icons.medication_outlined,
                    children: [
                      MedicationEditor(
                        medications: _draft.event.medications,
                        accentColor: _accent,
                        onChanged: (meds) => _draft.event.medications = meds,
                      ),
                      const SizedBox(height: 4),
                      _field(_proceduresCtrl, 'Procedures', maxLines: 2),
                    ],
                  ),
                  _section(
                    title: 'Recommendations and follow-up',
                    icon: Icons.checklist_rtl_rounded,
                    children: [
                      _field(_recommendationsCtrl, 'Recommendations', maxLines: 2),
                      _field(_observationsCtrl, 'Observations', maxLines: 2),
                      _dateField(
                        label: 'Next check-up',
                        value: _draft.event.nextControlDate,
                        onTap: _pickNextControlDate,
                        icon: Icons.event_available_outlined,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -2))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving ? null : _cancel,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _textMuted,
                        side: const BorderSide(color: Color(0xFFE0E4EC)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                          : const Text('Save clinical history', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _eventTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _draft.event.eventType,
      isExpanded: true,
      decoration: _decoration('Event type', icon: Icons.category_outlined),
      style: const TextStyle(fontSize: 14, color: _textDark),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
      items: PetClinicalEventType.values
          .map((v) => DropdownMenuItem(value: v, child: Text(PetClinicalEventType.label(v))))
          .toList(),
      onChanged: (v) {
        if (v != null) setState(() => _draft.event.eventType = v);
      },
    );
  }
}
