import '../../domain/entities/pet_health_context.dart';

class PickedFileInfo {
  const PickedFileInfo({
    required this.path,
    required this.name,
    required this.sizeBytes,
  });

  final String path;
  final String name;
  final int sizeBytes;

  String get extension {
    final dot = name.lastIndexOf('.');
    return dot == -1 ? '' : name.substring(dot + 1).toLowerCase();
  }
}

class VetDocumentValidationResult {
  const VetDocumentValidationResult.valid() : error = null;
  const VetDocumentValidationResult.invalid(String message) : error = message;

  final String? error;

  bool get isValid => error == null;
}

const List<String> supportedVetDocumentExtensions = [
  'pdf',
  'jpg',
  'jpeg',
  'png',
  'webp',
  'gif',
];

const int maxVetDocumentCount = 5;
const int maxVetDocumentSizeBytes = 10 * 1024 * 1024; // 10 MB, matches backend /api/upload cap

const List<String> knownPetSpecies = ['dog', 'cat', 'bird', 'rabbit', 'other'];

VetDocumentValidationResult validateFiles(List<PickedFileInfo> files) {
  if (files.isEmpty) {
    return const VetDocumentValidationResult.invalid(
      'Please add at least one document (PDF or image).',
    );
  }
  if (files.length > maxVetDocumentCount) {
    return VetDocumentValidationResult.invalid(
      'You can attach up to $maxVetDocumentCount files.',
    );
  }
  for (final file in files) {
    if (!supportedVetDocumentExtensions.contains(file.extension)) {
      return VetDocumentValidationResult.invalid(
        '"${file.name}" is not a supported file type. Allowed: ${supportedVetDocumentExtensions.join(', ')}.',
      );
    }
    if (file.sizeBytes > maxVetDocumentSizeBytes) {
      return VetDocumentValidationResult.invalid(
        '"${file.name}" exceeds the 10MB size limit.',
      );
    }
  }
  return const VetDocumentValidationResult.valid();
}

VetDocumentValidationResult validatePetContext(PetHealthContext context) {
  if (context.name.trim().isEmpty) {
    return const VetDocumentValidationResult.invalid('Pet name is required.');
  }
  if (context.species.trim().isEmpty) {
    return const VetDocumentValidationResult.invalid('Species is required.');
  }
  return const VetDocumentValidationResult.valid();
}
