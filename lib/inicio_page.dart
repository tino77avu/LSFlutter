import 'package:flutter/material.dart';

import 'books_service.dart';
import 'compartir_libro_page.dart';

/// Contenido de la pestaña Inicio (panel principal).
class InicioPage extends StatefulWidget {
  const InicioPage({super.key, required this.onIrExplorar});

  /// Abre la sección Explorar (catálogo / búsqueda).
  final VoidCallback onIrExplorar;

  static const Color _brandGreen = Color(0xFF1A533E);

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  static const Color _brandGreen = InicioPage._brandGreen;
  bool _loadingStats = true;
  String? _statsError;
  HomeStats _stats = const HomeStats(
    availableBooks: 0,
    myPublications: 0,
    donatedBooks: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _loadingStats = true;
      _statsError = null;
    });
    try {
      final stats = await BooksService.instance.loadHomeStats();
      if (!mounted) return;
      setState(() => _stats = stats);
    } catch (e) {
      if (!mounted) return;
      setState(
        () => _statsError = e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _loadingStats = false);
    }
  }

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
                Expanded(flex: 4, child: _statsPanel(context)),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _heroSection(context),
                const SizedBox(height: 28),
                _statsPanel(context),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.card_giftcard_outlined),
              label: const Text('Compartir un libro'),
            ),
            OutlinedButton.icon(
              onPressed: widget.onIrExplorar,
              style: OutlinedButton.styleFrom(
                foregroundColor: _brandGreen,
                side: const BorderSide(color: _brandGreen, width: 1.2),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
            _FeaturePill(
              icon: Icons.verified_user_outlined,
              text: 'Plataforma segura',
            ),
            _FeaturePill(icon: Icons.bolt_outlined, text: 'Gratis y rápido'),
            _FeaturePill(icon: Icons.public, text: 'Impacto real'),
          ],
        ),
      ],
    );
  }

  Widget _statsPanel(BuildContext context) {
    if (_loadingStats) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_statsError != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'No se pudieron cargar las métricas.',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              _statsError!,
              style: TextStyle(color: Colors.black.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _loadStats,
              style: FilledButton.styleFrom(backgroundColor: _brandGreen),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _statCard(
          wide: true,
          background: const Color(0xFFE8EDE9),
          icon: const Text('📚', style: TextStyle(fontSize: 28)),
          value: _stats.availableBooks.toString(),
          label: 'libros disponibles',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _statCard(
                background: const Color(0xFFF5E6C8),
                icon: const Text('🎁', style: TextStyle(fontSize: 26)),
                value: _stats.donatedBooks.toString(),
                label: 'libros donados',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                background: const Color(0xFFDFF0E4),
                icon: const Text('🌱', style: TextStyle(fontSize: 26)),
                value: _stats.impactedLives.toString(),
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
          value: _stats.myPublications.toString(),
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
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C2C2C),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black.withValues(alpha: 0.55),
            ),
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
        Text(
          text,
          style: const TextStyle(fontSize: 14, color: Color(0xFF5C5C5C)),
        ),
      ],
    );
  }
}
