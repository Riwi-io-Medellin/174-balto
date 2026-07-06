class PetClinicalMedication {
  const PetClinicalMedication({
    this.id,
    required this.name,
    this.dose,
    this.frequency,
    this.duration,
  });

  final String? id;
  final String name;
  final String? dose;
  final String? frequency;
  final String? duration;

  PetClinicalMedication copyWith({
    String? name,
    String? dose,
    String? frequency,
    String? duration,
  }) {
    return PetClinicalMedication(
      id: id,
      name: name ?? this.name,
      dose: dose ?? this.dose,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
    );
  }
}
