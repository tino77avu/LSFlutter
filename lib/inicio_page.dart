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
  bool _loadingBooks = true;
  String? _booksError;
  List<BookListItem> _availableBooks = const [];

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadAvailableBooks();
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

  Future<void> _loadAvailableBooks() async {
    setState(() {
      _loadingBooks = true;
      _booksError = null;
    });
    try {
      final allBooks = await BooksService.instance.loadExploreBooks();
      final books = allBooks
          .where((b) => b.status.toLowerCase().trim() == 'disponible')
          .take(10)
          .toList();
      if (!mounted) return;
      setState(() => _availableBooks = books);
    } catch (e) {
      if (!mounted) return;
      setState(() => _booksError = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loadingBooks = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 960;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (wide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: _heroSection(context)),
                const SizedBox(width: 32),
                Expanded(flex: 4, child: _statsPanel(context)),
              ],
            )
          else ...[
            _heroSection(context),
            const SizedBox(height: 28),
            _statsPanel(context),
          ],
          const SizedBox(height: 28),
          _availableBooksSection(),
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
          'Cada libro puede cambiar una historia',
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
      return const Column(
        children: [
          _StatCardSkeleton(wide: true),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _StatCardSkeleton()),
              SizedBox(width: 12),
              Expanded(child: _StatCardSkeleton()),
            ],
          ),
          SizedBox(height: 12),
          _StatCardSkeleton(wide: true),
        ],
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
          value: _stats.availableBooks,
          label: 'libros listos para ayudar',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _statCard(
                background: const Color(0xFFF5E6C8),
                icon: const Text('🎁', style: TextStyle(fontSize: 26)),
                value: _stats.donatedBooks,
                label: 'libros donados',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                background: const Color(0xFFDFF0E4),
                icon: const Text('🌱', style: TextStyle(fontSize: 26)),
                value: _stats.impactedLives,
                label: 'personas beneficiadas',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _statCard(
          wide: true,
          background: const Color(0xFFE4EDF5),
          icon: const Text('✍️', style: TextStyle(fontSize: 26)),
          value: _stats.myPublications,
          label: 'mis publicaciones',
        ),
      ],
    );
  }

  Widget _statCard({
    required Color background,
    required Widget icon,
    required int value,
    required String label,
    bool wide = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      width: wide ? double.infinity : null,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          icon,
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: value.toDouble()),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, _) => Text(
              animatedValue.toInt().toString(),
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C2C2C),
              ),
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

  Widget _availableBooksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Libros disponibles',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2C2C2C),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Explora publicaciones recientes cerca de ti.',
          style: TextStyle(color: Colors.black.withValues(alpha: 0.58)),
        ),
        const SizedBox(height: 14),
        if (_loadingBooks)
          const Column(
            children: [
              _BookCardSkeleton(),
              SizedBox(height: 10),
              _BookCardSkeleton(),
              SizedBox(height: 10),
              _BookCardSkeleton(),
            ],
          )
        else if (_booksError != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'No se pudieron cargar los libros.',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(_booksError!),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: _loadAvailableBooks,
                  style: FilledButton.styleFrom(backgroundColor: _brandGreen),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          )
        else if (_availableBooks.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              'Aún no hay libros disponibles.',
              style: TextStyle(color: Colors.black.withValues(alpha: 0.58)),
            ),
          )
        else
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Column(
              key: ValueKey<int>(_availableBooks.length),
              children: _availableBooks
                  .map((b) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _AvailableBookCard(book: b),
                      ))
                  .toList(),
            ),
          ),
      ],
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

class _StatCardSkeleton extends StatefulWidget {
  const _StatCardSkeleton({this.wide = false});

  final bool wide;

  @override
  State<_StatCardSkeleton> createState() => _StatCardSkeletonState();
}

class _StatCardSkeletonState extends State<_StatCardSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.5, end: 1).animate(_controller),
      child: Container(
        width: widget.wide ? double.infinity : null,
        height: 150,
        decoration: BoxDecoration(
          color: const Color(0xFFEDEDED),
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}

class _BookCardSkeleton extends StatefulWidget {
  const _BookCardSkeleton();

  @override
  State<_BookCardSkeleton> createState() => _BookCardSkeletonState();
}

class _BookCardSkeletonState extends State<_BookCardSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 1).animate(_controller),
      child: Container(
        width: double.infinity,
        height: 96,
        decoration: BoxDecoration(
          color: const Color(0xFFEDEDED),
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}

class _AvailableBookCard extends StatelessWidget {
  const _AvailableBookCard({required this.book});

  final BookListItem book;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 58,
              height: 82,
              child: book.imageUrl != null && book.imageUrl!.isNotEmpty
                  ? Image.network(
                      book.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _bookPlaceholder(),
                    )
                  : _bookPlaceholder(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  book.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.place_outlined,
                      size: 15,
                      color: Colors.black.withValues(alpha: 0.45),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        book.city,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4A6741), Color(0xFF2E4A32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(Icons.menu_book, color: Colors.white30),
    );
  }
}
