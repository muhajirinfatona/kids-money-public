import 'package:flutter/foundation.dart';

class SupabaseConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const publishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;

  static void validate() {
    if (!isConfigured) {
      debugPrint('Supabase belum dikonfigurasi. Jalankan dengan --dart-define.');
    }
  }
}
