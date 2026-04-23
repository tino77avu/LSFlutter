import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'books_service.dart';
import 'profile_service.dart';

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

  /// Valores de `book_categories.value` y `book_conditions.value`.
  String? _categoriaValue;
  String? _estadoValue;
  int _audiencia = 0;
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;

  List<BookSelectOption> _categorias = [];
  List<BookSelectOption> _estados = [];
  bool _loadingCatalogos = true;
  String? _errorCatalogos;

  /// Aviso si la consulta respondió OK pero 0 filas (típico: RLS sin SELECT).
  String? _infoCatalogos;
  bool _publicando = false;
  String _publicandoTexto = 'Publicando…';

  static const Color _bg = Color(0xFFF5F4F0);
  static const Color _heading = Color(0xFF1A3D32);
  static const Color _greenPct = Color(0xFF1F8F5F);
  static const Color _brandGreen = Color(0xFF1A533E);

  @override
  void initState() {
    super.initState();
    _cargarCatalogos();
  }

  Future<void> _cargarCatalogos() async {
    setState(() {
      _loadingCatalogos = true;
      _errorCatalogos = null;
      _infoCatalogos = null;
    });

    List<BookSelectOption> cat = [];
    List<BookSelectOption> cond = [];
    Object? err;

    try {
      cat = await BooksService.instance.loadActiveCategories();
    } catch (e, st) {
      debugPrint('CompartirLibroPage categorías: $e\n$st');
      err = 'Categorías: $e';
    }
    try {
      cond = await BooksService.instance.loadActiveConditions();
    } catch (e, st) {
      debugPrint('CompartirLibroPage estados: $e\n$st');
      err = err == null ? 'Estados: $e' : '$err · Estados: $e';
    }

    if (!mounted) return;
    setState(() {
      _categorias = cat;
      _estados = cond;
      if (_categoriaValue != null &&
          !_categorias.any((e) => e.value == _categoriaValue)) {
        _categoriaValue = null;
      }
      if (_estadoValue != null &&
          !_estados.any((e) => e.value == _estadoValue)) {
        _estadoValue = null;
      }
      _errorCatalogos = (err?.toString())?.replaceFirst('Exception: ', '');
      if (err == null) {
        if (cat.isEmpty && cond.isEmpty) {
          _infoCatalogos =
              'No hay datos en categorías ni estados. Suele deberse a RLS: permite SELECT en book_categories y book_conditions.';
        } else if (cat.isEmpty) {
          _infoCatalogos =
              'No hay categorías activas o no tienes permiso SELECT en book_categories.';
        } else if (cond.isEmpty) {
          _infoCatalogos =
              'No hay estados activos o no tienes permiso SELECT en book_conditions.';
        }
      }
    });

    if (mounted) setState(() => _loadingCatalogos = false);
  }

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
    if (_categoriaValue != null) n++;
    if (_estadoValue != null) n++;
    if (_ciudad.text.trim().isNotEmpty) n++;
    var p = n / 5.0 * 0.82;
    if (_selectedImageBytes != null) p += 0.18;
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
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    color: Colors.black.withValues(alpha: 0.52),
                  ),
                ),
                const SizedBox(height: 22),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Completado',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black.withValues(alpha: 0.55),
                            ),
                          ),
                          Text(
                            '$pct%',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: _greenPct,
                            ),
                          ),
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
                              decoration: _inputDeco(
                                hint: 'Ej: Cien años de soledad',
                              ),
                            ),
                          );
                          final autorField = _labeledField(
                            label: 'Autor',
                            requiredMark: true,
                            child: TextFormField(
                              controller: _autor,
                              onChanged: (_) => _refresh(),
                              decoration: _inputDeco(
                                hint: 'Ej: Gabriel García Márquez',
                              ),
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
                      if (_infoCatalogos != null &&
                          !_loadingCatalogos &&
                          _errorCatalogos == null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Material(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.amber.shade900,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _infoCatalogos!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        height: 1.35,
                                        color: Colors.amber.shade900,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _cargarCatalogos,
                                    child: const Text('Actualizar'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      LayoutBuilder(
                        builder: (context, c) {
                          final wide = c.maxWidth > 560;
                          Widget errorCombo() {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  _errorCatalogos!,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 13,
                                  ),
                                ),
                                TextButton(
                                  onPressed: _cargarCatalogos,
                                  child: const Text('Reintentar'),
                                ),
                              ],
                            );
                          }

                          final cat = _labeledField(
                            label: 'Categoría',
                            requiredMark: true,
                            child: _loadingCatalogos
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : _errorCatalogos != null
                                ? errorCombo()
                                : _categorias.isEmpty
                                ? Text(
                                    'Sin categorías. Revisa RLS (SELECT) en book_categories.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.red.shade800,
                                    ),
                                  )
                                : DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    value: _categoriaValue,
                                    hint: const Text('Seleccionar categoría'),
                                    decoration: _inputDeco(),
                                    items: _categorias
                                        .map(
                                          (e) => DropdownMenuItem(
                                            value: e.value,
                                            child: Text(e.label),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) =>
                                        setState(() => _categoriaValue = v),
                                  ),
                          );
                          final est = _labeledField(
                            label: 'Estado del libro',
                            requiredMark: true,
                            child: _loadingCatalogos
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : _errorCatalogos != null
                                ? errorCombo()
                                : _estados.isEmpty
                                ? Text(
                                    'Sin estados. Revisa RLS (SELECT) en book_conditions.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.red.shade800,
                                    ),
                                  )
                                : DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    value: _estadoValue,
                                    hint: const Text('¿En qué estado está?'),
                                    decoration: _inputDeco(),
                                    items: _estados
                                        .map(
                                          (e) => DropdownMenuItem(
                                            value: e.value,
                                            child: Text(e.label),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) =>
                                        setState(() => _estadoValue = v),
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
                            children: [cat, const SizedBox(height: 16), est],
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
                        helper:
                            'Opcional. Cuéntanos más sobre el libro o su estado actual.',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _descripcion,
                              onChanged: (_) => _refresh(),
                              maxLines: 5,
                              maxLength: 500,
                              decoration: _inputDeco(
                                hint:
                                    'Ej: Edición 2015, lomo ligeramente desgastado pero páginas en perfecto estado.',
                              ).copyWith(counterText: ''),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '${_descripcion.text.length}/500',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black.withValues(alpha: 0.45),
                                ),
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
                          onTap: _publicando ? null : _pickImageFromGallery,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 36,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFBDBDBD),
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                if (_selectedImageBytes != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.memory(
                                      _selectedImageBytes!,
                                      height: 170,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                else
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: const Color(0xFFF0F0F0),
                                    child: Icon(
                                      Icons.image_outlined,
                                      size: 32,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                const SizedBox(height: 14),
                                Text(
                                  _selectedImageBytes == null
                                      ? 'Haz clic para subir una foto'
                                      : 'Imagen seleccionada',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'JPG, PNG o WEBP · Máx. 5MB',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black.withValues(alpha: 0.42),
                                  ),
                                ),
                                if (_selectedImage != null) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    '✓ ${_selectedImage!.name}',
                                    style: const TextStyle(
                                      color: _greenPct,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
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
                  onPressed:
                      _publicando ||
                          _loadingCatalogos ||
                          _errorCatalogos != null ||
                          _categorias.isEmpty ||
                          _estados.isEmpty
                      ? null
                      : _publicarLibro,
                  style: FilledButton.styleFrom(
                    backgroundColor: _brandGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: _publicando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.menu_book_outlined),
                  label: Text(
                    _publicando ? _publicandoTexto : 'Compartir este libro',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Al compartirlo, otros usuarios podrán solicitarlo y coordinarte la entrega.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Colors.black.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _publicarLibro() async {
    if (_titulo.text.trim().isEmpty ||
        _autor.text.trim().isEmpty ||
        _categoriaValue == null ||
        _estadoValue == null ||
        _ciudad.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa los campos obligatorios (*).')),
      );
      return;
    }

    final authUser = Supabase.instance.client.auth.currentUser;
    if (authUser == null) {
      _showErrorSnackBar('Debes iniciar sesión para publicar un libro.');
      return;
    }

    setState(() {
      _publicando = true;
      _publicandoTexto = _selectedImageBytes != null
          ? 'Subiendo imagen…'
          : 'Guardando publicación…';
    });
    try {
      String? donorName;
      String? donorEmail = authUser?.email;
      String? imageUrl;

      if (_selectedImageBytes != null) {
        imageUrl = await _uploadBookImage(
          imageBytes: _selectedImageBytes!,
          userId: authUser.id,
        );
      }

      if (mounted) {
        setState(() => _publicandoTexto = 'Guardando publicación…');
      }

      try {
        final perfil = await ProfileService.instance.getMyProfile();
        donorEmail = perfil.email.isNotEmpty ? perfil.email : donorEmail;
        if (perfil.fullName.isNotEmpty && perfil.fullName != perfil.email) {
          donorName = perfil.fullName;
        }
      } catch (_) {
        // Sin perfil cargado: seguimos solo con email de Auth.
      }

      await BooksService.instance.publishBook(
        title: _titulo.text,
        author: _autor.text,
        categoryValue: _categoriaValue!,
        conditionValue: _estadoValue!,
        description: _descripcion.text,
        imageUrl: imageUrl,
        city: _ciudad.text,
        recipientTypeValue: _audiencia == 0 ? 'persona' : 'institucion',
        donorName: donorName,
        donorEmail: donorEmail,
      );

      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('¡Libro publicado correctamente!')),
      );
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(
        'No se pudo publicar: ${e.toString().replaceFirst('Exception: ', '')}',
      );
    } finally {
      if (mounted) setState(() => _publicando = false);
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 95,
      );
      if (file == null) return;

      final preparedBytes = await _prepareImageBytesForUpload(file);
      if (!mounted) return;
      setState(() {
        _selectedImage = file;
        _selectedImageBytes = preparedBytes;
      });
    } catch (_) {
      if (!mounted) return;
      _showErrorSnackBar(
        'No se pudo seleccionar la imagen. Intenta nuevamente.',
      );
    }
  }

  Future<Uint8List> _prepareImageBytesForUpload(XFile file) async {
    // Punto único para agregar compresión/redimensionado en una siguiente iteración.
    return file.readAsBytes();
  }

  Future<String> _uploadBookImage({
    required Uint8List imageBytes,
    required String userId,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return BooksService.instance.uploadBookImage(
      bytes: imageBytes,
      userId: userId,
      timestampMs: timestamp,
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  InputDecoration _inputDeco({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD0D0D0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD0D0D0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1A533E), width: 1.4),
      ),
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
                  style: TextStyle(
                    color: Color(0xFFC62828),
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 4),
          Text(
            helper,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black.withValues(alpha: 0.45),
            ),
          ),
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
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: Colors.black.withValues(alpha: 0.52),
                      ),
                    ),
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
