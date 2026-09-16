import 'package:flutter/material.dart';
import '../services/app_store.dart';
import '../widgets/brand.dart';
import 'chat.dart';
import 'settings.dart';

class HomeScreen extends StatefulWidget {
  final AppStore store;
  const HomeScreen({super.key, required this.store});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int tab = 0;
  String category = 'Semua', query = '';
  final helpers = const [
    (
      'Penulis Esai',
      'Struktur dan ide untuk tulisan yang berkesan.',
      Icons.edit_note,
      'Menulis',
    ),
    (
      'Penulis Akademik',
      'Susun gagasan akademik dengan lebih jelas.',
      Icons.school_outlined,
      'Menulis',
    ),
    (
      'Lirik & Lagu',
      'Temukan irama untuk setiap cerita.',
      Icons.music_note_outlined,
      'Menulis',
    ),
    (
      'Pencerita',
      'Hidupkan imajinasi dalam sebuah cerita.',
      Icons.auto_stories_outlined,
      'Menulis',
    ),
    (
      'Pembuat Email',
      'Pesan profesional untuk setiap kesempatan.',
      Icons.alternate_email,
      'Bisnis',
    ),
    (
      'Pelatih Wawancara',
      'Persiapkan langkah karier berikutnya.',
      Icons.work_outline,
      'Bisnis',
    ),
    (
      'Teman Refleksi',
      'Ruang untuk mencatat pikiran harian.',
      Icons.spa_outlined,
      'Keseharian',
    ),
    (
      'Penyemangat',
      'Inspirasi kecil untuk hari yang lebih baik.',
      Icons.wb_sunny_outlined,
      'Keseharian',
    ),
  ];
  void openChat([String title = 'Chat baru']) => Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => ChatScreen(store: widget.store, title: title),
    ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        ['Nova AI', 'Asisten AI', 'Riwayat', 'Pengaturan'][tab],
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        if (tab == 0)
          const Padding(
            padding: EdgeInsets.only(right: 20),
            child: Brand(size: 38),
          ),
        if (tab == 2)
          IconButton(
            tooltip: 'Hapus semua riwayat',
            onPressed: widget.store.conversations.isEmpty ? null : clearHistory,
            icon: const Icon(Icons.delete_outline),
          ),
      ],
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: [
          landing,
          assistants,
          history,
          () => SettingsBody(store: widget.store),
        ][tab](),
      ),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: tab,
      onDestinationSelected: (v) => setState(() => tab = v),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.chat_bubble_outline),
          selectedIcon: Icon(Icons.chat_bubble),
          label: 'Chat',
        ),
        NavigationDestination(
          icon: Icon(Icons.grid_view_outlined),
          selectedIcon: Icon(Icons.grid_view_rounded),
          label: 'Asisten AI',
        ),
        NavigationDestination(icon: Icon(Icons.history), label: 'Riwayat'),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Pengaturan',
        ),
      ],
    ),
  );
  Widget landing() => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      const SizedBox(height: 20),
      Text(
        'Halo, ${widget.store.name} 👋',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      const SizedBox(height: 12),
      const Text(
        'Ide tak terbatas.\nMulai satu percakapan.',
        style: TextStyle(
          fontSize: 32,
          height: 1.2,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 28),
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: purple,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
            const SizedBox(height: 22),
            const Text(
              'Teman berpikir,\nsetiap saat.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Menulis, merencanakan, atau sekadar mencari inspirasi.',
              style: TextStyle(color: Colors.white70, height: 1.5),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: purple,
              ),
              onPressed: () => openChat(),
              label: const Text('Mulai chat baru'),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
      const SizedBox(height: 30),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Dibuat untuk keseharianmu',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          IconButton(
            onPressed: () => setState(() => tab = 1),
            icon: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
      for (final item in helpers.take(3))
        Card(
          child: ListTile(
            leading: Icon(
              item.$3,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(item.$1),
            subtitle: Text(item.$2),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => openChat(item.$1),
          ),
        ),
      const SizedBox(height: 16),
      const Text(
        'Versi demo • Periksa kembali informasi penting.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
    ],
  );
  Widget assistants() => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final c in ['Semua', 'Menulis', 'Bisnis', 'Keseharian'])
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
      for (final group in ['Menulis', 'Bisnis', 'Keseharian'])
        if (category == 'Semua' || category == group) ...[
          Text(
            group,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) => GridView.count(
              crossAxisCount: constraints.maxWidth > 600 ? 3 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: .9,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                for (final h in helpers.where((e) => e.$4 == group))
                  Card(
                    margin: EdgeInsets.zero,
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => openChat(h.$1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(13),
                              decoration: BoxDecoration(
                                color: purple.withValues(alpha: .1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                h.$3,
                                size: 32,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              h.$1,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              h.$2,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, height: 1.4),
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 26),
        ],
    ],
  );
  Widget history() {
    final chats = widget.store.conversations
        .where(
          (c) =>
              c.title.toLowerCase().contains(query.toLowerCase()) ||
              c.messages.any(
                (m) => m.content.toLowerCase().contains(query.toLowerCase()),
              ),
        )
        .toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: TextField(
            onChanged: (v) => setState(() => query = v),
            decoration: const InputDecoration(
              hintText: 'Cari percakapan',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: chats.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 76,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: .35),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        query.isEmpty
                            ? 'Belum ada percakapan'
                            : 'Tidak ditemukan',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Mulai chat atau gunakan kata kunci lain.'),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () => openChat(),
                        child: const Text('Mulai percakapan'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: chats.length,
                  itemBuilder: (context, i) {
                    final c = chats[i];
                    return Dismissible(
                      key: ValueKey(c.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.all(20),
                        color: Colors.redAccent,
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                        ),
                      ),
                      confirmDismiss: (_) => confirm(
                        'Hapus percakapan?',
                        'Percakapan ini akan dihapus dari perangkat.',
                      ),
                      onDismissed: (_) => widget.store.remove(c),
                      child: Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          title: Text(
                            c.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${c.messages.length} pesan',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => ChatScreen(
                                store: widget.store,
                                conversation: c,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<bool> confirm(String title, String text) async =>
      await showModalBottomSheet<bool>(
        context: context,
        showDragHandle: true,
        builder: (context) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                Text(text, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                primaryButton('Hapus', () => Navigator.pop(context, true)),
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
              ],
            ),
          ),
        ),
      ) ??
      false;
  Future<void> clearHistory() async {
    if (await confirm(
      'Hapus semua riwayat?',
      'Semua percakapan di perangkat akan dihapus. Tindakan ini tidak dapat dibatalkan.',
    )) {
      widget.store.conversations.clear();
      await widget.store.persist();
    }
  }
}
