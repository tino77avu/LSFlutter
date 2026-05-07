import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Abre el chat de coordinación de una donación (desde solicitudes del panel, etc.).
void abrirChatDonacion(
  BuildContext context, {
  required int requestId,
  required String otroUsuarioId,
  required String tituloLibro,
  String? otroUsuarioNombre,
}) {
  Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => ChatDonacionPage(
        requestId: requestId,
        otroUsuarioId: otroUsuarioId,
        otroUsuarioNombre: otroUsuarioNombre,
        tituloLibro: tituloLibro,
      ),
    ),
  );
}

/// Pantalla de mensajes con persistencia en `messages`.
class ChatDonacionPage extends StatefulWidget {
  const ChatDonacionPage({
    super.key,
    required this.requestId,
    required this.otroUsuarioId,
    this.otroUsuarioNombre,
    required this.tituloLibro,
  });

  final int requestId;
  final String otroUsuarioId;
  final String? otroUsuarioNombre;
  final String tituloLibro;

  @override
  State<ChatDonacionPage> createState() => _ChatDonacionPageState();
}

class _ChatMensaje {
  _ChatMensaje({
    required this.texto,
    required this.esMio,
    required this.createdAt,
  });
  final String texto;
  final bool esMio;
  final DateTime? createdAt;
}

class _ChatDonacionPageState extends State<ChatDonacionPage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  RealtimeChannel? _channel;
  List<_ChatMensaje> _mensajes = const [];
  bool _loading = true;
  bool _sending = false;
  String? _error;

  static const Color _brandTitle = Color(0xFF1A533E);
  static const Color _sendGreen = Color(0xFF5D8F78);
  SupabaseClient get _client => Supabase.instance.client;
  String? get _myUserId => _client.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    _loadMensajes();
    _setupRealtime();
  }

  @override
  void dispose() {
    if (_channel != null) {
      _client.removeChannel(_channel!);
      _channel = null;
    }
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadMensajes() async {
    final myUserId = _myUserId;
    if (myUserId == null) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Debes iniciar sesión para usar el chat.';
      });
      return;
    }

    try {
      if (mounted) {
        setState(() {
          _loading = true;
          _error = null;
        });
      }
      final rows = await _client
          .from('messages')
          .select('sender_id,content,created_at')
          .eq('request_id', widget.requestId)
          .order('created_at', ascending: true);

      final mensajes = (rows as List<dynamic>).map((row) {
        final m = Map<String, dynamic>.from(row as Map);
        return _ChatMensaje(
          texto: (m['content'] ?? '').toString().trim(),
          esMio: (m['sender_id'] ?? '').toString().trim() == myUserId,
          createdAt:
              DateTime.tryParse((m['created_at'] ?? '').toString())?.toLocal(),
        );
      }).where((m) => m.texto.isNotEmpty).toList();

      if (!mounted) return;
      setState(() {
        _mensajes = mensajes;
        _loading = false;
      });
    } on PostgrestException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _setupRealtime() {
    final channel = _client.channel('messages_request_${widget.requestId}');
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'request_id',
            value: widget.requestId.toString(),
          ),
          callback: (_) {
            _loadMensajes();
          },
        )
        .subscribe();
    _channel = channel;
  }

  Future<void> _enviar() async {
    final t = _controller.text.trim();
    final myUserId = _myUserId;
    if (t.isEmpty || _sending || myUserId == null) return;
    setState(() => _sending = true);
    try {
      await _client.from('messages').insert({
        'request_id': widget.requestId,
        'sender_id': myUserId,
        'recipient_id': widget.otroUsuarioId,
        'content': t,
      });
      if (!mounted) return;
      setState(() => _controller.clear());
    } on PostgrestException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
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
              'Chat con ${widget.otroUsuarioNombre ?? widget.otroUsuarioId}',
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
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? _errorState()
                    : _mensajes.isEmpty
                    ? _emptyState()
                    : _listaMensajes(context),
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

  Widget _errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error ?? 'No se pudo cargar el chat.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            TextButton(onPressed: _loadMensajes, child: const Text('Reintentar')),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.texto,
                  style: const TextStyle(fontSize: 15, height: 1.35),
                ),
                if (m.createdAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${m.createdAt!.hour.toString().padLeft(2, '0')}:${m.createdAt!.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ],
            ),
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
                  onTap: _sending ? null : _enviar,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: _sending
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
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
