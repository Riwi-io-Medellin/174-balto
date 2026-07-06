import '../../domain/entities/pet_clinical_draft.dart';
import '../../domain/entities/pet_clinical_event.dart';
import '../../domain/entities/pet_clinical_medication.dart';
import '../../domain/entities/pet_clinical_record.dart';

DateTime _parseDate(dynamic v) => DateTime.parse(v as String).toLocal();
DateTime? _parseDateOrNull(dynamic v) =>
    v == null ? null : DateTime.parse(v as String).toLocal();
double? _toDouble(dynamic v) => (v as num?)?.toDouble();
int? _toInt(dynamic v) => (v as num?)?.toInt();

class PetProfileDraftDto {
  static Map<String, dynamic> toJson(PetProfileDraft d) => {
        if (d.sex != null) 'sex': d.sex,
        if (d.color != null) 'color': d.color,
        if (d.identificationNumber != null)
          'identificationNumber': d.identificationNumber,
        if (d.microchipNumber != null) 'microchipNumber': d.microchipNumber,
        if (d.weight != null) 'weight': d.weight,
      };

  static PetProfileDraft fromJson(Map<String, dynamic> json) => PetProfileDraft(
        sex: json['sex'] as String?,
        color: json['color'] as String?,
        identificationNumber: json['identificationNumber'] as String?,
        microchipNumber: json['microchipNumber'] as String?,
        weight: _toDouble(json['weight']),
      );
}

class ClinicalRecordDraftDto {
  static Map<String, dynamic> toJson(ClinicalRecordDraft d) => {
        if (d.allergies != null) 'allergies': d.allergies,
        if (d.chronicConditions != null)
          'chronicConditions': d.chronicConditions,
        if (d.dietaryRestrictions != null)
          'dietaryRestrictions': d.dietaryRestrictions,
      };

  static ClinicalRecordDraft fromJson(Map<String, dynamic> json) =>
      ClinicalRecordDraft(
        allergies: json['allergies'] as String?,
        chronicConditions: json['chronicConditions'] as String?,
        dietaryRestrictions: json['dietaryRestrictions'] as String?,
      );
}

class ClinicalMedicationDraftDto {
  static Map<String, dynamic> toJson(ClinicalMedicationDraft d) => {
        'name': d.name,
        if (d.dose != null) 'dose': d.dose,
        if (d.frequency != null) 'frequency': d.frequency,
        if (d.duration != null) 'duration': d.duration,
      };

  static ClinicalMedicationDraft fromJson(Map<String, dynamic> json) =>
      ClinicalMedicationDraft(
        name: json['name'] as String? ?? '',
        dose: json['dose'] as String?,
        frequency: json['frequency'] as String?,
        duration: json['duration'] as String?,
      );
}

class ClinicalEventDraftDto {
  static Map<String, dynamic> toJson(ClinicalEventDraft d) => {
        'eventType': d.eventType,
        'eventDate': d.eventDate.toIso8601String(),
        if (d.clinicName != null) 'clinicName': d.clinicName,
        if (d.veterinarianName != null)
          'veterinarianName': d.veterinarianName,
        if (d.reason != null) 'reason': d.reason,
        if (d.clinicalSigns != null) 'clinicalSigns': d.clinicalSigns,
        if (d.temperature != null) 'temperature': d.temperature,
        if (d.heartRate != null) 'heartRate': d.heartRate,
        if (d.respiratoryRate != null) 'respiratoryRate': d.respiratoryRate,
        if (d.weight != null) 'weight': d.weight,
        if (d.bodyCondition != null) 'bodyCondition': d.bodyCondition,
        if (d.findings != null) 'findings': d.findings,
        if (d.diagnosis != null) 'diagnosis': d.diagnosis,
        if (d.examsPerformed != null) 'examsPerformed': d.examsPerformed,
        if (d.examResults != null) 'examResults': d.examResults,
        if (d.procedures != null) 'procedures': d.procedures,
        if (d.recommendations != null) 'recommendations': d.recommendations,
        if (d.observations != null) 'observations': d.observations,
        if (d.nextControlDate != null)
          'nextControlDate': d.nextControlDate!.toIso8601String(),
        'medications':
            d.medications.map(ClinicalMedicationDraftDto.toJson).toList(),
      };

