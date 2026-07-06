import 'package:equatable/equatable.dart';

import '../../../core/utils/vet_document_validators.dart';
import '../../../domain/entities/vet_document_analysis.dart';

abstract class VetDocumentAnalysisState extends Equatable {
  const VetDocumentAnalysisState();

  @override
  List<Object?> get props => const [];
}

class VetDocumentAnalysisInitial extends VetDocumentAnalysisState {
  const VetDocumentAnalysisInitial({this.files = const []});

  final List<PickedFileInfo> files;

  @override
  List<Object?> get props => [files];
}

class VetDocumentAnalysisUploading extends VetDocumentAnalysisState {
  const VetDocumentAnalysisUploading();
}

class VetDocumentAnalysisAnalyzing extends VetDocumentAnalysisState {
  const VetDocumentAnalysisAnalyzing();
}

class VetDocumentAnalysisLoaded extends VetDocumentAnalysisState {
  const VetDocumentAnalysisLoaded(this.result);

  final VetDocumentAnalysisResult result;

  @override
  List<Object?> get props => [result];
}

class VetDocumentAnalysisError extends VetDocumentAnalysisState {
  const VetDocumentAnalysisError(this.message, {this.files = const []});

  final String message;
  final List<PickedFileInfo> files;

  @override
  List<Object?> get props => [message, files];
}
