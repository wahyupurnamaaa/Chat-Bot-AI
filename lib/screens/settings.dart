import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/app_store.dart';
import '../widgets/brand.dart';
import 'profile.dart';

class SettingsBody extends StatelessWidget {
  final AppStore store;
  const SettingsBody({super.key, required this.store});
  @override
  Widget build(BuildContext context) {
    void page(Widget child) =>
        Navigator.push(context, MaterialPageRoute<void>(builder: (_) => child));
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const CircleAvatar(child: Icon(Icons.person_outline)),
            title: Text(
              store.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(store.email),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'AKUN',
          style: TextStyle(fontSize: 11, letterSpacing: 2, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        _tile(
          Icons.person_outline,
          'Informasi pribadi',
          () => page(ProfileScreen(store: store)),
        ),
        _tile(
          Icons.workspace_premium_outlined,
          'Upgrade ke Premium',
          () => page(const PremiumScreen()),
        ),
        _tile(
          Icons.shield_outlined,
          'Kontrol data',
          () => page(DataScreen(store: store)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.dark_mode_outlined),
          title: const Text('Tema gelap'),
          value: store.dark,
          onChanged: store.toggleTheme,
        ),
        const SizedBox(height: 24),
        const Text(
          'TENTANG',
          style: TextStyle(fontSize: 11, letterSpacing: 2, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        _tile(
          Icons.help_outline,
          'Pusat bantuan',
          () => page(const HelpScreen()),
        ),
        _tile(
          Icons.description_outlined,
          'Ketentuan penggunaan',
          () => page(
            const TextScreen(
              title: 'Ketentuan penggunaan',
              text:
                  'Nova AI adalah prototipe aplikasi chatbot. Fitur login dan premium merupakan demonstrasi antarmuka. Tidak ada pembelian atau akun server yang dibuat.\n\nRespons demo bersifat ilustratif. Jika endpoint AI diaktifkan, hasil AI perlu ditinjau sebelum digunakan.\n\nDokumen ini adalah penjelasan demo, bukan ketentuan layanan produksi.',
            ),
          ),
        ),
        _tile(
          Icons.lock_outline,
          'Privasi',
          () => page(
            const TextScreen(
              title: 'Privasi',
              text:
                  'Nama, email, pilihan tema, dan riwayat disimpan secara lokal pada perangkat menggunakan SharedPreferences. Password tidak disimpan atau dikirim. Penyimpanan lokal ini tidak dienkripsi.\n\nDalam mode demo, pesan tidak dikirim ke server. Jika AI_ENDPOINT dikonfigurasi, isi percakapan dikirim ke endpoint tersebut.\n\nAnda dapat menyalin atau menghapus riwayat melalui Kontrol data. Keluar hanya mengakhiri sesi lokal; riwayat tetap tersimpan.',
            ),
          ),
        ),
        _tile(Icons.logout, 'Keluar', () async {
          final yes = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Keluar dari aplikasi?'),
              content: const Text(
                'Riwayat tetap tersimpan pada perangkat ini.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Keluar'),
                ),
              ],
            ),
          );
          if (yes == true) {
            store.logout();
          }
        }),
        const SizedBox(height: 28),
        const Center(
          child: Text(
            'Nova AI 1.0.0 • Dibuat untuk rasa ingin tahu',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _tile(IconData icon, String title, VoidCallback tap) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon),
    title: Text(title, style: const TextStyle(fontSize: 14)),
    trailing: const Icon(Icons.chevron_right, size: 18),
    onTap: tap,
  );
}

class TextScreen extends StatelessWidget {
  final String title, text;
  const TextScreen({super.key, required this.title, required this.text});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: SelectableText(text, style: const TextStyle(height: 1.8)),
    ),
  );
}

