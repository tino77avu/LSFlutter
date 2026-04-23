import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  SupabaseClient get _client => Supabase.instance.client;

  Future<AuthResponse> login(String email, String password) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> register(String email, String password) {
    return _client.auth.signUp(email: email, password: password);
  }

  Future<void> logout() {
    return _client.auth.signOut();
  }

  User? currentUser() {
    return _client.auth.currentUser;
  }
}
