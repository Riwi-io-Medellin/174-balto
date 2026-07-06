import '../entities/pet_health_context.dart';
import '../entities/vet_document_analysis.dart';

abstract class VetDocumentAnalysisRepository {
  Future<VetDocumentAnalysisResult> analyze({
    required PetHealthContext context,
    required List<String> fileUrls,
  });

  Future<List<VetDocumentAnalysisHistoryItem>> getHistory(String petId);
}

class VetDocumentAnalysisFailure implements Exception {
  const VetDocumentAnalysisFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'VetDocumentAnalysisFailure($code): $message';
}
