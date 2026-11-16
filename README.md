# MyPortfolio Mobile

Aplikasi portofolio pribadi berbasis Flutter untuk mata kuliah **Pemrograman Berbasis Platform (CSGE602022)**, Fasilkom Universitas Indonesia, Semester Gasal 2026/2027. Proyek ini melanjutkan Tutorial 08 dan menjadi versi mobile dari proyek portofolio web saya. Repositori mobile terpisah dari proyek Django.

# Data Diri

Nama : David Liman

NPM : 2506601956

Kelas : PBP B

# Cara Menjalankan Proyek

## Prasyarat

- Flutter SDK tersedia di `PATH`. Lingkungan yang digunakan saat verifikasi adalah **Flutter 3.47.9** dengan **Dart 3.13.7**. Batas versi Dart pada `pubspec.yaml` adalah `^3.13.7`.
- Git untuk mengambil repositori.
- Perangkat Android atau emulator untuk menjalankan aplikasi mobile. Siapkan Android SDK dan periksa kebutuhannya melalui `flutter doctor`.
- Untuk mencoba antarmuka melalui browser, dapat menggunakan target web jika tersedia pada lingkungan Flutter.

## Langkah-langkah

1. **Clone repositori** dan masuk ke direktori proyek:

   ```bash
   git clone https://github.com/depelemon/myportofolio_mobile.git
   cd myportofolio_mobile
   ```
2. **Periksa lingkungan Flutter**:

   ```bash
   flutter --version
   flutter doctor
   ```

   Selesaikan masalah pada toolchain untuk platform yang akan digunakan. Proyek ini tidak menggunakan virtual environment Python, migrasi Django, atau konfigurasi `.env`.
3. **Pasang dependency**:

   ```bash
   flutter pub get
   ```
4. **Nyalakan emulator atau sambungkan perangkat**, lalu periksa perangkat yang tersedia:

   ```bash
   flutter devices
   ```
5. **Jalankan aplikasi**:

   ```bash
   flutter run
   ```

   Jika terdapat beberapa perangkat, pilih target saat diminta atau jalankan `flutter run -d <device-id>` dengan ID dari `flutter devices`. Untuk target web Chrome yang sudah terpasang, gunakan `flutter run -d chrome`.
6. **Jalankan pemeriksaan kode dan tes** dari root proyek:

   ```bash
   flutter analyze
   flutter test
   ```

   Analisis harus menghasilkan `No issues found!`, sedangkan tes harus selesai tanpa kegagalan.

# Struktur Proyek

```text
lib/
  main.dart             # Entry point, MyApp, MaterialApp, dan tema aplikasi.
  menu.dart             # MyHomePage, InfoCard, ItemHomepage, dan ItemCard.
test/
  widget_test.dart      # Tes identitas, menu, SnackBar, dan ukuran layar.
pubspec.yaml            # Metadata, batas SDK, dan dependency.
README.md               # Dokumentasi proyek dan jawaban reflektif.
```

`main()` memanggil `runApp(const MyApp())`. `MyApp` menyiapkan `MaterialApp` dengan tema berbasis indigo dan menjadikan `MyHomePage` sebagai halaman awal. Halaman utama dipisahkan ke `lib/menu.dart`, sehingga konfigurasi aplikasi tidak bercampur dengan susunan kartu profil dan tombol.

# Progres Mingguan

## Tutorial 08: Basic Flutter

Fondasi proyek meliputi pemisahan `main.dart` dan `menu.dart`, penggunaan `StatelessWidget` untuk halaman utama, tiga `InfoCard`, serta menu berbentuk `ItemCard`. Komponen kartu dipakai ulang agar susunan tampilan tidak perlu ditulis berulang untuk setiap data.

## Tugas 7: Portofolio Pribadi dan Warna Menu

Identitas contoh diganti menjadi NPM **2506601956**, nama **David Liman**, dan kelas **PBP B**. Ketiganya ditampilkan di bagian atas halaman melalui `InfoCard`.

Menu aksi yang tersedia:

| Tombol        | Ikon                 | Warna latar      | Respons saat ditekan                         |
| ------------- | -------------------- | ---------------- | -------------------------------------------- |
| Lihat Proyek  | `Icons.folder`     | `Colors.blue`  | `Kamu telah menekan tombol Lihat Proyek!`  |
| Tambah Proyek | `Icons.add_circle` | `Colors.green` | `Kamu telah menekan tombol Tambah Proyek!` |
| Logout        | `Icons.logout`     | `Colors.red`   | `Kamu telah menekan tombol Logout!`        |

Model `ItemHomepage` menyimpan `name`, `icon`, dan `color`. `ItemCard` menggunakan `item.color` sebagai warna `Material`, bukan memilih warna dengan percabangan berdasarkan nama tombol. Saat kartu ditekan, `InkWell.onTap` menyembunyikan SnackBar sebelumnya dan menampilkan pesan sesuai nama item melalui `ScaffoldMessenger`.

Halaman dibungkus `SafeArea` dan `SingleChildScrollView`. Grid menggunakan tiga kolom, tinggi item 144, `shrinkWrap: true`, dan `NeverScrollableScrollPhysics`, sehingga pengguliran ditangani oleh halaman luarnya.

