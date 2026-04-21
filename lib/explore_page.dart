import 'package:flutter/material.dart';

/// Listado de libros con búsqueda y filtros (pestaña Explorar).
class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  static const Color brandGreen = Color(0xFF1A533E);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  static const int _totalLibros = 17;
  int _categoriaIndex = 0;

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

  static const List<_LibroDemo> _libros = [
    _LibroDemo(
      titulo: 'El nombre del viento',
      autor: 'Patrick Rothfuss',
      categoria: 'LITERATURA',
      condicion: 'Usado · Aceptable',
      ubicacion: 'Surco - Lima',
      esMio: true,
      gradiente: [Color(0xFF1B3D2F), Color(0xFF2D5A45)],
    ),
    _LibroDemo(
      titulo: 'Breve historia del tiempo',
      autor: 'Stephen Hawking',
      categoria: 'CIENCIA',
      condicion: 'Como nuevo',
      ubicacion: 'Miraflores - Lima',
      esMio: false,
      gradiente: [Color(0xFF1A2F4A), Color(0xFF2D4A6A)],
    ),
    _LibroDemo(
      titulo: 'It',
      autor: 'Stephen King',
      categoria: 'TERROR',
      condicion: 'Usado · Buen estado',
      ubicacion: 'San Isidro - Lima',
      esMio: false,
      gradiente: [Color(0xFF3D1515), Color(0xFF5C2020)],
    ),
    _LibroDemo(
      titulo: 'Sapiens',
      autor: 'Yuval Noah Harari',
      categoria: 'HISTORIA',
      condicion: 'Como nuevo',
      ubicacion: 'La Molina - Lima',
      esMio: false,
      gradiente: [Color(0xFF4A3A1A), Color(0xFF6B5428)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final crossCount = w >= 1100 ? 4 : w >= 700 ? 2 : 1;

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
                      '$_totalLibros libros disponibles en la comunidad',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black.withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Busca por título, autor o palabra clave...',
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF6B6B6B)),
                        suffixIcon: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.tune, color: Color(0xFF6B6B6B)),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF3F3F3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(c.icon, size: 18, color: sel ? Colors.white : const Color(0xFF444444)),
                          const SizedBox(width: 6),
                          Text(c.nombre),
                        ],
                      ),
                      selectedColor: ExplorePage.brandGreen,
                      labelStyle: TextStyle(
                        color: sel ? Colors.white : const Color(0xFF333333),
                        fontWeight: FontWeight.w500,
                      ),
                      backgroundColor: const Color(0xFFF0F0F0),
                      side: BorderSide(color: sel ? ExplorePage.brandGreen : const Color(0xFFE0E0E0)),
                      onSelected: (_) => setState(() => _categoriaIndex = i),
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossCount,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 0.62,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _BookCard(libro: _libros[index]),
                  childCount: _libros.length,
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

class _LibroDemo {
  const _LibroDemo({
    required this.titulo,
    required this.autor,
    required this.categoria,
    required this.condicion,
    required this.ubicacion,
    required this.esMio,
    required this.gradiente,
  });

  final String titulo;
  final String autor;
  final String categoria;
  final String condicion;
  final String ubicacion;
  final bool esMio;
  final List<Color> gradiente;
}

class _BookCard extends StatelessWidget {
  const _BookCard({required this.libro});

  final _LibroDemo libro;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      shadowColor: Colors.black12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: libro.gradiente,
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.auto_stories, size: 56, color: Colors.white24),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: libro.esMio ? ExplorePage.brandGreen : const Color(0xFF2E7D32),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            libro.esMio ? 'Mi libro' : 'Disponible',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: libro.esMio ? ExplorePage.brandGreen : const Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Row(
                      children: [
                        _roundIconBtn(Icons.favorite_border),
                        const SizedBox(width: 6),
                        _roundIconBtn(Icons.inventory_2_outlined),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        libro.categoria,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: ExplorePage.brandGreen,
                        ),
                      ),
                    ),
                    Text(
                      libro.condicion,
                      style: TextStyle(fontSize: 11, color: Colors.black.withValues(alpha: 0.45)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  libro.titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.2),
                ),
                const SizedBox(height: 4),
                Text(
                  libro.autor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: Colors.black.withValues(alpha: 0.5)),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.place_outlined, size: 16, color: Colors.black.withValues(alpha: 0.45)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        libro.ubicacion,
                        style: TextStyle(fontSize: 12, color: Colors.black.withValues(alpha: 0.5)),
                        overflow: TextOverflow.ellipsis,
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

  Widget _roundIconBtn(IconData icon) {
    return Material(
      color: Colors.white.withValues(alpha: 0.95),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: const Color(0xFF444444)),
        ),
      ),
    );
  }
}
