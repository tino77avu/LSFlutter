import 'package:flutter/material.dart';

/// Panel del usuario: resumen, actividad, pestañas y listas de libros.
class MiPanelPage extends StatefulWidget {
  const MiPanelPage({super.key});

  static const Color _green = Color(0xFF2E7D32);
  static const Color _bgCard = Colors.white;

  @override
  State<MiPanelPage> createState() => _MiPanelPageState();
}

class _MiPanelPageState extends State<MiPanelPage> {
  int _tab = 0;

  static const _totalPublicados = 12;
  static const _recibidas = 1;
  static const _enviadas = 1;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Mi panel',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Gestiona tus libros y solicitudes de donación',
                style: TextStyle(fontSize: 15, color: Colors.black.withValues(alpha: 0.52)),
              ),
              const SizedBox(height: 22),
              LayoutBuilder(
                builder: (context, c) {
                  final narrow = c.maxWidth < 720;
                  final cards = [
                    _SummaryCard(
                      icon: Icons.menu_book_outlined,
                      iconBg: const Color(0xFFE8F5E9),
                      iconColor: MiPanelPage._green,
                      value: '11',
                      valueColor: MiPanelPage._green,
                      label: 'Disponibles',
                      sublabel: 'de $_totalPublicados publicados',
                    ),
                    _SummaryCard(
                      icon: Icons.schedule_outlined,
                      iconBg: const Color(0xFFF0F0F0),
                      iconColor: const Color(0xFF616161),
                      value: '0',
                      valueColor: const Color(0xFF424242),
                      label: 'Por responder',
                      sublabel: 'solicitudes recibidas',
                    ),
                    _SummaryCard(
                      icon: Icons.check_circle_outline,
                      iconBg: const Color(0xFFE8F5E9),
                      iconColor: MiPanelPage._green,
                      value: '1',
                      valueColor: MiPanelPage._green,
                      label: 'Donaciones hechas',
                      sublabel: 'solicitudes aceptadas',
                    ),
                    _SummaryCard(
                      icon: Icons.send_outlined,
                      iconBg: const Color(0xFFE8F5E9),
                      iconColor: MiPanelPage._green,
                      value: '1',
                      valueColor: MiPanelPage._green,
                      label: 'Libros obtenidos',
                      sublabel: 'de $_enviadas enviadas',
                    ),
                  ];
                  if (narrow) {
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: cards
                          .map(
                            (w) => SizedBox(
                              width: (c.maxWidth - 12) / 2,
                              child: w,
                            ),
                          )
                          .toList(),
                    );
                  }
                  return Row(
                    children: [
                      for (var i = 0; i < cards.length; i++) ...[
                        if (i > 0) const SizedBox(width: 12),
                        Expanded(child: cards[i]),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 22),
              _actividadReciente(),
              const SizedBox(height: 20),
              _segmentedTabs(),
              const SizedBox(height: 16),
              _tabContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actividadReciente() {
    return Material(
      color: MiPanelPage._bgCard,
      borderRadius: BorderRadius.circular(18),
      elevation: 1,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 12, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.show_chart, size: 22, color: Colors.black.withValues(alpha: 0.55)),
                const SizedBox(width: 8),
                const Text(
                  'Actividad reciente',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _TimelineActivity(
              dotColor: const Color(0xFFFFC107),
              icon: Icons.mail_outline,
              iconColor: const Color(0xFFF9A825),
              title: "Nueva solicitud para 'Ciudad y Los Perros'",
              subtitle: 'De: n00325473',
              time: 'hace 21 días',
              showLineBelow: true,
            ),
            _TimelineActivity(
              dotColor: MiPanelPage._green,
              icon: Icons.check_circle_outline,
              iconColor: MiPanelPage._green,
              title: 'Tu solicitud fue aceptada',
              subtitle: "'Empanaditas'",
              time: 'hace 21 días',
              showLineBelow: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _segmentedTabs() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F4F0),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegTab(
              selected: _tab == 0,
              icon: Icons.menu_book_outlined,
              label: 'Mis libros',
              count: _totalPublicados,
              onTap: () => setState(() => _tab = 0),
            ),
          ),
          Expanded(
            child: _SegTab(
              selected: _tab == 1,
              icon: Icons.inbox_outlined,
              label: 'Recibidas',
              count: _recibidas,
              onTap: () => setState(() => _tab = 1),
            ),
          ),
          Expanded(
            child: _SegTab(
              selected: _tab == 2,
              icon: Icons.send_outlined,
              label: 'Enviadas',
              count: _enviadas,
              onTap: () => setState(() => _tab = 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabContent() {
    switch (_tab) {
      case 0:
        return _misLibrosLista();
      case 1:
        return _recibidasLista();
      case 2:
        return _enviadasLista();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _misLibrosLista() {
    const libros = [
      _LibroFila(
        titulo: 'Muñeca de huesos',
        autor: 'Black, Holly',
        categoria: null,
        ubicacion: 'Surco - Lima',
      ),
      _LibroFila(
        titulo: 'Morir no es nada del otro mundo',
        autor: 'Vila Sexto, Carlos',
        categoria: 'Otro',
        ubicacion: 'Lima - Surco',
      ),
      _LibroFila(
        titulo: 'Mi primer libro de los números',
        autor: 'Carle, Eric',
        categoria: 'Infantil',
        ubicacion: 'Santiago de Surco - Lima',
      ),
      _LibroFila(
        titulo: 'Animales mágicos. La granja',
        autor: 'Medeiros, Giovana',
        categoria: 'Infantil',
        ubicacion: 'Santiago de Surco - Lima',
      ),
      _LibroFila(
        titulo: 'Creciendo con Montessori. El huerto',
        autor: 'Moncho, Klara y Teba, Alicia',
        categoria: 'Infantil',
        ubicacion: 'Santiago de Surco - Lima',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$_totalPublicados libros publicados',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const SizedBox(height: 12),
        ...libros.map((l) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _LibroCard(libro: l))),
      ],
    );
  }

  /// Solicitudes que otros usuarios te envían (diseño Recibidas).
  Widget _recibidasLista() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _RecibidaSolicitudCard(),
      ],
    );
  }

  /// Solicitudes enviadas / libros obtenidos (diseño Enviadas).
  Widget _enviadasLista() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFFE8F5E9),
              child: Icon(Icons.menu_book_rounded, color: MiPanelPage._green, size: 28),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Libros que has obtenido',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '1 libro recibido',
                    style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const _EnviadaSolicitudCard(),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.value,
    required this.valueColor,
    required this.label,
    required this.sublabel,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String value;
  final Color valueColor;
  final String label;
  final String sublabel;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MiPanelPage._bgCard,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: iconBg,
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: valueColor, height: 1),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 2),
            Text(
              sublabel,
              style: TextStyle(fontSize: 12, color: Colors.black.withValues(alpha: 0.45)),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineActivity extends StatelessWidget {
  const _TimelineActivity({
    required this.dotColor,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.showLineBelow,
  });

  final Color dotColor;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;
  final bool showLineBelow;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                ),
                if (showLineBelow)
                  Container(
                    width: 2,
                    height: 44,
                    margin: const EdgeInsets.only(top: 4),
                    color: const Color(0xFFE0E0E0),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Icon(icon, color: iconColor, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.black.withValues(alpha: 0.5))),
                const SizedBox(height: 4),
                Text(time, style: TextStyle(fontSize: 12, color: Colors.black.withValues(alpha: 0.38))),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.black.withValues(alpha: 0.25)),
        ],
      ),
    );
  }
}

