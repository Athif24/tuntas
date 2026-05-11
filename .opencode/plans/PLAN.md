# Tuntas — Rencana Aplikasi Flutter

## 1. Struktur Proyek

```
Tuntas/
├── lib/
│   ├── main.dart                          # Entry point aplikasi, setup MaterialApp, tema, dan tabel rute
│   ├── models/
│   │   └── task.dart                      # Model data Task (id, title, description, due_date, category, is_done)
│   ├── database/
│   │   └── database_helper.dart           # Singleton SQLite: buka, buat tabel, operasi CRUD
│   ├── providers/
│   │   └── theme_provider.dart            # Mengelola state pergantian tema (Clean White, Carbon Mint, Slate Blue)
│   ├── screens/
│   │   ├── splash_screen.dart             # Splash animasi dengan logo; inisialisasi DB, navigasi ke login
│   │   ├── login_screen.dart              # Halaman login dengan field username/password, validasi ke DB (default: user/user)
│   │   ├── beranda_screen.dart            # Halaman utama: jumlah selesai/belum, grafik batang, 4 tombol navigasi
│   │   ├── tambah_tugas_screen.dart       # Halaman tambah tugas gabungan: menerima parameter kategori (penting/biasa) dan opsional edit tugas
│   │   ├── daftar_tugas_screen.dart       # Halaman daftar tugas: bisa di-scroll, swipe-to-delete, filter tab (Semua/Penting/Biasa)
│   │   ├── detail_tugas_screen.dart       # Tampilan detail: judul, tanggal, deskripsi; aksi: edit, hapus, toggle selesai
│   │   └── pengaturan_screen.dart         # Pengaturan: ganti password, pemilih tema, keluar, info developer
│   ├── widgets/
│   │   ├── nav_button.dart                # Widget tombol navigasi dengan gaya kustom yang digunakan di Beranda
│   │   ├── summary_card.dart              # Widget kartu reusable menampilkan jumlah (selesai/belum) di Beranda
│   │   ├── weekly_bar_chart.dart          # Widget grafik batang (fl_chart) dengan navigasi minggu dan pemilih bulan
│   │   ├── daily_task.dart                # Kelas data untuk jumlah tugas selesai per hari (digunakan grafik batang)
│   │   └── monthly_picker_dialog.dart     # Dialog untuk memilih bulan/tahun untuk navigasi grafik
│   └── utils/
│       ├── app_routes.dart                # Konstanta nama rute dan handler onGenerateRoute
│       ├── colors.dart                    # Konstanta warna lama (tidak dipakai; disimpan sebagai referensi)
│       └── theme_config.dart              # Kelas AppTheme dan 3 definisi tema (Clean White, Carbon Mint, Slate Blue)
├── assets/
│   └── images/
│       └── developer_photo.jpg            # Foto developer untuk layar Pengaturan
├── pubspec.yaml                           # Konfigurasi proyek dengan semua dependensi dan deklarasi aset
└── PLAN.md                                # File ini
```

---

## 2. Skema Database

### Tabel: `users`
| Kolom      | Tipe         | Konstrain                | Deskripsi                        |
|------------|--------------|--------------------------|----------------------------------|
| id         | INTEGER      | PRIMARY KEY AUTOINCREMENT | ID pengguna unik                |
| username   | TEXT         | NOT NULL, UNIQUE         | Username untuk login            |
| password   | TEXT         | NOT NULL                 | Password untuk login            |

- **Data awal**: Saat pertama kali aplikasi dijalankan, sisipkan baris default: `(1, 'user', 'user')`

### Tabel: `tasks`
| Kolom        | Tipe         | Konstrain                | Deskripsi                               |
|--------------|--------------|--------------------------|-----------------------------------------|
| id           | INTEGER      | PRIMARY KEY AUTOINCREMENT | ID tugas unik                          |
| title        | TEXT         | NOT NULL                 | Judul tugas                             |
| description  | TEXT         | NOT NULL DEFAULT ''      | Deskripsi tugas                         |
| due_date     | TEXT         | NOT NULL                 | Tanggal jatuh tempo format ISO (YYYY-MM-DD) |
| category     | TEXT         | NOT NULL                 | Kategori tugas ('penting' atau 'biasa') |
| is_done      | INTEGER      | NOT NULL DEFAULT 0       | 0 = belum selesai, 1 = selesai         |
| created_at   | TEXT         | NOT NULL                 | Stempel waktu pembuatan (YYYY-MM-DD)    |
| updated_at   | TEXT         | NULLABLE                 | Stempel waktu perubahan terakhir (YYYY-MM-DD) |

