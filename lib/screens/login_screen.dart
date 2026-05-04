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

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _remember = false;
  bool _loading = false;
  bool _showPassword = false;
  final AuthService _auth = AuthService();

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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? GlassColors.darkBg : GlassColors.lightBg,
      body: Stack(
        children: [
          // Subtle gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [GlassColors.darkBg, const Color(0xFF1a3a52)]
                    : [GlassColors.lightBg, const Color(0xFFE8F2FF)],
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  // Logo with frosted glass background
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0x2DF5F5F5)
                              : const Color(0x4DFFFFFF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? const Color(0x4DF5F5F5)
                                : const Color(0x80E0E5FF),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.terminal,
                          color: Theme.of(context).colorScheme.primary,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'CloudOps',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Identity & Access Management',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Sign-in glassmorphic card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0x1AF5F5F5)
                              : const Color(0x26FFFFFF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? const Color(0x4DF5F5F5)
                                : const Color(0x80E0E5FF),
                            width: 1.5,
                          ),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Sign in',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Enter your credentials to access the console',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.black54,
                                  ),
                            ),
                            const SizedBox(height: 20),
                            // Email field
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                child: TextField(
                                  controller: _emailCtrl,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  decoration: InputDecoration(
                                    labelText: 'Work email',
                                    prefixIcon: const Icon(Icons.email),
                                    filled: true,
                                    fillColor: isDark
                                        ? const Color(0x0DF5F5F5)
                                        : const Color(0x15FFFFFF),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: isDark
                                            ? const Color(0x3DF5F5F5)
                                            : const Color(0x80E0E5FF),
                                        width: 1.5,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: isDark
                                            ? const Color(0x3DF5F5F5)
                                            : const Color(0x80E0E5FF),
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Password field
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                child: TextField(
                                  controller: _passCtrl,
                                  obscureText: !_showPassword,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: const Icon(Icons.lock),
                                    suffixIcon: IconButton(
                                      onPressed: () => setState(
                                        () => _showPassword = !_showPassword,
                                      ),
                                      icon: Icon(
                                        _showPassword
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: isDark
                                        ? const Color(0x0DF5F5F5)
                                        : const Color(0x15FFFFFF),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: isDark
                                            ? const Color(0x3DF5F5F5)
                                            : const Color(0x80E0E5FF),
                                        width: 1.5,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: isDark
                                            ? const Color(0x3DF5F5F5)
                                            : const Color(0x80E0E5FF),
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Remember checkbox
                            Row(
                              children: [
                                Checkbox(
                                  value: _remember,
                                  onChanged: (v) =>
                                      setState(() => _remember = v ?? false),
                                ),
                                const SizedBox(width: 6),
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
                            const SizedBox(height: 16),
                            // Sign in button
                            ElevatedButton(
                              onPressed: _loading ? null : _submit,
                              child: _loading
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('SIGN IN TO CONSOLE'),
                            ),
                            const SizedBox(height: 16),
                            Divider(
                              color: isDark
                                  ? const Color(0x4DF5F5F5)
                                  : const Color(0x80E0E5FF),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'OR CONTINUE WITH',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black54,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {},
                                    child: const Text('SSO'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {},
                                    child: const Text('LDAP'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  Text(
                    'Privacy Policy • Security Audit • Contact Support',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'NODE_ID: 0X-FC892-PROD',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isDark ? Colors.white30 : Colors.black38,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }
}
