import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/auth_service.dart';
import '../theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  //Open the app and log in with:
  //Email: admin@cloudops.internal
  //Password: Password123!
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _remember = false;
  bool _loading = false;
  bool _showPassword = false;
  final AuthService _auth = AuthService();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  bool _emailFocused = false;
  bool _passFocused = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    final token = await _auth.login(
      _emailCtrl.text.trim(),
      _passCtrl.text,
      remember: _remember,
    );
    setState(() => _loading = false);
    if (!mounted) return;
    if (token != null) {
      // navigate into the app on successful login
      Navigator.pushReplacementNamed(context, '/app');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sign-in failed')));
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? GlassColors.darkBg : GlassColors.lightBg,
      body: Stack(
        children: [
          // Animated gradient background with liquid effect
          AnimatedContainer(
            duration: const Duration(seconds: 3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF0F1419),
                        const Color(0xFF1a2f4a),
                        const Color(0xFF0d1b2a),
                      ]
                    : [
                        const Color(0xFFF8FAFF),
                        const Color(0xFFEEF4FF),
                        const Color(0xFFF5EBFF),
                      ],
              ),
            ),
          ),
          // Animated accent blob (liquid glass effect)
          Positioned(
            top: -100,
            right: -100,
            child: AnimatedOpacity(
              opacity: 0.1,
              duration: const Duration(seconds: 3),
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? Colors.blue : Colors.blue.shade300,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -150,
            child: AnimatedOpacity(
              opacity: 0.08,
              duration: const Duration(seconds: 3),
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? Colors.purple : Colors.purple.shade200,
                ),
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 20),
                        // Animated logo with premium glass effect
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 1200),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: 0.8 + (value * 0.2),
                              child: Opacity(
                                opacity: value,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 20 * value,
                                      sigmaY: 20 * value,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Colors.white.withOpacity(0.08)
                                            : Colors.white.withOpacity(0.25),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isDark
                                              ? Colors.white.withOpacity(0.2)
                                              : Colors.white.withOpacity(0.4),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: isDark
                                                ? Colors.black.withOpacity(0.3)
                                                : Colors.black.withOpacity(0.1),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.terminal,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 1400),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Column(
                                children: [
                                  Text(
                                    'CloudOps',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.5,
                                          fontSize: 32,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Identity & Access Management',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: isDark
                                              ? Colors.white60
                                              : Colors.black54,
                                          fontSize: 14,
                                        ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 40),

                        // Premium glassmorphic card with liquid effect
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 1600),
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: Opacity(
                                opacity: value,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(28),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 25,
                                      sigmaY: 25,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Colors.white.withOpacity(0.06)
                                            : Colors.white.withOpacity(0.35),
                                        borderRadius: BorderRadius.circular(28),
                                        border: Border.all(
                                          color: isDark
                                              ? Colors.white.withOpacity(0.15)
                                              : Colors.white.withOpacity(0.35),
                                          width: 1.8,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: isDark
                                                ? Colors.black.withOpacity(0.4)
                                                : Colors.black.withOpacity(
                                                    0.15,
                                                  ),
                                            blurRadius: 30,
                                            offset: const Offset(0, 15),
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(28),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                            'Sign in',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 24,
                                                ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Enter your credentials to access the console',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: isDark
                                                      ? Colors.white60
                                                      : Colors.black54,
                                                ),
                                          ),
                                          const SizedBox(height: 28),
                                          // Email field with smooth transition
                                          _buildAnimatedTextField(
                                            controller: _emailCtrl,
                                            label: 'Work email',
                                            icon: Icons.email,
                                            isDark: isDark,
                                            onFocusChanged: (focused) {
                                              setState(
                                                () => _emailFocused = focused,
                                              );
                                            },
                                            isFocused: _emailFocused,
                                          ),
                                          const SizedBox(height: 16),
                                          // Password field with smooth transition
                                          _buildAnimatedPasswordField(
                                            controller: _passCtrl,
                                            isDark: isDark,
                                            onFocusChanged: (focused) {
                                              setState(
                                                () => _passFocused = focused,
                                              );
                                            },
                                            isFocused: _passFocused,
                                          ),
                                          const SizedBox(height: 16),
                                          // Remember checkbox with smooth transition
                                          AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8,
                                              horizontal: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _remember
                                                  ? Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                        .withOpacity(0.1)
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: _remember
                                                    ? Theme.of(context)
                                                          .colorScheme
                                                          .primary
                                                          .withOpacity(0.3)
                                                    : Colors.transparent,
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Transform.scale(
                                                  scale: 1.1,
                                                  child: Checkbox(
                                                    value: _remember,
                                                    onChanged: (v) {
                                                      setState(
                                                        () => _remember =
                                                            v ?? false,
                                                      );
                                                    },
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    'Remember this device for 30 days',
                                                    style: Theme.of(
                                                      context,
                                                    ).textTheme.bodySmall,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          // Sign in button with smooth animations
                                          _buildAnimatedSignInButton(
                                            isDark: isDark,
                                          ),
                                          const SizedBox(height: 20),
                                          Divider(
                                            color: isDark
                                                ? Colors.white.withOpacity(0.1)
                                                : Colors.black.withOpacity(0.1),
                                            thickness: 1,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'OR CONTINUE WITH',
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(
                                                  color: isDark
                                                      ? Colors.white54
                                                      : Colors.black54,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            children: [
                                              Expanded(
                                                child:
                                                    _buildAnimatedOutlineButton(
                                                      label: 'SSO',
                                                      isDark: isDark,
                                                    ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child:
                                                    _buildAnimatedOutlineButton(
                                                      label: 'LDAP',
                                                      isDark: isDark,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 40),
                        Text(
                          'Privacy Policy • Security Audit • Contact Support',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'NODE_ID: 0X-FC892-PROD',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: isDark ? Colors.white30 : Colors.black38,
                              ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    required Function(bool) onFocusChanged,
    required bool isFocused,
  }) {
    final FocusNode focusNode = FocusNode();

    focusNode.addListener(() {
      onFocusChanged(focusNode.hasFocus);
    });

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: isFocused
                  ? (isDark
                        ? Colors.white.withOpacity(0.12)
                        : Colors.white.withOpacity(0.5))
                  : (isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.white.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isFocused
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                    : (isDark
                          ? Colors.white.withOpacity(0.15)
                          : Colors.white.withOpacity(0.25)),
                width: isFocused ? 2 : 1.5,
              ),
            ),
            child: TextField(
              focusNode: focusNode,
              controller: controller,
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: InputDecoration(
                labelText: label,
                prefixIcon: Icon(icon),
                filled: true,
                fillColor: Colors.transparent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isFocused
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedPasswordField({
    required TextEditingController controller,
    required bool isDark,
    required Function(bool) onFocusChanged,
    required bool isFocused,
  }) {
    final FocusNode focusNode = FocusNode();

    focusNode.addListener(() {
      onFocusChanged(focusNode.hasFocus);
    });

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: isFocused
                  ? (isDark
                        ? Colors.white.withOpacity(0.12)
                        : Colors.white.withOpacity(0.5))
                  : (isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.white.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isFocused
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                    : (isDark
                          ? Colors.white.withOpacity(0.15)
                          : Colors.white.withOpacity(0.25)),
                width: isFocused ? 2 : 1.5,
              ),
            ),
            child: TextField(
              focusNode: focusNode,
              controller: controller,
              obscureText: !_showPassword,
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: AnimatedIconButton(
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                  icon: _showPassword ? Icons.visibility : Icons.visibility_off,
                ),
                filled: true,
                fillColor: Colors.transparent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isFocused
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSignInButton({required bool isDark}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _loading ? null : _submit,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: _loading
                  ? [
                      Theme.of(context).colorScheme.primary.withOpacity(0.6),
                      Theme.of(context).colorScheme.secondary.withOpacity(0.6),
                    ]
                  : [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: _loading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withOpacity(0.8),
                      ),
                    ),
                  )
                : Text(
                    'SIGN IN TO CONSOLE',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedOutlineButton({
    required String label,
    required bool isDark,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.2)
                  : Colors.black.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedIconButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;

  const AnimatedIconButton({
    required this.onPressed,
    required this.icon,
    super.key,
  });

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 1.15).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
          ),
          child: IconButton(
            onPressed: widget.onPressed,
            icon: Icon(widget.icon),
            splashRadius: 24,
          ),
        ),
      ),
    );
  }
}
