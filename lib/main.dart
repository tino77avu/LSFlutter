import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_shell.dart';
import 'login_page.dart';
import 'profile_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://hbcibskphzghxuajferf.supabase.co',
    anonKey: 'sb_publishable_riMMnuxTFzA7L59Te8_7jg_7_N3bm7T',
  );

  runApp(const LibroSolidarioApp());
}

class LibroSolidarioApp extends StatelessWidget {
  const LibroSolidarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LibroSolidario',
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  StreamSubscription<AuthState>? _authSub;
  Session? _session;

  @override
  void initState() {
    super.initState();
    _session = Supabase.instance.client.auth.currentSession;

    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final next = data.session;
      if (!mounted) return;
      setState(() => _session = next);

      if (next != null) {
        final ev = data.event;
        if (ev == AuthChangeEvent.signedIn || ev == AuthChangeEvent.userUpdated) {
          unawaited(_syncProfileFromAuth('onAuthStateChange:$ev'));
        }
      }
    });

    if (_session != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_syncProfileFromAuth('coldStart'));
      });
    }
  }

  Future<void> _syncProfileFromAuth(String reason) async {
    debugPrint('[AuthGate] sincronizar perfil ($reason)');
    try {
      await ProfileService.instance.createProfileIfNotExists();
      debugPrint('[AuthGate] sincronizar perfil OK ($reason)');
    } catch (e, st) {
      debugPrint('[AuthGate] sincronizar perfil FALLÓ ($reason): $e\n$st');
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = _session ?? Supabase.instance.client.auth.currentSession;
    if (session != null) {
      return const AppShell();
    }
    return const LoginPage();
  }
}
