import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/vet_document_validators.dart';
import '../../../domain/entities/pet_health_context.dart';
import '../../../domain/repositories/upload_repository.dart';
import '../../../domain/repositories/vet_document_analysis_repository.dart';
import 'vet_document_analysis_state.dart';

class VetDocumentAnalysisCubit extends Cubit<VetDocumentAnalysisState> {
  VetDocumentAnalysisCubit({
    required this._uploadRepository,
    required this._analysisRepository,
  }) : super(const VetDocumentAnalysisInitial());

  final UploadRepository _uploadRepository;
  final VetDocumentAnalysisRepository _analysisRepository;

  List<PickedFileInfo> get _currentFiles {
    final s = state;
    if (s is VetDocumentAnalysisInitial) return s.files;
    if (s is VetDocumentAnalysisError) return s.files;
    return const [];
  }

  void addFile(PickedFileInfo file) {
    final updated = [..._currentFiles, file];
    final validation = validateFiles(updated);
    if (!validation.isValid) {
      emit(VetDocumentAnalysisError(validation.error!, files: _currentFiles));
      return;
    }
    emit(VetDocumentAnalysisInitial(files: updated));
  }

  void removeFile(int index) {
    final updated = [..._currentFiles]..removeAt(index);
    emit(VetDocumentAnalysisInitial(files: updated));
  }

  void reset() => emit(const VetDocumentAnalysisInitial());

  Future<void> submit(PetHealthContext context) async {
    final files = _currentFiles;
    final filesValidation = validateFiles(files);
    if (!filesValidation.isValid) {
      emit(VetDocumentAnalysisError(filesValidation.error!, files: files));
      return;
    }
    final contextValidation = validatePetContext(context);
    if (!contextValidation.isValid) {
      emit(VetDocumentAnalysisError(contextValidation.error!, files: files));
      return;
    }

    emit(const VetDocumentAnalysisUploading());
    final fileUrls = <String>[];
    try {
      for (final file in files) {
        final url = await _uploadRepository.uploadFile(file.path, file.name);
        fileUrls.add(url);
      }
    } catch (e) {
      emit(
        VetDocumentAnalysisError(
          'Could not upload one or more files. Please try again.',
          files: files,
        ),
      );
      return;
    }

    emit(const VetDocumentAnalysisAnalyzing());
    try {
      final result = await _analysisRepository.analyze(
        context: context,
        fileUrls: fileUrls,
      );
      emit(VetDocumentAnalysisLoaded(result));
    } on VetDocumentAnalysisFailure catch (e) {
      emit(VetDocumentAnalysisError(e.message, files: files));
    } catch (_) {
      emit(
        VetDocumentAnalysisError(
          'Something went wrong while analyzing the document. Please try again.',
          files: files,
        ),
      );
    }
  }
}