/// Tarjeta de solicitud recibida (estado aceptada + mensaje + acciones).
class _RecibidaSolicitudCard extends StatelessWidget {
  const _RecibidaSolicitudCard();

  static const Color _primary = Color(0xFF008f68);
  static const Color _statusBg = Color(0xFFeffaf5);
  static const Color _statusFg = Color(0xFF2d8a64);
  static const Color _msgBg = Color(0xFFF5F0EA);
  static const Color _btnSecondary = Color(0xFFEDEAE4);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LIBRO SOLICITADO',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 0.7,
                          fontWeight: FontWeight.w700,
                          color: Colors.black.withValues(alpha: 0.45),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ciudad y Los Perros',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 18, color: Colors.black.withValues(alpha: 0.45)),
                          const SizedBox(width: 6),
                          Text(
                            'n00325473',
                            style: TextStyle(fontSize: 14, color: Colors.black.withValues(alpha: 0.5)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '28 de marzo · 22:07',
                        style: TextStyle(fontSize: 12, color: Colors.black.withValues(alpha: 0.42)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _statusFg.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.check_circle_outline, size: 17, color: _statusFg),
                      SizedBox(width: 5),
                      Text(
                        'Aceptada',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _statusFg,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: _msgBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 20, color: Colors.black.withValues(alpha: 0.4)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Dóname we',
                      style: TextStyle(fontSize: 14, height: 1.45, color: Colors.black.withValues(alpha: 0.75)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: _statusBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_box_rounded, color: _statusFg, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Solicitud aceptada · Coordina la entrega con n00325473.',
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: _statusFg,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton.icon(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    backgroundColor: _btnSecondary,
                    foregroundColor: const Color(0xFF333333),
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline, size: 20),
                  label: const Text('Abrir chat'),
                ),
                FilledButton.icon(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.check_circle_outline, size: 20),
                  label: const Text('Confirmar entrega'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta de solicitud enviada aceptada (libro obtenido).
class _EnviadaSolicitudCard extends StatelessWidget {
  const _EnviadaSolicitudCard();

  static const Color _statusBg = Color(0xFFeffaf5);
  static const Color _statusFg = Color(0xFF2d8a64);
  static const Color _orange = Color(0xFFE65100);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          'Empanaditas',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(Icons.open_in_new, size: 18, color: Colors.black.withValues(alpha: 0.45)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _statusFg.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.check_circle_outline, size: 17, color: _statusFg),
                      SizedBox(width: 5),
                      Text(
                        'Aceptada',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _statusFg,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Solicitado el 28 de marzo, 2026',
              style: TextStyle(fontSize: 13, color: Colors.black.withValues(alpha: 0.48)),
            ),
            const SizedBox(height: 10),
            Text(
              '«Hola, prestame tu libro pana»',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                height: 1.45,
                color: Colors.black.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _statusBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.celebration, color: _statusFg, size: 22),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          '¡Tu solicitud fue aceptada!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _statusFg,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Contacta al donante para coordinar la entrega del libro.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: Colors.black.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF333333),
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.chat_bubble_outline, size: 20),
                      label: const Text('Abrir chat'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: _orange,
                  side: const BorderSide(color: _orange, width: 1.2),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.star_border, size: 22, color: _orange),
                label: const Text(
                  'Calificar al donante',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegTab extends StatelessWidget {
  const _SegTab({
    required this.selected,
    required this.icon,
    required this.label,
    required this.count,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Colors.white : Colors.transparent,
      elevation: selected ? 2 : 0,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: selected ? Colors.black87 : const Color(0xFF666666)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? Colors.black87 : const Color(0xFF555555),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFE8F5E9) : const Color(0xFFDADADA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: selected ? const Color(0xFF2E7D32) : const Color(0xFF555555),
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

class _LibroFila {
  const _LibroFila({
    required this.titulo,
    required this.autor,
    required this.ubicacion,
    this.categoria,
  });

  final String titulo;
  final String autor;
  final String? categoria;
  final String ubicacion;
}

class _LibroCard extends StatelessWidget {
  const _LibroCard({required this.libro});

  final _LibroFila libro;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 1,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 52,
                height: 76,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4A6741), Color(0xFF2E4A32)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(Icons.menu_book, color: Colors.white24, size: 28),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          libro.titulo,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, height: 1.25),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF2E7D32)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.circle, size: 7, color: Color(0xFF2E7D32)),
                            SizedBox(width: 5),
                            Text(
                              'Disponible',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    libro.autor,
                    style: TextStyle(fontSize: 13, color: Colors.black.withValues(alpha: 0.5)),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (libro.categoria != null) ...[
                        Icon(Icons.label_outline, size: 15, color: Colors.black.withValues(alpha: 0.4)),
                        Text(
                          libro.categoria!,
                          style: TextStyle(fontSize: 12, color: Colors.black.withValues(alpha: 0.45)),
                        ),
                      ],
                      Icon(Icons.place_outlined, size: 15, color: Colors.black.withValues(alpha: 0.4)),
                      Text(
                        libro.ubicacion,
                        style: TextStyle(fontSize: 12, color: Colors.black.withValues(alpha: 0.45)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.visibility_outlined, size: 20)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined, size: 20)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.delete_outline, size: 20)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