### Migrasi
- **v1**: Skema awal dengan tabel `tasks` (6 kolom)
- **v2**: Buat ulang tabel `tasks`, tambah kolom `due_date` dan `category`
- **v3**: Tambah kolom `updated_at` melalui ALTER TABLE

### Metode Database Helper
| Method                                | Deskripsi                                                  |
|---------------------------------------|------------------------------------------------------------|
| `initDatabase()`                      | Membuka/membuat DB, menjalankan onCreate dan onUpgrade, sisip data awal |
| `getDatabase()`                       | Mengembalikan instance database singleton                  |
| `validateUser(username, password)`    | Mengembalikan true jika kredensial cocok dengan record     |
| `getUser()`                           | Mengembalikan record user pertama                          |
| `updatePassword(newPassword)`         | Memperbarui password untuk user id=1                       |
| `getTasks()`                          | Mengembalikan semua tugas diurutkan due_date ASC           |
| `getTask(id)`                         | Mengembalikan satu tugas berdasarkan ID                    |
| `insertTask(Map)`                     | Menyisipkan tugas baru, mengembalikan ID yang dihasilkan   |
| `toggleTaskDone(id, isDone)`          | Mengatur is_done dan memperbarui updated_at                |
| `getTaskCountDone()`                  | Mengembalikan jumlah di mana is_done = 1                   |
| `getTaskCountPending()`               | Mengembalikan jumlah di mana is_done = 0                   |
| `getTasksDonePerDay()`                | Mengembalikan peta {tanggal: jumlah} untuk tugas selesai   |
| `getTasksCompletedPerDay(weekStart)`  | Mengembalikan peta {tanggal: jumlah} untuk rentang minggu tertentu |
| `deleteTask(id)`                      | Menghapus tugas berdasarkan ID                             |
| `updateTask(id, data)`                | Memperbarui field tugas berdasarkan ID                     |

---

## 3. Dependensi

### `pubspec.yaml` — `dependencies`:
| Paket                | Rentang Versi | Tujuan                                                     |
|----------------------|---------------|------------------------------------------------------------|
| `flutter`            | `sdk: flutter` | SDK inti Flutter                                          |
| `cupertino_icons`    | `^1.0.8`      | Set ikon gaya iOS                                          |
| `sqflite`            | `^2.3.3`      | Database SQLite untuk penyimpanan lokal                    |
| `sqflite_common_ffi` | `^2.3.2`      | Dukungan FFI SQLite (untuk pengujian di desktop)           |
| `path`               | `^1.9.0`      | Manipulasi path lintas platform untuk lokasi file DB       |
| `intl`               | `^0.20.2`     | Format tanggal/waktu (lokal Indonesia)                     |
| `fl_chart`           | `^0.69.0`     | Grafik batang untuk tugas-selesai-per-hari di Beranda      |
| `shared_preferences` | `^2.3.0`      | Menyimpan state pemilihan tema                             |
| `provider`           | `^6.1.2`      | Manajemen state (ChangeNotifier untuk ThemeProvider)        |
| `google_fonts`       | `^6.1.0`      | Google Fonts (Poppins, Inter, Plus Jakarta Sans)           |

### `pubspec.yaml` — `dev_dependencies`:
| Paket             | Rentang Versi | Tujuan                            |
|-------------------|---------------|-----------------------------------|
| `flutter_test`    | `sdk: flutter`| Framework pengujian Flutter       |
| `flutter_lints`   | `^5.0.0`      | Aturan lint yang direkomendasikan |

### `pubspec.yaml` — `flutter.assets`:
```yaml
flutter:
  assets:
    - assets/images/
```

---

## 4. Alur Navigasi Halaman

### Peta Rute (Rute Bernama)

