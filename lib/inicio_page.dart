import 'package:flutter/material.dart';

import 'compartir_libro_page.dart';

/// Contenido de la pestaña Inicio (panel principal).
class InicioPage extends StatelessWidget {
  const InicioPage({super.key});

  static const Color _brandGreen = Color(0xFF1A533E);

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 960;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: _heroSection(context)),
                const SizedBox(width: 32),
                Expanded(flex: 4, child: _statsPanel()),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _heroSection(context),
                const SizedBox(height: 28),
                _statsPanel(),
              ],
            ),
    );
  }

  Widget _heroSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE8E0D5)),
          ),
          child: const Text(
            '✨ PLATAFORMA SOLIDARIA DE LIBROS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              color: Color(0xFF5C4A3A),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text.rich(
          TextSpan(
            style: const TextStyle(
              fontFamily: 'Georgia',
              fontSize: 40,
              height: 1.15,
              color: Color(0xFF2C2C2C),
              fontWeight: FontWeight.w600,
            ),
            children: const [
              TextSpan(text: 'Dona un libro, '),
              TextSpan(
                text: 'abre una puerta.',
                style: TextStyle(color: _brandGreen),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Conectamos donantes con estudiantes, bibliotecas y organizaciones que necesitan acceso a material educativo. Gratis. Siempre.',
          style: TextStyle(fontSize: 15, height: 1.5, color: Color(0xFF5C5C5C)),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: () => abrirCompartirLibro(context),
              style: FilledButton.styleFrom(
                backgroundColor: _brandGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.card_giftcard_outlined),
              label: const Text('Compartir un libro'),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: _brandGreen,
                side: const BorderSide(color: _brandGreen, width: 1.2),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.search),
              label: const Text('Encontrar un libro'),
            ),
          ],
        ),
        const SizedBox(height: 28),
        const Wrap(
          spacing: 24,
          runSpacing: 12,
          children: [
            _FeaturePill(icon: Icons.verified_user_outlined, text: 'Plataforma segura'),
            _FeaturePill(icon: Icons.bolt_outlined, text: 'Gratis y rápido'),
            _FeaturePill(icon: Icons.public, text: 'Impacto real'),
          ],
        ),
      ],
    );
  }

  Widget _statsPanel() {
    return Column(
      children: [
        _statCard(
          wide: true,
          background: const Color(0xFFE8EDE9),
          icon: const Text('📚', style: TextStyle(fontSize: 28)),
          value: '6',
          label: 'libros disponibles',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _statCard(
                background: const Color(0xFFF5E6C8),
                icon: const Text('🎁', style: TextStyle(fontSize: 26)),
                value: '2',
                label: 'libros donados',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                background: const Color(0xFFDFF0E4),
                icon: const Text('🌱', style: TextStyle(fontSize: 26)),
                value: '∞',
                label: 'vidas impactadas',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _statCard(
          wide: true,
          background: const Color(0xFFE4EDF5),
          icon: const Text('✍️', style: TextStyle(fontSize: 26)),
          value: '12',
          label: 'mis publicaciones',
        ),
      ],
    );
  }

  Widget _statCard({
    required Color background,
    required Widget icon,
    required String value,
    required String label,
    bool wide = false,
  }) {
    return Container(
      width: wide ? double.infinity : null,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          icon,
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Color(0xFF2C2C2C)),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.black.withValues(alpha: 0.55)),
          ),
        ],
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF5C5C5C)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14, color: Color(0xFF5C5C5C))),
      ],
    );
  }
}
