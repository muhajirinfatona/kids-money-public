# Rilis Kids Money di Google Play

## Prinsip penting

Tidak ada cara yang aman atau resmi untuk melewati Google Play Protect. Gunakan **Android App Bundle (AAB)** yang ditandatangani dengan upload key milik aplikasi, upload melalui Play Console, dan gunakan Play App Signing.

Build lokal dari sumber tidak dikenal atau APK yang ditandatangani debug dapat memunculkan peringatan. Itu berbeda dengan pemeriksaan keamanan terhadap isi aplikasi.

## 1. Buat upload keystore satu kali

Jalankan di komputer pribadi yang aman, bukan di repository:

```bash
keytool -genkeypair -v \
  -keystore kids-money-upload.jks \
  -alias kids-money-upload \
  -keyalg RSA -keysize 2048 -validity 10000
```

Simpan file `.jks`, password keystore, alias, dan password key dalam password manager. Jangan commit file ini ke Git.

## 2. Tambahkan GitHub Actions Secrets

Di GitHub repository → **Settings → Secrets and variables → Actions**, buat:

- `ANDROID_KEYSTORE_BASE64`: hasil `base64 -w 0 kids-money-upload.jks`
- `KEYSTORE_PASSWORD`: password keystore
- `KEY_ALIAS`: biasanya `kids-money-upload`
- `KEY_PASSWORD`: password key
- `SUPABASE_PUBLISHABLE_KEY`: publishable/anon key Supabase

Jangan gunakan `service_role` key.

## 3. Aktifkan Play App Signing

Pada Google Play Console:

1. Buat aplikasi Kids Money.
2. Upload AAB pertama dari workflow.
3. Pilih **Google Play App Signing**.
4. Simpan upload key dan ikuti instruksi Play Console.
5. Gunakan jalur Internal testing sebelum Production.

Play Console kemudian menandatangani distribusi final dengan app-signing key dan melakukan pemeriksaan Play Protect.

## 4. Validasi sebelum publikasi

- Gunakan AAB, bukan APK debug.
- Pastikan package name `com.kidsmoney.kids_money` tidak berubah setelah aplikasi pertama dirilis.
- Pastikan privacy policy tersedia.
- Jelaskan penggunaan email, profil anak, dan data keuangan secara akurat.
- Jangan meminta izin Android yang tidak diperlukan.
- Uji di Internal testing dan periksa Play Console > App integrity > App access.