| Nama Rute         | Widget Layar                   | Perlu Auth | Deskripsi                               |
|-------------------|--------------------------------|-----------|------------------------------------------|
| `/splash`         | `SplashScreen`                 | Tidak     | Layar masuk; inisialisasi DB, animasi, redirect |
| `/`               | `LoginScreen`                  | Tidak     | Halaman login, validasi ke DB            |
| `/beranda`        | `BerandaScreen`                | Ya        | Dashboard utama dengan statistik dan navigasi |
| `/tambah-tugas`   | `TambahTugasScreen`            | Ya        | Form untuk menambah/mengedit tugas (penting/biasa) |
| `/daftar-tugas`   | `DaftarTugasScreen`            | Ya        | Daftar tugas lengkap dengan filter tab    |
| `/detail-tugas`   | `DetailTugasScreen`            | Ya        | Tampilan detail tugas dengan aksi edit/hapus |
| `/pengaturan`     | `PengaturanScreen`             | Ya        | Ganti password, pemilih tema, keluar     |

### Detail Navigasi

1. **Aplikasi mulai** → `main.dart` merender `SplashScreen` (rute awal)
2. **SplashScreen** → inisialisasi DB, memainkan animasi → navigasi ke `/login`
3. **LoginScreen** → setelah validasi berhasil → `Navigator.pushReplacementNamed('/beranda')`
4. **BerandaScreen** → berisi 4 tombol navigasi:
   - "Tambah Tugas Penting" → `TambahTugasScreen(category: 'penting')`
   - "Tambah Tugas Biasa" → `TambahTugasScreen(category: 'biasa')`
   - "Daftar Tugas" → `DaftarTugasScreen`
   - "Pengaturan" → `PengaturanScreen`
5. **TambahTugasScreen** → setelah simpan → `Navigator.pop(true)` (kembali ke Beranda)
6. **DaftarTugasScreen** → ketuk tugas → `/detail-tugas` dengan argumen tugas
7. **DetailTugasScreen** → edit → `/tambah-tugas` dengan data tugas; hapus → konfirmasi → pop
8. **PengaturanScreen** → "Keluar" → `Navigator.pushReplacementNamed('/')` (kembali ke login)

### Strategi Pembuatan Rute
- Menggunakan `onGenerateRoute` di `AppRoutes.onGenerateRoute`
- Argumen dikirim melalui `RouteSettings.arguments` untuk `/tambah-tugas` (peta kategori & tugas) dan `/detail-tugas` (peta tugas)

---

## 5. Pendekatan Manajemen State

### Pendekatan: **Provider (ChangeNotifier)**

**Mengapa Provider:**
- Aplikasi berskala kecil (7 layar, satu state tema). Provider ringan dan mencukupi.
- Pola `ChangeNotifier` mudah digunakan untuk state tema.
- Tidak perlu pohon state kompleks, middleware, atau stream.
- Operasi database menggunakan panggilan langsung `DatabaseHelper.instance` (tanpa provider data terpisah).

### Provider:

#### `ThemeProvider` (extends ChangeNotifier)
| Field/Method              | Deskripsi                                               |
|---------------------------|----------------------------------------------------------|
| `themes` (List<AppTheme>) | Daftar 3 tema yang tersedia                              |
| `currentTheme` (AppTheme) | Objek tema yang sedang dipilih                           |
| `selectedThemeIndex` (int)| Indeks tema yang dipilih                                 |
| `setTheme(index)`         | Mengubah tema, menyimpan ke SharedPreferences, memberi notifikasi |

### Penanganan State (Non-Provider):
- **Autentikasi**: Tidak ada sesi persisten. Setiap kali aplikasi dimulai dari splash → login. Login memvalidasi langsung via `DatabaseHelper`.
- **Data tugas**: Setiap layar mengambil data langsung dari `DatabaseHelper.instance`. Tidak ada state tugas terpusat.
- **Penyegaran data**: Layar menyegarkan dengan memanggil `_loadData()` di `initState()` dan setelah kembali dari layar anak melalui `.then()`.

### Penempatan Provider:
- `ThemeProvider` dideklarasikan di puncak pohon widget di `main.dart` melalui `ChangeNotifierProvider`.
- Layar mengakses tema menggunakan `Provider.of<ThemeProvider>(context)`.
- `context.watch` / `Provider.of` dengan `listen: false` untuk pembacaan satu kali.

---

## 6. Daftar Periksa Pembangunan

