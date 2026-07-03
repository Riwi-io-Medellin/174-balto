import 'package:equatable/equatable.dart';

/// A one-off override of the weekly schedule for a specific date
/// (e.g. holiday closure or special hours).
class BusinessHourException extends Equatable {
  const BusinessHourException({
    this.id = '',
    required this.businessId,
    required this.date,
    required this.isUnavailable,
    this.startTime,
    this.endTime,
  });

  final String id;
  final String businessId;
  final DateTime date;
  final bool isUnavailable;
  final String? startTime;
  final String? endTime;

  @override
  List<Object?> get props => [id, date, isUnavailable, startTime, endTime];
}
