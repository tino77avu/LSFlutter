import 'package:flutter/material.dart';

/// Formulario para publicar un libro (pantalla completa con scroll).
class CompartirLibroPage extends StatefulWidget {
  const CompartirLibroPage({super.key});

  @override
  State<CompartirLibroPage> createState() => _CompartirLibroPageState();
}

class _CompartirLibroPageState extends State<CompartirLibroPage> {
  final _titulo = TextEditingController();
  final _autor = TextEditingController();
  final _ciudad = TextEditingController();
  final _descripcion = TextEditingController();

  String? _categoria;
  String? _estado;
  int _audiencia = 0;
  bool _fotoMarcada = false;

  static const _categorias = [
    'Educación',
    'Literatura',
    'Infantil',
    'Ciencia',
    'Historia',
    'Arte',
    'Tecnología',
    'Idiomas',
    'Autoayuda',
    'Otro',
  ];

  static const _estados = [
    'Como nuevo',
    'Usado · Excelente estado',
    'Usado · Buen estado',
    'Usado · Aceptable',
  ];

  static const Color _bg = Color(0xFFF5F4F0);
  static const Color _heading = Color(0xFF1A3D32);
  static const Color _greenPct = Color(0xFF1F8F5F);
  static const Color _brandGreen = Color(0xFF1A533E);