> Tombol pada tugas ini hanya menampilkan SnackBar. **Lihat Proyek** belum membuka halaman daftar, **Tambah Proyek** belum menyimpan data, dan **Logout** belum mengakhiri sesi login. Fitur-fitur tersebut tidak diklaim sudah tersedia.

# AI Disclosure (last upd: Tugas Individu 7)

Untuk Tugas 7, saya menggunakan **Hermes Agent** (model `gpt-6.1-sol-900k`, provider OpenAI Codex) untuk mengklarifikasi pemahaman untuk menjawab pertanyaan refleksi.

### Log Prompt

> Jelaskan apa yang dimaksud dengan widget tree pada Flutter dan bagaimana hubungan induk-anak (parent-child) bekerja antar-widget!

> Apa fungsi dari widget MaterialApp? Jelaskan mengapa widget ini umumnya digunakan sebagai root widget pada aplikasi Flutter!

> Jelaskan perbedaan antara StatelessWidget dan StatefulWidget! Kapan kita sebaiknya memilih StatelessWidget dan kapan harus menggunakan StatefulWidget?

> Apa itu BuildContext dan mengapa penting di Flutter? Bagaimana penggunaannya di dalam metode build?

> Jelaskan konsep hot reload di Flutter dan apa perbedaannya dengan hot restart! Kapan kita tidak bisa hanya mengandalkan hot reload dan harus melakukan hot restart atau full restart?

# Pertanyaan Reflektif

### Tugas 7

1. **Jelaskan apa yang dimaksud dengan widget tree pada Flutter dan bagaimana hubungan induk-anak (parent-child) bekerja antar-widget!**

   Widget tree mirip seperti DOM di HTML, widget tree menunjukkan susunan widget, di mana setiap node di widget tree adalah sebuah widget, parent dari node tersebut adalah widget yang "menampung" node tersebut dan childnya adalah widget yang ditampung node tersebut.

   Alur constraint dan ukuran:

   - Parent memwariskan constraint ke child (misalnya batas lebar/tinggi)
   - Child menentukan size dirinya sendiri lalu melaporkan ke parent
   - Parent menentukan posisi child

   Alur data dan event:

   - Parent mengirim data ke child
   - Child dapat memberi tahu parent tentang suatu event melalui callback yang diberikan parent.
2. **Sebutkan semua widget yang kamu gunakan dalam proyek ini dan jelaskan fungsinya masing-masing!**

   | Widget                    | Fungsi dalam proyek                                                         |
   | ------------------------- | --------------------------------------------------------------------------- |
   | `MyApp`                 | Widget buatan sendiri yang menyiapkan konfigurasi aplikasi.                 |
   | `MaterialApp`           | Menyediakan konfigurasi Material, tema, judul, dan halaman awal.            |
   | `MyHomePage`            | Menyusun halaman utama profil dan menu aksi.                                |
   | `Scaffold`              | Kerangka halaman dengan `appBar` dan `body`.                            |
   | `AppBar`                | Menampilkan judul MyPortfolio di bagian atas.                               |
   | `SafeArea`              | Menjaga konten dari area sistem seperti notch.                              |
   | `SingleChildScrollView` | Membuat isi halaman dapat digulir ketika tidak muat.                        |
   | `Column`                | Menyusun konten secara vertikal.                                            |
   | `Row`                   | Menyusun tiga kartu profil secara horizontal.                               |
   | `Expanded`              | Membagi lebar baris untuk masing-masing kartu profil.                       |
   | `InfoCard`              | Komponen buatan sendiri untuk pasangan label dan identitas.                 |
   | `Card`                  | Memberi permukaan kartu dan elevasi pada informasi profil.                  |
   | `Padding`               | Memberi jarak di sekeliling konten.                                         |
   | `SizedBox`              | Memberi jarak vertikal antarbagian.                                         |
   | `Text`                  | Menampilkan judul, identitas, sambutan, label tombol, dan pesan.            |
   | `GridView.count`        | Menyusun tombol menjadi grid tiga kolom; ini constructor dari `GridView`. |
   | `ItemCard`              | Komponen buatan sendiri untuk satu tombol aksi portofolio.                  |
   | `Material`              | Permukaan berwarna untuk kartu aksi dan efek tinta.                         |
   | `InkWell`               | Menangani ketukan kartu dan memberi efek sentuhan.                          |
   | `Center`                | Memusatkan konten di dalam kartu aksi.                                      |
   | `Icon`                  | Menampilkan simbol folder, tambah, dan logout.                              |
   | `SnackBar`              | Menampilkan umpan balik singkat setelah tombol ditekan.                     |
