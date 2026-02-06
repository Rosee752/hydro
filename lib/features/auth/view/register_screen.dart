import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../dashboard/widgets/mood_background.dart';
import '../../dashboard/widgets/bubble_field.dart';
import '../../dashboard/widgets/weather_chip.dart';
import '../widgets/auth_controller.dart';

/// Registration screen wrapped in the calming background.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _nameCtl  = TextEditingController();
  final _mailCtl  = TextEditingController();
  final _phoneCtl = TextEditingController();
  final _pwdCtl   = TextEditingController();

  bool _obscure = true;
  bool _busy    = false;

  @override
  void dispose() {
    _nameCtl.dispose();
    _mailCtl.dispose();
    _phoneCtl.dispose();
    _pwdCtl.dispose();
    super.dispose();
  }

  // ───────────────────────────── UI
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
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop()),
              const SizedBox(height: 16),

              Text('Create account',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text('Join the Hydro! universe',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),

              _glassCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _input(
                        controller: _nameCtl,
                        hint: 'Full name',
                        icon: Icons.person_outline,
                        validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      _input(
                        controller: _mailCtl,
                        hint: 'Email',
                        icon: Icons.mail_outline,
                        validator: (v) => v != null && v.contains('@')
                            ? null
                            : 'Invalid email',
                      ),
                      const SizedBox(height: 12),
                      _input(
                        controller: _phoneCtl,
                        hint: 'Phone (optional “+”)',
                        icon: Icons.phone_android_outlined,
                        // accepts only + and digits
                        validator: (v) {
                          final s = v?.trim() ?? '';
                          final ok = RegExp(r'^\+?\d*$').hasMatch(s);
                          return ok ? null : 'Digits only';
                        },
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
                      const SizedBox(height: 20),
                      _primaryBtn(
                        label: 'Create Account',
                        busy: _busy,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Wrap(
                  children: [
                    const Text('I already have an account  '),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Text(
                        'Log in',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  // ───────────────────────────── helpers
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

  // ───────────────────────────── submit logic
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);

    final auth = Provider.of<AuthController>(context, listen: false);
    final ok   = await auth.register(
      fullName: _nameCtl.text.trim(),
      email   : _mailCtl.text.trim(),
      phone   : _phoneCtl.text.trim(),
      password: _pwdCtl.text,
    );

    setState(() => _busy = false);
    if (!mounted) return;

    if (ok) {
      // 🎉  welcome snackbar with the name they just typed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome, ${auth.current?.fullName}!')),
      );
      context.go('/dashboard');
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Email already in use')));
    }
  }

}