  @override
  void dispose() {
    _titulo.dispose();
    _autor.dispose();
    _ciudad.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  double get _progress {
    var n = 0;
    if (_titulo.text.trim().isNotEmpty) n++;
    if (_autor.text.trim().isNotEmpty) n++;
    if (_categoria != null) n++;
    if (_estado != null) n++;
    if (_ciudad.text.trim().isNotEmpty) n++;
    var p = n / 5.0 * 0.82;
    if (_fotoMarcada) p += 0.18;
    return p.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final pct = (_progress * 100).round();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        foregroundColor: const Color(0xFF222222),
        title: const SizedBox.shrink(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Compartir un libro',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: _heading,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Tu libro puede cambiar una vida. Publicarlo es gratis y toma solo 2 minutos.',
                  style: TextStyle(fontSize: 15, height: 1.45, color: Colors.black.withValues(alpha: 0.52)),
                ),
                const SizedBox(height: 22),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Completado', style: TextStyle(fontSize: 14, color: Colors.black.withValues(alpha: 0.55))),
                          Text('$pct%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _greenPct)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _progress,
                          minHeight: 8,
                          backgroundColor: const Color(0xFFE4E4E4),
                          color: _greenPct,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'INFORMACIÓN DEL LIBRO',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w800,
                          color: Colors.black.withValues(alpha: 0.45),
                        ),
                      ),
                      const SizedBox(height: 20),
                      LayoutBuilder(
                        builder: (context, c) {
                          final wide = c.maxWidth > 560;
                          final tituloField = _labeledField(
                            label: 'Título del libro',
                            requiredMark: true,
                            child: TextFormField(
                              controller: _titulo,
                              onChanged: (_) => _refresh(),
                              decoration: _inputDeco(hint: 'Ej: Cien años de soledad'),
                            ),
                          );
                          final autorField = _labeledField(
                            label: 'Autor',
                            requiredMark: true,
                            child: TextFormField(
                              controller: _autor,
                              onChanged: (_) => _refresh(),
                              decoration: _inputDeco(hint: 'Ej: Gabriel García Márquez'),
                            ),
                          );
                          if (wide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: tituloField),
                                const SizedBox(width: 16),
                                Expanded(child: autorField),
                              ],
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              tituloField,
                              const SizedBox(height: 16),
                              autorField,
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, c) {
                          final wide = c.maxWidth > 560;
                          final cat = _labeledField(
                            label: 'Categoría',
                            requiredMark: true,
                            child: DropdownButtonFormField<String>(
                              value: _categoria,
                              hint: const Text('Seleccionar categoría'),
                              decoration: _inputDeco(),
                              items: _categorias
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (v) => setState(() => _categoria = v),
                            ),
                          );
                          final est = _labeledField(
                            label: 'Estado del libro',
                            requiredMark: true,
                            child: DropdownButtonFormField<String>(
                              value: _estado,
                              hint: const Text('¿En qué estado está?'),
                              decoration: _inputDeco(),
                              items: _estados
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (v) => setState(() => _estado = v),
                            ),
                          );
                          if (wide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: cat),
                                const SizedBox(width: 16),
                                Expanded(child: est),
                              ],
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              cat,
                              const SizedBox(height: 16),
                              est,
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _labeledField(
                        label: 'Ciudad',
                        requiredMark: true,
                        helper: '¿Desde dónde se entregará el libro?',
                        child: TextFormField(
                          controller: _ciudad,
                          onChanged: (_) => _refresh(),
                          decoration: _inputDeco(hint: 'Ej: Ciudad de México'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _labeledField(
                        label: 'Descripción',
                        requiredMark: false,
                        helper: 'Opcional. Cuéntanos más sobre el libro o su estado actual.',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _descripcion,
                              onChanged: (_) => _refresh(),
                              maxLines: 5,
                              maxLength: 500,
                              decoration: _inputDeco(
                                hint: 'Ej: Edición 2015, lomo ligeramente desgastado pero páginas en perfecto estado.',
                              ).copyWith(counterText: ''),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '${_descripcion.text.length}/500',
                                style: TextStyle(fontSize: 12, color: Colors.black.withValues(alpha: 0.45)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        '¿A QUIÉN VA DIRIGIDO?',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: _heading,
                        ),
                      ),
                      const SizedBox(height: 14),
                      LayoutBuilder(
                        builder: (context, c) {
                          final wide = c.maxWidth > 480;
                          final persona = _audienciaCard(
                            selected: _audiencia == 0,
                            icon: Icons.person_outline,
                            title: 'Persona',
                            subtitle: 'Cualquier persona que lo necesite',
                            onTap: () => setState(() => _audiencia = 0),
                          );
                          final inst = _audienciaCard(
                            selected: _audiencia == 1,
                            icon: Icons.apartment_outlined,
                            title: 'Institución',
                            subtitle: 'Colegio, biblioteca u ONG',
                            onTap: () => setState(() => _audiencia = 1),
                          );
                          if (wide) {
                            return Row(
                              children: [
                                Expanded(child: persona),
                                const SizedBox(width: 12),
                                Expanded(child: inst),
                              ],
                            );
                          }
                          return Column(
                            children: [
                              persona,
                              const SizedBox(height: 12),
                              inst,
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'FOTO DEL LIBRO (recomendado)',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                          color: _heading,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() => _fotoMarcada = true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Aquí podrás elegir una imagen desde tu dispositivo.')),
                            );
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFBDBDBD), width: 2),
                            ),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: const Color(0xFFF0F0F0),
                                  child: Icon(Icons.image_outlined, size: 32, color: Colors.grey.shade600),
                                ),
                                const SizedBox(height: 14),
                                const Text(
                                  'Haz clic para subir una foto',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'JPG, PNG o WEBP · Máx. 5MB',
                                  style: TextStyle(fontSize: 13, color: Colors.black.withValues(alpha: 0.42)),
                                ),
                                if (_fotoMarcada) ...[
                                  const SizedBox(height: 10),
                                  const Text('✓ Foto indicada', style: TextStyle(color: _greenPct, fontWeight: FontWeight.w600)),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    if (_titulo.text.trim().isEmpty ||
                        _autor.text.trim().isEmpty ||
                        _categoria == null ||
                        _estado == null ||
                        _ciudad.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Completa los campos obligatorios (*).')),
                      );
                      return;
                    }
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.of(context).pop();
                    messenger.showSnackBar(
                      const SnackBar(content: Text('¡Libro publicado! (demo)')),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: _brandGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.menu_book_outlined),
                  label: const Text('Compartir este libro', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                ),
                const SizedBox(height: 14),
                Text(
                  'Al compartirlo, otros usuarios podrán solicitarlo y coordinarte la entrega.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, height: 1.4, color: Colors.black.withValues(alpha: 0.45)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: child,
    );
  }

  InputDecoration _inputDeco({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD0D0D0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD0D0D0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1A533E), width: 1.4)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  Widget _labeledField({
    required String label,
    required bool requiredMark,
    required Widget child,
    String? helper,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            children: [
              TextSpan(text: label),
              if (requiredMark)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Color(0xFFC62828), fontWeight: FontWeight.w700),
                ),
            ],
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 4),
          Text(helper, style: TextStyle(fontSize: 12, color: Colors.black.withValues(alpha: 0.45))),
        ],
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _audienciaCard({
    required bool selected,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final border = selected ? _brandGreen : const Color(0xFFD0D0D0);
    final titleColor = selected ? _brandGreen : const Color(0xFF333333);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border, width: selected ? 2 : 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFFF0F0F0),
                child: Icon(icon, color: const Color(0xFF555555)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: titleColor)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(fontSize: 13, height: 1.35, color: Colors.black.withValues(alpha: 0.52))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Abre el formulario de compartir libro (desde cualquier pantalla con `context`).
void abrirCompartirLibro(BuildContext context) {
  Navigator.of(context).push<void>(
    MaterialPageRoute<void>(builder: (_) => const CompartirLibroPage()),
  );
}
