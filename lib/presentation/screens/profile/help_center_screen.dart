import 'package:flutter/material.dart';

import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_text_styles.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const Color _bg = Color(0xFFF0F4F4);
  static const Color _textDark = Color(0xFF1A1A2E);
  static const Color _textMuted = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Help Center'),
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                _buildSection(
                  icon: Icons.person_outline,
                  iconBg: const Color(0xFFEAF2FB),
                  iconColor: const Color(0xFF3A80C2),
                  title: 'Your Profile',
                  description:
                      'Your Balto profile connects you to pet owners, walkers, and businesses. '
                      'Keep your information up to date to get the most out of the platform.',
                ),
                _divider(),
                _buildSection(
                  icon: Icons.pets_outlined,
                  iconBg: const Color(0xFFE8F5EE),
                  iconColor: const Color(0xFF1BAA71),
                  title: 'Pets & Their Profiles',
                  description:
                      'Manage your pets\' profiles with photos, medical history, and walking preferences. '
                      'Share the profile automatically when booking a walk.',
                ),
                _divider(),
                _buildSection(
                  icon: Icons.route_outlined,
                  iconBg: const Color(0xFFEEF0FF),
                  iconColor: const Color(0xFF5F36C2),
                  title: 'Walk Lifecycle',
                  description:
                      'From finding a walker to real-time GPS tracking and post-walk ratings, '
                      'every step is designed for a seamless experience.',
                ),
                _divider(),
                _buildSection(
                  icon: Icons.auto_awesome_outlined,
                  iconBg: const Color(0xFFFFF1E6),
                  iconColor: const Color(0xFFD05A24),
                  title: 'AI Coach',
                  description:
                      'Balto analyzes your pet\'s walking history to detect patterns, '
                      'suggest frequency adjustments, and alert you to inactivity.',
                ),
                _divider(),
                _buildSection(
                  icon: Icons.shield_outlined,
                  iconBg: const Color(0xFFEAF2FB),
                  iconColor: const Color(0xFF3A80C2),
                  title: 'Safety System',
                  description:
                      'Report lost or found pets, receive geographic notifications from '
                      'nearby users, and get help from the community.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: AppRadius.radius12,
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyStrong.copyWith(color: _textDark),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Divider(height: 1, color: Color(0xFFE0E4F0)),
    );
  }
}