### Fase 1: Persiapan Proyek
1. [x] Perbarui `pubspec.yaml`: tambah semua dependensi (sqflite, path, intl, fl_chart, shared_preferences, provider, google_fonts)
2. [x] Perbarui `pubspec.yaml`: tambah `assets/images/` di bawah `flutter.assets`
3. [x] Jalankan `flutter pub get` untuk mengambil semua paket
4. [x] Buat struktur direktori:
   - `lib/models/`, `lib/database/`, `lib/providers/`, `lib/screens/`, `lib/widgets/`, `lib/utils/`
   - `assets/images/`

### Fase 2: Lapisan Utilitas & Model
5. [x] Buat `lib/utils/colors.dart`: definisikan konstanta warna lama (disimpan sebagai referensi)
6. [x] Buat `lib/utils/app_routes.dart`: definisikan konstanta nama rute dan fungsi `onGenerateRoute`
7. [x] Buat `lib/utils/theme_config.dart`: definisikan kelas `AppTheme` dan 3 definisi tema
8. [x] Buat `lib/models/task.dart`: definisikan kelas `Task` dengan metode `fromMap`, `toMap`, dan `copyWith`

### Fase 3: Lapisan Database
9. [x] Buat `lib/database/database_helper.dart`:
   - Implementasikan kelas singleton `DatabaseHelper`
   - `initDatabase()` dengan `onCreate` membuat tabel `users` dan `tasks`
   - Sisipkan data awal user `(user, user)` di `onCreate`
   - Tangani migrasi (v1→v3)
   - Implementasikan semua metode CRUD yang tercantum di Bagian 2

### Fase 4: Lapisan Manajemen State
10. [x] Buat `lib/providers/theme_provider.dart`:
    - Implementasikan kelas `ThemeProvider` yang memperluas `ChangeNotifier`
    - Metode `setTheme()` dengan persistensi SharedPreferences
    - `_loadSavedTheme()` pada inisialisasi

### Fase 5: Widget yang Dapat Digunakan Kembali
11. [x] Buat `lib/widgets/summary_card.dart`: menampilkan label jumlah dengan angka berwarna ikon
12. [x] Buat `lib/widgets/nav_button.dart`: tombol bergaya dengan ikon + label untuk navigasi Beranda
13. [x] Buat `lib/widgets/daily_task.dart`: kelas data untuk nilai harian grafik batang
14. [x] Buat `lib/widgets/monthly_picker_dialog.dart`: dialog untuk pemilihan bulan/tahun di grafik
15. [x] Buat `lib/widgets/weekly_bar_chart.dart`: BarChart fl_chart dengan navigasi minggu, pemilih bulan, tooltip

### Fase 6: Layar (Bangun sesuai urutan)
16. [x] Buat `lib/screens/splash_screen.dart`:
    - Splash animasi dengan ikon gradien, transisi fade + scale
    - Inisialisasi database, tunda, navigasi ke `/login`
17. [x] Buat `lib/screens/login_screen.dart`:
    - Latar belakang gradien, starfield AnimatedBuilder kustom
    - TextFormField untuk username dan password
    - Tombol login memvalidasi via `DatabaseHelper.validateUser`
    - Menampilkan snackbar error jika kredensial tidak valid
    - Jika berhasil: navigasi ke `/beranda`
18. [x] Buat `lib/screens/beranda_screen.dart`:
    - AppBar kustom dengan ikon gradien
    - Salam dengan username dan tanggal hari ini
    - Dua widget `SummaryCard` (jumlah selesai, jumlah belum)
    - Widget `WeeklyBarChart` menampilkan 7 hari terakhir tugas selesai
    - 4 widget `NavButton` dalam grid 2×2
    - Efek latar starfield kustom
19. [x] Buat `lib/screens/tambah_tugas_screen.dart`:
    - Menerima `category` (penting/biasa) dan opsional `task` untuk mode edit
    - Form dengan: DatePicker, TextFormField judul, TextFormField deskripsi
    - Dialog konfirmasi keluar jika form memiliki data
    - Tombol simpan menyisipkan tugas baru atau memperbarui tugas yang ada
    - Setelah simpan: kembali dengan hasil `true`
20. [x] Buat `lib/screens/daftar_tugas_screen.dart`:
    - Filter tab bar: Semua, Penting, Biasa (dengan jumlah)
    - `ListView` dengan `Dismissible` untuk swipe-to-delete
    - Widget `_TaskCard` per baris: checkbox, judul (garis coret jika selesai), label tanggal, lencana terlambat, ikon panah
    - Ketuk tugas → navigasi ke detail
    - Widget state kosong
