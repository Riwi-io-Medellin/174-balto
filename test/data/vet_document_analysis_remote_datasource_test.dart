import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_pets/data/datasources/vet_document_analysis_remote_datasource.dart';
import 'package:mobile_pets/domain/entities/pet_health_context.dart';
import 'package:mobile_pets/domain/repositories/vet_document_analysis_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

Response<dynamic> _response(int status, dynamic data) => Response<dynamic>(
      data: data,
      statusCode: status,
      requestOptions: RequestOptions(path: '/vet-document-analysis'),
    );

void main() {
  late _MockDio dio;
  late VetDocumentAnalysisRemoteDataSource datasource;

  const context = PetHealthContext(petId: 'pet-1', name: 'Rocky', species: 'Dog', breed: 'Labrador');
  const fileUrls = ['https://cdn.example.com/report.jpg'];

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(Options());
  });

  setUp(() {
    dio = _MockDio();
    datasource = VetDocumentAnalysisRemoteDataSource(dio);
  });

  test('sends petContext and fileUrls in the request body', () async {
    when(() => dio.post<dynamic>(any(), data: any(named: 'data'), options: any(named: 'options'))).thenAnswer(
      (_) async => _response(200, {
        'summary': 's',
        'keyFindings': <String>[],
        'abnormalValues': <dynamic>[],
        'possibleConcerns': <String>[],
        'urgencyLevel': 'routine',
        'questionsForVet': <String>[],
        'missingInformation': <String>[],
        'disclaimer': 'd',
      }),
    );

    await datasource.analyze(context: context, fileUrls: fileUrls);

    final captured = verify(() => dio.post<dynamic>('/vet-document-analysis', data: captureAny(named: 'data'), options: any(named: 'options')))
        .captured
        .single as Map<String, dynamic>;

    expect(captured['fileUrls'], fileUrls);
    expect(captured['petId'], 'pet-1');
    expect(captured['petContext']['name'], 'Rocky');
    expect(captured['petContext']['species'], 'Dog');
    expect(captured['petContext']['breed'], 'Labrador');
  });

  test('parses a successful response into a VetDocumentAnalysisResult', () async {
    when(() => dio.post<dynamic>(any(), data: any(named: 'data'), options: any(named: 'options'))).thenAnswer(
      (_) async => _response(200, {
        'summary': 'All good.',
        'keyFindings': ['Finding A'],
        'abnormalValues': [
          {'label': 'WBC', 'value': '18', 'referenceRange': '6-17', 'interpretation': 'High'}
        ],
        'possibleConcerns': ['Mild infection'],
        'urgencyLevel': 'urgent',
        'questionsForVet': ['Is this serious?'],
        'missingInformation': ['Baseline history'],
        'disclaimer': 'Consult a vet.',
      }),
    );

    final result = await datasource.analyze(context: context, fileUrls: fileUrls);

    expect(result.summary, 'All good.');
    expect(result.keyFindings, ['Finding A']);
    expect(result.abnormalValues.single.label, 'WBC');
    expect(result.urgencyLevel.name, 'urgent');
    expect(result.disclaimer, 'Consult a vet.');
  });

  test('maps a 400 error body to a VetDocumentAnalysisFailure with the server code', () async {
    when(() => dio.post<dynamic>(any(), data: any(named: 'data'), options: any(named: 'options'))).thenAnswer(
      (_) async => _response(400, {'error': 'Pet name is required.', 'code': 'VALIDATION_FAILED'}),
    );

    await expectLater(
      () => datasource.analyze(context: context, fileUrls: fileUrls),
      throwsA(isA<VetDocumentAnalysisFailure>().having((e) => e.code, 'code', 'VALIDATION_FAILED')),
    );
  });

  test('maps a 503 with no structured body to AI_UNAVAILABLE', () async {
    when(() => dio.post<dynamic>(any(), data: any(named: 'data'), options: any(named: 'options'))).thenAnswer(
      (_) async => _response(503, null),
    );

    await expectLater(
      () => datasource.analyze(context: context, fileUrls: fileUrls),
      throwsA(isA<VetDocumentAnalysisFailure>().having((e) => e.code, 'code', 'AI_UNAVAILABLE')),
    );
  });

  test('maps a 502 with no structured body to AI_PARSE_ERROR', () async {
    when(() => dio.post<dynamic>(any(), data: any(named: 'data'), options: any(named: 'options'))).thenAnswer(
      (_) async => _response(502, null),
    );

    await expectLater(
      () => datasource.analyze(context: context, fileUrls: fileUrls),
      throwsA(isA<VetDocumentAnalysisFailure>().having((e) => e.code, 'code', 'AI_PARSE_ERROR')),
    );
  });
}
