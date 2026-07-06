import '../entities/pet_clinical_draft.dart';
import '../entities/pet_clinical_event.dart';
import '../entities/pet_clinical_record.dart';

abstract class PetClinicalRepository {
  /// 1. Registra metadata de un archivo ya subido a /api/upload (fuente para IA).
  Future<String> registerSourceDocument({
    required String petId,
    required String fileUrl,
    required String fileName,
    required String fileType,
  });

  /// 2. Corre OCR + extracción IA sobre los documentos registrados.
  Future<ClinicalExtractionDraft> runExtraction({
    required String petId,
    required List<String> documentIds,
  });

  /// 3. Confirma el formulario revisado -> guarda evento + regenera documento + tips.
  Future<PetClinicalEvent> confirmEvent({
    required String petId,
    required ClinicalExtractionDraft draft,
  });

  /// 4. Historia clínica estructurada completa.
  Future<PetClinicalRecord> getRecord(String petId);

  /// 5. Tips generados por IA.
  Future<List<PetClinicalTip>> getTips(String petId);
}

class PetClinicalFailure implements Exception {
  PetClinicalFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'PetClinicalFailure($code): $message';
}
