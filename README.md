# Kids Money Flutter

Fondasi Flutter modular untuk aplikasi Kids Money dengan backend Supabase terpisah.

## Arsitektur

```text
GitHub:   muhajirinfatona/kids-money-public
Supabase: Kids Money (project baru)
Cloudflare: deployment publik terpisah
```

## Struktur

```text
lib/
├── main.dart
├── application/app_state.dart
├── domain/models/kids_money_models.dart
├── core/config/supabase_config.dart
├── core/theme/app_theme.dart
├── data/repositories/children_repository.dart
├── features/parent/
├── features/child/
├── features/transactions/
├── features/goals/
└── features/missions/
```

## Menjalankan dengan Supabase

Jangan simpan URL atau key di source code. Gunakan parameter runtime:

```bash
flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=https://PROJECT-REF.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_xxx
```

Gunakan **publishable key** atau legacy `anon` key saja. Jangan pernah memasukkan `service_role` key ke APK, GitHub, atau Cloudflare Pages.

## Build APK

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://PROJECT-REF.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_xxx
```

## Backend

Project Supabase baru berisi tabel `children`, `wallets`, `transactions`, `savings_goals`, `tasks`, dan `earning_projects` dengan Row Level Security aktif. Repository data berada di `lib/data/repositories/`.

Project Supabase Kids Money sudah terhubung dan memiliki migration core schema serta RLS aktif. Migration tambahan untuk transaksi atomik ada di `supabase/20261005_atomic_transaction.sql` dan sudah diterapkan ke project production. Aktifkan Auth email/password pada Authentication > Providers. Aplikasi memiliki mode demo lokal jika `SUPABASE_URL` dan `SUPABASE_PUBLISHABLE_KEY` belum diberikan; pada mode terkonfigurasi, login/register orang tua memuat data dari Supabase.

Fitur yang tersedia:

- Login dan register orang tua dengan Supabase Auth.
- Profil anak: tambah, pilih, dan muat ulang dari Supabase.
- Saldo tiga wallet (`spend`, `save`, `share`) dan transaksi income/expense.
- CRUD awal misi serta target tabungan.
- Mode anak untuk melihat saldo dan misi tanpa akses pengelolaan orang tua.
