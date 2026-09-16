import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/conversation.dart';
import '../services/app_store.dart';
import '../services/chat_service.dart';
import '../widgets/brand.dart';

class ChatScreen extends StatefulWidget {
  final AppStore store;
  final Conversation? conversation;
  final String title;
  const ChatScreen({
    super.key,
    required this.store,
    this.conversation,
    this.title = 'Chat baru',
  });
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final input = TextEditingController();
  final scroll = ScrollController();
  late Conversation chat =
      widget.conversation ??
      Conversation(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: widget.title,
      );
  bool busy = false;
  String? error;
  @override
  void dispose() {
    input.dispose();
    scroll.dispose();
    super.dispose();
  }

  void bottom() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted && scroll.hasClients) {
      scroll.animateTo(
        scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  });
  Future<void> send({bool retry = false}) async {
    if (busy || (!retry && input.text.trim().isEmpty)) {
      return;
    }
    final text = input.text.trim();
    setState(() {
      busy = true;
      error = null;
      if (!retry) {
        if (chat.messages.isEmpty && widget.title == 'Chat baru') {
          chat = Conversation(
            id: chat.id,
            title: text.length > 45 ? '${text.substring(0, 45)}…' : text,
          );
        }
        chat.messages.add(Message('user', text));
        input.clear();
        if (!widget.store.conversations.contains(chat)) {
          widget.store.conversations.insert(0, chat);
        }
      }
    });
    await widget.store.persist();
    bottom();
    try {
      final answer = await ChatService().reply(List.of(chat.messages));
      chat.messages.add(Message('assistant', answer));
      await widget.store.persist();
    } catch (_) {
      if (mounted) {
        setState(
          () => error =
              'Gagal mendapatkan jawaban. Periksa koneksi atau endpoint backend.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => busy = false);
        bottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(chat.title, overflow: TextOverflow.ellipsis),
      actions: [
        IconButton(
          tooltip: 'Salin percakapan',
          onPressed: () {
            Clipboard.setData(
              ClipboardData(
                text: chat.messages
                    .map((m) => '${m.role}: ${m.content}')
                    .join('\n\n'),
              ),
            );
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Percakapan disalin')));
          },
          icon: const Icon(Icons.copy_outlined),
        ),
      ],
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Column(
          children: [
            if (ChatService.isDemo)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: purple.withValues(alpha: .08),
                child: const Text(
                  'MODE DEMO • Respons simulasi',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, letterSpacing: 1),
                ),
              ),
            Expanded(
              child: chat.messages.isEmpty
                  ? _empty()
                  : ListView.builder(
                      controller: scroll,
                      padding: const EdgeInsets.all(20),
                      itemCount: chat.messages.length + (busy ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == chat.messages.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('Nova sedang menulis…'),
                          );
                        }
                        final m = chat.messages[index];
                        final user = m.role == 'user';
                        return Align(
                          alignment: user
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 540),
                            margin: EdgeInsets.only(
                              bottom: 18,
                              left: user ? 44 : 0,
                              right: user ? 0 : 36,
                            ),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: user
                                  ? purple
                                  : Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: SelectableText(
                              m.content,
                              style: TextStyle(
                                color: user ? Colors.white : null,
                                height: 1.6,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => send(retry: true),
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: input,
                        minLines: 1,
                        maxLines: 5,
                        enabled: !busy && error == null,
                        decoration: const InputDecoration(
                          hintText: 'Tulis pesanmu…',
                        ),
                        onSubmitted: (_) => send(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton.filled(
                      onPressed: busy || error != null ? null : () => send(),
                      style: IconButton.styleFrom(
                        backgroundColor: purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                      ),
                      icon: const Icon(Icons.arrow_upward),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  Widget _empty() => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      const SizedBox(height: 48),
      const Center(child: Brand(size: 104)),
      const SizedBox(height: 24),
      Text(
        'Apa yang ingin\nkamu ciptakan hari ini?',
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      const Text(
        'Mulai dengan ide kecil. Kita kembangkan bersama.',
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 36),
      for (final prompt in [
        'Buat kerangka artikel tentang gaya hidup sehat',
        'Bantu saya memasak pasta yang lezat',
        'Jelaskan konsep AI dengan sederhana',
      ])
        Card(
          child: ListTile(
            title: Text(prompt, style: const TextStyle(fontSize: 14)),
            trailing: const Icon(Icons.north_east, size: 18),
            onTap: () {
              input.text = prompt;
              send();
            },
          ),
        ),
    ],
  );
}
