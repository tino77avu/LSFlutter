import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_top_bar.dart';
import 'books_service.dart';

/// Detalle de un libro desde Explorar (botón «Ver»).
class ExploreBookDetailPage extends StatefulWidget {
  const ExploreBookDetailPage({super.key, required this.bookId});

  final int bookId;

  @override
  State<ExploreBookDetailPage> createState() => _ExploreBookDetailPageState();
}

class _ExploreBookDetailPageState extends State<ExploreBookDetailPage> {
  bool _loading = true;
  String? _error;
  BookDetail? _book;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final b = await BooksService.instance.loadBookDetail(widget.bookId);
      if (!mounted) return;
      setState(() {
        _book = b;
        if (b == null) {
          _error = 'No se encontró este libro.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool get _isMine {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    final b = _book;
    if (uid == null || b == null) return false;
    return b.userId == uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A1A),
        elevation: 0.5,
        title: const Text(
          'Detalle del libro',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _load,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTopBar.brandGreen,
                      ),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            )
          : _book == null
          ? const Center(child: Text('Libro no disponible.'))
          : LayoutBuilder(
              builder: (context, c) {
                final wide = c.maxWidth >= 840;
                final pad = 24.0;
                final book = _book!;
                if (wide) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(pad),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 320,
                          child: _LeftColumn(book: book),
                        ),
                        const SizedBox(width: 28),
                        Expanded(child: _RightColumn(book: book, isMine: _isMine)),
                      ],
                    ),
                  );
                }
                return SingleChildScrollView(
                  padding: EdgeInsets.all(pad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _LeftColumn(book: book),
                      const SizedBox(height: 24),
                      _RightColumn(book: book, isMine: _isMine),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _LeftColumn extends StatelessWidget {
  const _LeftColumn({required this.book});

  final BookDetail book;

  static const List<Color> _placeholderGradient = [
    Color(0xFF1B3D2F),
    Color(0xFF2D5A45),
  ];

  @override
  Widget build(BuildContext context) {
    final status = _statusPresentation(book.status);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: book.imageUrl != null && book.imageUrl!.isNotEmpty
                ? Image.network(
                    book.imageUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return _placeholder(_placeholderGradient);
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        _placeholder(_placeholderGradient),
                  )
                : _placeholder(_placeholderGradient),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: status.bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: status.borderColor),
          ),
          child: Row(
            children: [
              Icon(Icons.circle, size: 10, color: status.accentColor),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: status.accentColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      status.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withValues(alpha: 0.5),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _placeholder(List<Color> colors) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: const Center(
        child: Icon(Icons.auto_stories, size: 64, color: Colors.white24),
      ),
    );
  }
}

class _RightColumn extends StatelessWidget {
  const _RightColumn({required this.book, required this.isMine});

  final BookDetail book;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final dateStr = _formatDateEs(book.createdAt);
    final categoryLower = book.category.toLowerCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _GenreChip(label: categoryLower),
            _GreyChip(
              icon: Icons.auto_stories_outlined,
              text: book.condition.isEmpty ? '—' : book.condition,
            ),
            if (dateStr.isNotEmpty)
              _GreyChip(icon: Icons.calendar_today_outlined, text: dateStr),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          book.title,
          style: const TextStyle(
            fontFamily: 'Georgia',
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A533E),
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          book.author,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.place_outlined, size: 20, color: AppTopBar.brandGreen),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                book.city.isEmpty ? '—' : book.city,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTopBar.brandGreen,
                ),
              ),
            ),
          ],
        ),
        if (book.recipientType.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            _recipientLabel(book.recipientType),
            style: TextStyle(
              fontSize: 12,
              color: Colors.black.withValues(alpha: 0.45),
            ),
          ),
        ],
        const SizedBox(height: 22),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0EE),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DESCRIPCIÓN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: Colors.black.withValues(alpha: 0.45),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                book.description?.trim().isNotEmpty == true
                    ? book.description!.trim()
                    : 'Sin descripción aportada por el donante.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.black.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFFE8F5E9),
                child: Text(
                  _initial(book.ownerDisplayName),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Publicado por',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF888888),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.ownerDisplayName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          size: 16,
                          color: Colors.black.withValues(alpha: 0.4),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Miembro verificado',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black.withValues(alpha: 0.45),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (isMine) ...[
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5EC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFC8E6C9)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTopBar.brandGreen),
                    const SizedBox(width: 8),
                    Text(
                      'Este es tu libro',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppTopBar.brandGreen,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Puedes gestionarlo desde tu panel de control.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black.withValues(alpha: 0.55),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Abre «Mi panel» en el menú para gestionar tu libro.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  label: const Text('Gestionar libro'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTopBar.brandGreen,
                    side: const BorderSide(color: Color(0xFFC8E6C9)),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _GenreChip extends StatelessWidget {
  const _GenreChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE65100),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.menu_book_rounded, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _GreyChip extends StatelessWidget {
  const _GreyChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF555555)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF444444),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

_StatusPresentation _statusPresentation(String raw) {
  final s = raw.toLowerCase().trim().replaceAll('á', 'a');
  if (s == 'disponible') {
    return const _StatusPresentation(
      title: 'Disponible',
      subtitle: 'Listo para ser solicitado',
      bgColor: Color(0xFFE8F5E9),
      borderColor: Color(0xFFC8E6C9),
      accentColor: Color(0xFF2E7D32),
    );
  }
  if (s.contains('donad') || s == 'entregado' || s == 'entregada') {
    return _StatusPresentation(
      title: 'Donado',
      subtitle: 'Este ejemplar ya fue entregado.',
      bgColor: Colors.blue.shade50,
      borderColor: Colors.blue.shade100,
      accentColor: Colors.blue.shade800,
    );
  }
  return _StatusPresentation(
    title: raw.isEmpty ? 'Estado' : raw,
    subtitle: 'Consulta al donante para más detalles.',
    bgColor: const Color(0xFFF5F5F5),
    borderColor: const Color(0xFFE0E0E0),
    accentColor: const Color(0xFF616161),
  );
}

class _StatusPresentation {
  const _StatusPresentation({
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.borderColor,
    required this.accentColor,
  });

  final String title;
  final String subtitle;
  final Color bgColor;
  final Color borderColor;
  final Color accentColor;
}

String _formatDateEs(DateTime? d) {
  if (d == null) return '';
  const meses = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];
  return '${d.day} ${meses[d.month - 1]} ${d.year}';
}

String _recipientLabel(String raw) {
  final r = raw.toLowerCase().trim();
  if (r == 'institucion' || r == 'institución') {
    return 'Destino: institución (colegio, biblioteca u ONG)';
  }
  if (r == 'persona') return 'Destino: persona';
  if (raw.isEmpty) return '';
  return 'Destino: $raw';
}

String _initial(String name) {
  final t = name.trim();
  if (t.isEmpty) return '?';
  return t.substring(0, 1).toUpperCase();
}
