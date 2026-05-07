import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'books_service.dart';
import 'profile_service.dart';

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
  bool _publicando = false;
  String _publicandoTexto = 'Publicando...';
  bool _allowExitWithoutPrompt = false;
  int _step = 0;
  bool _showFieldErrors = false;

  static const Color _bg = Color(0xFFF5F4F0);
  static const Color _heading = Color(0xFF1A3D32);
  static const Color _green = Color(0xFF1F8F5F);
  static const Color _brandGreen = Color(0xFF1A533E);

  @override
  void initState() {
    super.initState();
    _cargarCatalogos();
  }

  @override
  void dispose() {
    _titulo.dispose();
    _autor.dispose();
    _ciudad.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  int get _totalSteps => 3;
  bool get _step1Valid =>
      _titulo.text.trim().isNotEmpty &&
      _autor.text.trim().isNotEmpty &&
      _categoriaValue != null;
  bool get _step2Valid =>
      _estadoValue != null && _ciudad.text.trim().isNotEmpty;
  bool get _currentStepValid => _step == 0 ? _step1Valid : (_step == 1 ? _step2Valid : true);

  String? _requiredError(bool valid) {
    if (!_showFieldErrors) return null;
    return valid ? null : 'Campo obligatorio';
  }

  Future<void> _cargarCatalogos() async {
    setState(() {
      _loadingCatalogos = true;
      _errorCatalogos = null;
    });
    try {
      final cat = await BooksService.instance.loadActiveCategories();
      final cond = await BooksService.instance.loadActiveConditions();
      if (!mounted) return;
      setState(() {
        _categorias = cat;
        _estados = cond;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorCatalogos = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loadingCatalogos = false);
    }
  }

  void _goNextStep() {
    if (!_currentStepValid) {
      setState(() => _showFieldErrors = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa los campos obligatorios de este paso.')),
      );
      return;
    }
    if (_step < _totalSteps - 1) {
      setState(() {
        _step++;
        _showFieldErrors = false;
      });
    }
  }

  void _goPrevStep() {
    if (_step == 0) return;
    setState(() {
      _step--;
      _showFieldErrors = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final canLeave = await _handleWillPop();
        if (!mounted || !canLeave) return;
        _allowExitWithoutPrompt = true;
        Navigator.of(this.context).pop();
      },
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(backgroundColor: _bg, elevation: 0),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 140),
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
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Este libro puede cambiar una vida.',
                      style: TextStyle(color: Colors.black.withValues(alpha: 0.58))),
                  const SizedBox(height: 14),
                  _stepHeader(),
                  const SizedBox(height: 14),
                  _photoCard(),
                  const SizedBox(height: 14),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    child: _card(
                      key: ValueKey<int>(_step),
                      child: _step == 0 ? _step1() : (_step == 1 ? _step2() : _step3()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 8, 16, 14),
          child: Row(
            children: [
              if (_step > 0)
                OutlinedButton(onPressed: _publicando ? null : _goPrevStep, child: const Text('Anterior')),
              if (_step > 0) const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _publicando || _loadingCatalogos || _errorCatalogos != null
                      ? null
                      : (_step < _totalSteps - 1 ? _goNextStep : _publicarLibro),
                  style: FilledButton.styleFrom(
                    backgroundColor: _brandGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: _publicando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Icon(_step < 2 ? Icons.arrow_forward : Icons.menu_book_outlined),
                  label: Text(_publicando ? _publicandoTexto : (_step < 2 ? 'Continuar' : 'Compartir libro')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepHeader() {
    return _card(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Progreso de publicación'),
              Text('Paso ${_step + 1} de $_totalSteps', style: const TextStyle(color: _green)),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: (_step + 1) / _totalSteps, color: _green),
        ],
      ),
    );
  }

  Widget _photoCard() {
    return _card(
      child: InkWell(
        onTap: _publicando ? null : _pickImageFromGallery,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('FOTO DEL LIBRO (recomendado)', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            if (_selectedImageBytes != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(_selectedImageBytes!, height: 170, width: double.infinity, fit: BoxFit.cover),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFBDBDBD), width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.image_outlined, size: 34),
                    SizedBox(height: 6),
                    Text('Sube una foto de portada'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _step1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Paso 1: título, autor y categoría', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        _labeledField(
          label: 'Título del libro',
          requiredMark: true,
          child: TextField(
            controller: _titulo,
            onChanged: (_) => setState(() {}),
            decoration: _inputDeco(
              hint: 'Ej: Cien años de soledad',
              errorText: _requiredError(_titulo.text.trim().isNotEmpty),
              showCheck: _titulo.text.trim().isNotEmpty,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _labeledField(
          label: 'Autor',
          requiredMark: true,
          child: TextField(
            controller: _autor,
            onChanged: (_) => setState(() {}),
            decoration: _inputDeco(
              hint: 'Ej: Gabriel García Márquez',
              errorText: _requiredError(_autor.text.trim().isNotEmpty),
              showCheck: _autor.text.trim().isNotEmpty,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _labeledField(label: 'Categoría', requiredMark: true, child: _buildDropdownCategoria()),
      ],
    );
  }

  Widget _step2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Paso 2: estado, ciudad y descripción', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        _labeledField(label: 'Estado del libro', requiredMark: true, child: _buildDropdownEstado()),
        const SizedBox(height: 12),
        _labeledField(
          label: 'Ciudad',
          requiredMark: true,
          child: TextField(
            controller: _ciudad,
            onChanged: (_) => setState(() {}),
            decoration: _inputDeco(
              hint: 'Ej: Ciudad de México',
              errorText: _requiredError(_ciudad.text.trim().isNotEmpty),
              showCheck: _ciudad.text.trim().isNotEmpty,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _labeledField(
          label: 'Descripción',
          requiredMark: false,
          child: TextField(
            controller: _descripcion,
            onChanged: (_) => setState(() {}),
            maxLines: 4,
            maxLength: 500,
            decoration: _inputDeco(hint: 'Opcional: agrega detalles del estado').copyWith(counterText: ''),
          ),
        ),
      ],
    );
  }

  Widget _step3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Paso 3: destinatario y foto', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Text('Elige a quién quieres ayudar con esta donación.',
            style: TextStyle(color: Colors.black.withValues(alpha: 0.55))),
        const SizedBox(height: 12),
        _audienciaCard(
          selected: _audiencia == 0,
          icon: Icons.person_outline,
          title: 'Persona',
          subtitle: 'Cualquier persona que lo necesite',
          onTap: () => setState(() => _audiencia = 0),
        ),
        const SizedBox(height: 10),
        _audienciaCard(
          selected: _audiencia == 1,
          icon: Icons.apartment_outlined,
          title: 'Institución',
          subtitle: 'Colegio, biblioteca u ONG',
          onTap: () => setState(() => _audiencia = 1),
        ),
      ],
    );
  }

  Widget _buildDropdownCategoria() {
    if (_loadingCatalogos) return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    if (_errorCatalogos != null) return Text(_errorCatalogos!, style: const TextStyle(color: Colors.redAccent));
    if (_categorias.isEmpty) return const Text('Sin categorías disponibles');
    return DropdownButtonFormField<String>(
      value: _categoriaValue,
      isExpanded: true,
      hint: const Text('Seleccionar categoría'),
      decoration: _inputDeco(errorText: _requiredError(_categoriaValue != null), showCheck: _categoriaValue != null),
      items: _categorias.map((e) => DropdownMenuItem(value: e.value, child: Text(e.label))).toList(),
      onChanged: (v) => setState(() => _categoriaValue = v),
    );
  }

  Widget _buildDropdownEstado() {
    if (_loadingCatalogos) return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    if (_errorCatalogos != null) return Text(_errorCatalogos!, style: const TextStyle(color: Colors.redAccent));
    if (_estados.isEmpty) return const Text('Sin estados disponibles');
    return DropdownButtonFormField<String>(
      value: _estadoValue,
      isExpanded: true,
      hint: const Text('¿En qué estado está?'),
      decoration: _inputDeco(errorText: _requiredError(_estadoValue != null), showCheck: _estadoValue != null),
      items: _estados.map((e) => DropdownMenuItem(value: e.value, child: Text(e.label))).toList(),
      onChanged: (v) => setState(() => _estadoValue = v),
    );
  }

  Future<void> _publicarLibro() async {
    if (_titulo.text.trim().isEmpty || _autor.text.trim().isEmpty || _categoriaValue == null || _estadoValue == null || _ciudad.text.trim().isEmpty) {
      setState(() => _showFieldErrors = true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Completa los campos obligatorios (*).')));
      return;
    }

    final authUser = Supabase.instance.client.auth.currentUser;
    if (authUser == null) {
      _showErrorSnackBar('Debes iniciar sesión para publicar un libro.');
      return;
    }

    setState(() {
      _publicando = true;
      _publicandoTexto = _selectedImageBytes != null ? 'Subiendo imagen...' : 'Guardando publicación...';
    });
    try {
      String? donorName;
      String? donorEmail = authUser.email;
      String? imageUrl;

      if (_selectedImageBytes != null) {
        imageUrl = await _uploadBookImage(imageBytes: _selectedImageBytes!, userId: authUser.id);
      }
      if (mounted) setState(() => _publicandoTexto = 'Guardando publicación...');

      try {
        final perfil = await ProfileService.instance.getMyProfile();
        donorEmail = perfil.email.isNotEmpty ? perfil.email : donorEmail;
        if (perfil.fullName.isNotEmpty && perfil.fullName != perfil.email) donorName = perfil.fullName;
      } catch (_) {}

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
      _allowExitWithoutPrompt = true;
      Navigator.of(context).pop();
      messenger.showSnackBar(const SnackBar(content: Text('¡Libro publicado correctamente!')));
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('No se pudo publicar: ${e.toString().replaceFirst('Exception: ', '')}');
    } finally {
      if (mounted) setState(() => _publicando = false);
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final file = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 95);
      if (file == null) return;
      final preparedBytes = await _prepareImageBytesForUpload(file);
      if (!mounted) return;
      setState(() {
        _selectedImage = file;
        _selectedImageBytes = preparedBytes;
      });
    } catch (_) {
      if (!mounted) return;
      _showErrorSnackBar('No se pudo seleccionar la imagen. Intenta nuevamente.');
    }
  }

  Future<Uint8List> _prepareImageBytesForUpload(XFile file) async => file.readAsBytes();

  Future<String> _uploadBookImage({required Uint8List imageBytes, required String userId}) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return BooksService.instance.uploadBookImage(bytes: imageBytes, userId: userId, timestampMs: timestamp);
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  bool get _hasDraftChanges {
    return _titulo.text.trim().isNotEmpty ||
        _autor.text.trim().isNotEmpty ||
        _ciudad.text.trim().isNotEmpty ||
        _descripcion.text.trim().isNotEmpty ||
        _categoriaValue != null ||
        _estadoValue != null ||
        _audiencia != 0 ||
        _selectedImageBytes != null;
  }

  Future<bool> _handleWillPop() async {
    if (_allowExitWithoutPrompt) return true;
    if (_publicando) {
      _showErrorSnackBar('Espera a que finalice la publicación.');
      return false;
    }
    if (!_hasDraftChanges) return true;
    return _confirmDiscardDraft();
  }

  Future<bool> _confirmDiscardDraft() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Descartar cambios?'),
        content: const Text('Tienes datos de libro sin guardar. Si sales ahora, se perderán.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Seguir editando')),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: _brandGreen),
            child: const Text('Descartar y salir'),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  Widget _card({required Widget child, Key? key}) {
    return Container(
      key: key,
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

  InputDecoration _inputDeco({String? hint, String? errorText, bool showCheck = false}) {
    return InputDecoration(
      hintText: hint,
      errorText: errorText,
      suffixIcon: showCheck ? const Icon(Icons.check_circle, color: _green, size: 20) : null,
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD0D0D0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD0D0D0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _brandGreen, width: 1.4)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.4)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  Widget _labeledField({required String label, required bool requiredMark, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            children: [
              TextSpan(text: label),
              if (requiredMark) const TextSpan(text: ' *', style: TextStyle(color: Color(0xFFC62828), fontWeight: FontWeight.w700)),
            ],
          ),
        ),
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
            children: [
              CircleAvatar(radius: 22, backgroundColor: const Color(0xFFF0F0F0), child: Icon(icon, color: const Color(0xFF555555))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: titleColor)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.black.withValues(alpha: 0.52))),
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

void abrirCompartirLibro(BuildContext context) {
  Navigator.of(context).push<void>(
    MaterialPageRoute<void>(builder: (_) => const CompartirLibroPage()),
  );
}
