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
  bool _submittingRequest = false;
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

  bool get _canRequestBook {
    final b = _book;
    if (b == null || _isMine) return false;
    final status = b.status.toLowerCase().trim().replaceAll('á', 'a');
    return status == 'disponible';
  }

  Future<void> _openRequestDialog() async {
    final book = _book;
    if (book == null || _submittingRequest) return;

    final controller = TextEditingController();
    var localError = '';
    var localSubmitting = false;

    final submitted = await showDialog<bool>(
      context: context,
      barrierDismissible: !localSubmitting,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              titlePadding: const EdgeInsets.fromLTRB(18, 16, 12, 6),
              contentPadding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
              actionsPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
              title: Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFFEAF3EC),
                    child: Icon(Icons.menu_book, color: AppTopBar.brandGreen),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _friendlyText(book.title),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _friendlyText(book.author),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cerrar',
                    onPressed: localSubmitting
                        ? null
                        : () => Navigator.of(dialogContext).pop(false),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              content: SizedBox(
                width: 520,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cuéntale al donante por qué necesitas este libro.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withValues(alpha: 0.65),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Mensaje para el donante *',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller,
                      enabled: !localSubmitting,
                      maxLines: 4,
                      maxLength: 300,
                      decoration: InputDecoration(
                        hintText:
                            'Ej: Soy estudiante y este libro me ayudaría con mis clases...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppTopBar.brandGreen,
                          ),
                        ),
                        errorText: localError.isEmpty ? null : localError,
                      ),
                      onChanged: (_) {
                        if (localError.isNotEmpty) {
                          setLocalState(() => localError = '');
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: localSubmitting
                      ? null
                      : () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancelar'),
                ),
                FilledButton.icon(
                  onPressed: localSubmitting
                      ? null
                      : () async {
                          final message = controller.text.trim();
                          if (message.isEmpty) {
                            setLocalState(
                              () => localError = 'Este campo es obligatorio.',
                            );
                            return;
                          }
                          if (message.length > 300) {
                            setLocalState(
                              () =>
                                  localError = 'El mensaje no debe exceder 300 caracteres.',
                            );
                            return;
                          }

                          setLocalState(() => localSubmitting = true);
                          try {
                            await BooksService.instance.submitBookRequest(
                              bookId: book.id,
                              message: message,
                              ownerUserId: book.userId,
                              bookTitle: book.title,
                            );
                            if (!dialogContext.mounted) return;
                            Navigator.of(dialogContext).pop(true);
                          } catch (e) {
                            setLocalState(() {
                              localError = e.toString().replaceFirst(
                                'Exception: ',
                                '',
                              );
                              localSubmitting = false;
                            });
                          }
                        },
                  icon: localSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.volunteer_activism_outlined),
                  label: Text(
                    localSubmitting ? 'Enviando...' : 'Enviar solicitud',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTopBar.brandGreen,
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
    if (!mounted || submitted != true) return;
    setState(() => _submittingRequest = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Solicitud enviada. El donante la verá en su panel.'),
      ),
    );
    setState(() => _submittingRequest = false);
  }

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.paddingOf(context).bottom;
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
                    padding: EdgeInsets.fromLTRB(pad, pad, pad, pad + 96),
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
                  padding: EdgeInsets.fromLTRB(pad, pad, pad, pad + 110),
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
      bottomNavigationBar:
          (!_loading && _error == null && _book != null && _canRequestBook)
          ? SafeArea(
              minimum: EdgeInsets.fromLTRB(16, 8, 16, 12 + safeBottom),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Pronto podras contactar al donante desde aqui.',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Contactar donante'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTopBar.brandGreen,
                        side: const BorderSide(color: AppTopBar.brandGreen),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _submittingRequest ? null : _openRequestDialog,
                      icon: const Icon(Icons.volunteer_activism_outlined),
                      label: const Text('Solicitar libro'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTopBar.brandGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
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
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
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
    final categoryLabel = _friendlyText(book.category);
    final conditionLabel = _friendlyCondition(book.condition);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionCard(
          title: 'Información del libro',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _friendlyText(book.title),
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
                _friendlyText(book.author),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black.withValues(alpha: 0.58),
                ),
              ),
              if (dateStr.isNotEmpty) ...[
                const SizedBox(height: 8),
                _GreyChip(icon: Icons.calendar_today_outlined, text: dateStr),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        _SectionCard(
          title: 'Estado y categoria',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _GenreChip(label: categoryLabel),
              _GreyChip(icon: Icons.auto_stories_outlined, text: conditionLabel),
              _GreyChip(
                icon: Icons.task_alt,
                text: _friendlyStatus(book.status),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _SectionCard(
          title: 'Donante / ubicacion',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.place_outlined,
                    size: 20,
                    color: AppTopBar.brandGreen,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _friendlyText(book.city),
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
              const SizedBox(height: 12),
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
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: Color(0xFFFFB300),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                book.ownerRatingAvg == null
                                    ? 'Sin calificación'
                                    : '${book.ownerRatingAvg!.toStringAsFixed(1)} (${book.ownerRatingCount})',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black.withValues(alpha: 0.62),
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
            ],
          ),
        ),
        const SizedBox(height: 14),
        _SectionCard(
          title: 'Descripcion',
          child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0EE),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            book.description?.trim().isNotEmpty == true
                ? book.description!.trim()
                : 'Sin descripción aportada por el donante.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black.withValues(alpha: 0.75),
            ),
          ),
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: Colors.black.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
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
  if (s.contains('donandos') || s.contains('donandose')) {
    return const _StatusPresentation(
      title: 'Donándose',
      subtitle: 'Ya fue aceptado y está en coordinación de entrega.',
      bgColor: Color(0xFFFFF8E1),
      borderColor: Color(0xFFFFE082),
      accentColor: Color(0xFFE65100),
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

String _friendlyCondition(String raw) {
  final normalized = raw.toLowerCase().trim().replaceAll('_', ' ');
  if (normalized == 'usado aceptable') return 'Usado - aceptable';
  if (normalized.isEmpty) return '—';
  return _friendlyText(normalized);
}

String _friendlyStatus(String raw) {
  final normalized = raw.toLowerCase().trim().replaceAll('_', ' ');
  if (normalized == 'disponible') return 'Disponible';
  if (normalized.isEmpty) return '—';
  return _friendlyText(normalized);
}

String _friendlyText(String raw) {
  final clean = raw.trim().replaceAll('_', ' ');
  if (clean.isEmpty) return '—';
  final words = clean.split(RegExp(r'\s+'));
  return words
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
      .join(' ');
}

String _initial(String name) {
  final t = name.trim();
  if (t.isEmpty) return '?';
  return t.substring(0, 1).toUpperCase();
}
