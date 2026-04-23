import 'package:flutter/material.dart';

import 'books_service.dart';

class MisFavoritosPage extends StatefulWidget {
  const MisFavoritosPage({super.key});

  static const Color _brand = Color(0xFF1A533E);

  @override
  State<MisFavoritosPage> createState() => _MisFavoritosPageState();
}

class _MisFavoritosPageState extends State<MisFavoritosPage> {
  bool _loading = true;
  String? _error;
  List<FavoriteBookItem> _favorites = const [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final favorites = await BooksService.instance.loadMyFavorites();
      if (!mounted) return;
      setState(() => _favorites = favorites);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _removeFavorite(FavoriteBookItem item) async {
    try {
      await BooksService.instance.toggleFavorite(
        bookId: item.bookId,
        shouldFavorite: false,
      );
      if (!mounted) return;
      setState(
        () => _favorites = _favorites
            .where((e) => e.bookId != item.bookId)
            .toList(),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo quitar de favoritos: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F0E8),
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 560;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.favorite_border,
                          color: const Color(0xFFEF5350),
                          size: isNarrow ? 28 : 34,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Mis favoritos',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: isNarrow ? 28 : 46,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Libros que guardaste para no perder de vista',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black.withValues(alpha: 0.6),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 26),
                    if (_loading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_error != null)
                      _stateCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'No se pudo cargar tus favoritos.',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            Text(_error!),
                            const SizedBox(height: 10),
                            FilledButton(
                              onPressed: _loadFavorites,
                              style: FilledButton.styleFrom(
                                backgroundColor: MisFavoritosPage._brand,
                              ),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      )
                    else if (_favorites.isEmpty)
                      _stateCard(
                        child: Text(
                          'Aún no tienes libros favoritos. Marca el corazón en Explorar para guardarlos.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black.withValues(alpha: 0.6),
                          ),
                        ),
                      )
                    else
                      Column(
                        children: _favorites
                            .map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _favoriteCard(item),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _stateCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: child,
    );
  }

  Widget _favoriteCard(FavoriteBookItem item) {
    final isAvailable = item.status.toLowerCase().trim() == 'disponible';
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 620;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 62,
                  height: 90,
                  child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                      ? Image.network(
                          item.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholderCover(),
                        )
                      : _placeholderCover(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isNarrow) ...[
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      _statusPill(item.status, isAvailable),
                    ] else
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _statusPill(item.status, isAvailable),
                        ],
                      ),
                    const SizedBox(height: 8),
                    Text(
                      item.author,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black.withValues(alpha: 0.6),
                      ),
                    ),
                    if (item.category.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.category,
                        style: const TextStyle(
                          fontSize: 13,
                          color: MisFavoritosPage._brand,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  TextButton.icon(
                    onPressed: () {},
                    iconAlignment: IconAlignment.end,
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    style: TextButton.styleFrom(
                      foregroundColor: MisFavoritosPage._brand,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(52, 36),
                    ),
                    label: const Text('Ver'),
                  ),
                  IconButton(
                    tooltip: 'Quitar de favoritos',
                    onPressed: () => _removeFavorite(item),
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.black.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statusPill(String status, bool isAvailable) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAvailable
              ? const Color(0xFF2E7D32)
              : const Color(0xFF757575),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 7,
            color: isAvailable
                ? const Color(0xFF2E7D32)
                : const Color(0xFF757575),
          ),
          const SizedBox(width: 6),
          Text(
            status.isEmpty ? 'Sin estado' : status,
            style: TextStyle(
              fontSize: 13,
              color: isAvailable
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFF757575),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderCover() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4A6741), Color(0xFF2E4A32)],
        ),
      ),
      child: const Icon(Icons.menu_book, color: Colors.white24, size: 28),
    );
  }
}
