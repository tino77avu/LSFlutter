import 'package:flutter/material.dart';

import 'app_top_bar.dart';

/// Recomendaciones personalizadas con IA (desde icono en barra o tarjeta en perfil).
class RecomendacionesPage extends StatelessWidget {
  const RecomendacionesPage({super.key});

  static const Color _bg = Color(0xFFFDFBF7);
  static const Color _brand = AppTopBar.brandGreen;
  static const Color _accentGreen = Color(0xFF2E7D5B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: const SizedBox.shrink(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5EC),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _accentGreen.withValues(alpha: 0.25)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome, size: 16, color: _accentGreen),
                        SizedBox(width: 8),
                        Text(
                          'IA PERSONALIZADA',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.7,
                            color: _accentGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Recomendaciones para ti',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Nuestra IA analiza los libros disponibles y tus gustos para encontrar los más adecuados para ti.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.black.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE8E4DC)),
                    boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.menu_book_outlined, color: _accentGreen, size: 22),
                          const SizedBox(width: 10),
                          Text(
                            'Basado en tus gustos',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: _accentGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _tagGusto('terror'),
                          _tagGusto('ficcion'),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '«Me gustan las novelas de terror y ficcion»',
                        style: TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          height: 1.45,
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Aquí se mostrarán tus recomendaciones cuando conectemos el servicio de IA.'),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: _brand,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.auto_awesome, size: 22),
                  label: const Text(
                    'Obtener mis recomendaciones',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _tagGusto(String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5EC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accentGreen.withValues(alpha: 0.35)),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          color: _accentGreen,
        ),
      ),
    );
  }
}
