import 'package:equatable/equatable.dart';

class AvailableSlot extends Equatable {
  const AvailableSlot({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  @override
  List<Object?> get props => [start, end];
}
