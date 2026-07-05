import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_pets/core/utils/vet_document_validators.dart';
import 'package:mobile_pets/domain/entities/pet_health_context.dart';
import 'package:mobile_pets/domain/entities/vet_document_analysis.dart';
import 'package:mobile_pets/domain/repositories/upload_repository.dart';
import 'package:mobile_pets/domain/repositories/vet_document_analysis_repository.dart';
import 'package:mobile_pets/presentation/bloc/vet_document_analysis/vet_document_analysis_cubit.dart';
import 'package:mobile_pets/presentation/bloc/vet_document_analysis/vet_document_analysis_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockUploadRepository extends Mock implements UploadRepository {}

class _MockVetDocumentAnalysisRepository extends Mock implements VetDocumentAnalysisRepository {}

void main() {
  late _MockUploadRepository uploadRepository;
  late _MockVetDocumentAnalysisRepository analysisRepository;
  late VetDocumentAnalysisCubit cubit;

  const petContext = PetHealthContext(name: 'Rocky', species: 'Dog');
  const validFile = PickedFileInfo(path: '/tmp/report.jpg', name: 'report.jpg', sizeBytes: 1024);
  const result = VetDocumentAnalysisResult(
    summary: 's',
    keyFindings: [],
    abnormalValues: [],
    possibleConcerns: [],
    urgencyLevel: UrgencyLevel.routine,
    questionsForVet: [],
    missingInformation: [],
    disclaimer: 'd',
  );

  setUpAll(() {
    registerFallbackValue(petContext);
    registerFallbackValue(<String>[]);
  });

  setUp(() {
    uploadRepository = _MockUploadRepository();
    analysisRepository = _MockVetDocumentAnalysisRepository();
    cubit = VetDocumentAnalysisCubit(
      uploadRepository: uploadRepository,
      analysisRepository: analysisRepository,
    );
  });

  tearDown(() => cubit.close());

  test('addFile appends a valid file to the initial state', () {
    cubit.addFile(validFile);

    final state = cubit.state as VetDocumentAnalysisInitial;
    expect(state.files, [validFile]);
  });

  test('addFile emits an error for an unsupported file type without dropping existing files', () {
    cubit.addFile(validFile);
    cubit.addFile(const PickedFileInfo(path: '/tmp/doc.docx', name: 'doc.docx', sizeBytes: 100));

    final state = cubit.state as VetDocumentAnalysisError;
    expect(state.files, [validFile]);
    expect(state.message, contains('not a supported file type'));
  });

  test('submit without any files emits a validation error and does not call repositories', () async {
    await cubit.submit(petContext);

    expect(cubit.state, isA<VetDocumentAnalysisError>());
    verifyNever(() => uploadRepository.uploadFile(any(), any()));
    verifyNever(() => analysisRepository.analyze(context: any(named: 'context'), fileUrls: any(named: 'fileUrls')));
  });

  test('submit uploads files then analyzes and emits Loaded on success', () async {
    cubit.addFile(validFile);
    when(() => uploadRepository.uploadFile(validFile.path, validFile.name))
        .thenAnswer((_) async => 'https://cdn.example.com/report.jpg');
    when(() => analysisRepository.analyze(context: any(named: 'context'), fileUrls: any(named: 'fileUrls')))
        .thenAnswer((_) async => result);

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder(<VetDocumentAnalysisState>[
        const VetDocumentAnalysisUploading(),
        const VetDocumentAnalysisAnalyzing(),
        const VetDocumentAnalysisLoaded(result),
      ]),
    );

    await cubit.submit(petContext);
    await expectation;
  });

  test('submit emits an error when upload fails, preserving the file list', () async {
    cubit.addFile(validFile);
    when(() => uploadRepository.uploadFile(validFile.path, validFile.name))
        .thenThrow(UploadFailure('NETWORK_ERROR', 'no connection'));

    await cubit.submit(petContext);

    final state = cubit.state as VetDocumentAnalysisError;
    expect(state.files, [validFile]);
    verifyNever(() => analysisRepository.analyze(context: any(named: 'context'), fileUrls: any(named: 'fileUrls')));
  });

  test('submit emits the failure message when analysis fails', () async {
    cubit.addFile(validFile);
    when(() => uploadRepository.uploadFile(validFile.path, validFile.name))
        .thenAnswer((_) async => 'https://cdn.example.com/report.jpg');
    when(() => analysisRepository.analyze(context: any(named: 'context'), fileUrls: any(named: 'fileUrls')))
        .thenThrow(const VetDocumentAnalysisFailure('AI_UNAVAILABLE', 'Service is down.'));

    await cubit.submit(petContext);

    final state = cubit.state as VetDocumentAnalysisError;
    expect(state.message, 'Service is down.');
  });
}
