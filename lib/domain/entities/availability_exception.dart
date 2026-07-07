import 'package:equatable/equatable.dart';

class AvailabilityException extends Equatable {
  const AvailabilityException({
    required this.date,
    required this.isUnavailable,
    this.startTime,
    this.endTime,
  });

  final String date; // "yyyy-MM-dd"
  final bool isUnavailable;
  final String? startTime; // "HH:mm" when isUnavailable is false
  final String? endTime; // "HH:mm" when isUnavailable is false

  @override
  List<Object?> get props => [date, isUnavailable, startTime, endTime];
}
