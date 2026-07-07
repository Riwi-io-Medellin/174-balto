import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/di/injection.dart';
import '../../domain/repositories/feedback_repository.dart';

class ReviewSheet extends StatefulWidget {
  const ReviewSheet({
    super.key,
    required this.targetId,
    required this.targetType,
    required this.targetName,
    this.title = 'Rate your experience',
    this.subtitle,
  });

  final String targetId;
  final String targetType;
  final String targetName;
  final String title;
  final String? subtitle;

  @override
  State<ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<ReviewSheet> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) return;
    setState(() => _isSubmitting = true);
    try {
      final repo = sl<FeedbackRepository>();
      final comment = _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim();
      switch (widget.targetType) {
        case 'walker':
          await repo.createWalkerReview(
            walkerId: widget.targetId,
            rating: _rating,
            comment: comment,
          );
        case 'home_service_provider':
          await repo.createHomeServiceProviderReview(
            providerId: widget.targetId,
            rating: _rating,
            comment: comment,
          );
        default:
          await repo.createBusinessReview(
            businessId: widget.targetId,
            rating: _rating,
            comment: comment,
          );
      }
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review submitted!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final displaySubtitle =
        widget.subtitle ?? 'How was your experience with ${widget.targetName}?';

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E4EC),
              borderRadius: AppRadius.radius2,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            displaySubtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF8A93A0),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final star = i + 1;
              return GestureDetector(
                onTap: () => setState(() => _rating = star),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    star <= _rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 44,
                    color: star <= _rating
                        ? const Color(0xFFF6C86A)
                        : const Color(0xFFE0E4EC),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _commentController,
            maxLines: 3,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'Share your experience (optional)',
              hintStyle: const TextStyle(color: Color(0xFFB0B8C1)),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: AppRadius.radius12,
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
              counterStyle: const TextStyle(
                fontSize: 11,
                color: Color(0xFFB0B8C1),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _rating > 0 && !_isSubmitting ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navWalkers,
                foregroundColor: Colors.white,
                elevation: 0,
                disabledBackgroundColor: const Color(0xFFE0E4EC),
                disabledForegroundColor: const Color(0xFFB0B8C1),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.radius12,
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Submit Review',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

void showReviewSheet({
  required BuildContext context,
  required String targetId,
  required String targetType,
  required String targetName,
  String title = 'Rate your experience',
  String? subtitle,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.r20)),
    ),
    builder: (_) => ReviewSheet(
      targetId: targetId,
      targetType: targetType,
      targetName: targetName,
      title: title,
      subtitle: subtitle,
    ),
  );
}
