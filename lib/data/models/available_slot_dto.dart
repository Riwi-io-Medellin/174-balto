import '../../domain/entities/available_slot.dart';

class AvailableSlotDto {
  const AvailableSlotDto({required this.start, required this.end});

  factory AvailableSlotDto.fromJson(Map<String, dynamic> json) {
    return AvailableSlotDto(
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
    );
  }

  final DateTime start;
  final DateTime end;

  AvailableSlot toEntity() => AvailableSlot(start: start, end: end);

  static List<AvailableSlot> listToEntities(List<dynamic> json) => json
      .map((e) => AvailableSlotDto.fromJson(e as Map<String, dynamic>).toEntity())
      .toList();
}
