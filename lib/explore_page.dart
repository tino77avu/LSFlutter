import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'books_service.dart';
import 'explore_book_detail_page.dart';

/// Listado de libros con búsqueda y filtros (pestaña Explorar).
class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  static const Color brandGreen = Color(0xFF1A533E);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  int _categoriaIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  bool _loading = true;
  String? _error;
  List<BookListItem> _allBooks = [];
  Set<int> _favoriteBookIds = <int>{};

  static const List<_CategoriaChip> _categorias = [
    _CategoriaChip('Todos', Icons.grid_view_rounded),
    _CategoriaChip('Educación', Icons.school_outlined),
    _CategoriaChip('Literatura', Icons.menu_book_outlined),
    _CategoriaChip('Infantil', Icons.child_care_outlined),
    _CategoriaChip('Ciencia', Icons.science_outlined),
    _CategoriaChip('Historia', Icons.account_balance_outlined),
    _CategoriaChip('Arte', Icons.palette_outlined),
    _CategoriaChip('Tecnología', Icons.computer_outlined),
    _CategoriaChip('Idiomas', Icons.translate),
    _CategoriaChip('Autoayuda', Icons.psychology_outlined),
    _CategoriaChip('Otro', Icons.label_outline),
  ];

  @override
  void initState() {
    super.initState();
    _loadBooks();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final books = await BooksService.instance.loadExploreBooks();
      final favoriteIds = await BooksService.instance.loadFavoriteBookIds();
      if (!mounted) return;
      setState(() {
        _allBooks = books;
        _favoriteBookIds = favoriteIds;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleFavorite(BookListItem book) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión para guardar favoritos.')),
      );
      return;
    }
    final currentlyFav = _favoriteBookIds.contains(book.id);
    final nextFav = !currentlyFav;

    setState(() {
      if (nextFav) {
        _favoriteBookIds.add(book.id);
      } else {
        _favoriteBookIds.remove(book.id);
      }
    });

    try {
      await BooksService.instance.toggleFavorite(
        bookId: book.id,
        shouldFavorite: nextFav,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (currentlyFav) {
          _favoriteBookIds.add(book.id);
        } else {
          _favoriteBookIds.remove(book.id);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo actualizar favoritos: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    }
  }

  List<BookListItem> get _filteredBooks {
    final query = _searchController.text.trim().toLowerCase();
    var list = _allBooks;

    if (_categoriaIndex > 0) {
      final selectedCategoryName = _categorias[_categoriaIndex].nombre;
      list = list
          .where(
            (b) => _matchesSelectedCategory(selectedCategoryName, b.category),
          )
          .toList();
    }

    if (query.isNotEmpty) {
      list = list.where((b) {
        return b.title.toLowerCase().contains(query) ||
            b.author.toLowerCase().contains(query) ||
            b.category.toLowerCase().contains(query) ||
            b.city.toLowerCase().contains(query);
      }).toList();
    }
    return list;
  }

  bool _matchesSelectedCategory(
    String selectedCategoryName,
    String bookCategory,
  ) {
    final selected = _normalizeCategoryText(selectedCategoryName);
    final category = _normalizeCategoryText(bookCategory);
    return category == selected ||
        category.contains(selected) ||
        selected.contains(category);
  }

  String _normalizeCategoryText(String value) {
    return value
        .toLowerCase()
        .trim()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final crossCount = w >= 1100
            ? 4
            : w >= 700
            ? 2
            : 1;

        final filteredBooks = _filteredBooks;
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Explorar libros',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${filteredBooks.length} libros disponibles en la comunidad',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black.withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar por título o autor',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF6B6B6B),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.tune,
                            color: Color(0xFF6B6B6B),
                          ),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF3F3F3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 46,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  scrollDirection: Axis.horizontal,
                  itemCount: _categorias.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final c = _categorias[i];
                    final sel = i == _categoriaIndex;
                    return FilterChip(
                      showCheckmark: false,
                      selected: sel,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            c.icon,
                            size: 18,
                            color: sel ? Colors.white : const Color(0xFF444444),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            c.nombre,
                            softWrap: false,
                            overflow: TextOverflow.visible,
                          ),
                        ],
                      ),
                      selectedColor: ExplorePage.brandGreen,
                      labelStyle: TextStyle(
                        color: sel ? Colors.white : const Color(0xFF333333),
                        fontWeight: FontWeight.w500,
                      ),
                      backgroundColor: const Color(0xFFF0F0F0),
                      side: BorderSide(
                        color: sel
                            ? ExplorePage.brandGreen
                            : const Color(0xFFE0E0E0),
                      ),
                      onSelected: (_) => setState(() => _categoriaIndex = i),
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            if (_loading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 34,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No se pudieron cargar los libros.\n$_error',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        FilledButton(
                          onPressed: _loadBooks,
                          style: FilledButton.styleFrom(
                            backgroundColor: ExplorePage.brandGreen,
                          ),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (filteredBooks.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('No hay libros para mostrar.')),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossCount,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: w >= 1100 ? 0.88 : (w >= 700 ? 0.82 : 0.9),
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _BookCard(
                      libro: filteredBooks[index],
                      isFavorite: _favoriteBookIds.contains(
                        filteredBooks[index].id,
                      ),
                      onToggleFavorite: () =>
                          _toggleFavorite(filteredBooks[index]),
                    ),
                    childCount: filteredBooks.length,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CategoriaChip {
  const _CategoriaChip(this.nombre, this.icon);
  final String nombre;
  final IconData icon;
}

class _BookCard extends StatelessWidget {
  const _BookCard({
    required this.libro,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  final BookListItem libro;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  static const List<Color> _defaultGradient = [
    Color(0xFF1B3D2F),
    Color(0xFF2D5A45),
  ];

  bool get _isMine {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return false;
    return libro.userId == userId;
  }

  String get _statusNorm => libro.status.toLowerCase().trim();

  String get _statusBadgeText {
    if (_isMine) return 'Mi libro';
    if (_statusNorm == 'disponible') return 'Disponible';
    if (_statusNorm.contains('donandos') || _statusNorm.contains('donandose')) {
      return 'Donándose';
    }
    if (_statusNorm == 'entregado' || _statusNorm.contains('donad')) {
      return 'Entregado';
    }
    return _prettyText(libro.status);
  }

  Color get _statusBadgeColor {
    if (_isMine) return ExplorePage.brandGreen;
    if (_statusNorm == 'disponible') return const Color(0xFF2E7D32);
    if (_statusNorm.contains('donandos') || _statusNorm.contains('donandose')) {
      return const Color(0xFFE65100);
    }
    if (_statusNorm == 'entregado' || _statusNorm.contains('donad')) {
      return const Color(0xFF1565C0);
    }
    return const Color(0xFF616161);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      shadowColor: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openDetail(context),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 132,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (libro.imageUrl != null && libro.imageUrl!.isNotEmpty)
                          Image.network(
                            libro.imageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return _bookPlaceholder(_defaultGradient);
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                _bookPlaceholder(_defaultGradient),
                          )
                        else
                          _bookPlaceholder(_defaultGradient),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.94),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 7,
                                  color: _statusBadgeColor,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  _statusBadgeText,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: _statusBadgeColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: _roundIconBtn(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            iconColor: isFavorite
                                ? const Color(0xFFD32F2F)
                                : const Color(0xFF444444),
                            onTap: onToggleFavorite,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _prettyText(libro.title),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _prettyText(libro.author),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.black.withValues(alpha: 0.58),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ciudad: ${_prettyText(libro.city)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.black.withValues(alpha: 0.58),
                  ),
                ),
                Text(
                  'Categoría: ${_prettyText(libro.category)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.black.withValues(alpha: 0.58),
                  ),
                ),
                Text(
                  'Estado: ${_prettyText(libro.status)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: ExplorePage.brandGreen,
                  ),
                ),
                const Spacer(),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _openDetail(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: ExplorePage.brandGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('Ver detalle'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ExploreBookDetailPage(bookId: libro.id),
      ),
    );
  }

  Widget _roundIconBtn(
    IconData icon, {
    VoidCallback? onTap,
    Color iconColor = const Color(0xFF444444),
  }) {
    return Material(
      color: Colors.white.withValues(alpha: 0.95),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap ?? () {},
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: iconColor),
        ),
      ),
    );
  }

  Widget _bookPlaceholder(List<Color> gradient) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
      ),
      child: const Center(
        child: Icon(Icons.auto_stories, size: 56, color: Colors.white24),
      ),
    );
  }

  String _prettyText(String raw) {
    final clean = raw.trim();
    if (clean.isEmpty) return '—';
    final parts = clean.split(RegExp(r'\s+'));
    return parts
        .map((w) {
          if (w.isEmpty) return w;
          return w[0].toUpperCase() + w.substring(1).toLowerCase();
        })
        .join(' ');
  }
}
