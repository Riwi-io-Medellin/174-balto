import 'pet_clinical_medication.dart';

/// Event types supported by the backend (PetClinicalEventType).
class PetClinicalEventType {
  PetClinicalEventType._();

  static const consultation = 'consultation';
  static const vaccine = 'vaccine';
  static const deworming = 'deworming';
  static const surgery = 'surgery';
  static const lab = 'lab';
  static const hospitalization = 'hospitalization';
  static const sterilization = 'sterilization';
  static const other = 'other';

  static const values = [
    consultation,
    vaccine,
    deworming,
    surgery,
    lab,
    hospitalization,
    sterilization,
    other,
  ];

  static String label(String value) {
    switch (value) {
      case consultation:
        return 'Consultation';
      case vaccine:
        return 'Vaccine';
      case deworming:
        return 'Deworming';
      case surgery:
        return 'Surgery';
      case lab:
        return 'Lab';
      case hospitalization:
        return 'Hospitalization';
      case sterilization:
        return 'Sterilization';
      case other:
      default:
        return 'Other';
    }
  }
}

/// Clinical event already persisted (comes from the clinical history GET).
class PetClinicalEvent {
  const PetClinicalEvent({
    required this.id,
    required this.petId,
    required this.eventType,
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
    required this.source,
    required this.createdAt,
    this.medications = const [],
  });

  final String id;
  final String petId;
  final String eventType;
  final DateTime eventDate;
  final String? clinicName;
  final String? veterinarianName;
  final String? reason;
  final String? clinicalSigns;
  final double? temperature;
  final int? heartRate;
  final int? respiratoryRate;
  final double? weight;
  final String? bodyCondition;
  final String? findings;
  final String? diagnosis;
  final String? examsPerformed;
  final String? examResults;
  final String? procedures;
  final String? recommendations;
  final String? observations;
  final DateTime? nextControlDate;
  final String source;
  final DateTime createdAt;
  final List<PetClinicalMedication> medications;
}
