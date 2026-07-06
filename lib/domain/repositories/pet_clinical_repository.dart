import '../entities/pet_clinical_draft.dart';
import '../entities/pet_clinical_event.dart';
import '../entities/pet_clinical_record.dart';

abstract class PetClinicalRepository {
  /// 1. Registers metadata for a file already uploaded to /api/upload (AI source).
  Future<String> registerSourceDocument({
    required String petId,
    required String fileUrl,
    required String fileName,
    required String fileType,
  });

  /// 2. Runs OCR + AI extraction on the registered documents.
  Future<ClinicalExtractionDraft> runExtraction({
    required String petId,
    required List<String> documentIds,
  });

  /// 3. Confirms the reviewed form -> saves the event + regenerates the document + tips.
  Future<PetClinicalEvent> confirmEvent({
    required String petId,
    required ClinicalExtractionDraft draft,
  });

  /// 4. Full structured clinical history.
  Future<PetClinicalRecord> getRecord(String petId);

  /// 5. AI-generated tips.
  Future<List<PetClinicalTip>> getTips(String petId);
}

class PetClinicalFailure implements Exception {
  PetClinicalFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'PetClinicalFailure($code): $message';
}
