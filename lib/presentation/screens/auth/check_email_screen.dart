import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';

class CheckEmailScreen extends StatelessWidget {
  const CheckEmailScreen({super.key, required this.email});

  final String email;

  static const Color _bg = Color(0xFFF0F4F4);
  static const Color _textDark = Color(0xFF1A1A2E);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _textLight = Color(0xFF9AA0B2);
  static const Color _success = Color(0xFF1BAA71);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              _buildLogo(),
              const SizedBox(height: 32),
              _buildCard(context),
              const SizedBox(height: 28),
              _buildFooter(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: AppRadius.radius14,
          child: Image.asset(
            'assets/icon/app_icon.png',
            width: 54,
            height: 54,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Balto',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.navWalks,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: _heroIcon()),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Check Your\nEmail',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _textDark,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  color: _textMuted,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: "We've sent a reset link to "),
                  TextSpan(
                    text: email,
                    style: const TextStyle(
                      color: _textDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(
                    text: ". Open it from your inbox to set a new password.",
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          _openMailButton(),
          const SizedBox(height: 12),
          _backToSignInButton(context),
          const SizedBox(height: 20),
          _resendRow(),
        ],
      ),
    );
  }

  Widget _heroIcon() {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: AppColors.navWalks.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mark_email_read_outlined,
                color: AppColors.navWalks,
                size: 56,
              ),
            ),
          ),
          Positioned(
            right: 4,
            bottom: 10,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.check_circle, color: _success, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _openMailButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navWalks,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radius14),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mail_outline, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              'Open Mail App',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _backToSignInButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: () =>
            Navigator.of(context).popUntil((route) => route.isFirst),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radius14),
          side: const BorderSide(color: AppColors.navWalks, width: 1.5),
          backgroundColor: Colors.white,
        ),
        child: const Text(
          'Back to Sign In',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.navWalks,
          ),
        ),
      ),
    );
  }

  Widget _resendRow() {
    return Center(
      child: RichText(
        text: const TextSpan(
          text: "Didn't receive the email? ",
          style: TextStyle(fontSize: 14, color: Color(0xFF4A4A6A)),
          children: [
            TextSpan(
              text: 'Resend',
              style: TextStyle(
                color: AppColors.navWalks,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _footerLink('Privacy Policy'),
            _footerSeparator(),
            _footerLink('Terms of Service'),
            _footerSeparator(),
            _footerLink('Help Center'),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          '© 2026 Balto Inc. Secure Recovery',
          style: TextStyle(fontSize: 11, color: _textLight),
        ),
      ],
    );
  }

  Widget _footerSeparator() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text('·', style: TextStyle(color: _textLight, fontSize: 11)),
    );
  }

  Widget _footerLink(String text) {
    return GestureDetector(
      onTap: () {},
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, color: _textLight),
      ),
    );
  }
}
