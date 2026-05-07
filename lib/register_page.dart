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
  static const Color _primaryGreen = Color(0xFF1F8F5F);
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _loading = false;
  String? _error;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  final _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

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

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.18)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryGreen, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.8),
      ),
    );
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
        const msg = 'Este correo ya está registrado. Inicia sesión.';
        setState(() {
          _error = msg;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(msg)),
        );
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
      final msg = _mensajeErrorRegistro(e.message);
      setState(() => _error = msg);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } on Exception catch (e) {
      debugPrint('Exception register: $e');
      final msg = _mensajeErrorGeneral(e);
      setState(() => _error = msg);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      debugPrint('Unknown register error: $e');
      final msg = _mensajeErrorGeneral(e);
      setState(() => _error = msg);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
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
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Crea tu cuenta y empieza a compartir libros',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration(
                            label: 'Correo electrónico',
                            hint: 'ejemplo@correo.com',
                          ),
                          validator: (value) {
                            final v = (value ?? '').trim();
                            if (v.isEmpty) return 'Ingresa tu correo.';
                            if (!_emailRegex.hasMatch(v)) {
                              return 'Ingresa un correo válido.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: _obscurePassword,
                          decoration: _inputDecoration(
                            label: 'Contraseña',
                            hint: 'Mínimo 6 caracteres',
                            suffixIcon: IconButton(
                              tooltip: _obscurePassword
                                  ? 'Mostrar contraseña'
                                  : 'Ocultar contraseña',
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.black54,
                              ),
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
                          obscureText: _obscureConfirm,
                          decoration: _inputDecoration(
                            label: 'Confirmar contraseña',
                            hint: 'Repite tu contraseña',
                            suffixIcon: IconButton(
                              tooltip: _obscureConfirm
                                  ? 'Mostrar contraseña'
                                  : 'Ocultar contraseña',
                              onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm,
                              ),
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.black54,
                              ),
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
                              backgroundColor: _primaryGreen,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: _primaryGreen.withValues(
                                alpha: 0.5,
                              ),
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
                                : const Text('Crear mi cuenta'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