21. [x] Buat `lib/screens/detail_tugas_screen.dart`:
    - Lencana kategori, judul, kartu tanggal jatuh tempo, kartu deskripsi
    - Tombol aksi: "Ubah Tugas" dan "Hapus Tugas"
    - Dialog konfirmasi hapus
    - Edit navigasi ke `/tambah-tugas` dengan data tugas
22. [x] Buat `lib/screens/pengaturan_screen.dart`:
    - Bagian "Keamanan Akun": 3 field password (saat ini, baru, konfirmasi)
    - Checkbox tampilkan password
    - Tombol simpan password dengan validasi
    - Pemilih tema melalui bottom sheet dengan 3 opsi tema
    - Bagian "Akun": kartu keluar dengan dialog konfirmasi
    - Bagian "Developer": nama, NIM, ikon

### Fase 7: Entry Point Aplikasi & Perangkaian
23. [x] Buat `lib/main.dart`:
    - Bungkus aplikasi dalam `ChangeNotifierProvider<ThemeProvider>`
    - Inisialisasi `initializeDateFormatting('id_ID')` untuk locale
    - Setup `MaterialApp` dengan:
      - `title: 'Tuntas'`
      - `theme` dari `themeProvider.currentTheme.materialTheme`
      - `initialRoute: '/splash'`
      - `onGenerateRoute: AppRoutes.onGenerateRoute`

### Fase 8: Aset
24. [x] Tambah foto developer placeholder di `assets/images/developer_photo.jpg`

### Fase 9: Pengujian (perlu diverifikasi)
25. [ ] Jalankan `flutter analyze` — perbaiki semua peringatan/error
26. [ ] Jalankan `flutter run` di emulator/perangkat — verifikasi semua layar termuat
27. [ ] Uji login: kredensial default berhasil, kredensial salah tampilkan error
28. [ ] Uji pembuatan tugas: penting (panah merah) dan biasa (panah hijau)
29. [ ] Uji daftar tugas: checkbox toggle garis coret, filter tab, swipe hapus
30. [ ] Uji detail tugas: edit, hapus, navigasi kembali
31. [ ] Uji Beranda: jumlah diperbarui, grafik batang mencerminkan tugas selesai
32. [ ] Uji pengaturan: validasi ganti password, pergantian tema, keluar

---

## 7. Sistem Warna

### Arsitektur
Aplikasi menggunakan **sistem multi-tema** melalui kelas `AppTheme` di `utils/theme_config.dart`. Tiga tema tersedia:

### Definisi Tema

| Nama Tema      | Tipe  | Primer/Aksen | Latar Belakang   | Latar Kartu      |
|----------------|-------|--------------|------------------|------------------|
| Clean White    | Terang| `#757575`    | `#F5F5F5`        | `#FFFFFF`        |
| Carbon Mint    | Gelap | `#2BBFA8`    | `#181E1E`        | `#232D2D`        |
| Slate Blue     | Gelap | `#4A90D9`    | `#1A2332`        | `#253347`        |

### Warna Kategori Tetap (digunakan di semua tema)
| Konstanta          | Kode Hex  | Penggunaan                                       |
|--------------------|-----------|--------------------------------------------------|
| `AppTheme.fixedRed`   | `#E53935` | Tugas penting (penting) panah, lencana, aksen  |
| `AppTheme.fixedGreen` | `#43A047` | Tugas biasa (biasa) panah, lencana, aksen       |
| `AppTheme.fixedBlue`  | `#1E88E5` | Titik tombol navigasi Daftar Tugas              |
| `AppTheme.fixedGray`  | `#757575` | Titik tombol navigasi Pengaturan                |

### Konfigurasi ThemeData
```dart
ThemeData(
  brightness: isDark ? Brightness.dark : Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: accentColor,
    brightness: isDark ? Brightness.dark : Brightness.light,
  ),
  textTheme: GoogleFonts.interTextTheme(...),
  primaryTextTheme: GoogleFonts.plusJakartaSansTextTheme(...),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: textPrimary,
    elevation: 0,
  ),
  useMaterial3: true,
  scaffoldBackgroundColor: bgSolid ?? bgBottom,
)
```
