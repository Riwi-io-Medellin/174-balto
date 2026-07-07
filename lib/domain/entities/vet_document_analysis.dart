import 'package:equatable/equatable.dart';

enum UrgencyLevel {
  routine,
  scheduleVetVisit,
  urgent,
  emergency;

  static UrgencyLevel fromJson(String value) {
    switch (value) {
      case 'routine':
        return UrgencyLevel.routine;
      case 'urgent':
        return UrgencyLevel.urgent;
      case 'emergency':
        return UrgencyLevel.emergency;
      case 'schedule_vet_visit':
      default:
        return UrgencyLevel.scheduleVetVisit;
    }
  }

  String get label {
    switch (this) {
      case UrgencyLevel.routine:
        return 'Routine';
      case UrgencyLevel.scheduleVetVisit:
        return 'Schedule a vet visit';
      case UrgencyLevel.urgent:
        return 'Urgent';
      case UrgencyLevel.emergency:
        return 'Emergency';
    }
  }
}

class AbnormalValue extends Equatable {
  const AbnormalValue({
    required this.label,
    required this.value,
    this.referenceRange,
    required this.interpretation,
  });

  final String label;
  final String value;
  final String? referenceRange;
  final String interpretation;

  factory AbnormalValue.fromJson(Map<String, dynamic> json) => AbnormalValue(
    label: json['label'] as String,
    value: json['value'] as String,
    referenceRange: json['referenceRange'] as String?,
    interpretation: json['interpretation'] as String,
  );

  @override
  List<Object?> get props => [label, value, referenceRange, interpretation];
}

class VetDocumentAnalysisHistoryItem extends Equatable {
  const VetDocumentAnalysisHistoryItem({
    required this.id,
    required this.createdAt,
    this.documentType,
    required this.result,
  });

  final String id;
  final DateTime createdAt;
  final String? documentType;
  final VetDocumentAnalysisResult result;

  factory VetDocumentAnalysisHistoryItem.fromJson(Map<String, dynamic> json) {
    return VetDocumentAnalysisHistoryItem(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      documentType: json['documentType'] as String?,
      result: VetDocumentAnalysisResult.fromJson(
        json['result'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  List<Object?> get props => [id, createdAt, documentType, result];
}

class VetDocumentAnalysisResult extends Equatable {
  const VetDocumentAnalysisResult({
    required this.summary,
    required this.keyFindings,
    required this.abnormalValues,
    required this.possibleConcerns,
    required this.urgencyLevel,
    required this.questionsForVet,
    required this.missingInformation,
    required this.disclaimer,
  });

  final String summary;
  final List<String> keyFindings;
  final List<AbnormalValue> abnormalValues;
  final List<String> possibleConcerns;
  final UrgencyLevel urgencyLevel;
  final List<String> questionsForVet;
  final List<String> missingInformation;
  final String disclaimer;

  factory VetDocumentAnalysisResult.fromJson(Map<String, dynamic> json) {
    return VetDocumentAnalysisResult(
      summary: json['summary'] as String,
      keyFindings: (json['keyFindings'] as List).cast<String>(),
      abnormalValues: (json['abnormalValues'] as List)
          .map((e) => AbnormalValue.fromJson(e as Map<String, dynamic>))
          .toList(),
      possibleConcerns: (json['possibleConcerns'] as List).cast<String>(),
      urgencyLevel: UrgencyLevel.fromJson(json['urgencyLevel'] as String),
      questionsForVet: (json['questionsForVet'] as List).cast<String>(),
      missingInformation: (json['missingInformation'] as List).cast<String>(),
      disclaimer: json['disclaimer'] as String,
    );
  }

  @override
  List<Object?> get props => [
    summary,
    keyFindings,
    abnormalValues,
    possibleConcerns,
    urgencyLevel,
    questionsForVet,
    missingInformation,
    disclaimer,
  ];
}
