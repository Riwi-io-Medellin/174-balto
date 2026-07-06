import 'pet_clinical_medication.dart';

/// Tipos de evento soportados por el backend (PetClinicalEventType).
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
        return 'Consulta';
      case vaccine:
        return 'Vacuna';
      case deworming:
        return 'Desparasitación';
      case surgery:
        return 'Cirugía';
      case lab:
        return 'Laboratorio';
      case hospitalization:
        return 'Hospitalización';
      case sterilization:
        return 'Esterilización';
      case other:
      default:
        return 'Otro';
    }
  }
}

/// Evento clínico ya persistido (viene del GET de historia clínica).
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
