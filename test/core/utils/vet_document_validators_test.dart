import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_pets/core/utils/vet_document_validators.dart';
import 'package:mobile_pets/domain/entities/pet_health_context.dart';

void main() {
  group('validateFiles', () {
    test('rejects an empty file list', () {
      final result = validateFiles([]);
      expect(result.isValid, isFalse);
      expect(result.error, contains('at least one document'));
    });

    test('rejects more than the maximum allowed files', () {
      final files = List.generate(
        maxVetDocumentCount + 1,
        (i) => PickedFileInfo(path: 'p$i.jpg', name: 'p$i.jpg', sizeBytes: 100),
      );
      final result = validateFiles(files);
      expect(result.isValid, isFalse);
      expect(result.error, contains('up to $maxVetDocumentCount'));
    });

    test('rejects an unsupported file extension', () {
      final result = validateFiles([
        const PickedFileInfo(path: 'doc.docx', name: 'doc.docx', sizeBytes: 100),
      ]);
      expect(result.isValid, isFalse);
      expect(result.error, contains('not a supported file type'));
    });

    test('rejects a file over the size cap', () {
      final result = validateFiles([
        PickedFileInfo(
          path: 'big.pdf',
          name: 'big.pdf',
          sizeBytes: maxVetDocumentSizeBytes + 1,
        ),
      ]);
      expect(result.isValid, isFalse);
      expect(result.error, contains('10MB'));
    });

    test('accepts a valid list of supported files', () {
      final result = validateFiles([
        const PickedFileInfo(path: 'report.pdf', name: 'report.pdf', sizeBytes: 1024),
        const PickedFileInfo(path: 'scan.jpg', name: 'scan.jpg', sizeBytes: 2048),
      ]);
      expect(result.isValid, isTrue);
    });
  });

  group('validatePetContext', () {
    test('rejects an empty name', () {
      const context = PetHealthContext(petId: 'pet-1', name: '  ', species: 'Dog');
      final result = validatePetContext(context);
      expect(result.isValid, isFalse);
      expect(result.error, contains('name'));
    });

    test('rejects an empty species', () {
      const context = PetHealthContext(petId: 'pet-1', name: 'Rocky', species: '');
      final result = validatePetContext(context);
      expect(result.isValid, isFalse);
      expect(result.error, contains('Species'));
    });

    test('accepts a valid pet context', () {
      const context = PetHealthContext(petId: 'pet-1', name: 'Rocky', species: 'Dog');
      final result = validatePetContext(context);
      expect(result.isValid, isTrue);
    });
  });
}
