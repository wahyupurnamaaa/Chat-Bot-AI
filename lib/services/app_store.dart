import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/conversation.dart';

class AppStore extends ChangeNotifier {
  final SharedPreferences prefs;
  AppStore(this.prefs) {
    dark = prefs.getBool('dark') ?? false;
    name = prefs.getString('name') ?? '';
    email = prefs.getString('email') ?? '';
    signedIn = prefs.getBool('signedIn') ?? false;
    try {
      conversations.addAll(
        (jsonDecode(prefs.getString('chats') ?? '[]') as List).map(
          (e) => Conversation.fromJson(Map<String, dynamic>.from(e)),
        ),
      );
    } catch (_) {
      /* Ignore invalid local history, preserving profile access. */
    }
  }
  late bool dark, signedIn;
  late String name, email;
  final List<Conversation> conversations = [];
  Future<void> persist() async {
    await prefs.setBool('dark', dark);
    await prefs.setBool('signedIn', signedIn);
    await prefs.setString('name', name);
    await prefs.setString('email', email);
    await prefs.setString(
      'chats',
      jsonEncode(conversations.map((c) => c.toJson()).toList()),
    );
    notifyListeners();
  }

  void toggleTheme(bool value) {
    dark = value;
    persist();
  }

  void logout() {
    signedIn = false;
    persist();
  }

  void remove(Conversation c) {
    conversations.remove(c);
    persist();
  }
}
