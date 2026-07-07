import 'package:flutter/material.dart';

import '../../../../domain/entities/vet_document_analysis.dart';
import 'urgency_badge.dart';

class AnalysisResultView extends StatelessWidget {
  const AnalysisResultView({super.key, required this.result});

  final VetDocumentAnalysisResult result;

  static const Color _textDark = Color(0xFF1A1A2E);
  static const Color _textMuted = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
            UrgencyBadge(urgencyLevel: result.urgencyLevel),
          ],
        ),
        const SizedBox(height: 10),
        _card(
          child: Text(
            result.summary,
            style: const TextStyle(fontSize: 14, color: _textDark, height: 1.5),
          ),
        ),
        if (result.keyFindings.isNotEmpty) ...[
          const SizedBox(height: 20),
          _sectionTitle('Key Findings'),
          const SizedBox(height: 8),
          _bulletList(result.keyFindings),
        ],
        if (result.abnormalValues.isNotEmpty) ...[
          const SizedBox(height: 20),
          _sectionTitle('Abnormal / Notable Values'),
          const SizedBox(height: 8),
          ...result.abnormalValues.map(
            (v) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            v.label,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: _textDark,
                            ),
                          ),
                        ),
                        Text(
                          v.value,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: _textDark,
                          ),
                        ),
                      ],
                    ),
                    if (v.referenceRange != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Reference range: ${v.referenceRange}',
                        style: const TextStyle(fontSize: 12, color: _textMuted),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      v.interpretation,
                      style: const TextStyle(fontSize: 13, color: _textDark),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        if (result.possibleConcerns.isNotEmpty) ...[
          const SizedBox(height: 20),
          _sectionTitle('Possible Concerns'),
          const SizedBox(height: 8),
          _bulletList(result.possibleConcerns),
        ],
        if (result.questionsForVet.isNotEmpty) ...[
          const SizedBox(height: 20),
          _sectionTitle('Questions to Ask Your Veterinarian'),
          const SizedBox(height: 8),
          _bulletList(result.questionsForVet),
        ],
        if (result.missingInformation.isNotEmpty) ...[
          const SizedBox(height: 20),
          _sectionTitle('Missing Information'),
          const SizedBox(height: 8),
          _bulletList(result.missingInformation),
        ],
        const SizedBox(height: 24),
        _disclaimer(result.disclaimer),
      ],
    );
  }

  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: _textDark,
    ),
  );

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE5E7EB)),
    ),
    child: child,
  );

  Widget _bulletList(List<String> items) => _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '•  ',
                    style: TextStyle(
                      color: _textDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 14,
                        color: _textDark,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    ),
  );

  Widget _disclaimer(String text) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF3CD),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE8A84C).withValues(alpha: 0.5)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.info_outline_rounded,
          size: 18,
          color: Color(0xFFB07D00),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF6B4E00),
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );
}
