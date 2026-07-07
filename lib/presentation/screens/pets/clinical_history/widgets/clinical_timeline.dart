import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../domain/entities/pet_clinical_event.dart';

/// Timeline of clinical events (visit, vaccine, surgery, etc), rendered as a
/// sliver so a long history is built lazily instead of all at once — use it
/// directly inside a `CustomScrollView`'s `slivers`.
/// Each event is shown as a card with the essentials and a button
/// to expand all the details.
class ClinicalTimeline extends StatelessWidget {
  const ClinicalTimeline({super.key, required this.events});

  final List<PetClinicalEvent> events;

  IconData _iconFor(String type) {
    switch (type) {
      case PetClinicalEventType.vaccine:
        return Icons.vaccines_rounded;
      case PetClinicalEventType.surgery:
        return Icons.cut_rounded;
      case PetClinicalEventType.lab:
        return Icons.biotech_rounded;
      case PetClinicalEventType.hospitalization:
        return Icons.local_hospital_rounded;
      case PetClinicalEventType.deworming:
        return Icons.bug_report_outlined;
      case PetClinicalEventType.sterilization:
        return Icons.healing_rounded;
      case PetClinicalEventType.consultation:
        return Icons.event_note_rounded;
      default:
        return Icons.folder_shared_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE0E4EC)),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timeline_rounded, size: 40, color: Color(0xFFB0B8C1)),
              SizedBox(height: 10),
              Text(
                'No events recorded yet.',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    // `events` is expected to already be sorted newest-first by the caller
    // (sorted once when loaded, not re-sorted on every build).
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, i) => _TimelineEntry(
          event: events[i],
          icon: _iconFor(events[i].eventType),
          isLast: i == events.length - 1,
        ),
        childCount: events.length,
      ),
    );
  }
}

class _TimelineEntry extends StatefulWidget {
  const _TimelineEntry({
    required this.event,
    required this.icon,
    required this.isLast,
  });

  final PetClinicalEvent event;
  final IconData icon;
  final bool isLast;

  @override
  State<_TimelineEntry> createState() => _TimelineEntryState();
}

class _TimelineEntryState extends State<_TimelineEntry> {
  static const _accent = AppColors.petProfile;
  static const _textDark = Color(0xFF1A1A2E);
  static const _textMuted = Color(0xFF6B7280);

  bool _expanded = false;

  Widget _detailRow(String label, String? value) {
    if (value == null || value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _textMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 13, color: _textDark, height: 1.4),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.event;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, size: 17, color: _accent),
              ),
              if (!widget.isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: const Color(0xFFE0E4EC),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
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
                      Expanded(
                        child: Text(
                          PetClinicalEventType.label(e.eventType),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _textDark,
                          ),
                        ),
                      ),
                      Text(
                        '${e.eventDate.day}/${e.eventDate.month}/${e.eventDate.year}',
                        style: const TextStyle(fontSize: 12, color: _textMuted),
                      ),
                    ],
                  ),
                  if (e.veterinarianName != null || e.clinicName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      [
                        e.veterinarianName,
                        e.clinicName,
                      ].where((s) => s != null && s.isNotEmpty).join(' · '),
                      style: const TextStyle(fontSize: 12, color: _textMuted),
                    ),
                  ],
                  if (e.diagnosis != null && e.diagnosis!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      e.diagnosis!,
                      style: const TextStyle(fontSize: 13, color: _textDark),
                    ),
                  ],
                  if (_expanded) ...[
                    const Divider(height: 20, color: Color(0xFFE0E4EC)),
                    _detailRow('Reason', e.reason),
                    _detailRow('Clinical signs', e.clinicalSigns),
                    _detailRow('Findings', e.findings),
                    _detailRow('Exams performed', e.examsPerformed),
                    _detailRow('Results', e.examResults),
                    _detailRow('Procedures', e.procedures),
                    _detailRow('Recommendations', e.recommendations),
                    _detailRow('Observations', e.observations),
                    if (e.medications.isNotEmpty) ...[
                      const Text(
                        'Medications',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      for (final m in e.medications)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '• ${m.name}${m.dose != null ? ' — ${m.dose}' : ''}${m.frequency != null ? ' · ${m.frequency}' : ''}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: _textDark,
                            ),
                          ),
                        ),
                    ],
                    if (e.nextControlDate != null)
                      _detailRow(
                        'Next check-up',
                        '${e.nextControlDate!.day}/${e.nextControlDate!.month}/${e.nextControlDate!.year}',
                      ),
                  ],
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _expanded ? 'See less' : 'See details',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _accent,
                          ),
                        ),
                        Icon(
                          _expanded
                              ? Icons.expand_less_rounded
                              : Icons.expand_more_rounded,
                          size: 16,
                          color: _accent,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
