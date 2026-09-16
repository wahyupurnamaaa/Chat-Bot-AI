import 'package:flutter/material.dart';
import '../services/app_store.dart';
import '../widgets/brand.dart';
import 'profile.dart';

class OnboardingScreen extends StatefulWidget {
  final AppStore store;
  const OnboardingScreen({super.key, required this.store});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int page = 0;
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (mounted && page == 0) {
        setState(() => page = 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (page == 0) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Brand(size: 120),
              SizedBox(height: 24),
              Text(
                'Nova AI',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40),
              CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () =>
                          widget.store.toggleTheme(!widget.store.dark),
                      icon: const Icon(Icons.brightness_6_outlined),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: page == 1
                            ? Transform.rotate(
                                angle: -.09,
                                child: Container(
                                  width: 235,
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline
                                          .withValues(alpha: .3),
                                      width: 5,
                                    ),
                                    borderRadius: BorderRadius.circular(32),
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    boxShadow: [
                                      BoxShadow(
                                        color: purple.withValues(alpha: .15),
                                        blurRadius: 36,
                                        offset: const Offset(0, 16),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Brand(size: 62),
                                      const SizedBox(height: 20),
                                      _bubble(
                                        'Bagaimana memulai ide baru?',
                                        true,
                                      ),
                                      _bubble(
                                        'Setiap ide hebat dimulai dari rasa ingin tahu. Mari kita wujudkan bersama.',
                                        false,
                                      ),
                                      _bubble(
                                        'Bantu saya membuat rencana ✨',
                                        true,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : const Brand(size: 170),
                      ),
                    ),
                  ),
                  Text(
                    page == 1
                        ? 'Chat tanpa batas,\nkapan saja.'
                        : 'Ide besar dimulai\ndari percakapan.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 29,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Asisten AI pribadi untuk menulis, belajar, dan menemukan inspirasi setiap hari.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      height: 1.6,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 1; i <= 2; i++)
                        Container(
                          margin: const EdgeInsets.all(4),
                          width: page == i ? 24 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: page == i ? purple : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  primaryButton(page == 1 ? 'Selanjutnya' : 'Masuk', () {
                    if (page == 1) {
                      setState(() => page = 2);
                    } else {
                      _auth(false);
                    }
                  }),
                  TextButton(
                    onPressed: () =>
                        page == 1 ? setState(() => page = 2) : _auth(true),
                    child: Text(page == 1 ? 'Lewati' : 'Buat akun'),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bubble(String text, bool user) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: user
          ? purple
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      text,
      style: TextStyle(fontSize: 12, color: user ? Colors.white : null),
    ),
  );
  void _auth(bool signup) => Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => AuthScreen(store: widget.store, signup: signup),
    ),
  );
}

class AuthScreen extends StatefulWidget {
  final AppStore store;
  final bool signup;
  const AuthScreen({super.key, required this.store, required this.signup});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  bool accepted = false, obscure = true;
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Brand(size: 72),
            const SizedBox(height: 32),
            Text(
              widget.signup ? 'Halo, teman baru!' : 'Selamat datang kembali!',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Mode demo lokal. Akun belum terhubung ke layanan autentikasi.',
              style: TextStyle(height: 1.5),
            ),
            const SizedBox(height: 28),
            Form(
              key: form,
              child: Column(
                children: [
                  TextFormField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) =>
                        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v ?? '')
                        ? null
                        : 'Masukkan email yang valid',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: password,
                    obscureText: obscure,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => obscure = !obscure),
                        icon: Icon(
                          obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                    ),
                    validator: (v) =>
                        (v ?? '').length >= 8 ? null : 'Minimal 8 karakter',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: accepted,
              onChanged: (v) => setState(() => accepted = v!),
              title: const Text(
                'Saya memahami ini akun demo lokal.',
                style: TextStyle(fontSize: 13),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 24),
            primaryButton('Lanjutkan', () {
              if (form.currentState!.validate() && accepted) {
                widget.store.email = email.text.trim();
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        ProfileScreen(store: widget.store, onboarding: true),
                  ),
                );
              } else if (!accepted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Centang persetujuan mode demo terlebih dahulu.',
                    ),
                  ),
                );
              }
            }),
          ],
        ),
      ),
    ),
  );
}
