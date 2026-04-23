import 'package:flutter/material.dart';

/// Abre el chat de coordinación de una donación (desde solicitudes del panel, etc.).
void abrirChatDonacion(
  BuildContext context, {
  required String otroUsuario,
  required String tituloLibro,
}) {
  Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => ChatDonacionPage(otroUsuario: otroUsuario, tituloLibro: tituloLibro),
    ),
  );
}

/// Pantalla de mensajes con un usuario sobre un libro concreto (mock local hasta backend).
class ChatDonacionPage extends StatefulWidget {
  const ChatDonacionPage({
    super.key,
    required this.otroUsuario,
    required this.tituloLibro,
  });

  final String otroUsuario;
  final String tituloLibro;

  @override
  State<ChatDonacionPage> createState() => _ChatDonacionPageState();
}

class _ChatMensaje {
  _ChatMensaje({required this.texto, required this.esMio});
  final String texto;
  final bool esMio;
}

class _ChatDonacionPageState extends State<ChatDonacionPage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final List<_ChatMensaje> _mensajes = [];

  static const Color _brandTitle = Color(0xFF1A533E);
  static const Color _sendGreen = Color(0xFF5D8F78);

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _enviar() {
    final t = _controller.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _mensajes.add(_ChatMensaje(texto: t, esMio: true));
      _controller.clear();
    });
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F5),
      appBar: AppBar(
        elevation: 0.5,
        scrolledUnderElevation: 0.5,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2C2C2C),
        toolbarHeight: 72,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Chat con ${widget.otroUsuario}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.menu_book_outlined, size: 15, color: Colors.black.withValues(alpha: 0.45)),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    widget.tituloLibro,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _mensajes.isEmpty ? _emptyState() : _listaMensajes(context),
              ),
            ),
          ),
          _barraEntrada(),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: Color(0xFFF0F0F0),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.chat_bubble_outline, size: 38, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 22),
            const Text(
              'Inicia la conversación',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _brandTitle,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Coordina los detalles de la donación aquí',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: Colors.black.withValues(alpha: 0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _listaMensajes(BuildContext context) {
    final maxW = MediaQuery.sizeOf(context).width * 0.78;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
      itemCount: _mensajes.length,
      itemBuilder: (context, i) {
        final m = _mensajes[i];
        return Align(
          alignment: m.esMio ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: BoxConstraints(maxWidth: maxW),
            decoration: BoxDecoration(
              color: m.esMio ? const Color(0xFFE8F5E9) : const Color(0xFFF3F3F3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(m.texto, style: const TextStyle(fontSize: 15, height: 1.35)),
          ),
        );
      },
    );
  }

  Widget _barraEntrada() {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide(color: Colors.grey.shade300),
    );
    return Material(
      color: const Color(0xFFEBEBE9),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  minLines: 1,
                  maxLines: 1,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _enviar(),
                  decoration: InputDecoration(
                    hintText: 'Escribe un mensaje... (Enter para enviar)',
                    hintStyle: TextStyle(fontSize: 14, color: Colors.black.withValues(alpha: 0.38)),
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    border: border,
                    enabledBorder: border,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: _sendGreen, width: 1.2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Material(
                color: _sendGreen,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: _enviar,
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(Icons.send_rounded, color: Colors.white, size: 22),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
