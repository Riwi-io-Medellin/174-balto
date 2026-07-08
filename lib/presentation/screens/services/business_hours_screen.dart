import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/di/injection.dart';
import '../../../core/widgets/balto_toast.dart';
import '../../../domain/entities/business.dart';
import '../../../domain/repositories/business_repository.dart';

/// Lets a business owner configure their weekly opening hours, mirroring the
/// walker availability screen's interaction pattern (day rows + time chips),
/// but simplified to a single open/closed range per day since that's what
/// the BusinessHour backend model supports (no multiple intervals per day).
class BusinessHoursScreen extends StatefulWidget {
  const BusinessHoursScreen({super.key, required this.businessId});

  final String businessId;

  @override
  State<BusinessHoursScreen> createState() => _BusinessHoursScreenState();
}

class _DaySchedule {
  _DaySchedule({
    required this.isActive,
    required this.startTime,
    required this.endTime,
  });
  bool isActive;
  String startTime;
  String endTime;
}

class _BusinessHoursScreenState extends State<BusinessHoursScreen> {
  static const Color _accent = AppColors.navWalkers;
  static const Color _textDark = Color(0xFF1F2937);
  static const Color _textMuted = Color(0xFF8A93A0);

  static const _dayNames = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  final Map<int, _DaySchedule> _schedule = {
    for (var i = 0; i < 7; i++)
      i: _DaySchedule(isActive: false, startTime: '09:00', endTime: '17:00'),
  };

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final hours = await sl<BusinessRepository>().getBusinessHours(
        widget.businessId,
      );
      if (!mounted) return;
      setState(() {
        for (final h in hours) {
          if (h.dayOfWeek < 0 || h.dayOfWeek > 6) continue;
          _schedule[h.dayOfWeek] = _DaySchedule(
            isActive: h.isActive,
            startTime: h.startTime,
            endTime: h.endTime,
          );
        }
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      BaltoToast.error(context, 'Failed to load hours.');
    }
  }

  Future<void> _save() async {
    // Validate active days have a proper range; backend also requires
    // startTime < endTime even for inactive days, so defaults cover that.
    for (final entry in _schedule.entries) {
      final s = entry.value;
      if (_toMinutes(s.startTime) >= _toMinutes(s.endTime)) {
        BaltoToast.warning(
          context,
          '${_dayNames[entry.key]}: start time must be before end time.',
        );
        return;
      }
    }

    setState(() => _saving = true);
    try {
      final hours = _schedule.entries
          .map(
            (e) => BusinessHour(
              businessId: widget.businessId,
              dayOfWeek: e.key,
              startTime: e.value.startTime,
              endTime: e.value.endTime,
              isActive: e.value.isActive,
            ),
          )
          .toList();

      await sl<BusinessRepository>().updateMyHours(hours);

      if (!mounted) return;
      BaltoToast.success(context, 'Hours saved successfully.');
      Navigator.of(context).pop();
    } on BusinessFailure catch (e) {
      if (!mounted) return;
      BaltoToast.error(context, e.message);
    } catch (e) {
      if (!mounted) return;
      BaltoToast.error(context, 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  int _toMinutes(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) return 0;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    return h * 60 + m;
  }

  Future<void> _pickTime({
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: _textDark,
          ),
        ),
        title: Text(
          'Business Hours',
          style: AppTextStyles.h3.copyWith(color: _textDark),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saving || _loading ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _accent,
                    ),
                  ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _accent))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Weekly Schedule',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Turn on the days you\'re open and set your hours.',
                      style: TextStyle(fontSize: 13, color: _textMuted),
                    ),
                  ),
                  ...List.generate(7, (i) => _buildDayRow(i)),
                ],
              ),
            ),
    );
  }

  Widget _buildDayRow(int dayOfWeek) {
    final day = _schedule[dayOfWeek]!;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radius14,
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
                  color: _accent.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _dayNames[dayOfWeek].substring(0, 3),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: _accent,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _dayNames[dayOfWeek],
                  style: AppTextStyles.bodyBold.copyWith(color: _textDark),
                ),
              ),
              Switch(
                value: day.isActive,
                activeThumbColor: _accent,
                onChanged: (v) => setState(() => day.isActive = v),
              ),
            ],
          ),
          if (day.isActive) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTimeChip(
                    label: day.startTime,
                    onTap: () => _pickTime(
                      initial: day.startTime,
                      onPicked: (v) => setState(() => day.startTime = v),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '—',
                    style: TextStyle(
                      fontSize: 16,
                      color: _textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: _buildTimeChip(
                    label: day.endTime,
                    onTap: () => _pickTime(
                      initial: day.endTime,
                      onPicked: (v) => setState(() => day.endTime = v),
                    ),
                  ),
                ),
              ],
            ),
          ] else
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Closed',
                style: TextStyle(
                  fontSize: 13,
                  color: _textMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeChip({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: AppRadius.radius10,
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
                color: _textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