  static ClinicalEventDraft fromJson(Map<String, dynamic> json) =>
      ClinicalEventDraft(
        eventType: json['eventType'] as String? ?? PetClinicalEventType.consultation,
        eventDate: _parseDate(json['eventDate']),
        clinicName: json['clinicName'] as String?,
        veterinarianName: json['veterinarianName'] as String?,
        reason: json['reason'] as String?,
        clinicalSigns: json['clinicalSigns'] as String?,
        temperature: _toDouble(json['temperature']),
        heartRate: _toInt(json['heartRate']),
        respiratoryRate: _toInt(json['respiratoryRate']),
        weight: _toDouble(json['weight']),
        bodyCondition: json['bodyCondition'] as String?,
        findings: json['findings'] as String?,
        diagnosis: json['diagnosis'] as String?,
        examsPerformed: json['examsPerformed'] as String?,
        examResults: json['examResults'] as String?,
        procedures: json['procedures'] as String?,
        recommendations: json['recommendations'] as String?,
        observations: json['observations'] as String?,
        nextControlDate: _parseDateOrNull(json['nextControlDate']),
        medications: ((json['medications'] as List?) ?? [])
            .map((m) => ClinicalMedicationDraftDto.fromJson(m as Map<String, dynamic>))
            .toList(),
      );
}

class ClinicalExtractionDraftDto {
  static Map<String, dynamic> toJson(ClinicalExtractionDraft d) => {
        'petProfile': PetProfileDraftDto.toJson(d.petProfile),
        'clinicalRecord': ClinicalRecordDraftDto.toJson(d.clinicalRecord),
        'event': ClinicalEventDraftDto.toJson(d.event),
      };

  static ClinicalExtractionDraft fromJson(Map<String, dynamic> json) =>
      ClinicalExtractionDraft(
        petProfile: PetProfileDraftDto.fromJson(
            json['petProfile'] as Map<String, dynamic>? ?? {}),
        clinicalRecord: ClinicalRecordDraftDto.fromJson(
            json['clinicalRecord'] as Map<String, dynamic>? ?? {}),
        event: ClinicalEventDraftDto.fromJson(
            json['event'] as Map<String, dynamic>? ?? {}),
      );
}

class ClinicalMedicationResponseDto {
  static PetClinicalMedication fromJson(Map<String, dynamic> json) =>
      PetClinicalMedication(
        id: json['id'] as String?,
        name: json['name'] as String? ?? '',
        dose: json['dose'] as String?,
        frequency: json['frequency'] as String?,
        duration: json['duration'] as String?,
      );
}

class ClinicalEventResponseDto {
  static PetClinicalEvent fromJson(Map<String, dynamic> json) => PetClinicalEvent(
        id: json['id'] as String,
        petId: json['petId'] as String,
        eventType: json['eventType'] as String,
        eventDate: _parseDate(json['eventDate']),
        clinicName: json['clinicName'] as String?,
        veterinarianName: json['veterinarianName'] as String?,
        reason: json['reason'] as String?,
        clinicalSigns: json['clinicalSigns'] as String?,
        temperature: _toDouble(json['temperature']),
        heartRate: _toInt(json['heartRate']),
        respiratoryRate: _toInt(json['respiratoryRate']),
        weight: _toDouble(json['weight']),
        bodyCondition: json['bodyCondition'] as String?,
        findings: json['findings'] as String?,
        diagnosis: json['diagnosis'] as String?,
        examsPerformed: json['examsPerformed'] as String?,
        examResults: json['examResults'] as String?,
        procedures: json['procedures'] as String?,
        recommendations: json['recommendations'] as String?,
        observations: json['observations'] as String?,
        nextControlDate: _parseDateOrNull(json['nextControlDate']),
        source: json['source'] as String? ?? 'manual',
        createdAt: _parseDate(json['createdAt']),
        medications: ((json['medications'] as List?) ?? [])
            .map((m) =>
                ClinicalMedicationResponseDto.fromJson(m as Map<String, dynamic>))
            .toList(),
      );
}

class ClinicalRecordResponseDto {
  static PetClinicalRecord fromJson(Map<String, dynamic> json) => PetClinicalRecord(
        petId: json['petId'] as String,
        allergies: json['allergies'] as String?,
        chronicConditions: json['chronicConditions'] as String?,
        dietaryRestrictions: json['dietaryRestrictions'] as String?,
        documentUrl: json['documentUrl'] as String?,
        documentGeneratedAt: _parseDateOrNull(json['documentGeneratedAt']),
        events: ((json['events'] as List?) ?? [])
            .map((e) => ClinicalEventResponseDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class ClinicalTipResponseDto {
  static PetClinicalTip fromJson(Map<String, dynamic> json) => PetClinicalTip(
        id: json['id'] as String,
        category: json['category'] as String,
        message: json['message'] as String,
        createdAt: _parseDate(json['createdAt']),
      );
}
