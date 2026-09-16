import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chat_bot_ai/main.dart';
import 'package:chat_bot_ai/services/app_store.dart';

void main() {
  testWidgets('Onboarding reaches validated local profile and home', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final store = AppStore(await SharedPreferences.getInstance());
    await tester.pumpWidget(SparkApp(store: store));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lewati'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'test@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Lanjutkan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lanjutkan'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Dina');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Mulai sekarang'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mulai sekarang'));
    await tester.pumpAndSettle();
    expect(find.text('Halo, Dina 👋'), findsOneWidget);
    expect(store.signedIn, isTrue);
  });
  testWidgets('Chat persists, history searches, and theme changes', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'signedIn': true,
      'name': 'Dina',
      'email': 'dina@example.com',
    });
    final store = AppStore(await SharedPreferences.getInstance());
    await tester.pumpWidget(SparkApp(store: store));
    await tester.tap(find.text('Mulai chat baru'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Ide menulis');
    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(store.conversations.single.messages.length, 2);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Riwayat'));
    await tester.pumpAndSettle();
    expect(find.text('Ide menulis'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'tidak-cocok');
    await tester.pumpAndSettle();
    expect(find.text('Tidak ditemukan'), findsOneWidget);
    await tester.tap(find.text('Pengaturan').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(store.dark, isTrue);
    final restored = AppStore(await SharedPreferences.getInstance());
    expect(restored.conversations.single.messages.length, 2);
    expect(restored.dark, isTrue);
  });
}
