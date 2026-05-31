# 📖 Cerita Nusturara — Flutter App

Aplikasi cerita rakyat Indonesia berbasis Flutter & Dart.

---

## 📁 Struktur Proyek

```
cerita_nusturara/
├── lib/
│   ├── main.dart                  ← Entry point aplikasi
│   ├── routes/
│   │   ├── app_routes.dart        ← Konstanta nama route
│   │   └── app_pages.dart         ← Mapping route → Screen
│   └── screens/
│       ├── landing_page.dart      ← Halaman splash/intro (sesuai desain)
│       ├── home_page.dart         ← Beranda + Bottom Navigation
│       ├── explore_page.dart      ← Halaman Jelajahi
│       ├── region_page.dart       ← Halaman Daerah
│       ├── story_detail_page.dart ← Detail satu cerita
│       ├── collection_page.dart   ← Koleksi tersimpan
│       └── settings_page.dart     ← Pengaturan
├── assets/
│   └── images/                    ← Taruh gambar Anda di sini
├── pubspec.yaml
└── README.md
```

---

## 🖼️ Cara Menambahkan Gambar / Aset

### 1. Taruh file gambar di folder `assets/images/`
```
assets/
  └── images/
      ├── landing_bg.png              ← Background karakter landing page
      └── logo_cerita_nusturara.png   ← Logo judul
```

### 2. Pastikan `pubspec.yaml` sudah ada entry ini (sudah ada):
```yaml
flutter:
  assets:
    - assets/images/
```

### 3. Di `landing_page.dart`, gambar sudah di-set:
- **Background karakter**: `assets/images/landing_bg.png`
  - Gunakan gambar dari desain (karakter orc, elf, dll) sebagai satu file PNG
  - Resolusi rekomendasi: **1080 x 1920 px** (portrait)
- **Logo "Cerita Nusturara"**: Untuk menggunakan gambar logo, buka `landing_page.dart`, 
  cari fungsi `_buildLogo()`, dan uncomment bagian `Image.asset(...)` serta ganti 
  path dengan nama file logo Anda.

> ✅ Jika gambar belum disiapkan, aplikasi akan menampilkan **placeholder otomatis** 
> (text logo dan silhouette karakter) tanpa error.

---

## 🗺️ Navigasi Antar Halaman (Alur Lengkap)

Aplikasi menggunakan **GetX** untuk routing. Berikut alur navigasi:

```
┌─────────────────────────────────────────────────┐
│              LANDING PAGE (/)                    │
│                                                 │
│   [Play ▶] ──────────────→ HOME PAGE (/home)   │
│   [Koleksi ku] ──────────→ COLLECTION PAGE     │
│   [⚙ Settings] ──────────→ SETTINGS PAGE       │
└─────────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────┐
│              HOME PAGE (/home)                   │
│   Bottom Nav: Beranda | Jelajahi | Koleksi |Profil│
│                                                 │
│   Tab "Beranda":                                │
│     [Cerita Featured] ───→ STORY DETAIL         │
│     [Cerita Populer]  ───→ STORY DETAIL         │
│     [Kartu Daerah]    ───→ REGION PAGE          │
│     [⚙ icon atas]     ───→ SETTINGS PAGE        │
│                                                 │
│   Tab "Jelajahi":                               │
│     ─────────────────────→ EXPLORE PAGE         │
│                                                 │
│   Tab "Koleksi":                                │
│     ─────────────────────→ COLLECTION PAGE      │
└─────────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────┐
│           EXPLORE PAGE (/explore)                │
│   [Setiap cerita di list] ──→ STORY DETAIL      │
└─────────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────┐
│           REGION PAGE (/region)                  │
│   [Setiap cerita] ──────────→ STORY DETAIL      │
└─────────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────┐
│        STORY DETAIL PAGE (/story_detail)         │
│   [← Back] ─────────────→ Kembali ke halaman    │
│                              sebelumnya          │
└─────────────────────────────────────────────────┘
```

### Cara kerja navigasi di code:

**Masuk ke halaman baru:**
```dart
import 'package:get/get.dart';
import '../routes/app_routes.dart';

// Navigasi forward (push)
Get.toNamed(AppRoutes.HOME);

// Navigasi dengan argument (misal passing data daerah)
Get.toNamed(AppRoutes.REGION, arguments: {'region': 'Java'});
```

**Kembali ke halaman sebelumnya:**
```dart
Get.back();  // Kembali 1 halaman
```

**Di halaman tujuan, ambil argument:**
```dart
// Di region_page.dart:
final region = Get.arguments?['region'] ?? 'Java';
```

---

## 📦 Dependencies

| Package | Fungsi |
|---|---|
| `flutter` (SDK) | Core framework |
| `get: ^4.7.0` | State management & routing |
| `cupertino_icons` | Icon set tambahan |

---

## ▶️ Cara Jalankan

```bash
# 1. Install dependencies
flutter pub get

# 2. Jalankan aplikasi
flutter run
```

---

## 💡 Tips Pengembangan Lanjutan

- **Tambah cerita baru**: Edit data di masing-masing screen atau buat model & service terpisah.
- **Ganti placeholder gambar**: Taruh gambar di `assets/images/` dan update path di code.
- **Tambah animasi**: Gunakan `AnimatedOpacity`, `AnimatedSlide`, atau paket seperti `flutter_animate`.
- **Simpan koleksi secara lokal**: Gunakan `shared_preferences` atau `hive` untuk persistence.
