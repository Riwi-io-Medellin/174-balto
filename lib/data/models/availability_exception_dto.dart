import '../../domain/entities/availability_exception.dart';

class AvailabilityExceptionDto {
  const AvailabilityExceptionDto({
    required this.date,
    required this.isUnavailable,
    this.startTime,
    this.endTime,
  });

  factory AvailabilityExceptionDto.fromJson(Map<String, dynamic> json) {
    return AvailabilityExceptionDto(
      date: json['date'] as String,
      isUnavailable: json['isUnavailable'] as bool,
      startTime: _normalizeTime(json['startTime'] as String?),
      endTime: _normalizeTime(json['endTime'] as String?),
    );
  }

  static List<AvailabilityExceptionDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((e) =>
            AvailabilityExceptionDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  final String date;
  final bool isUnavailable;
  final String? startTime;
  final String? endTime;

  Map<String, dynamic> toJson() => {
        'date': date,
        'isUnavailable': isUnavailable,
        if (startTime != null) 'startTime': startTime,
        if (endTime != null) 'endTime': endTime,
      };

  AvailabilityException toEntity() => AvailabilityException(
        date: date,
        isUnavailable: isUnavailable,
        startTime: startTime,
        endTime: endTime,
      );

  static String? _normalizeTime(String? time) {
    if (time == null) return null;
    if (time.length > 5) return time.substring(0, 5);
    return time;
  }
}
