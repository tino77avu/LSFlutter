import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.city,
    required this.phone,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String email;
  final String fullName;
  final String? city;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: (map['id'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      fullName: (map['full_name'] as String?) ?? '',
      city: map['city'] as String?,
      phone: map['phone'] as String?,
      createdAt: _parseDate(map['created_at']),
      updatedAt: _parseDate(map['updated_at']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

class ProfileService {
  ProfileService._();

  static final ProfileService instance = ProfileService._();

  SupabaseClient get _client => Supabase.instance.client;

  Future<void> createProfileIfNotExists() async {
    debugPrint('[ProfileService] createProfileIfNotExists: inicio');

    final authUser = Supabase.instance.client.auth.currentUser;
    final session = Supabase.instance.client.auth.currentSession;

    if (authUser == null) {
      debugPrint('[ProfileService] ABORT: currentUser == null (no hay sesión JWT para PostgREST)');
      throw Exception('No hay usuario autenticado para crear el perfil.');
    }

    final userId = Supabase.instance.client.auth.currentUser!.id;
    final userEmail = Supabase.instance.client.auth.currentUser!.email ?? '';

    debugPrint(
      '[ProfileService] auth.currentUser.id=$userId email=$userEmail '
      'session=${session != null ? "sí" : "no"}',
    );

    try {
      debugPrint('[ProfileService] INSERT public.profiles id=$userId email=$userEmail');
      await _client.from('profiles').insert({
        'id': userId,
        'email': userEmail,
        'full_name': userEmail,
        'city': null,
        'phone': null,
      });
      debugPrint('[ProfileService] INSERT OK');
    } on PostgrestException catch (e, st) {
      debugPrint(
        '[ProfileService] PostgrestException code=${e.code} message=${e.message} '
        'details=${e.details} hint=${e.hint}\n$st',
      );
      if (e.code == '23505') {
        debugPrint('[ProfileService] fila ya existía (23505), se ignora');
        return;
      }
      throw Exception('No se pudo crear el perfil de usuario: ${e.message}');
    } catch (e, st) {
      debugPrint('[ProfileService] error genérico: $e\n$st');
      throw Exception('Error al crear el perfil de usuario: $e');
    }
  }

  Future<UserProfile> getMyProfile() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('No hay sesión activa.');
    }

    try {
      await createProfileIfNotExists();
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', currentUser.id)
          .single();
      return UserProfile.fromMap(data);
    } on PostgrestException catch (e) {
      throw Exception('No se pudo cargar tu perfil: ${e.message}');
    } catch (e) {
      throw Exception('Error al obtener tu perfil: $e');
    }
  }

  Future<void> updateMyProfile({
    String? fullName,
    String? city,
    String? phone,
    String? email,
  }) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('No hay sesión activa.');
    }

    final updates = <String, dynamic>{};
    if (fullName != null) updates['full_name'] = fullName.trim();
    if (city != null) updates['city'] = city.trim().isEmpty ? null : city.trim();
    if (phone != null) updates['phone'] = phone.trim().isEmpty ? null : phone.trim();
    if (email != null) updates['email'] = email.trim();

    if (updates.isEmpty) return;

    try {
      updates['updated_at'] = DateTime.now().toUtc().toIso8601String();
      await _client.from('profiles').update(updates).eq('id', currentUser.id);
    } on PostgrestException catch (e) {
      throw Exception('No se pudo actualizar tu perfil: ${e.message}');
    } catch (e) {
      throw Exception('Error al actualizar tu perfil: $e');
    }
  }
}
