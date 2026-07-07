import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../domain/entities/coach_message.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message});

  final CoachMessage message;

  @override
  Widget build(BuildContext context) {
    return message.role == CoachRole.user
        ? _UserBubble(content: message.content)
        : _AssistantBubble(content: message.content);
  }
}

// ── User bubble ────────────────────────────────────────────────
class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.content});
  final String content;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        margin: const EdgeInsets.only(top: 6, bottom: 6, left: 64),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.navCoach,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppRadius.r18),
            topRight: Radius.circular(AppRadius.r18),
            bottomLeft: Radius.circular(AppRadius.r18),
            bottomRight: Radius.circular(AppRadius.r4),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.navCoach.withValues(alpha: 0.30),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          content,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            height: 1.45,
          ),
        ),
      ),
    );
  }
}

// ── Assistant bubble ───────────────────────────────────────────
class _AssistantBubble extends StatelessWidget {
  const _AssistantBubble({required this.content});
  final String content;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        margin: const EdgeInsets.only(top: 6, bottom: 6, right: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppRadius.r4),
            topRight: Radius.circular(AppRadius.r18),
            bottomLeft: Radius.circular(AppRadius.r18),
            bottomRight: Radius.circular(AppRadius.r18),
          ),
          border: Border.all(
            color: AppColors.navCoach.withValues(alpha: 0.25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header strip
            Container(
              decoration: BoxDecoration(
                color: AppColors.navCoach.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.r4),
                  topRight: Radius.circular(AppRadius.r18),
                ),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 13,
                    color: AppColors.navCoach,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Balto Coach',
                    style: AppTextStyles.micro.copyWith(
                      color: AppColors.navCoach,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            // Body
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Text(
                content,
                style: const TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 15,
                  height: 1.55,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Typing indicator ───────────────────────────────────────────
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 6, bottom: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppRadius.r4),
            topRight: Radius.circular(AppRadius.r18),
            bottomLeft: Radius.circular(AppRadius.r18),
            bottomRight: Radius.circular(AppRadius.r18),
          ),
          border: Border.all(
            color: AppColors.navCoach.withValues(alpha: 0.25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.navCoach.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.r4),
                  topRight: Radius.circular(AppRadius.r18),
                ),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome_rounded,
                      size: 13, color: AppColors.navCoach),
                  const SizedBox(width: 5),
                  Text(
                    'Balto Coach',
                    style: AppTextStyles.micro.copyWith(
                      color: AppColors.navCoach,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (_, child) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (i) {
                      final t = (_ctrl.value + i / 3) % 1.0;
                      final opacity =
                          (0.25 + 0.75 * (t < 0.5 ? t * 2 : (1.0 - t) * 2))
                              .clamp(0.0, 1.0);
                      final yOffset =
                          -3.0 * (t < 0.5 ? t * 2 : (1.0 - t) * 2);
                      return Transform.translate(
                        offset: Offset(0, yOffset),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.navCoach.withValues(alpha: opacity),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
