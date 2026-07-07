import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_pets/data/datasources/vet_document_analysis_remote_datasource.dart';
import 'package:mobile_pets/data/repositories/vet_document_analysis_repository_impl.dart';
import 'package:mobile_pets/domain/entities/pet_health_context.dart';
import 'package:mobile_pets/domain/entities/vet_document_analysis.dart';
import 'package:mobile_pets/domain/repositories/vet_document_analysis_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemoteDataSource extends Mock
    implements VetDocumentAnalysisRemoteDataSource {}

void main() {
  late _MockRemoteDataSource remote;
  late VetDocumentAnalysisRepositoryImpl repository;

  const context = PetHealthContext(
    petId: 'pet-1',
    name: 'Rocky',
    species: 'Dog',
  );
  const fileUrls = ['https://cdn.example.com/report.jpg'];

  setUpAll(() {
    registerFallbackValue(context);
    registerFallbackValue(<String>[]);
  });

  setUp(() {
    remote = _MockRemoteDataSource();
    repository = VetDocumentAnalysisRepositoryImpl(remote);
  });

  test('returns the result from the remote datasource on success', () async {
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
    when(
      () => remote.analyze(
        context: any(named: 'context'),
        fileUrls: any(named: 'fileUrls'),
      ),
    ).thenAnswer((_) async => result);

    final actual = await repository.analyze(
      context: context,
      fileUrls: fileUrls,
    );

    expect(actual, result);
  });

  test('rethrows a VetDocumentAnalysisFailure unchanged', () async {
    when(
      () => remote.analyze(
        context: any(named: 'context'),
        fileUrls: any(named: 'fileUrls'),
      ),
    ).thenThrow(const VetDocumentAnalysisFailure('AI_UNAVAILABLE', 'down'));

    await expectLater(
      () => repository.analyze(context: context, fileUrls: fileUrls),
      throwsA(
        isA<VetDocumentAnalysisFailure>().having(
          (e) => e.code,
          'code',
          'AI_UNAVAILABLE',
        ),
      ),
    );
  });

  test('wraps a DioException as a NETWORK_ERROR failure', () async {
    when(
      () => remote.analyze(
        context: any(named: 'context'),
        fileUrls: any(named: 'fileUrls'),
      ),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/vet-document-analysis'),
        message: 'timeout',
      ),
    );

    await expectLater(
      () => repository.analyze(context: context, fileUrls: fileUrls),
      throwsA(
        isA<VetDocumentAnalysisFailure>().having(
          (e) => e.code,
          'code',
          'NETWORK_ERROR',
        ),
      ),
    );
  });
}
