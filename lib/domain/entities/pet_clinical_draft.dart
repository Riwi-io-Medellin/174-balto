import 'pet_clinical_event.dart';
import 'pet_clinical_medication.dart';

/// Pet profile data that comes inside the AI draft
/// and can also be edited manually (sex/color/microchip/etc).
class PetProfileDraft {
  PetProfileDraft({
    this.sex,
    this.color,
    this.identificationNumber,
    this.microchipNumber,
    this.weight,
  });

  String? sex;
  String? color;
  String? identificationNumber;
  String? microchipNumber;
  double? weight;
}

/// Cumulative pet history (allergies, chronic conditions, diet).
class ClinicalRecordDraft {
  ClinicalRecordDraft({
    this.allergies,
    this.chronicConditions,
    this.dietaryRestrictions,
  });

  String? allergies;
  String? chronicConditions;
  String? dietaryRestrictions;
}

/// Editable medication within the event (dynamic list).
class ClinicalMedicationDraft {
  ClinicalMedicationDraft({
    required this.name,
    this.dose,
    this.frequency,
    this.duration,
  });

  String name;
  String? dose;
  String? frequency;
  String? duration;

  factory ClinicalMedicationDraft.empty() => ClinicalMedicationDraft(name: '');
}

/// The new clinical event to be registered (visit, vaccine, surgery, etc).
class ClinicalEventDraft {
  ClinicalEventDraft({
    this.eventType = PetClinicalEventType.consultation,
    required this.eventDate,
    this.clinicName,
    this.veterinarianName,
    this.reason,
    this.clinicalSigns,
    this.temperature,
    this.heartRate,
    this.respiratoryRate,
    this.weight,
    this.bodyCondition,
    this.findings,
    this.diagnosis,
    this.examsPerformed,
    this.examResults,
    this.procedures,
    this.recommendations,
    this.observations,
    this.nextControlDate,
    List<ClinicalMedicationDraft>? medications,
  }) : medications = medications ?? [];

  String eventType;
  DateTime eventDate;
  String? clinicName;
  String? veterinarianName;
  String? reason;
  String? clinicalSigns;
  double? temperature;
  int? heartRate;
  int? respiratoryRate;
  double? weight;
  String? bodyCondition;
  String? findings;
  String? diagnosis;
  String? examsPerformed;
  String? examResults;
  String? procedures;
  String? recommendations;
  String? observations;
  DateTime? nextControlDate;
  List<ClinicalMedicationDraft> medications;

  factory ClinicalEventDraft.empty() =>
      ClinicalEventDraft(eventDate: DateTime.now());
}

/// The complete form: what the AI extraction returns and what
/// the user finishes reviewing/editing before confirming.
class ClinicalExtractionDraft {
  ClinicalExtractionDraft({
    required this.petProfile,
    required this.clinicalRecord,
    required this.event,
  });

  final PetProfileDraft petProfile;
  final ClinicalRecordDraft clinicalRecord;
  final ClinicalEventDraft event;

  factory ClinicalExtractionDraft.empty() => ClinicalExtractionDraft(
        petProfile: PetProfileDraft(),
        clinicalRecord: ClinicalRecordDraft(),
        event: ClinicalEventDraft.empty(),
      );
}
