import 'pet_clinical_event.dart';

class PetClinicalRecord {
  const PetClinicalRecord({
    required this.petId,
    this.allergies,
    this.chronicConditions,
    this.dietaryRestrictions,
    this.documentUrl,
    this.documentGeneratedAt,
    this.events = const [],
  });

  final String petId;
  final String? allergies;
  final String? chronicConditions;
  final String? dietaryRestrictions;
  final String? documentUrl;
  final DateTime? documentGeneratedAt;
  final List<PetClinicalEvent> events;
}

class PetClinicalTipCategory {
  PetClinicalTipCategory._();

  static const care = 'care';
  static const feeding = 'feeding';
  static const vaccination = 'vaccination';
  static const alert = 'alert';
  static const general = 'general';

  static String label(String value) {
    switch (value) {
      case care:
        return 'Cuidados';
      case feeding:
        return 'Alimentación';
      case vaccination:
        return 'Vacunas';
      case alert:
        return 'Alerta';
      case general:
      default:
        return 'Recomendación';
    }
  }
}

class PetClinicalTip {
  const PetClinicalTip({
    required this.id,
    required this.category,
    required this.message,
    required this.createdAt,
  });

  final String id;
  final String category;
  final String message;
  final DateTime createdAt;
}
