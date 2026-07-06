import 'package:dio/dio.dart';

import '../../domain/entities/pet_clinical_draft.dart';
import '../../domain/entities/pet_clinical_event.dart';
import '../../domain/entities/pet_clinical_record.dart';
import '../../domain/repositories/pet_clinical_repository.dart';
import '../datasources/pet_clinical_remote_datasource.dart';
import '../models/pet_clinical_dtos.dart';

class PetClinicalRepositoryImpl implements PetClinicalRepository {
  PetClinicalRepositoryImpl(this._remote);

  final PetClinicalRemoteDataSource _remote;

  @override
  Future<String> registerSourceDocument({
    required String petId,
    required String fileUrl,
    required String fileName,
    required String fileType,
  }) async {
    try {
      return await _remote.registerDocument(
        petId,
        fileUrl: fileUrl,
        fileName: fileName,
        fileType: fileType,
      );
    } on PetClinicalFailure {
      rethrow;
    } on DioException catch (e) {
      throw PetClinicalFailure('NETWORK_ERROR', e.message ?? 'Could not reach the server.');
    }
  }

  @override
  Future<ClinicalExtractionDraft> runExtraction({
    required String petId,
    required List<String> documentIds,
  }) async {
    try {
      final json = await _remote.runExtraction(petId, documentIds);
      return ClinicalExtractionDraftDto.fromJson(json);
    } on PetClinicalFailure {
      rethrow;
    } on DioException catch (e) {
      throw PetClinicalFailure('NETWORK_ERROR', e.message ?? 'Could not reach the server.');
    }
  }

  @override
  Future<PetClinicalEvent> confirmEvent({
    required String petId,
    required ClinicalExtractionDraft draft,
  }) async {
    try {
      final json = await _remote.confirmEvent(
        petId,
        ClinicalExtractionDraftDto.toJson(draft),
      );
      return ClinicalEventResponseDto.fromJson(json);
    } on PetClinicalFailure {
      rethrow;
    } on DioException catch (e) {
      throw PetClinicalFailure('NETWORK_ERROR', e.message ?? 'Could not reach the server.');
    }
  }

  @override
  Future<PetClinicalRecord> getRecord(String petId) async {
    try {
      final json = await _remote.getRecord(petId);
      return ClinicalRecordResponseDto.fromJson(json);
    } on PetClinicalFailure {
      rethrow;
    } on DioException catch (e) {
      throw PetClinicalFailure('NETWORK_ERROR', e.message ?? 'Could not reach the server.');
    }
  }

  @override
  Future<List<PetClinicalTip>> getTips(String petId) async {
    try {
      final list = await _remote.getTips(petId);
      return list
          .map((t) => ClinicalTipResponseDto.fromJson(t as Map<String, dynamic>))
          .toList();
    } on PetClinicalFailure {
      rethrow;
    } on DioException catch (e) {
      throw PetClinicalFailure('NETWORK_ERROR', e.message ?? 'Could not reach the server.');
    }
  }
}
