import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/di/injection.dart';
import '../../../core/widgets/balto_toast.dart';
import '../../../main.dart';
import '../../bloc/auth/auth_cubit.dart';
import '../../bloc/auth/auth_state.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) => sl<AuthCubit>(),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _idNumberCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  final _lastNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();
  final _idNumberFocus = FocusNode();
  final _phoneFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptTerms = false;
  String _selectedIdType = 'CC';

  static const List<String> _idTypes = ['CC', 'CE', 'Passport', 'TI'];

  static const Color _bg = Color(0xFFF0F4F4);
  static const Color _inputFill = Color(0xFFEEF3F3);
  static const Color _textDark = Color(0xFF1A1A2E);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _textLight = Color(0xFF9AA0B2);
  static const Color _divider = Color(0xFFE0E4F0);
  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _idNumberCtrl.dispose();
    _phoneCtrl.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    _idNumberFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_acceptTerms) {
      BaltoToast.warning(context, 'You must accept the Terms and Privacy Policy.');
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<AuthCubit>().register(
          firstName: _firstNameCtrl.text.trim(),
          lastName: _lastNameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          idNumber: _idNumberCtrl.text.trim(),
          idType: _selectedIdType,
          phone: _phoneCtrl.text.trim(),
        );
  }

  void _showSnack(String message, {bool isSuccess = false}) {
    if (isSuccess) {
      BaltoToast.success(context, message);
    } else {
      BaltoToast.error(context, message);
    }
  }

  String _mapErrorMessage(String code, String fallback) {
    switch (code) {
      case 'EMAIL_ALREADY_TAKEN':
        return 'An account with this email already exists.';
      case 'PASSWORD_WEAK':
        return 'Password does not meet the requirements.';
      case 'VALIDATION_FAILED':
        return 'Please review the form fields.';
      case 'NETWORK_ERROR':
        return 'Could not reach the server.';
      default:
        return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _showSnack('Account created. Welcome to Balto!', isSuccess: true);
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute<void>(builder: (_) => const MainShell()),
            (route) => false,
          );
        } else if (state is AuthError) {
          _showSnack(_mapErrorMessage(state.code, state.message));
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Scaffold(
          backgroundColor: _bg,
          body: SafeArea(
            child: AbsorbPointer(
              absorbing: isLoading,
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildLogo(),
                      const SizedBox(height: 32),
                      _buildCard(isLoading),
                      const SizedBox(height: 28),
                      _buildFooter(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
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

  Widget _buildCard(bool isLoading) {
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
          const Center(
            child: Text(
              'Create your\nBalto account',
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
          const Center(
            child: Text(
              'Join the premium sanctuary for you and your companion.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: _textMuted, height: 1.5),
            ),
          ),
          const SizedBox(height: 28),
          // Name row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('First Name'),
                    const SizedBox(height: 8),
                    _firstNameField(),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Last Name'),
                    const SizedBox(height: 8),
                    _lastNameField(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _fieldLabel('Email Address'),
          const SizedBox(height: 8),
          _emailField(),
          const SizedBox(height: 20),
          _fieldLabel('Password'),
          const SizedBox(height: 8),
          _passwordField(),
          const SizedBox(height: 20),
          _fieldLabel('Confirm Password'),
          const SizedBox(height: 8),
          _confirmPasswordField(),
          const SizedBox(height: 20),
          // ID row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('ID Type'),
                  const SizedBox(height: 8),
                  _idTypeDropdown(),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('ID Number'),
                    const SizedBox(height: 8),
                    _idNumberField(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _fieldLabel('Phone'),
          const SizedBox(height: 8),
          _phoneField(),
          const SizedBox(height: 16),
          _termsRow(),
          const SizedBox(height: 20),
          _signUpButton(isLoading),
          const SizedBox(height: 24),
          _orDivider(),
          const SizedBox(height: 20),
          _socialRow(),
          const SizedBox(height: 24),
          _signInRow(),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _textDark,
      ),
    );
  }

  InputDecoration _decoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _textLight, fontSize: 14),
      prefixIcon: Icon(icon, color: _textMuted, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: _inputFill,
      border: OutlineInputBorder(
        borderRadius: AppRadius.radius12,
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
    );
  }

  Widget _firstNameField() {
    return TextFormField(
      controller: _firstNameCtrl,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) => _lastNameFocus.requestFocus(),
      style: const TextStyle(fontSize: 14, color: _textDark),
      decoration: _decoration(hint: 'First', icon: Icons.person_outline),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Required.' : null,
    );
  }

  Widget _lastNameField() {
    return TextFormField(
      controller: _lastNameCtrl,
      focusNode: _lastNameFocus,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) => _emailFocus.requestFocus(),
      style: const TextStyle(fontSize: 14, color: _textDark),
      decoration: _decoration(hint: 'Last', icon: Icons.person_outline),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Required.' : null,
    );
  }

  Widget _emailField() {
    return TextFormField(
      controller: _emailCtrl,
      focusNode: _emailFocus,
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      enableSuggestions: false,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
      style: const TextStyle(fontSize: 14, color: _textDark),
      decoration:
          _decoration(hint: 'name@email.com', icon: Icons.mail_outline),
      validator: (v) {
        final value = v?.trim() ?? '';
        if (value.isEmpty) return 'Enter your email.';
        if (!_emailRegex.hasMatch(value)) return 'Invalid email.';
        return null;
      },
    );
  }

  Widget _passwordField() {
    return TextFormField(
      controller: _passwordCtrl,
      focusNode: _passwordFocus,
      obscureText: _obscurePassword,
      autocorrect: false,
      enableSuggestions: false,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) => _confirmFocus.requestFocus(),
      style: const TextStyle(fontSize: 14, color: _textDark),
      decoration: _decoration(
        hint: '••••••••',
        icon: Icons.lock_outline,
        suffix: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: _textMuted,
            size: 20,
          ),
          onPressed: () =>
              setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (v) {
        final value = v ?? '';
        if (value.length < 8) return 'At least 8 characters.';
        if (!RegExp(r'[A-Z]').hasMatch(value)) {
          return 'Missing an uppercase letter.';
        }
        if (!RegExp(r'[a-z]').hasMatch(value)) {
          return 'Missing a lowercase letter.';
        }
        if (!RegExp(r'\d').hasMatch(value)) return 'Missing a digit.';
        if (!RegExp(r'[^A-Za-z0-9]').hasMatch(value)) {
          return 'Missing a symbol.';
        }
        return null;
      },
    );
  }

  Widget _confirmPasswordField() {
    return TextFormField(
      controller: _confirmCtrl,
      focusNode: _confirmFocus,
      obscureText: _obscureConfirm,
      autocorrect: false,
      enableSuggestions: false,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) => _idNumberFocus.requestFocus(),
      style: const TextStyle(fontSize: 14, color: _textDark),
      decoration: _decoration(
        hint: '••••••••',
        icon: Icons.lock_outline,
        suffix: IconButton(
          icon: Icon(
            _obscureConfirm
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: _textMuted,
            size: 20,
          ),
          onPressed: () =>
              setState(() => _obscureConfirm = !_obscureConfirm),
        ),
      ),
      validator: (v) =>
          (v ?? '') == _passwordCtrl.text ? null : 'Passwords do not match.',
    );
  }

  Widget _idTypeDropdown() {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _inputFill,
        borderRadius: AppRadius.radius12,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedIdType,
          items: _idTypes
              .map(
                (t) => DropdownMenuItem(
                  value: t,
                  child: Text(
                    t,
                    style: const TextStyle(fontSize: 14, color: _textDark),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _selectedIdType = v ?? 'CC'),
          icon: const Icon(Icons.arrow_drop_down, color: _textMuted),
          style: const TextStyle(fontSize: 14, color: _textDark),
          dropdownColor: Colors.white,
        ),
      ),
    );
  }

  Widget _idNumberField() {
    return TextFormField(
      controller: _idNumberCtrl,
      focusNode: _idNumberFocus,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) => _phoneFocus.requestFocus(),
      style: const TextStyle(fontSize: 14, color: _textDark),
      decoration:
          _decoration(hint: '1234567890', icon: Icons.badge_outlined),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Required.' : null,
    );
  }

  Widget _phoneField() {
    return TextFormField(
      controller: _phoneCtrl,
      focusNode: _phoneFocus,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _submit(),
      style: const TextStyle(fontSize: 14, color: _textDark),
      decoration:
          _decoration(hint: '3001234567', icon: Icons.phone_outlined),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Required.' : null,
    );
  }

  Widget _termsRow() {
    return InkWell(
      onTap: () => setState(() => _acceptTerms = !_acceptTerms),
      borderRadius: AppRadius.radius8,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _acceptTerms,
                onChanged: (v) => setState(() => _acceptTerms = v ?? false),
                activeColor: AppColors.navWalks,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.radius4,
                ),
                side: const BorderSide(color: Color(0xFFCDD2E0), width: 1.5),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: const TextSpan(
                  text: 'I agree to the ',
                  style: TextStyle(fontSize: 13, color: Color(0xFF4A4A6A)),
                  children: [
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                        color: AppColors.navWalks,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: AppColors.navWalks,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _signUpButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navWalks,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radius14,
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                ],
              ),
      ),
    );
  }

  Widget _orDivider() {
    return Row(
      children: const [
        Expanded(child: Divider(color: _divider, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR SIGN UP WITH',
            style: TextStyle(
              fontSize: 11,
              color: _textLight,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: _divider, thickness: 1)),
      ],
    );
  }

  Widget _socialRow() {
    return Row(
      children: [
        Expanded(
          child: _SocialButton(
            label: 'Google',
            icon: SvgPicture.asset(
              'assets/icons/google.svg',
              width: 20,
              height: 20,
            ),
            onPressed: () => _showComingSoon(context, 'Google'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _SocialButton(
            label: 'Apple',
            icon: const Icon(Icons.apple, size: 22, color: _textDark),
            onPressed: () => _showComingSoon(context, 'Apple'),
          ),
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context, String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$provider login coming soon'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _signInRow() {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: RichText(
          text: const TextSpan(
            text: 'Already have an account? ',
            style: TextStyle(fontSize: 14, color: Color(0xFF4A4A6A)),
            children: [
              TextSpan(
                text: 'Sign In',
                style: TextStyle(
                  color: AppColors.navWalks,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
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
          '© 2026 Balto Inc. Secure Signup',
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

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.icon, this.onPressed});

  final String label;
  final Widget icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radius12,
        ),
        side: const BorderSide(color: Color(0xFFDDE1F0), width: 1.5),
        backgroundColor: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }
}
