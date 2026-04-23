import 'package:flutter/material.dart';

/// Muestra el formulario para calificar al donante por un libro concreto.
Future<bool?> mostrarCalificarDonante(
  BuildContext context, {
  required String tituloLibro,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => _CalificarDonanteDialog(tituloLibro: tituloLibro),
  );
}

class _CalificarDonanteDialog extends StatefulWidget {
  const _CalificarDonanteDialog({required this.tituloLibro});

  final String tituloLibro;

  @override
  State<_CalificarDonanteDialog> createState() => _CalificarDonanteDialogState();
}

class _CalificarDonanteDialogState extends State<_CalificarDonanteDialog> {
  static const Color _submitGreen = Color(0xFF8CB3A3);

  int _estrellas = 0;
  final _comentario = TextEditingController();

  @override
  void dispose() {
    _comentario.dispose();
    super.dispose();
  }

  void _enviar() {
    if (_estrellas == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Elige una puntuación con las estrellas.')),
      );
      return;
    }
    Navigator.of(context).pop(true);
  }

  Widget? _buildComentarioCounter(
    BuildContext context, {
    required int currentLength,
    required bool isFocused,
    required int? maxLength,
  }) {
    final max = maxLength ?? 300;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          '$currentLength/$max',
          style: TextStyle(fontSize: 12, color: Colors.black.withValues(alpha: 0.42)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subStyle = TextStyle(fontSize: 14, color: Colors.black.withValues(alpha: 0.48));
    final labelStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.black.withValues(alpha: 0.75),
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Califica al donante',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              Text('Por el libro: ${widget.tituloLibro}', style: subStyle),
              const SizedBox(height: 22),
              Text('Puntuación', style: labelStyle),
              const SizedBox(height: 10),
              Row(
                children: List.generate(5, (i) {
                  final n = i + 1;
                  final activa = n <= _estrellas;
                  return IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    iconSize: 36,
                    onPressed: () => setState(() => _estrellas = n),
                    icon: Icon(
                      activa ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: activa ? const Color(0xFFE6A819) : Colors.black38,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 18),
              Text('Comentario (opcional)', style: labelStyle),
              const SizedBox(height: 8),
              TextField(
                controller: _comentario,
                maxLines: 5,
                maxLength: 300,
                buildCounter: _buildComentarioCounter,
                decoration: InputDecoration(
                  hintText: 'Cuenta cómo fue la experiencia...',
                  hintStyle: TextStyle(fontSize: 14, color: Colors.black.withValues(alpha: 0.35)),
                  filled: true,
                  fillColor: const Color(0xFFFAFAFA),
                  contentPadding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _submitGreen, width: 1.2),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: _enviar,
                    style: FilledButton.styleFrom(
                      backgroundColor: _submitGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.star_rate_rounded, size: 20),
                    label: const Text('Enviar reseña', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black.withValues(alpha: 0.72),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
