import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  static const Color _bg = Color(0xFFF0F4F4);
  static const Color _textDark = Color(0xFF1A1A2E);
  static const Color _textMuted = Color(0xFF6B7280);

  int _expandedIndex = -1;
  final List<ExpansibleController> _controllers = List.generate(
    8,
    (_) => ExpansibleController(),
  );

  void _onItemTap(int index) {
    HapticFeedback.lightImpact();
    final isExpanded = _expandedIndex == index;
    for (var i = 0; i < _controllers.length; i++) {
      if (i == index) {
        if (isExpanded) {
          _controllers[i].collapse();
        } else {
          _controllers[i].expand();
        }
      } else {
        _controllers[i].collapse();
      }
    }
    setState(() => _expandedIndex = isExpanded ? -1 : index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('FAQs'),
        backgroundColor: Colors.white,
        foregroundColor: _textDark,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.radius20,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildFaqItem(
                  index: 0,
                  question: 'The GPS map is not updating',
                  answer:
                      'Make sure location services are enabled on your device. '
                      'If the issue persists, try closing and reopening the walk session.',
                ),
                _divider(),
                _buildFaqItem(
                  index: 1,
                  question: 'I can\'t cancel a scheduled walk',
                  answer:
                      'Cancellations are allowed up to 1 hour before the start time. '
                      'If the option is disabled, contact the walker directly through the app.',
                ),
                _divider(),
                _buildFaqItem(
                  index: 2,
                  question: 'My walker didn\'t show up',
                  answer:
                      'Wait 15 minutes past the scheduled time, then cancel the walk. '
                      'You can report the no-show in the walk history for follow-up.',
                ),
                _divider(),
                _buildFaqItem(
                  index: 3,
                  question: 'I can\'t rate my last walk',
                  answer:
                      'Ratings are available immediately after the walk ends and within 48 hours. '
                      'If the window has expired, contact support for assistance.',
                ),
                _divider(),
                _buildFaqItem(
                  index: 4,
                  question: 'My notifications aren\'t working',
                  answer:
                      'Check that notifications are enabled in your device settings '
                      'and in the Privacy Settings screen within the app.',
                ),
                _divider(),
                _buildFaqItem(
                  index: 5,
                  question: 'I forgot my password',
                  answer:
                      'Use the "Forgot Password" option on the login screen '
                      'to reset it via your registered email address.',
                ),
                _divider(),
                _buildFaqItem(
                  index: 6,
                  question: 'The app is crashing on startup',
                  answer:
                      'Make sure you\'re on the latest version of the app. '
                      'Try clearing the app cache or reinstalling if the problem continues.',
                ),
                _divider(),
                _buildFaqItem(
                  index: 7,
                  question: 'I was charged incorrectly',
                  answer:
                      'Check the walk details in your history. If the amount doesn\'t match, '
                      'contact support with the walk ID for assistance.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem({
    required int index,
    required String question,
    required String answer,
  }) {
    final isExpanded = _expandedIndex == index;
    return ExpansionTile(
      controller: _controllers[index],
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(left: 56, right: 4, bottom: 12),
      shape: const Border(),
      collapsedShape: const Border(),
      trailing: const SizedBox.shrink(),
      onExpansionChanged: (_) => _onItemTap(index),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.navWalks.withValues(alpha: 0.1),
          borderRadius: AppRadius.radius12,
        ),
        child: const Icon(
          Icons.help_outline,
          size: 20,
          color: AppColors.navWalks,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              question,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _textDark,
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedRotation(
            turns: isExpanded ? 0.5 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(
              Icons.expand_more,
              size: 20,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
      children: [
        Text(
          answer,
          style: const TextStyle(fontSize: 13, color: _textMuted, height: 1.4),
        ),
      ],
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Divider(height: 1, color: Color(0xFFE0E4F0)),
    );
  }
}
