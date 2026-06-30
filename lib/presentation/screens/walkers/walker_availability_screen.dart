import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/widgets/balto_toast.dart';
import '../../../domain/entities/availability_exception.dart';
import '../../../domain/entities/availability_slot.dart';
import '../../../domain/repositories/walker_availability_repository.dart';
import '../../bloc/walker_availability/walker_availability_cubit.dart';
import '../../bloc/walker_availability/walker_availability_state.dart';

class WalkerAvailabilityScreen extends StatefulWidget {
  const WalkerAvailabilityScreen({super.key});

  @override
  State<WalkerAvailabilityScreen> createState() =>
      _WalkerAvailabilityScreenState();
}

class _TimeRange {
  _TimeRange({required this.startTime, required this.endTime});
  String startTime;
  String endTime;
}

class _ExceptionEntry {
  _ExceptionEntry({
    required this.date,
    required this.isUnavailable,
    this.startTime,
    this.endTime,
  });
  String date;
  bool isUnavailable;
  String? startTime;
  String? endTime;
}

class _WalkerAvailabilityScreenState extends State<WalkerAvailabilityScreen> {
  final _cubit = sl<WalkerAvailabilityCubit>();

  final _dayNames = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  /// Local editing state: dayOfWeek → list of intervals
  Map<int, List<_TimeRange>> _weeklySchedule = {};
  List<_ExceptionEntry> _exceptions = [];
  bool _initialized = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _cubit.load();
  }

  void _onState(BuildContext context, WalkerAvailabilityState state) {
    if (state is WalkerAvailabilityLoaded && !_initialized) {
      final schedule = <int, List<_TimeRange>>{};
      for (final slot in state.slots) {
        schedule.putIfAbsent(slot.dayOfWeek, () => []);
        schedule[slot.dayOfWeek]!.add(_TimeRange(
          startTime: slot.startTime,
          endTime: slot.endTime,
        ));
      }
      setState(() {
        _weeklySchedule = schedule;
        _exceptions = state.exceptions
            .map((e) => _ExceptionEntry(
                  date: e.date,
                  isUnavailable: e.isUnavailable,
                  startTime: e.startTime,
                  endTime: e.endTime,
                ))
            .toList();
        _initialized = true;
      });
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      // Validate and build slots
      final slots = <AvailabilitySlot>[];
      for (final entry in _weeklySchedule.entries) {
        for (final interval in entry.value) {
          if (interval.startTime.isEmpty || interval.endTime.isEmpty) continue;
          slots.add(AvailabilitySlot(
            dayOfWeek: entry.key,
            startTime: interval.startTime,
            endTime: interval.endTime,
          ));
        }
      }

      // Validate and build exceptions
      final exceptions = <AvailabilityException>[];
      for (final ex in _exceptions) {
        if (!ex.isUnavailable &&
            (ex.startTime == null || ex.endTime == null)) {
          if (!mounted) return;
          BaltoToast.warning(
            context,
            'Custom hours require both start and end time for ${ex.date}.',
          );
          setState(() => _saving = false);
          return;
        }
        exceptions.add(AvailabilityException(
          date: ex.date,
          isUnavailable: ex.isUnavailable,
          startTime: ex.startTime,
          endTime: ex.endTime,
        ));
      }

      await sl<WalkerAvailabilityRepository>().replaceMyAvailability(slots);
      await sl<WalkerAvailabilityRepository>().replaceMyExceptions(exceptions);
      await _cubit.load();

      if (!mounted) return;
      BaltoToast.success(context, 'Availability saved successfully.');
      Navigator.of(context).pop();
    } on WalkerAvailabilityFailure catch (e) {
      if (!mounted) return;
      BaltoToast.error(context, e.message);
    } catch (e) {
      if (!mounted) return;
      BaltoToast.error(context, 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickTime({
    required String label,
    required String initial,
    required ValueChanged<String> onPicked,
  }) async {
    final parts = initial.split(':');
    final initialTime = TimeOfDay(
      hour: parts.length == 2 ? int.tryParse(parts[0]) ?? 9 : 9,
      minute: parts.length == 2 ? int.tryParse(parts[1]) ?? 0 : 0,
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) {
      onPicked(
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
      );
    }
  }

  Future<void> _pickDate({
    required ValueChanged<String> onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      final y = picked.year.toString();
      final m = picked.month.toString().padLeft(2, '0');
      final d = picked.day.toString().padLeft(2, '0');
      onPicked('$y-$m-$d');
    }
  }

  void _addInterval(int dayOfWeek) {
    setState(() {
      _weeklySchedule.putIfAbsent(dayOfWeek, () => []);
      _weeklySchedule[dayOfWeek]!.add(_TimeRange(
        startTime: '09:00',
        endTime: '17:00',
      ));
    });
  }

  void _removeInterval(int dayOfWeek, int index) {
    setState(() {
      _weeklySchedule[dayOfWeek]!.removeAt(index);
      if (_weeklySchedule[dayOfWeek]!.isEmpty) {
        _weeklySchedule.remove(dayOfWeek);
      }
    });
  }

  void _addException() {
    _pickDate(
      onPicked: (date) {
        if (_exceptions.any((e) => e.date == date)) {
          BaltoToast.warning(context, 'This date already has an exception.');
          return;
        }
        setState(() {
          _exceptions.add(_ExceptionEntry(
            date: date,
            isUnavailable: true,
          ));
        });
      },
    );
  }

  void _removeException(int index) {
    setState(() => _exceptions.removeAt(index));
  }

  String _formatDate(String isoDate) {
    final parts = isoDate.split('-');
    if (parts.length != 3) return isoDate;
    final month = int.tryParse(parts[1]) ?? 1;
    final day = int.tryParse(parts[2]) ?? 1;
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[month - 1]} $day, ${parts[0]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Color(0xFF1F2937),
          ),
        ),
        title: const Text(
          'Manage Availability',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saving || !_initialized ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navWalkers,
                    ),
                  ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: BlocConsumer<WalkerAvailabilityCubit, WalkerAvailabilityState>(
        bloc: _cubit,
        listener: _onState,
        builder: (context, state) {
          if (state is WalkerAvailabilityLoading && !_initialized) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is WalkerAvailabilityError && !_initialized) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: Color(0xFF8A93A0),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF5A6473),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => _cubit.load(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navWalkers,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          return _buildForm();
        },
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Weekly Schedule'),
          const SizedBox(height: 16),
          ...List.generate(7, (i) => _buildDaySection(i)),
          const SizedBox(height: 32),
          _buildSectionTitle('Date Exceptions'),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Override your regular schedule for specific dates.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF5A6473),
              ),
            ),
          ),
          if (_exceptions.isEmpty)
            _buildEmptyExceptions()
          else
            ..._exceptions.asMap().entries.map(
                  (entry) => _buildExceptionCard(entry.key, entry.value),
                ),
          const SizedBox(height: 12),
          _buildAddExceptionButton(),
        ],
      ),
    );
  }

  Widget _buildDaySection(int dayOfWeek) {
    final intervals = _weeklySchedule[dayOfWeek] ?? [];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E4EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.navWalkers.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _dayNames[dayOfWeek].substring(0, 3),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navWalkers,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _dayNames[dayOfWeek],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              const Spacer(),
              if (intervals.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    setState(() => _weeklySchedule.remove(dayOfWeek));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0ED),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD05A24),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (intervals.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'No hours set',
                style: TextStyle(
                  fontSize: 13,
                  color: const Color(0xFF8A93A0),
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ...intervals.asMap().entries.map(
                  (entry) => _buildIntervalRow(dayOfWeek, entry.key, entry.value),
                ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => _addInterval(dayOfWeek),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add Interval'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.navWalkers,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: AppColors.navWalkers.withValues(alpha: 0.30),
                    style: BorderStyle.solid,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntervalRow(int dayOfWeek, int index, _TimeRange interval) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Expanded(
            child: _buildTimeChip(
              label: interval.startTime,
              onTap: () => _pickTime(
                label: 'Start time',
                initial: interval.startTime,
                onPicked: (v) {
                  setState(() => interval.startTime = v);
                },
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '—',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF8A93A0),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: _buildTimeChip(
              label: interval.endTime,
              onTap: () => _pickTime(
                label: 'End time',
                initial: interval.endTime,
                onPicked: (v) {
                  setState(() => interval.endTime = v);
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _removeInterval(dayOfWeek, index),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0ED),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 16,
                color: Color(0xFFD05A24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeChip({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6FA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE0E4EC)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.schedule_rounded,
              size: 14,
              color: Color(0xFF5A6473),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Exceptions Section ────────────────────────────────────────────────────

  Widget _buildEmptyExceptions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E4EC)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 36,
            color: Color(0xFFB0B8C1),
          ),
          SizedBox(height: 8),
          Text(
            'No exceptions yet',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF8A93A0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExceptionCard(int index, _ExceptionEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E4EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: entry.isUnavailable
                      ? const Color(0xFFFFF0ED)
                      : AppColors.navWalkers.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  entry.isUnavailable
                      ? Icons.block_rounded
                      : Icons.edit_calendar_rounded,
                  size: 18,
                  color: entry.isUnavailable
                      ? const Color(0xFFD05A24)
                      : AppColors.navWalkers,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _formatDate(entry.date),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _removeException(index),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0ED),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: Color(0xFFD05A24),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => entry.isUnavailable = !entry.isUnavailable);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: entry.isUnavailable
                          ? const Color(0xFFFFF0ED)
                          : const Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: entry.isUnavailable
                            ? const Color(0xFFD05A24).withValues(alpha: 0.30)
                            : const Color(0xFFE0E4EC),
                      ),
                    ),
                    child: Text(
                      entry.isUnavailable ? 'Unavailable' : 'Custom hours',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: entry.isUnavailable
                            ? const Color(0xFFD05A24)
                            : const Color(0xFF1F2937),
                      ),
                    ),
                  ),
                ),
              ),
              if (!entry.isUnavailable) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTimeChip(
                    label: entry.startTime ?? '09:00',
                    onTap: () => _pickTime(
                      label: 'Start time',
                      initial: entry.startTime ?? '09:00',
                      onPicked: (v) {
                        setState(() => entry.startTime = v);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildTimeChip(
                    label: entry.endTime ?? '17:00',
                    onTap: () => _pickTime(
                      label: 'End time',
                      initial: entry.endTime ?? '17:00',
                      onPicked: (v) {
                        setState(() => entry.endTime = v);
                      },
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddExceptionButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _addException,
        icon: const Icon(Icons.add_rounded, size: 16),
        label: const Text('Add Exception'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navWalkers,
          side: BorderSide(
            color: AppColors.navWalkers.withValues(alpha: 0.30),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1F2937),
      ),
    );
  }
}
