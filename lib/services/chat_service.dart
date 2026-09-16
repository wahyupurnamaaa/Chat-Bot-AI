import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/conversation.dart';

class ChatService {
  static const endpoint = String.fromEnvironment('AI_ENDPOINT');
  static bool get isDemo => endpoint.isEmpty;
  Future<String> reply(List<Message> messages) async {
    if (isDemo) {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      final prompt = messages.last.content;
      return 'Ini respons demo untuk: “$prompt”\n\nMari mulai dengan tiga langkah:\n\n1. Tentukan tujuan dan konteks yang ingin dicapai.\n2. Buat kerangka sederhana dengan poin utama.\n3. Kembangkan tiap poin, lalu periksa hasilnya.\n\nTambahkan detail agar percakapan lebih spesifik. Hubungkan AI_ENDPOINT untuk jawaban AI sungguhan.';
    }
    final response = await http
        .post(
          Uri.parse(endpoint),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'messages': messages.map((m) => m.toJson()).toList(),
          }),
        )
        .timeout(const Duration(seconds: 40));
    if (response.statusCode != 200) {
      throw Exception(
        'Server tidak tersedia (${response.statusCode}). Coba lagi.',
      );
    }
    final data = jsonDecode(response.body);
    if (data is! Map ||
        data['reply'] is! String ||
        (data['reply'] as String).trim().isEmpty) {
      throw Exception('Format respons server tidak valid.');
    }
    return data['reply'] as String;
  }
}
