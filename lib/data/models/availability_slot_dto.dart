import '../../domain/entities/availability_slot.dart';

class AvailabilitySlotDto {
  const AvailabilitySlotDto({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  factory AvailabilitySlotDto.fromJson(Map<String, dynamic> json) {
    return AvailabilitySlotDto(
      dayOfWeek: json['dayOfWeek'] as int,
      startTime: _normalizeTime(json['startTime'] as String),
      endTime: _normalizeTime(json['endTime'] as String),
    );
  }

  static List<AvailabilitySlotDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((e) => AvailabilitySlotDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  final int dayOfWeek;
  final String startTime;
  final String endTime;

  Map<String, dynamic> toJson() => {
        'dayOfWeek': dayOfWeek,
        'startTime': startTime,
        'endTime': endTime,
      };

  AvailabilitySlot toEntity() => AvailabilitySlot(
        dayOfWeek: dayOfWeek,
        startTime: startTime,
        endTime: endTime,
      );

  /// Strips seconds from "HH:mm:ss" → "HH:mm".
  static String _normalizeTime(String time) {
    if (time.length > 5) return time.substring(0, 5);
    return time;
  }
}
