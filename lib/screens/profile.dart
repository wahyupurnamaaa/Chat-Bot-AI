import 'package:flutter/material.dart';
import '../services/app_store.dart';
import '../widgets/brand.dart';

class ProfileScreen extends StatefulWidget {
  final AppStore store;
  final bool onboarding;
  const ProfileScreen({
    super.key,
    required this.store,
    this.onboarding = false,
  });
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final form = GlobalKey<FormState>();
  late final name = TextEditingController(text: widget.store.name);
  late final email = TextEditingController(text: widget.store.email);
  @override
  void dispose() {
    name.dispose();
    email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.onboarding ? '' : 'Informasi pribadi')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Lengkapi profilmu!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Sedikit tentangmu untuk percakapan yang lebih personal.',
            ),
            const SizedBox(height: 36),
            const Center(
              child: CircleAvatar(
                radius: 48,
                child: Icon(Icons.person_outline, size: 48),
              ),
            ),
            const SizedBox(height: 36),
            Form(
              key: form,
              child: Column(
                children: [
                  TextFormField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'Nama'),
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) =>
                        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v ?? '')
                        ? null
                        : 'Email tidak valid',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            primaryButton(
              widget.onboarding ? 'Mulai sekarang' : 'Simpan profil',
              () async {
                if (!form.currentState!.validate()) {
                  return;
                }
                widget.store.name = name.text.trim();
                widget.store.email = email.text.trim();
                widget.store.signedIn = true;
                await widget.store.persist();
                if (!context.mounted) {
                  return;
                }
                if (widget.onboarding) {
                  Navigator.popUntil(context, (r) => r.isFirst);
                } else {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    ),
  );
}
