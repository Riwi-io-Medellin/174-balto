import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../domain/entities/pet.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../bloc/profile/profile_cubit.dart';
import '../../bloc/profile/profile_state.dart';
import '../auth/login_screen.dart';
import '../../screens/pets/create_pet_screen.dart';
import '../../screens/pets/pet_detail_screen.dart';
import 'edit_profile_screen.dart';
import 'privacy_settings_screen.dart';
import 'profile_settings_screen.dart';
import 'support_screen.dart';
import '../../../domain/entities/walker_profile.dart';
import '../walkers/become_walker_screen.dart';
import '../walkers/edit_walker_profile_screen.dart';
import '../walkers/walker_availability_screen.dart';
import '../walkers/walker_bookings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileCubit>(
      create: (_) => sl<ProfileCubit>()..load(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  bool _twoFactor = true;

  static const Color _textDark = Color(0xFF1F2937);
  static const Color _textMid = Color(0xFF5A6473);
  static const Color _textMuted = Color(0xFF8A93A0);
  static const Color _textSection = Color(0xFF9AA2AE);

  static const Color _blue = Color(0xFF3A80C2);
  static const Color _green = Color(0xFF1BAA71);
  static const Color _purple = Color(0xFF5F36C2);
  static const Color _orange = Color(0xFFD05A24);
  static const Color _red = Color(0xFFE5544B);
  static const Color _gold = Color(0xFFF6C86A);
  static const Color _goldText = Color(0xFFA8791F);
  static const Color _indigo = Color(0xFF5563E0);

  static const Color _bgBlueTint = Color(0xFFEAF2FB);
  static const Color _bgGreenTint = Color(0xFFE8F5EE);
  static const Color _bgPurpleTint = Color(0xFFEEF0FF);
  static const Color _bgOrangeTint = Color(0xFFFFF1E6);
  static const Color _bgGoldTint = Color(0xFFFBF6E9);
  static const Color _bgAddPet = Color(0xFFFFF6E9);
  static const Color _addPetBorder = Color(0xFFF1C97A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE7EAFF),
              Color(0xFFEDF0FB),
              Color(0xFFF4F6FA),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildIdentityRowFromState(),
                  const SizedBox(height: 18),
                  _buildStatsCard(),
                  const SizedBox(height: 18),
                  _buildQuickActions(),
                  const SizedBox(height: 22),
                  _buildWalkerSection(),
                  const SizedBox(height: 18),
                  _buildMyPets(),
                  const SizedBox(height: 18),
                  _buildPersonalInformationFromState(),
                  const SizedBox(height: 18),
                  _buildSectionTitle('PREFERENCES'),
                  const SizedBox(height: 8),
                  _buildListCard([
                    _buildIconRow(
                      icon: Icons.person_outline,
                      iconBgColor: _bgBlueTint,
                      iconColor: _blue,
                      title: 'Preferred Walker Gender',
                      trailingValue: 'No preference',
                    ),
                    _divider(),
                    _buildIconRow(
                      icon: Icons.directions_walk,
                      iconBgColor: _bgGreenTint,
                      iconColor: _green,
                      title: 'Walking Preferences',
                      trailingValue: 'Mornings',
                    ),
                    _divider(),
                    _buildIconRow(
                      icon: Icons.shield_outlined,
                      iconBgColor: _bgGoldTint,
                      iconColor: _gold,
                      title: 'Emergency Contacts',
                      trailingValue: '2 added',
                    ),
                  ]),
                  const SizedBox(height: 18),
                  _buildSectionTitle('PRIVACY & SECURITY'),
                  const SizedBox(height: 8),
                  _buildListCard([
                    _buildIconRow(
                      icon: Icons.lock_outline,
                      iconBgColor: _bgBlueTint,
                      iconColor: _blue,
                      title: 'Change Password',
                    ),
                    _divider(),
                    _buildIconRow(
                      icon: Icons.verified_user_outlined,
                      iconBgColor: _bgGreenTint,
                      iconColor: _green,
                      title: 'Two-Factor Authentication',
                      trailing: Switch(
                        value: _twoFactor,
                        activeThumbColor: Colors.white,
                        activeTrackColor: _green,
                        onChanged: (v) => setState(() => _twoFactor = v),
                      ),
                    ),
                    _divider(),
                    _buildIconRow(
                      icon: Icons.visibility_outlined,
                      iconBgColor: _bgPurpleTint,
                      iconColor: _purple,
                      title: 'Privacy Settings',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PrivacySettingsScreen(),
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 18),
                  _buildPremiumCard(),
                  const SizedBox(height: 18),
                  _buildSectionTitle('SUPPORT'),
                  const SizedBox(height: 8),
                  _buildListCard([
                    _buildIconRow(
                      icon: Icons.help_outline,
                      iconBgColor: _bgBlueTint,
                      iconColor: _blue,
                      title: 'Help Center',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SupportScreen(),
                        ),
                      ),
                    ),
                    _divider(),
                    _buildIconRow(
                      icon: Icons.headset_mic_outlined,
                      iconBgColor: _bgGreenTint,
                      iconColor: _green,
                      title: 'Contact Support',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SupportScreen(),
                        ),
                      ),
                    ),
                    _divider(),
                    _buildIconRow(
                      icon: Icons.chat_bubble_outline,
                      iconBgColor: _bgPurpleTint,
                      iconColor: _purple,
                      title: 'FAQs',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SupportScreen(),
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 18),
                  _buildSignOut(),
                  const SizedBox(height: 20),
                  _buildFooter(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final name = state is ProfileLoaded ? state.user.firstName : 'there';
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Welcome back, $name 👋',
              style: const TextStyle(fontSize: 13, color: _textMid),
            ),
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ProfileSettingsScreen(),
                ),
              ),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: const Icon(Icons.tune, size: 18, color: _textDark),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIdentityRow({
    required String firstName,
    required String fullName,
    required DateTime? createdAt,
    String? errorMessage,
    String? photoUrl,
  }) {
    return Row(
      children: [
        _buildAvatar(firstName, size: 64, withCheck: true, photoUrl: photoUrl),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                errorMessage ??
                    (createdAt != null
                        ? 'Member since ${_formatMonthYear(createdAt)}'
                        : '—'),
                style: const TextStyle(fontSize: 12, color: _textMuted),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _bgGoldTint,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Text(
                  '👑 PREMIUM MEMBER',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _goldText,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatMonthYear(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  Widget _buildIdentityRowFromState() {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded) {
          return _buildIdentityRow(
            firstName: state.user.firstName,
            fullName: state.user.fullName,
            createdAt: state.user.createdAt,
            photoUrl: state.user.photoUrl,
          );
        }
        if (state is ProfileError) {
          return _buildIdentityRow(
            firstName: '—',
            fullName: 'Could not load profile',
            createdAt: null,
            errorMessage: state.message,
          );
        }
        return _buildIdentitySkeleton();
      },
    );
  }

  Widget _buildPersonalInformationFromState() {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        String email = '—';
        String phone = '—';
        String address = '—';
        if (state is ProfileLoaded) {
          email = state.user.email;
          phone = _formatPhone(state.user.phone, state.user.phoneExtra);
          address = _formatAddress(state.user.address, state.user.location);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('PERSONAL INFORMATION'),
            const SizedBox(height: 8),
            _buildListCard([
              _buildIconRow(
                icon: Icons.mail_outline,
                iconBgColor: _bgBlueTint,
                iconColor: _blue,
                title: 'Email',
                trailingValue: email,
              ),
              _divider(),
              _buildIconRow(
                icon: Icons.phone_outlined,
                iconBgColor: _bgGreenTint,
                iconColor: _green,
                title: 'Phone Number',
                trailingValue: phone,
              ),
              _divider(),
              _buildIconRow(
                icon: Icons.place_outlined,
                iconBgColor: _bgOrangeTint,
                iconColor: _orange,
                title: 'Address',
                trailingValue: address,
              ),
            ]),
          ],
        );
      },
    );
  }

  String _formatPhone(String phone, String? extra) {
    return extra == null || extra.isEmpty ? phone : '$phone · $extra';
  }

  String _formatAddress(String? address, String? location) {
    final parts = <String>[
      if (address != null && address.isNotEmpty) address,
      if (location != null && location.isNotEmpty) location,
    ];
    return parts.isEmpty ? '—' : parts.join(', ');
  }

  Widget _buildIdentitySkeleton() {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: Color(0xFFE5E7EB),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 160,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 110,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEFF3),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _onSignOut() async {
    await sl<AuthRepository>().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Widget _buildAvatar(String name, {required double size, bool withCheck = false, String? photoUrl}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
          ),
          alignment: Alignment.center,
          child: photoUrl != null && photoUrl.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    photoUrl,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _e, _s) => Text(
                      name,
                      style: TextStyle(
                        fontSize: size * 0.22,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                  ),
                )
              : Text(
                  name,
                  style: TextStyle(
                    fontSize: size * 0.22,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
        ),
        if (withCheck)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: _blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.check, size: 12, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final petCount = state is ProfileLoaded ? state.petCount : 0;
        final walkCount = state is ProfileLoaded ? state.walkCount : 0;
        final avgRating = state is ProfileLoaded ? state.averageRating : 0.0;
        return Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCell(
                  icon: Icons.pets,
                  iconBg: _bgPurpleTint,
                  iconColor: _purple,
                  value: '$petCount',
                  label: 'Dogs Registered',
                ),
              ),
              _statDivider(),
              Expanded(
                child: _buildStatCell(
                  icon: Icons.directions_walk,
                  iconBg: _bgGreenTint,
                  iconColor: _green,
                  value: '$walkCount',
                  label: 'Completed Walks',
                ),
              ),
              _statDivider(),
              Expanded(
                child: _buildStatCell(
                  icon: Icons.star,
                  iconBg: _bgGoldTint,
                  iconColor: _gold,
                  value: avgRating.toStringAsFixed(1),
                  label: 'Average Rating',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statDivider() {
    return Container(
      width: 1,
      height: 48,
      color: const Color(0xFFEFF1F5),
    );
  }

  Widget _buildStatCell({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: _textDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: _textMuted),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickAction(
            icon: Icons.edit_outlined,
            iconBg: _bgPurpleTint,
            iconColor: _indigo,
            label: 'Edit Profile',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<ProfileCubit>(),
                  child: const EditProfileScreen(),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: _buildQuickAction(
            icon: Icons.pets,
            iconBg: _bgOrangeTint,
            iconColor: _orange,
            label: 'Manage Pets',
          ),
        ),
        Expanded(
          child: _buildQuickAction(
            icon: Icons.credit_card,
            iconBg: _bgBlueTint,
            iconColor: _blue,
            label: 'Payments',
          ),
        ),
        Expanded(
          child: _buildQuickAction(
            icon: Icons.notifications_outlined,
            iconBg: _bgOrangeTint,
            iconColor: _orange,
            label: 'Alerts',
            hasDot: true,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    bool hasDot = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, size: 22, color: iconColor),
              ),
              if (hasDot)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: _textDark),
          ),
        ],
      ),
    );
  }

  // ─── Walker Status Section ────────────────────────────────────────────────

  Widget _buildWalkerSection() {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is! ProfileLoaded) return const SizedBox.shrink();
        final wp = state.walkerProfile;
        if (wp == null) return _buildWalkerNotApplied();
        switch (wp.status) {
          case WalkerStatus.pending:
            return _buildWalkerPending();
          case WalkerStatus.approved:
            return _buildWalkerApproved();
          case WalkerStatus.rejected:
            return _buildWalkerRejected();
        }
      },
    );
  }

  Widget _buildWalkerNotApplied() {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider.value(
            value: context.read<ProfileCubit>(),
            child: const BecomeWalkerScreen(),
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F8F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _green.withValues(alpha: 0.30)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _green.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.directions_walk, color: _green, size: 22),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Become a Walker',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Earn money walking dogs in your area.',
                    style: TextStyle(fontSize: 12, color: _textMid),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: _textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildWalkerPending() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF3FB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _blue.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _blue.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hourglass_top_rounded,
              color: _blue,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verification Pending',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Your application is under review. We\'ll notify you within 24–48 hours.',
                  style: TextStyle(fontSize: 12, color: _textMid),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalkerApproved() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F8F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _green.withValues(alpha: 0.40)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified_rounded, color: _green, size: 22),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Walker Profile Active',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'You\'re a verified walker. Pet owners can now book you.',
                      style: TextStyle(fontSize: 12, color: _textMid),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => BlocProvider.value(
                      value: context.read<ProfileCubit>(),
                      child: const EditWalkerProfileScreen(),
                    ),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _green,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const WalkerAvailabilityScreen(),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 16,
                      color: _green,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Manage Availability',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _green,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: _green,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const WalkerBookingsScreen(),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_month_rounded, size: 16, color: _green),
                    SizedBox(width: 8),
                    Text(
                      'My Bookings',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _green,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded, size: 16, color: _green),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalkerRejected() {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider.value(
            value: context.read<ProfileCubit>(),
            child: const BecomeWalkerScreen(isReapply: true),
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEECE8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _orange.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _orange.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: _orange,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verification Failed',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Your document was not accepted. Tap to upload a new one.',
                    style: TextStyle(fontSize: 12, color: _textMid),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: _textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildMyPets() {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final pets = state is ProfileLoaded ? state.pets : <Pet>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Pets',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _textDark,
                  ),
                ),
                Text(
                  '${pets.length} registered',
                  style: const TextStyle(fontSize: 12, color: _textMuted),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (pets.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'No pets registered yet',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF8A93A0)),
                ),
              )
            else
              ...pets.map((pet) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildPetCard(pet: pet),
                  )),
            const SizedBox(height: 12),
            _buildAddPetButton(),
          ],
        );
      },
    );
  }

  Widget _buildPetCard({required Pet pet}) {
    final age = pet.birthDate != null
        ? '${DateTime.now().year - pet.birthDate!.year} yr'
        : '—';
    final subtitle = [
      if (pet.breed != null) pet.breed!,
      age,
    ].join(' · ');

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<ProfileCubit>(),
            child: PetDetailScreen(petId: pet.id),
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildPetAvatar(pet),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        pet.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _bgGreenTint,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: const Text(
                          'Active',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: _textMuted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: _textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildPetAvatar(Pet pet) {
    if (pet.photoUrl != null && pet.photoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          pet.photoUrl!,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildAvatar(pet.name, size: 44),
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return _buildAvatar(pet.name, size: 44);
          },
        ),
      );
    }
    return _buildAvatar(pet.name, size: 44);
  }

  Widget _buildAddPetButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<ProfileCubit>(),
            child: const CreatePetScreen(),
          ),
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: _bgAddPet,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _addPetBorder,
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        alignment: Alignment.center,
        child: const Text(
          '+ Add New Pet',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _orange,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: _textSection,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildListCard(List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: rows),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 14),
      child: Divider(height: 1, color: Color(0xFFF1F3F6)),
    );
  }

  Widget _buildIconRow({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    String? trailingValue,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
            ),
            if (trailing != null)
              trailing
            else ...[
              if (trailingValue != null)
                Text(
                  trailingValue,
                  style: const TextStyle(fontSize: 13, color: _textMuted),
                ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, size: 20, color: _textMuted),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6D7CFF),
            Color(0xFF7C6BF5),
            Color(0xFF5F6BE8),
          ],
          stops: [0.0, 0.52, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D7CFF).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CURRENT PLAN',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _gold,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Text(
                  '👑 PREMIUM',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                'Balto Premium',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '· \$19/mo',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(child: _PremiumCheck(label: 'Priority Booking')),
              Expanded(child: _PremiumCheck(label: 'Advanced Tracking')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              Expanded(child: _PremiumCheck(label: 'Walk Reports')),
              Expanded(child: _PremiumCheck(label: 'AI Pet Insights')),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _purple,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Manage Subscription',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOut() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _onSignOut,
        icon: const Icon(Icons.logout, size: 18, color: _red),
        label: const Text(
          'Sign Out',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _red,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return const Center(
      child: Text(
        'Balto · v2.4.0',
        style: TextStyle(fontSize: 11, color: _textSection),
      ),
    );
  }
}

class _PremiumCheck extends StatelessWidget {
  const _PremiumCheck({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle_outline, size: 14, color: Colors.white),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
