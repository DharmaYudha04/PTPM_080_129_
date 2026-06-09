import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/glass_card.dart';
import 'auth_controller.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = true;
  bool _obscurePassword = true;

  static const _bgTop = Color(0xFF181821);
  static const _bgMid = Color(0xFF0F0F16);
  static const _bgBottom = Color(0xFF06070B);
  static const _surface = Color(0x12FFFFFF);
  static const _border = Color(0x22FFFFFF);
  static const _highlight = Color(0x66FFFFFF);
  static const _text = Color(0xFFF8F8FB);
  static const _muted = Color(0xFFA0A0AA);
  static const _fieldRadius = 20.0;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.user != null) context.go(RouteNames.home);
    });

    final state = ref.watch(authControllerProvider);

    return CupertinoPageScaffold(
      backgroundColor: _bgBottom,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.18,
            colors: [
              Color(0xFF282836),
              _bgTop,
              _bgMid,
              _bgBottom,
            ],
            stops: [0, 0.32, 0.68, 1],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spaceLG,
                vertical: 22,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: _LiquidAuthPanel(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _BrandMark(),
                      const SizedBox(height: 18),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: Column(
                          key: ValueKey(_isLogin),
                          children: [
                            Text(
                              _isLogin ? 'Sugeng rawuh' : 'Miwiti jelajahmu',
                              textAlign: TextAlign.center,
                              style: AppTypography.displayBold34.copyWith(
                                color: _text,
                                fontSize: 32,
                                letterSpacing: 0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isLogin
                                  ? 'Masuk dan lanjutkan cerita jalan-jalanmu di Jogja.'
                                  : 'Buat akun agar tempat favorit dan riwayat jelajahmu tetap tersimpan.',
                              textAlign: TextAlign.center,
                              style: AppTypography.textRegular13.copyWith(
                                color: _muted,
                                height: 1.42,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _AuthModeSwitch(
                        isLogin: _isLogin,
                        onChanged: (value) {
                          HapticFeedback.selectionClick();
                          setState(() => _isLogin = value);
                        },
                      ),
                      const SizedBox(height: 22),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.035),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: _isLogin
                            ? _LoginFields(
                                key: const ValueKey('login-fields'),
                                emailController: _emailController,
                                passwordController: _passwordController,
                                obscurePassword: _obscurePassword,
                                onTogglePassword: () {
                                  HapticFeedback.selectionClick();
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              )
                            : _RegisterFields(
                                key: const ValueKey('register-fields'),
                                nameController: _nameController,
                                emailController: _emailController,
                                passwordController: _passwordController,
                                obscurePassword: _obscurePassword,
                                onTogglePassword: () {
                                  HapticFeedback.selectionClick();
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                      ),
                      if (state.error != null) ...[
                        const SizedBox(height: 14),
                        _AuthErrorBanner(
                          message: state.error!.replaceFirst('Exception: ', ''),
                        ),
                      ],
                      const SizedBox(height: 20),
                      _LiquidActionButton(
                        label: state.isLoading
                            ? 'Sebentar ya...'
                            : _isLogin
                                ? 'Masuk Sekarang'
                                : 'Daftar & Jelajahi',
                        icon: _isLogin
                            ? CupertinoIcons.arrow_right_circle_fill
                            : CupertinoIcons.person_crop_circle_badge_plus,
                        filled: true,
                        isLoading: state.isLoading,
                        onPressed: state.isLoading
                            ? null
                            : () {
                                HapticFeedback.lightImpact();

                                if (_isLogin) {
                                  ref
                                      .read(authControllerProvider.notifier)
                                      .login(
                                        _emailController.text,
                                        _passwordController.text,
                                      );
                                } else {
                                  ref
                                      .read(authControllerProvider.notifier)
                                      .register(
                                        _nameController.text,
                                        _emailController.text,
                                        _passwordController.text,
                                      );
                                }
                              },
                      ),
                      if (!kIsWeb) ...[
                        const SizedBox(height: 12),
                        _LiquidActionButton(
                          label: 'Buka dengan Biometrik',
                          icon:
                              CupertinoIcons.person_crop_circle_badge_checkmark,
                          onPressed: () async {
                            HapticFeedback.selectionClick();

                            final success = await ref
                                .read(authControllerProvider.notifier)
                                .biometricLogin();

                            if (success && context.mounted) {
                              context.go(RouteNames.home);
                            }
                          },
                        ),
                      ],
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LiquidAuthPanel extends StatelessWidget {
  const _LiquidAuthPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 34,
      opacity: 0.074,
      borderRadius: 32,
      borderColor: _AuthScreenState._border,
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: const RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.08,
                  colors: [
                    Color(0x18FFFFFF),
                    Color(0x08FFFFFF),
                    Color(0x03000000),
                  ],
                  stops: [0, 0.48, 1],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 26,
            right: 26,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CupertinoColors.white.withOpacity(0),
                    _AuthScreenState._highlight,
                    CupertinoColors.white.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 28, 26, 26),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: Alignment.topLeft,
              radius: 1,
              colors: [
                AppColors.accentPrimary.withOpacity(0.30),
                AppColors.accentSecondary.withOpacity(0.18),
                CupertinoColors.white.withOpacity(0.055),
              ],
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 28,
                spreadRadius: -10,
                color: AppColors.accentPrimary.withOpacity(0.32),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Image.asset(
              'assets/branding/IkonJS.png',
              fit: BoxFit.contain,
              cacheWidth: 128,
            ),
          ),
        ),
        const SizedBox(height: 13),
        Text(
          'JogjaSplorasi',
          textAlign: TextAlign.center,
          style: AppTypography.labelMedium12.copyWith(
            color: _AuthScreenState._muted,
            fontSize: 12,
            letterSpacing: 1.3,
          ),
        ),
      ],
    );
  }
}

class _AuthModeSwitch extends StatelessWidget {
  const _AuthModeSwitch({
    required this.isLogin,
    required this.onChanged,
  });

  final bool isLogin;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: _AuthScreenState._surface,
        borderRadius: BorderRadius.circular(_AuthScreenState._fieldRadius),
        border: Border.all(color: _AuthScreenState._border, width: 0.8),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: isLogin ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(_AuthScreenState._fieldRadius - 5),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      CupertinoColors.white.withOpacity(0.17),
                      CupertinoColors.white.withOpacity(0.07),
                    ],
                  ),
                  border: Border.all(
                    color: CupertinoColors.white.withOpacity(0.12),
                    width: 0.8,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 18,
                      spreadRadius: -8,
                      color: Color(0x9A000000),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _AuthModeItem(
                  label: 'Masuk',
                  selected: isLogin,
                  onTap: () => onChanged(true),
                ),
              ),
              Expanded(
                child: _AuthModeItem(
                  label: 'Daftar',
                  selected: !isLogin,
                  onTap: () => onChanged(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AuthModeItem extends StatelessWidget {
  const _AuthModeItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: onTap,
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          style: AppTypography.textMedium15.copyWith(
            fontSize: 15,
            fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
            color: selected ? _AuthScreenState._text : _AuthScreenState._muted,
            letterSpacing: -0.15,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

class _LoginFields extends StatelessWidget {
  const _LoginFields({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AuthTextField(
          controller: emailController,
          placeholder: 'Email',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: CupertinoIcons.mail,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        _AuthTextField(
          controller: passwordController,
          placeholder: 'Password',
          prefixIcon: CupertinoIcons.lock,
          obscureText: obscurePassword,
          suffix: _PasswordEyeButton(
            obscure: obscurePassword,
            onTap: onTogglePassword,
          ),
        ),
      ],
    );
  }
}

class _RegisterFields extends StatelessWidget {
  const _RegisterFields({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AuthTextField(
          controller: nameController,
          placeholder: 'Nama pengguna',
          prefixIcon: CupertinoIcons.person,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        _AuthTextField(
          controller: emailController,
          placeholder: 'Email',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: CupertinoIcons.mail,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        _AuthTextField(
          controller: passwordController,
          placeholder: 'Password',
          prefixIcon: CupertinoIcons.lock,
          obscureText: obscurePassword,
          suffix: _PasswordEyeButton(
            obscure: obscurePassword,
            onTap: onTogglePassword,
          ),
        ),
      ],
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.placeholder,
    required this.prefixIcon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffix,
  });

  final TextEditingController controller;
  final String placeholder;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_AuthScreenState._fieldRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CupertinoColors.white.withOpacity(0.082),
            CupertinoColors.white.withOpacity(0.036),
          ],
        ),
        border: Border.all(
          color: _AuthScreenState._border,
          width: 0.8,
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            spreadRadius: -10,
            color: Color(0x8E000000),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 18,
            right: 18,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CupertinoColors.white.withOpacity(0),
                    CupertinoColors.white.withOpacity(0.24),
                    CupertinoColors.white.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          CupertinoTextField.borderless(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            placeholder: placeholder,
            placeholderStyle: AppTypography.textRegular13.copyWith(
              color: _AuthScreenState._muted.withOpacity(0.76),
              fontSize: 14,
            ),
            style: AppTypography.textMedium15.copyWith(
              color: _AuthScreenState._text,
              fontSize: 14.5,
              letterSpacing: -0.1,
            ),
            prefix: Padding(
              padding: const EdgeInsets.only(left: 14, right: 8),
              child: Icon(
                prefixIcon,
                size: 17,
                color: _AuthScreenState._muted.withOpacity(0.86),
              ),
            ),
            suffix: suffix,
            suffixMode: OverlayVisibilityMode.always,
            cursorColor: _AuthScreenState._text,
          ),
        ],
      ),
    );
  }
}

class _PasswordEyeButton extends StatelessWidget {
  const _PasswordEyeButton({
    required this.obscure,
    required this.onTap,
  });

  final bool obscure;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.only(left: 6, right: 13),
      minimumSize: Size.zero,
      onPressed: onTap,
      child: Icon(
        obscure ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
        size: 18,
        color: _AuthScreenState._muted.withOpacity(0.9),
      ),
    );
  }
}

