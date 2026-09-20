# Kids Money Flutter

Project ini adalah fondasi migrasi aplikasi Kids Money HTML/Android ke Flutter. **Tampilan yang sudah dibuat dipertahankan**, sedangkan fondasi pengembangan disiapkan agar fitur baru tidak perlu ditulis dalam satu file besar.

## Struktur

```text
lib/
├── main.dart                         # Entry point dan UI legacy yang sudah menyerupai HTML asli
├── application/
│   └── app_state.dart                # State aplikasi dan aksi bisnis
├── domain/
│   └── models/
│       └── kids_money_models.dart    # Model child, wallet, goal, task, transaction
├── core/
│   └── theme/
│       └── app_theme.dart            # Warna, tema, dan formatter bersama
├── features/
│   ├── parent/                       # Screen mode orang tua (pindahkan dari main.dart bertahap)
│   ├── child/                        # Screen mode anak (pindahkan dari main.dart bertahap)
│   ├── transactions/                 # Fitur transaksi
│   ├── goals/                        # Fitur target tabungan
│   └── missions/                     # Fitur misi/tugas
└── data/
    ├── repositories/                 # Tempat repository lokal/API nantinya
    └── sources/                      # SQLite, REST API, atau Firebase nantinya
```

## Prinsip pengembangan

1. **UI tidak menyimpan aturan bisnis.** Widget memanggil method pada `AppState` atau repository.
2. **Model domain tidak bergantung pada Flutter UI.** Model dapat digunakan untuk SQLite/API.
3. **State terpusat.** Ganti profil, mode orang tua/anak, tab, dan saldo berada di `AppState`.
4. **Fitur baru dibuat per folder.** Contoh: fitur transaksi baru diletakkan di `features/transactions/`.
5. **Tampilan tetap responsive.** Gunakan `LayoutBuilder`, `Expanded`, `Flexible`, `Wrap`, `minWidth`, dan `SafeArea`.

## Menjalankan

```bash
flutter pub get
flutter run
```

Flutter SDK belum tersedia di sandbox ini, sehingga validasi akhir perlu dilakukan di komputer yang memiliki Flutter SDK dan Android SDK.
