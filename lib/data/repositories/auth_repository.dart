import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  AuthRepository(this.client);
  final SupabaseClient client;

  User? get currentUser => client.auth.currentUser;

  Future<AuthResponse> signIn(String email, String password) => client.auth.signInWithPassword(email: email.trim(), password: password);

  Future<AuthResponse> signUp(String email, String password, String name) => client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': name.trim()},
      );

  Future<void> signOut() => client.auth.signOut();
}
