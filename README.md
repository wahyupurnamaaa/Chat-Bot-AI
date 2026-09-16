# Nova AI — Chat Bot AI

Aplikasi Flutter Android, iOS, dan web berdasarkan referensi `../workflow.jpg`. Desain menggunakan aksen ungu, kartu lembut, logo geometris, serta tema terang dan gelap. Teks UI dalam bahasa Indonesia. Ilustrasi dan ikon dibuat dengan widget Flutter; bukan salinan piksel persis dari referensi.

## Menjalankan

```sh
cd '/Users/mymac/Downloads/chat bot ai'
flutter pub get
flutter run
```

Pilih emulator/perangkat yang tersedia. Untuk browser: `flutter run -d chrome`.

```sh
flutter analyze
flutter test
flutter build web
flutter build apk --release
```

Build iOS membutuhkan Xcode, simulator/perangkat, dan konfigurasi signing milik pengguna. Build web tersedia pada `build/web` setelah proses build berhasil.

## Alur layar

Splash → onboarding → masuk/buat akun demo → lengkapi profil → beranda.

Navigasi bawah: Chat, Asisten AI, Riwayat, Pengaturan.

- Chat: keadaan kosong, saran prompt, kirim pesan, indikator menulis, jawaban, kegagalan dan coba lagi, salin percakapan.
- Asisten: Menulis, Bisnis, Keseharian; delapan pilihan membuka percakapan berjudul sesuai pilihan.
- Riwayat: tersimpan lokal, cari judul/isi, keadaan tidak ditemukan, buka percakapan lama, geser hapus, konfirmasi hapus seluruhnya.
- Pengaturan: profil, tema, paket Basic/Premium, kontrol data/ekspor JSON, FAQ/filter/kontak, ketentuan, privasi, keluar.

## Status integrasi

Aplikasi dapat digunakan langsung dengan **respons demo**, bukan model AI lokal. Login adalah alur validasi formulir dan sesi lokal, tidak memverifikasi akun server. Password tidak disimpan. Premium merupakan pratinjau tanpa transaksi. Kontak dukungan belum dikonfigurasi.

Profil, tema, sesi, dan riwayat menggunakan SharedPreferences (tidak terenkripsi). Keluar mempertahankan data perangkat; hapus riwayat melalui Kontrol data sebelum berganti pengguna pada perangkat bersama.

### Backend AI opsional

```sh
flutter run --dart-define=AI_ENDPOINT=https://backend-anda.example/chat
```

Endpoint harus menerima POST JSON:

```json
{"messages":[{"role":"user","content":"Halo"}]}
```

Respons HTTP 200:

```json
{"reply":"Halo! Ada yang bisa saya bantu?"}
```

Simpan API key provider hanya di server. Endpoint produksi perlu autentikasi, pembatasan penggunaan, dan CORS untuk web. Aplikasi tidak menyertakan backend atau API key. Seluruh percakapan dikirim sebagai konteks saat endpoint diaktifkan. Referensi implementasi HTTP: https://docs.flutter.dev/cookbook/networking/send-data.

## Struktur

- `lib/screens/`: onboarding/auth, profil, home/asisten/riwayat, chat, pengaturan/bantuan/premium.
- `lib/models/`: model percakapan dan pesan.
- `lib/services/`: penyimpanan lokal dan koneksi HTTP/demo.
- `lib/widgets/`: identitas visual dan tombol bersama.
- `test/widget_test.dart`: alur masuk/profil serta chat, persistensi, pencarian, dan tema.

## Hasil verifikasi

- `flutter analyze`: tidak ada masalah.
- `flutter test`: 2 pengujian alur lulus.
- `flutter build web`: berhasil.
- Build APK belum berhasil: unduhan Android NDK `28.2.13676358` terputus (`Connection reset`), sehingga instalasi NDK tidak lengkap. Perbaiki/pasang ulang versi NDK tersebut melalui Android Studio SDK Manager, lalu jalankan `flutter build apk --release`.
- Build iOS belum diuji.
