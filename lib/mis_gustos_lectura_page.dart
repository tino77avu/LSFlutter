import 'package:flutter/material.dart';

import 'app_top_bar.dart';

/// Edición de categorías favoritas y nota libre (Ver y modificar en Mi perfil).
class MisGustosLecturaPage extends StatefulWidget {
  const MisGustosLecturaPage({super.key});

  static const Color _brand = AppTopBar.brandGreen;
  static const Color _bg = Color(0xFFF5F0E8);

  @override
  State<MisGustosLecturaPage> createState() => _MisGustosLecturaPageState();
}

class _MisGustosLecturaPageState extends State<MisGustosLecturaPage> {
  static const List<_CatOpcion> _todas = [
    _CatOpcion('Arte', '🎨'),
    _CatOpcion('Autoayuda', '🌱'),
    _CatOpcion('Ciencia', '🔬'),
    _CatOpcion('Educación', '📚'),
    _CatOpcion('Gastronomía', '👩‍🍳'),
    _CatOpcion('Historia', '🏛️'),
    _CatOpcion('Idiomas', '🌐'),
    _CatOpcion('Infantil', '🎠'),
    _CatOpcion('Literatura', '📖'),
    _CatOpcion('Mangas', '🪄'),
    _CatOpcion('Otro', '📦'),
    _CatOpcion('Romance', '💕'),
    _CatOpcion('Tecnología', '💻'),
    _CatOpcion('Ficción', '🛸'),
    _CatOpcion('Terror', '👻'),
  ];

  late final Set<String> _seleccion;
  late final TextEditingController _nota;

  @override
  void initState() {
    super.initState();
    _seleccion = {'Terror', 'Ficción'};
    _nota = TextEditingController(text: 'Me gustan las novelas de terror y ficcion');
  }

  @override
  void dispose() {
    _nota.dispose();
    super.dispose();
  }

  void _toggle(String id) {
    setState(() {
      if (_seleccion.contains(id)) {
        _seleccion.remove(id);
      } else {
        _seleccion.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MisGustosLecturaPage._bg,
      appBar: AppBar(
        backgroundColor: MisGustosLecturaPage._bg,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: const SizedBox.shrink(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Mi perfil',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: MisGustosLecturaPage._brand,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Resumen de tu actividad en LibroSolidario',
                  style: TextStyle(fontSize: 15, color: Colors.black.withValues(alpha: 0.52)),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                    boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, color: MisGustosLecturaPage._brand, size: 22),
                          const SizedBox(width: 8),
                          const Text(
                            'Mis gustos de lectura',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Color(0xFF1A1A1A)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Selecciona las categorías que más te interesan:',
                        style: TextStyle(fontSize: 14, color: Colors.black.withValues(alpha: 0.58)),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _todas.map((c) => _chipCategoria(c)).toList(),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        '¿Qué tipo de libros buscas? (opcional)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black.withValues(alpha: 0.72),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nota,
                        maxLines: 5,
                        maxLength: 400,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFFAFAFA),
                          hintText: 'Cuéntanos qué buscas leer…',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFD0D0D0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: MisGustosLecturaPage._brand, width: 1.4),
                          ),
                          counterText: '',
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${_nota.text.length}/400',
                          style: TextStyle(fontSize: 12, color: Colors.black.withValues(alpha: 0.45)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          FilledButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Gustos guardados (demo)')),
                              );
                              Navigator.of(context).pop();
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: MisGustosLecturaPage._brand,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.check, size: 20),
                            label: const Text('Guardar gustos', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              'Cancelar',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black.withValues(alpha: 0.65),
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
          ),
        ),
      ),
    );
  }

  Widget _chipCategoria(_CatOpcion c) {
    final sel = _seleccion.contains(c.nombre);
    return FilterChip(
      showCheckmark: false,
      selected: sel,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(c.emoji, style: const TextStyle(fontSize: 15)),
          const SizedBox(width: 6),
          Text(c.nombre),
          if (sel) ...[
            const SizedBox(width: 4),
            const Icon(Icons.check, size: 16, color: MisGustosLecturaPage._brand),
          ],
        ],
      ),
      selectedColor: const Color(0xFFE8F5EC),
      backgroundColor: const Color(0xFFF0F0F0),
      side: BorderSide(color: sel ? MisGustosLecturaPage._brand.withValues(alpha: 0.45) : const Color(0xFFE0E0E0)),
      labelStyle: TextStyle(
        color: sel ? MisGustosLecturaPage._brand : const Color(0xFF444444),
        fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
        fontSize: 13,
      ),
      onSelected: (_) => _toggle(c.nombre),
    );
  }
}

class _CatOpcion {
  const _CatOpcion(this.nombre, this.emoji);
  final String nombre;
  final String emoji;
}