class DataScreen extends StatelessWidget {
  final AppStore store;
  const DataScreen({super.key, required this.store});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Kontrol data')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Icon(Icons.shield_outlined, size: 64, color: purple),
        const SizedBox(height: 24),
        const Text(
          'Datamu, kendalimu.',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          'Riwayat tersimpan di perangkat ini. Salin sebagai JSON untuk membuat cadangan.',
          style: TextStyle(height: 1.6),
        ),
        const SizedBox(height: 24),
        primaryButton('Salin data percakapan (JSON)', () async {
          await Clipboard.setData(
            ClipboardData(
              text: const JsonEncoder.withIndent(
                '  ',
              ).convert(store.conversations.map((e) => e.toJson()).toList()),
            ),
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data JSON disalin ke clipboard')),
            );
          }
        }),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () async {
            final yes = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Hapus seluruh percakapan?'),
                content: const Text(
                  'Data yang dihapus tidak dapat dikembalikan.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Batal'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Hapus'),
                  ),
                ],
              ),
            );
            if (yes == true) {
              store.conversations.clear();
              await store.persist();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Riwayat dihapus')),
                );
              }
            }
          },
          child: const Text('Hapus seluruh percakapan'),
        ),
      ],
    ),
  );
}

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});
  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  int selected = 1;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Upgrade ke Premium')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Center(child: Brand(size: 80)),
        const SizedBox(height: 22),
        const Text(
          'Lebih banyak ruang\nuntuk ide hebat.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          'Pratinjau paket • Pembayaran belum tersedia',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 28),
        for (int i = 0; i < 2; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => setState(() => selected = i),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: selected == i
                      ? purple
                      : Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DefaultTextStyle(
                  style: TextStyle(
                    color: selected == i
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                    height: 1.6,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              i == 0 ? 'Basic Plan' : 'Premium Plan',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(
                            selected == i
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: selected == i ? Colors.white : Colors.grey,
                          ),
                        ],
                      ),
                      Text(i == 0 ? 'Gratis' : '\$10 / bulan • ilustrasi'),
                      const SizedBox(height: 18),
                      Text(
                        i == 0
                            ? '✓ Chat demo\n✓ Pilihan asisten\n✓ Riwayat lokal'
                            : '✓ Konsep akses AI lebih luas\n✓ Konsep respons prioritas\n✓ Konsep fitur lanjutan',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
        primaryButton(
          'Lanjutkan',
          () => showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(selected == 0 ? 'Paket Basic' : 'Pratinjau Premium'),
              content: Text(
                selected == 0
                    ? 'Paket demo Basic sudah dapat digunakan.'
                    : 'Integrasi pembayaran belum dikonfigurasi. Tidak ada biaya yang dikenakan atau langganan yang diaktifkan.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Mengerti'),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});
  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  String category = 'Semua';
  final faqs = const [
    (
      'Apakah jawaban dibuat oleh AI?',
      'Mode demo memberikan respons simulasi. Jawaban AI sungguhan tersedia setelah backend AI_ENDPOINT dihubungkan.',
      'Prompt',
    ),
    (
      'Bagaimana mengganti profil?',
      'Buka Pengaturan → Informasi pribadi, ubah nama atau email, lalu simpan.',
      'Akun',
    ),
    (
      'Bagaimana mereset password?',
      'Versi ini memakai sesi demo lokal. Password tidak disimpan. Reset password memerlukan integrasi autentikasi produksi.',
      'Akun',
    ),
    (
      'Bisakah saya mengekspor data?',
      'Buka Pengaturan → Kontrol data → Salin data percakapan untuk menyalin riwayat dalam format JSON.',
      'Akun',
    ),
    (
      'Bagaimana menghapus riwayat?',
      'Geser percakapan ke kiri untuk menghapus satu chat, atau gunakan ikon tempat sampah untuk menghapus semua.',
      'Akun',
    ),
    (
      'Apakah Premium sudah tersedia?',
      'Halaman Premium adalah pratinjau desain. Tidak ada tagihan atau transaksi pada versi ini.',
      'Tagihan',
    ),
    (
      'Bagaimana membuat prompt yang baik?',
      'Sebutkan tujuan, konteks, format hasil, serta contoh jika diperlukan. Ajukan pertanyaan lanjutan untuk memperjelas jawaban.',
      'Prompt',
    ),
  ];
  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 2,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Pusat bantuan'),
        bottom: const TabBar(
          tabs: [
            Tab(text: 'FAQ'),
            Tab(text: 'Kontak'),
          ],
        ),
      ),
      body: TabBarView(
        children: [
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final c in ['Semua', 'Akun', 'Tagihan', 'Prompt'])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(c),
                          selected: category == c,
                          onSelected: (_) => setState(() => category = c),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              for (final f in faqs.where(
                (e) => category == 'Semua' || e.$3 == category,
              ))
                Card(
                  child: ExpansionTile(
                    title: Text(
                      f.$1,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    children: [Text(f.$2, style: const TextStyle(height: 1.6))],
                  ),
                ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.support_agent, size: 72, color: purple),
                SizedBox(height: 24),
                Text(
                  'Kami siap membantu',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  'Kanal dukungan belum dikonfigurasi pada versi demo. Hubungi pengelola aplikasi untuk informasi dukungan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
