import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/di/injection.dart';
import '../../../domain/entities/business.dart';
import '../../../domain/entities/pet.dart';
import '../../../domain/entities/walker_profile.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../bloc/profile/profile_cubit.dart';
import '../../bloc/profile/profile_state.dart';
import '../../screens/pets/create_pet_screen.dart';
import '../../screens/pets/edit_pet_screen.dart';
import '../../screens/pets/manage_pets_screen.dart';
import '../../screens/pets/pet_detail_screen.dart';
import '../auth/change_password_screen.dart';
import '../auth/login_screen.dart';
import '../services/become_business_screen.dart';
import '../services/edit_business_profile_screen.dart';
import '../walkers/become_walker_screen.dart';
import '../walkers/edit_walker_profile_screen.dart';
import '../walkers/walker_availability_screen.dart';
import '../walkers/walker_bookings_screen.dart';
import '../../widgets/balto_bottom_sheet.dart';
import '../../widgets/balto_screen_scaffold.dart';
import '../../widgets/skeletons/profile_skeleton.dart';
import 'edit_profile_screen.dart';
import 'faq_screen.dart';
import 'help_center_screen.dart';
import 'privacy_settings_screen.dart';
import 'profile_settings_screen.dart';
import 'support_screen.dart';
import '../notifications/notifications_screen.dart';

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
  static const Color _textMid = Color(0xFF5A6473);
  static const Color _textSection = Color(0xFF9AA2AE);
  static const Color _red = Color(0xFFE5544B);
  static const Color _indigo = Color(0xFF5563E0);

  static const Color _bgBlueTint = Color(0xFFEAF2FB);
  static const Color _bgGreenTint = Color(0xFFE8F5EE);
  static const Color _bgPurpleTint = Color(0xFFEEF0FF);
  static const Color _bgOrangeTint = Color(0xFFFFF1E6);

  @override
  Widget build(BuildContext context) {
    if (context.watch<ProfileCubit>().state is ProfileLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(child: ProfileSkeleton()),
      );
    }

    return BaltoScreenScaffold(
      header: _buildHeader(),
      body: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIdentityRowFromState(),
                  const SizedBox(height: 18),
                  _buildStatsCard(),
                  const SizedBox(height: 18),
                  _buildQuickActions(),
                  const SizedBox(height: 22),
                  _buildWalkerSection(),
                  const SizedBox(height: 16),
                  _buildBusinessSection(),
                  const SizedBox(height: 18),
                  _buildMyPets(),
                  const SizedBox(height: 18),
                  _buildSectionTitle('PRIVACY & SECURITY'),
                  const SizedBox(height: 8),
                  _buildListCard([
                    _buildIconRow(
                      icon: Icons.lock_outline,
                      iconBgColor: _bgBlueTint,
                      iconColor: AppColors.navWalks,
                      title: 'Change Password',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ChangePasswordScreen(),
                        ),
                      ),
                    ),
                    _divider(),
                    _buildIconRow(
                      icon: Icons.verified_user_outlined,
                      iconBgColor: _bgGreenTint,
                      iconColor: AppColors.navWalkers,
                      title: 'Two-Factor Authentication',
                      onTap: () => _showComingSoonSheet('Two-Factor Authentication'),
                    ),
                    _divider(),
                    _buildIconRow(
                      icon: Icons.visibility_outlined,
                      iconBgColor: _bgPurpleTint,
                      iconColor: AppColors.navCoach,
                      title: 'Privacy Settings',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PrivacySettingsScreen(),
                        ),
                      ),
                    ),
                  ]),
                  // TODO: Re-implement when subscription system is ready
                  // const SizedBox(height: 18),
                  // _buildPremiumCard(),
                  // const SizedBox(height: 18),
                  _buildSectionTitle('SUPPORT'),
                  const SizedBox(height: 8),
                  _buildListCard([
                    _buildIconRow(
                      icon: Icons.help_outline,
                      iconBgColor: _bgBlueTint,
                      iconColor: AppColors.navWalks,
                      title: 'Help Center',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HelpCenterScreen(),
                        ),
                      ),
                    ),
                    _divider(),
                    _buildIconRow(
                      icon: Icons.headset_mic_outlined,
                      iconBgColor: _bgGreenTint,
                      iconColor: AppColors.navWalkers,
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
                      iconColor: AppColors.navCoach,
                      title: 'FAQs',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const FaqScreen(),
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
                  borderRadius: AppRadius.radius12,
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: const Icon(Icons.tune, size: 18, color: AppColors.textPrimary),
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
    required String email,
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
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                email,
                style: const TextStyle(fontSize: 12, color: _textMid),
              ),
              const SizedBox(height: 1),
              Text(
                errorMessage ??
                    (createdAt != null
                        ? 'Member since ${_formatMonthYear(createdAt)}'
                        : '—'),
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatMonthYear(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
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
            email: state.user.email,
            createdAt: state.user.createdAt,
            photoUrl: state.user.photoUrl,
          );
        }
        if (state is ProfileError) {
          return _buildIdentityRow(
            firstName: '—',
            fullName: 'Could not load profile',
            email: '',
            createdAt: null,
            errorMessage: state.message,
          );
        }
        return _buildIdentitySkeleton();
      },
    );
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
                  borderRadius: AppRadius.radius6,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 110,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEFF3),
                  borderRadius: AppRadius.radius6,
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
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                )
              : Text(
                  name,
                  style: TextStyle(
                    fontSize: size * 0.22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
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
                color: AppColors.navWalks,
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
        return Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.radius16,
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
                  iconColor: AppColors.navCoach,
                  value: '$petCount',
                  label: 'Pets Registered',
                ),
              ),
              _statDivider(),
              Expanded(
                child: _buildStatCell(
                  icon: Icons.directions_walk,
                  iconBg: _bgGreenTint,
                  iconColor: AppColors.navWalkers,
                  value: '$walkCount',
                  label: 'Total Walks',
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
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final unreadCount = context.watch<ProfileCubit>().state is ProfileLoaded
        ? (context.watch<ProfileCubit>().state as ProfileLoaded).unreadNotificationCount
        : 0;
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
            iconBg: _bgPurpleTint,
            iconColor: AppColors.navCoach,
            label: 'Manage Pets',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<ProfileCubit>(),
                  child: const ManagePetsScreen(),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: _buildQuickAction(
            icon: Icons.notifications_active,
            iconBg: _bgOrangeTint,
            iconColor: AppColors.alert,
            label: 'Notifications',
            hasDot: unreadCount > 0,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const NotificationsScreen(),
              ),
            ),
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
                  borderRadius: AppRadius.radius18,
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
            style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

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
          borderRadius: AppRadius.radius16,
          border: Border.all(color: AppColors.navWalkers.withValues(alpha: 0.30)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.navWalkers.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.directions_walk, color: AppColors.navWalkers, size: 22),
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
                      color: AppColors.textPrimary,
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
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
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
        borderRadius: AppRadius.radius16,
        border: Border.all(color: AppColors.navWalks.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.navWalks.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.hourglass_top_rounded, color: AppColors.navWalks, size: 22),
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
                    color: AppColors.textPrimary,
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
        borderRadius: AppRadius.radius16,
        border: Border.all(color: AppColors.navWalkers.withValues(alpha: 0.40)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.navWalkers.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified_rounded, color: AppColors.navWalkers, size: 22),
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
                        color: AppColors.textPrimary,
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
                    color: AppColors.navWalkers,
                    borderRadius: AppRadius.radiusPill,
                  ),
                  child: const Text(
                    'Edit',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
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
                  color: AppColors.navWalkers.withValues(alpha: 0.10),
                  borderRadius: AppRadius.radius10,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.schedule_rounded, size: 16, color: AppColors.navWalkers),
                    SizedBox(width: 8),
                    Text('Manage Availability', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.navWalkers)),
                    SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.navWalkers),
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
                  color: AppColors.navWalkers.withValues(alpha: 0.10),
                  borderRadius: AppRadius.radius10,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.navWalkers),
                    SizedBox(width: 8),
                    Text('My Bookings', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.navWalkers)),
                    SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.navWalkers),
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
          borderRadius: AppRadius.radius16,
          border: Border.all(color: AppColors.alert.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.alert.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded, color: AppColors.alert, size: 22),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Verification Failed', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  SizedBox(height: 3),
                  Text('Your document was not accepted. Tap to upload a new one.', style: TextStyle(fontSize: 12, color: _textMid)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessSection() {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is! ProfileLoaded) return const SizedBox.shrink();
        final b = state.businessProfile;
        if (b == null) return _buildBusinessNotApplied();
        switch (b.verificationStatus) {
          case 'approved':
            return _buildBusinessApproved(b);
          case 'rejected':
            return _buildBusinessRejected();
          default:
            return _buildBusinessPending();
        }
      },
    );
  }

  Widget _buildBusinessNotApplied() {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider.value(
            value: context.read<ProfileCubit>(),
            child: const BecomeBusinessScreen(),
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F8F2),
          borderRadius: AppRadius.radius16,
          border: Border.all(color: AppColors.navWalkers.withValues(alpha: 0.30)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: AppColors.navWalkers.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: const Icon(Icons.storefront_rounded, color: AppColors.navWalkers, size: 22),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Register a Business', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  SizedBox(height: 3),
                  Text('List your veterinary or store on Balto.', style: TextStyle(fontSize: 12, color: _textMid)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessPending() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF3FB),
        borderRadius: AppRadius.radius16,
        border: Border.all(color: AppColors.navWalks.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: AppColors.navWalks.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: const Icon(Icons.hourglass_top_rounded, color: AppColors.navWalks, size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Business Verification Pending', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                SizedBox(height: 3),
                Text('Your NIT document is under review. We\'ll notify you within 24–48 hours.', style: TextStyle(fontSize: 12, color: _textMid)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessApproved(Business b) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F8F2),
        borderRadius: AppRadius.radius16,
        border: Border.all(color: AppColors.navWalkers.withValues(alpha: 0.40)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: AppColors.navWalkers.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: const Icon(Icons.verified_rounded, color: AppColors.navWalkers, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Business Verified', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 3),
                Text('${b.name} is live. Pet owners can find you now.', style: const TextStyle(fontSize: 12, color: _textMid)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => BlocProvider.value(
                  value: context.read<ProfileCubit>(),
                  child: const EditBusinessProfileScreen(),
                ),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppColors.navWalkers, borderRadius: AppRadius.radiusPill),
              child: const Text('Edit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessRejected() {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider.value(
            value: context.read<ProfileCubit>(),
            child: const BecomeBusinessScreen(isReapply: true),
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEECE8),
          borderRadius: AppRadius.radius16,
          border: Border.all(color: AppColors.alert.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: AppColors.alert.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: const Icon(Icons.error_outline_rounded, color: AppColors.alert, size: 22),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Business Verification Failed', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  SizedBox(height: 3),
                  Text('Your NIT document was not accepted. Tap to upload a new one.', style: TextStyle(fontSize: 12, color: _textMid)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
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
                const Text('My Pets', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                Text('${pets.length} registered', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 10),
            if (pets.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.radius14),
                child: const Text('No pets registered yet', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Color(0xFF8A93A0))),
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
    ].join(' \u00b7 ');

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
          borderRadius: AppRadius.radius14,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 2)),
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
                      Text(pet.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: _bgGreenTint, borderRadius: AppRadius.radiusPill),
                        child: const Text('Active', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.navWalkers)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<ProfileCubit>(),
                    child: EditPetScreen(pet: pet),
                  ),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: _bgPurpleTint,
                  borderRadius: AppRadius.radius10,
                ),
                child: const Icon(Icons.edit_outlined, size: 16, color: AppColors.navCoach),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetAvatar(Pet pet) {
    if (pet.photoUrl != null && pet.photoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: AppRadius.radius12,
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
          color: _bgPurpleTint,
          borderRadius: AppRadius.radius14,
          border: Border.all(color: AppColors.navCoach.withValues(alpha: 0.30), width: 1.5, style: BorderStyle.solid),
        ),
        alignment: Alignment.center,
        child: Text('+ Add New Pet', style: AppTextStyles.bodyBold.copyWith(color: AppColors.navCoach)),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _textSection, letterSpacing: 1.0)),
    );
  }

  Widget _buildListCard(List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radius16,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 3)),
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
            Container(width: 36, height: 36, decoration: BoxDecoration(color: iconBgColor, borderRadius: AppRadius.radius12), child: Icon(icon, size: 18, color: iconColor)),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
            if (trailing != null)
              trailing
            else ...[
              if (trailingValue != null) Text(trailingValue, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
            ],
          ],
        ),
      ),
    );
  }

  // TODO: Re-implement when subscription system is ready
  // Widget _buildPremiumCard() {
  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(16),
  //       gradient: const LinearGradient(
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //         colors: [Color(0xFF6D7CFF), Color(0xFF7C6BF5), Color(0xFF5F6BE8)],
  //         stops: [0.0, 0.52, 1.0],
  //       ),
  //       boxShadow: [
  //         BoxShadow(color: Color(0xFF6D7CFF).withValues(alpha: 0.35), blurRadius: 18, offset: const Offset(0, 8)),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Text('CURRENT PLAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: Colors.white.withValues(alpha: 0.7))),
  //             Container(
  //               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  //               decoration: BoxDecoration(color: _gold, borderRadius: BorderRadius.circular(99)),
  //               child: const Text('👑 PREMIUM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 10),
  //         Row(
  //           crossAxisAlignment: CrossAxisAlignment.baseline,
  //           textBaseline: TextBaseline.alphabetic,
  //           children: [
  //             const Text('Balto Premium', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
  //             const SizedBox(width: 6),
  //             Text('· \$19/mo', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7))),
  //           ],
  //         ),
  //         const SizedBox(height: 16),
  //         Row(
  //           children: const [
  //             Expanded(child: _PremiumCheck(label: 'Priority Booking')),
  //             Expanded(child: _PremiumCheck(label: 'Advanced Tracking')),
  //           ],
  //         ),
  //         const SizedBox(height: 10),
  //         Row(
  //           children: const [
  //             Expanded(child: _PremiumCheck(label: 'Walk Reports')),
  //             Expanded(child: _PremiumCheck(label: 'AI Pet Insights')),
  //           ],
  //         ),
  //         const SizedBox(height: 18),
  //         SizedBox(
  //           width: double.infinity,
  //           child: ElevatedButton(
  //             onPressed: () {},
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: Colors.white,
  //               foregroundColor: AppColors.navCoach,
  //               elevation: 0,
  //               padding: const EdgeInsets.symmetric(vertical: 13),
  //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //             ),
  //             child: const Text('Manage Subscription', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _showComingSoonSheet(String feature) {
    BaltoBottomSheet.show(
      context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _bgPurpleTint,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.rocket_launch_outlined, size: 30, color: AppColors.navCoach),
          ),
          const SizedBox(height: 16),
          const Text(
            'Coming Soon',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            '$feature is not available yet.\nWe\'re working hard to bring it to you soon!',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: _textMid, height: 1.5),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navCoach,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.radius14),
              ),
              child: const Text('Got it', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
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
        label: const Text('Sign Out', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _red)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radius16),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return const Center(
      child: Text('Balto · v1.0.0', style: TextStyle(fontSize: 11, color: _textSection)),
    );
  }
}

// TODO: Re-implement when subscription system is ready
// class _PremiumCheck extends StatelessWidget {
//   const _PremiumCheck({required this.label});
//
//   final String label;
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         const Icon(Icons.check_circle_outline, size: 14, color: Colors.white),
//         const SizedBox(width: 6),
//         Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500))),
//       ],
//     );
//   }
// }
