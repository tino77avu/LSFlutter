import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_service.dart';
import 'profile_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  String _mensajeErrorRegistro(String rawMessage) {
    final raw = rawMessage.toLowerCase();
    if (raw.contains('unable to validate email address') ||
        raw.contains('invalid format')) {
      return 'El correo no tiene un formato válido. Verifícalo e inténtalo de nuevo.';
    }
    if (raw.contains('already') ||
        raw.contains('registered') ||
        raw.contains('exists') ||
        raw.contains('ya registrado') ||
        raw.contains('correo')) {
      return 'Este correo ya está registrado. Inicia sesión.';
    }
    if (raw.contains('password')) {
      return 'La contraseña no cumple los requisitos de seguridad.';
    }
    if (raw.contains('rate limit') || raw.contains('email rate limit exceeded')) {
      return 'Se alcanzó el límite de correos de verificación. Espera unos minutos e inténtalo otra vez.';
    }
    final limpio = rawMessage.trim();
    if (limpio.isNotEmpty) return limpio;
    return 'No se pudo completar el registro. Inténtalo nuevamente.';
  }

  String _mensajeErrorGeneral(Object error) {
    final raw = error.toString().replaceFirst('Exception: ', '').trim();
    if (raw.isEmpty) {
      return 'No se pudo completar el registro. Inténtalo nuevamente.';
    }
    return raw;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      debugPrint('[RegisterPage] signUp…');
      final response = await AuthService.instance.register(
        _emailCtrl.text.trim(),
        _passwordCtrl.text.trim(),
      );
      debugPrint(
        '[RegisterPage] signUp response user=${response.user?.id} '
        'session=${response.session != null} identities=${response.user?.identities?.length}',
      );

      final identities = response.user?.identities;
      final emailYaExiste = identities != null && identities.isEmpty;
      if (emailYaExiste) {
        setState(() {
          _error = 'Este correo ya está registrado. Inicia sesión.';
        });
        return;
      }

      final currentUser = Supabase.instance.client.auth.currentUser;
      debugPrint(
        '[RegisterPage] después signUp currentUser=${currentUser?.id} '
        'session=${Supabase.instance.client.auth.currentSession != null}',
      );
      if (currentUser != null) {
        try {
          debugPrint('[RegisterPage] createProfileIfNotExists…');
          await ProfileService.instance.createProfileIfNotExists();
          debugPrint('[RegisterPage] createProfileIfNotExists OK');
        } on Exception catch (e) {
          debugPrint('[RegisterPage] createProfileIfNotExists error: $e');
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Cuenta creada, pero no se pudo crear perfil: ${e.toString().replaceFirst('Exception: ', '')}',
              ),
            ),
          );
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            currentUser == null
                ? 'Cuenta creada. Revisa tu correo para confirmar el registro.'
                : 'Cuenta creada correctamente.',
          ),
        ),
      );
      Navigator.of(context).pop();
    } on AuthException catch (e) {
      debugPrint('AuthException register: ${e.message}');
      setState(() => _error = _mensajeErrorRegistro(e.message));
    } on Exception catch (e) {
      debugPrint('Exception register: $e');
      setState(() => _error = _mensajeErrorGeneral(e));
    } catch (e) {
      debugPrint('Unknown register error: $e');
      setState(() => _error = _mensajeErrorGeneral(e));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Crear cuenta'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Correo electrónico',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        final v = (value ?? '').trim();
                        if (v.isEmpty) return 'Ingresa tu correo.';
                        if (!v.contains('@')) return 'Correo inválido.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Contraseña',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        final v = (value ?? '').trim();
                        if (v.isEmpty) return 'Ingresa una contraseña.';
                        if (v.length < 6) return 'Mínimo 6 caracteres.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _confirmCtrl,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Confirmar contraseña',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        final v = (value ?? '').trim();
                        if (v.isEmpty) return 'Confirma la contraseña.';
                        if (v != _passwordCtrl.text.trim()) {
                          return 'Las contraseñas no coinciden.';
                        }
                        return null;
                      },
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ],
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F8F5F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Registrarme',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
