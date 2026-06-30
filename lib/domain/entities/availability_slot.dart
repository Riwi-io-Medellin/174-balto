import 'package:equatable/equatable.dart';

class AvailabilitySlot extends Equatable {
  const AvailabilitySlot({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  /// 0 = Sunday, 1 = Monday, … 6 = Saturday
  final int dayOfWeek;
  final String startTime; // "HH:mm"
  final String endTime;   // "HH:mm"

  @override
  List<Object?> get props => [dayOfWeek, startTime, endTime];
}
