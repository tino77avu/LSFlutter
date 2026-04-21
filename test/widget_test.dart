import 'dart:ui' show Size;

import 'package:flutter_test/flutter_test.dart';

import 'package:lsflutter/main.dart';

void main() {
  testWidgets('LibroSolidarioApp muestra la pantalla de inicio', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(480, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const LibroSolidarioApp());

    expect(find.textContaining('LibroSolidario'), findsWidgets);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
