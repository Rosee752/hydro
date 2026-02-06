import 'dart:ui';
//demo@hydro.app / password123
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';          // ← routing ext.

import '../../../core/services/local_storage.dart';
import '../../dashboard/widgets/mood_background.dart';
import '../../dashboard/widgets/bubble_field.dart';
import '../../dashboard/widgets/weather_chip.dart';
import '../widgets/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mailCtl = TextEditingController();
  final _pwdCtl  = TextEditingController();

  bool _obscure  = true;
  bool _remember = false;
  bool _busy     = false;

  @override
  void initState() {
    super.initState();
    _remember = LocalStorage().getBool('remember_me') ?? false;
  }

  @override
  void dispose() {
    _mailCtl.dispose();
    _pwdCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    extendBodyBehindAppBar: true,
    body: Stack(
      children: [
        const MoodBackground(progress: 0),
        const BubbleField(),
        const Positioned(top: 8, right: 12, child: WeatherChip()),
        SingleChildScrollView(
          padding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => context.pop(),
              ),
              const SizedBox(height: 16),

              Text('Login',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text('Securely login to your account',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),

              _glassCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _input(
                        controller: _mailCtl,
                        hint: 'Email',
                        icon: Icons.mail_outline,
                        validator: (v) => v == null || !v.contains('@')
                            ? 'Enter a valid email'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _input(
                        controller: _pwdCtl,
                        hint: 'Password',
                        icon: Icons.lock_outline,
                        obscure: _obscure,
                        suffix: IconButton(
                          icon: AnimatedRotation(
                            turns: _obscure ? 0 : .5,
                            duration:
                            const Duration(milliseconds: 300),
                            child: const Icon(Icons.visibility),
                          ),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                        validator: (v) =>
                        v != null && v.length >= 6
                            ? null
                            : 'Min 6 characters',
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Checkbox(
                              value: _remember,
                              onChanged: (v) =>
                                  setState(() => _remember = v!)),
                          const Text('Remember me'),
                          const Spacer(),
                          TextButton(
                            onPressed: () =>
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Feature coming soon'))),
                            child: const Text('Forgot password?'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _primaryBtn(
                        label: 'LOG IN',
                        busy: _busy,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              _divider('OR Continue with'),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialBtn(label: 'G'),
                  const SizedBox(width: 16),
                  _socialBtn(label: 'f'),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: Wrap(
                  children: [
                    const Text('Create an account  '),
                    GestureDetector(
                      onTap: () => context.push('/register'),
                      child: const Text('Sign Up',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline)),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    ),
  );

  // ── small UI helpers (unchanged from previous message) ──────────
  Widget _glassCard({required Widget child}) => ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.85),
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      ),
    ),
  );

  Widget _input({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) =>
      AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12,
                offset: Offset(0, 1),
                blurRadius: 2,
                spreadRadius: 0),
          ],
        ),
        child: TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscure,
          decoration: InputDecoration(
            icon: Icon(icon),
            hintText: hint,
            border: InputBorder.none,
            suffixIcon: suffix,
          ),
        ),
      );

  Widget _primaryBtn({
    required String label,
    required VoidCallback onPressed,
    required bool busy,
  }) {
    return SizedBox(
      width: double.infinity,          // take all horizontal space
      height: 48,
      child: ElevatedButton(
        onPressed: busy ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 4,
          padding: EdgeInsets.zero,    // so Ink covers the full button
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          // backgroundColor must be transparent so the Ink gradient shows
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shadowColor: const Color(0x552196F3),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6DD5FA), Color(0xFF2196F3)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: busy
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.white,
              ),
            )
                : Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider(String text) => Row(
    children: [
      const Expanded(child: Divider()),
      const SizedBox(width: 8),
      Text(text),
      const SizedBox(width: 8),
      const Expanded(child: Divider()),
    ],
  );

  Widget _socialBtn({required String label}) => InkWell(
    onTap: null,
    borderRadius: BorderRadius.circular(24),
    child: Ink(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold))),
    ),
  );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    final ok = await Provider.of<AuthController>(context, listen: false)
        .login(
      email: _mailCtl.text.trim(),
      password: _pwdCtl.text,
      rememberMe: _remember,
    );
    setState(() => _busy = false);
    if (!mounted) return;
    if (ok) {
      context.go('/dashboard');
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Invalid credentials')));
    }
  }
}
