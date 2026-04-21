import 'package:flutter/material.dart';

import 'login_page.dart';

void main() {
  runApp(const LibroSolidarioApp());
}

class LibroSolidarioApp extends StatelessWidget {
  const LibroSolidarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LibroSolidario',
      home: const LoginPage(),
    );
  }
}
