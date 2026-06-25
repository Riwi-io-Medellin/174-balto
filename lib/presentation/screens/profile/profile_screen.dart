import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
                  _buildIdentityRow(),
                  const SizedBox(height: 18),
                  _buildStatsCard(),
                  const SizedBox(height: 18),
                  _buildQuickActions(),
                  const SizedBox(height: 22),
                  _buildMyPets(),
                  const SizedBox(height: 18),
                  _buildSectionTitle('PERSONAL INFORMATION'),
                  const SizedBox(height: 8),
                  _buildListCard([
                    _buildIconRow(
                      icon: Icons.mail_outline,
                      iconBgColor: _bgBlueTint,
                      iconColor: _blue,
                      title: 'Email',
                      trailingValue: 'diego.m@email.com',
                    ),
                    _divider(),
                    _buildIconRow(
                      icon: Icons.phone_outlined,
                      iconBgColor: _bgGreenTint,
                      iconColor: _green,
                      title: 'Phone Number',
                      trailingValue: '+52 55 1234 5678',
                    ),
                    _divider(),
                    _buildIconRow(
                      icon: Icons.place_outlined,
                      iconBgColor: _bgOrangeTint,
                      iconColor: _orange,
                      title: 'Address',
                      trailingValue: 'Polanco, CDMX',
                    ),
                  ]),
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
                    ),
                    _divider(),
                    _buildIconRow(
                      icon: Icons.headset_mic_outlined,
                      iconBgColor: _bgGreenTint,
                      iconColor: _green,
                      title: 'Contact Support',
                    ),
                    _divider(),
                    _buildIconRow(
                      icon: Icons.chat_bubble_outline,
                      iconBgColor: _bgPurpleTint,
                      iconColor: _purple,
                      title: 'FAQs',
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Welcome back, Diego 👋',
          style: TextStyle(fontSize: 13, color: _textMid),
        ),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: const Icon(Icons.tune, size: 18, color: _textDark),
        ),
      ],
    );
  }

  Widget _buildIdentityRow() {
    return Row(
      children: [
        _buildAvatar('Diego', size: 64, withCheck: true),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Diego Morales',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Member since January 2026',
                style: TextStyle(fontSize: 12, color: _textMuted),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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

  Widget _buildAvatar(String name, {required double size, bool withCheck = false}) {
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
          child: Text(
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
              value: '3',
              label: 'Dogs Registered',
            ),
          ),
          _statDivider(),
          Expanded(
            child: _buildStatCell(
              icon: Icons.directions_walk,
              iconBg: _bgGreenTint,
              iconColor: _green,
              value: '147',
              label: 'Completed Walks',
            ),
          ),
          _statDivider(),
          Expanded(
            child: _buildStatCell(
              icon: Icons.star,
              iconBg: _bgGoldTint,
              iconColor: _gold,
              value: '4.9',
              label: 'Average Rating',
            ),
          ),
        ],
      ),
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
  }) {
    return GestureDetector(
      onTap: () {},
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

  Widget _buildMyPets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'My Pets',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _textDark,
              ),
            ),
            Text(
              '3 registered',
              style: TextStyle(fontSize: 12, color: _textMuted),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildPetCard(
          name: 'Max',
          status: 'Walking',
          statusColor: _green,
          statusBg: _bgGreenTint,
          breed: 'Golden Retriever',
          age: '3 yr',
        ),
        const SizedBox(height: 10),
        _buildPetCard(
          name: 'Luna',
          status: 'Resting',
          statusColor: _blue,
          statusBg: _bgBlueTint,
          breed: 'French Bulldog',
          age: '2 yr',
        ),
        const SizedBox(height: 10),
        _buildPetCard(
          name: 'Rocky',
          status: 'Resting',
          statusColor: _blue,
          statusBg: _bgBlueTint,
          breed: 'Labrador',
          age: '5 yr',
        ),
        const SizedBox(height: 12),
        _buildAddPetButton(),
      ],
    );
  }

  Widget _buildPetCard({
    required String name,
    required String status,
    required Color statusColor,
    required Color statusBg,
    required String breed,
    required String age,
  }) {
    return Container(
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
          _buildAvatar(name, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
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
                        color: statusBg,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '$breed · $age',
                  style: const TextStyle(fontSize: 12, color: _textMuted),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: _textMuted),
        ],
      ),
    );
  }

  Widget _buildAddPetButton() {
    return GestureDetector(
      onTap: () {},
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
  }) {
    return InkWell(
      onTap: () {},
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
        onPressed: () {},
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