class _LiquidActionButton extends StatefulWidget {
  const _LiquidActionButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.filled = false,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool filled;
  final bool isLoading;

  @override
  State<_LiquidActionButton> createState() => _LiquidActionButtonState();
}

class _LiquidActionButtonState extends State<_LiquidActionButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value || widget.onPressed == null) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) {
        _setPressed(false);
        widget.onPressed?.call();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.975 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: enabled ? 1 : 0.62,
          duration: const Duration(milliseconds: 160),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
              gradient: widget.filled
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.accentPrimary.withOpacity(0.92),
                        AppColors.accentPrimary.withOpacity(0.68),
                        AppColors.accentSecondary.withOpacity(0.50),
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        CupertinoColors.white.withOpacity(0.105),
                        CupertinoColors.white.withOpacity(0.045),
                      ],
                    ),
              border: Border.all(
                color: widget.filled
                    ? CupertinoColors.white.withOpacity(0.20)
                    : _AuthScreenState._border,
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: widget.filled ? 26 : 18,
                  spreadRadius: -10,
                  color: widget.filled
                      ? AppColors.accentPrimary.withOpacity(0.48)
                      : const Color(0x97000000),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 24,
                  right: 24,
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          CupertinoColors.white.withOpacity(0),
                          CupertinoColors.white.withOpacity(0.42),
                          CupertinoColors.white.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: widget.isLoading
                      ? const CupertinoActivityIndicator(
                          color: _AuthScreenState._text,
                        )
                      : Text(
                          widget.label,
                          style: AppTypography.textMedium15.copyWith(
                            color: _AuthScreenState._text,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.1,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthErrorBanner extends StatelessWidget {
  const _AuthErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.destructive.withOpacity(0.14),
        borderRadius: BorderRadius.circular(_AuthScreenState._fieldRadius),
        border: Border.all(
          color: AppColors.destructive.withOpacity(0.28),
        ),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTypography.textRegular13.copyWith(
          color: const Color(0xFFFF9A92),
          height: 1.35,
        ),
      ),
    );
  }
}