3. **Apa fungsi dari widget MaterialApp? Jelaskan mengapa widget ini umumnya digunakan sebagai root widget pada aplikasi Flutter!**

   `MaterialApp` menyiapkan kebutuhan umum aplikasi Material Design, seperti tema, navigasi, lokalisasi, dan pengelolaan SnackBar melalui `ScaffoldMessenger`.

   Dalam proyek ini, `MaterialApp` menetapkan judul `MyPortfolio`, tema dengan warna dasar indigo, penggunaan Material 3, dan `home: MyHomePage()`. `Theme.of(context).colorScheme.primary` pada `AppBar` membaca tema yang disediakan dari atas.

   Widget ini lazim ditempatkan di tingkat atas agar konfigurasi berlaku konsisten untuk seluruh aplikasi. Namun, root yang dikirim ke `runApp` pada proyek ini sebenarnya adalah `MyApp`, yang kemudian membangun `MaterialApp`. `MaterialApp` juga bukan kewajiban untuk semua aplikasi Flutter, aplikasi dengan kebutuhan lain dapat memakai `CupertinoApp` atau `WidgetsApp`.
4. **Jelaskan perbedaan antara StatelessWidget dan StatefulWidget! Kapan kita sebaiknya memilih StatelessWidget dan kapan harus menggunakan StatefulWidget?**

   | Aspek                     | StatelessWidget                         | StatefulWidget                                                           |
   | ------------------------- | --------------------------------------- | ------------------------------------------------------------------------ |
   | **State**           | Tidak punya state internal yang berubah | Punya state yang bisa berubah selama widget hidup                        |
   | **Struktur**        | Satu kelas dengan `build()`           | Dua kelas: widget dan `State`                                          |
   | **Update tampilan** | Hanya saat parent mengirim data baru    | Lewat `setState()`                                                     |
   | **Siklus hidup**    | Hanya `build()`                       | `initState()`, `build()`, `didUpdateWidget()`, `dispose()`, dll. |
   | **Performa**        | Lebih ringan                            | Sedikit lebih berat                                                      |

   **Pilih `StatelessWidget` jika:**


   * Tampilan sepenuhnya ditentukan oleh data dari parent (parameter konstruktor).
   * Widget bersifat statis, misalnya label, ikon, atau kartu informasi.
   * State dikelola di luar widget (misalnya Provider atau Bloc).

   **Pilih `StatefulWidget` jika:**

   * Widget perlu menyimpan data yang berubah karena interaksi, misalnya input form, checkbox, atau counter.
   * Membutuhkan resource yang harus dibuat dan dibersihkan, seperti `AnimationController`, `TextEditingController`, atau `StreamSubscription` (dibuat di `initState()`, dibuang di `dispose()`).
   * Perlu bereaksi terhadap siklus hidup widget.
5. **Apa itu BuildContext dan mengapa penting di Flutter? Bagaimana penggunaannya di dalam metode build?**

   `BuildContext` adalah **referensi ke posisi sebuah widget di dalam widget tree** . Setiap widget punya context-nya sendiri, dan context itu “tahu” siapa parent dan ancestor-nya. Flutter memberikan parameter ini pada `build(BuildContext context)` agar widget dapat mengakses informasi atau layanan yang disediakan ancestor-nya.

   Pada proyek ini, `Theme.of(context)` membaca tema untuk warna `AppBar`. Di `ItemCard`, `ScaffoldMessenger.of(context)` mendapatkan pengelola SnackBar lalu menjalankan `hideCurrentSnackBar()` dan `showSnackBar()`.
6. **Jelaskan konsep hot reload di Flutter dan apa perbedaannya dengan hot restart! Kapan kita tidak bisa hanya mengandalkan hot reload dan harus melakukan hot restart atau full restart?**

   Hot Reload memasukkan perubahan kode Dart lalu membangun ulang widget tree sambil mempertahankan state aplikasi. `main()` dan `initState()` tidak dijalankan ulang. Hot reload cocok untuk menggati teks, warna, atau layout dalam mode debug, intinya perubahan yang cepat dan tidak terlalu ribet.

   Hot Restart memulai ulang aplikasi Flutter dari kode Dart dan menghapus state yang sedang berjalan. Hot Restart dapat digunakan ketika perubahan harus menjalankan kembali `main()` atau inisialisasi state, termasuk ketika nilai awal yang sudah tersimpan tidak berubah melalui hot reload. Perubahan struktur tipe tertentu seperti parameter generik juga mungkin memerlukan restart.

   Full Restart menghentikan lalu menjalankan aplikasi kembali beserta proses build platform yang diperlukan. Ini diperlukan untuk perubahan kode native seperti Kotlin, Java, Swift, atau Objective-C, maupun perubahan plugin atau konfigurasi platform yang membutuhkan build ulang. Hot restart saja tidak mengompilasi ulang kode native.

## Referensi Teknis

- [Penyusunan antarmuka dan widget](https://docs.flutter.dev/ui)
- [MaterialApp](https://api.flutter.dev/flutter/material/MaterialApp-class.html)
- [StatelessWidget](https://api.flutter.dev/flutter/widgets/StatelessWidget-class.html)
- [StatefulWidget](https://api.flutter.dev/flutter/widgets/StatefulWidget-class.html)
- [BuildContext](https://api.flutter.dev/flutter/widgets/BuildContext-class.html)
- [Hot reload, hot restart, dan full restart](https://docs.flutter.dev/tools/hot-reload)
