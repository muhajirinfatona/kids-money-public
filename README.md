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

Sebelum dipakai publik, aktifkan Auth email/password atau magic link di Supabase dan buat policy RLS sesuai kebutuhan. Jangan menggunakan policy `using (true)` untuk data saldo/transaksi.
