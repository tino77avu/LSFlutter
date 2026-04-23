import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_destination.dart';
import 'compartir_libro_page.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    required this.current,
    required this.onDestinationSelected,
    required this.onLogout,
    required this.onOpenProfile,
    required this.onOpenRecomendaciones,
    required this.onOpenFavorites,
  });

  static const Color brandGreen = Color(0xFF1A533E);

  final AppDestination current;
  final ValueChanged<AppDestination> onDestinationSelected;
  final VoidCallback onLogout;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenRecomendaciones;
  final VoidCallback onOpenFavorites;

  /// A partir de este ancho: enlaces en fila, botón Compartir, avatar y logout visibles.
  static const double _desktopNavBreakpoint = 1040;

  static const double _minBarWidthDesktop = 1320;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final wide = screenW >= _desktopNavBreakpoint;

    return Material(
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black12,
      child: wide ? _barDesktop(context) : _barCompact(context),
    );
  }

  /// Escritorio: scroll horizontal si hace falta; `Spacer` empuja acciones a la derecha dentro del ancho mínimo.
  Widget _barDesktop(BuildContext context) {
    final barContentWidth = math.max(
      MediaQuery.sizeOf(context).width,
      _minBarWidthDesktop,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: barContentWidth,
          child: Row(
            children: [
              _brandBlock(titleFontSize: 22, logoHeight: 40),
              const SizedBox(width: 32),
              _navItem(
                icon: Icons.home_outlined,
                label: 'Inicio',
                dest: AppDestination.inicio,
              ),
              _navItem(
                icon: Icons.search,
                label: 'Explorar',
                dest: AppDestination.explorar,
              ),
              _navItem(
                icon: Icons.trending_up,
                label: 'Impacto',
                dest: AppDestination.impacto,
              ),
              _navItem(
                icon: Icons.menu_book_outlined,
                label: 'Mi panel',
                dest: AppDestination.miPanel,
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => abrirCompartirLibro(context),
                style: FilledButton.styleFrom(
                  backgroundColor: brandGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Compartir un libro'),
              ),
              const SizedBox(width: 8),
              _iconBarAcciones(
                onOpenRecomendaciones: onOpenRecomendaciones,
                compact: false,
              ),
              InkWell(
                customBorder: const CircleBorder(),
                onTap: onOpenProfile,
                child: const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFFE0E0E0),
                  child: Text(
                    'A',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Cerrar sesión',
                onPressed: onLogout,
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Móvil: una sola fila al ancho de la pantalla (sin ancho mínimo artificial). Título con ellipsis; iconos compactos.
  Widget _barCompact(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: _brandBlock(
              titleFontSize: 18,
              logoHeight: 36,
              titleEllipsis: true,
            ),
          ),
          _iconBarAcciones(
            onOpenRecomendaciones: onOpenRecomendaciones,
            compact: true,
          ),
          _menuMovil(context, compact: true),
        ],
      ),
    );
  }

  Widget _brandBlock({
    required double titleFontSize,
    required double logoHeight,
    bool titleEllipsis = false,
  }) {
    final title = Text(
      'LibroSolidario',
      overflow: titleEllipsis ? TextOverflow.ellipsis : TextOverflow.visible,
      maxLines: 1,
      style: TextStyle(
        fontFamily: 'Georgia',
        fontSize: titleFontSize,
        fontWeight: FontWeight.w600,
        color: brandGreen,
      ),
    );

    return Row(
      children: [
        Image.asset(
          'assets/images/libro_solidario.png',
          height: logoHeight,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 8),
        if (titleEllipsis) Expanded(child: title) else title,
      ],
    );
  }

  static ButtonStyle _iconButtonStyleCompact() {
    return IconButton.styleFrom(
      padding: const EdgeInsets.all(4),
      minimumSize: const Size(36, 40),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _iconBarAcciones({
    required VoidCallback onOpenRecomendaciones,
    required bool compact,
  }) {
    final style = compact ? _iconButtonStyleCompact() : null;
    final iconSize = compact ? 22.0 : 24.0;

    Widget iconBtn({
      required IconData icon,
      VoidCallback? onPressed,
      String? tooltip,
    }) {
      return IconButton(
        style: style,
        tooltip: tooltip,
        onPressed: onPressed ?? () {},
        icon: Icon(icon, size: iconSize),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        iconBtn(icon: Icons.notifications_outlined, tooltip: 'Notificaciones'),
        iconBtn(
          icon: Icons.auto_awesome_outlined,
          onPressed: onOpenRecomendaciones,
          tooltip: 'Recomendaciones IA',
        ),
        iconBtn(
          icon: Icons.favorite_border,
          tooltip: 'Favoritos',
          onPressed: onOpenFavorites,
        ),
      ],
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required AppDestination dest,
  }) {
    final active = current == dest;
    final color = active ? brandGreen : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton.icon(
        onPressed: () => onDestinationSelected(dest),
        icon: Icon(icon, size: 20, color: color),
        label: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        style: TextButton.styleFrom(foregroundColor: color),
      ),
    );
  }

  /// Móvil: menú ☰ al final (donde iba el avatar), con navegación + compartir + perfil + salir.
  Widget _menuMovil(BuildContext context, {bool compact = false}) {
    return PopupMenuButton<_MenuMovil>(
      tooltip: 'Menú',
      padding: compact
          ? const EdgeInsetsDirectional.only(start: 2, end: 2)
          : EdgeInsets.zero,
      constraints: compact
          ? const BoxConstraints(minWidth: 36, minHeight: 40)
          : null,
      icon: Icon(
        Icons.menu,
        size: compact ? 24 : 28,
        color: const Color(0xFF333333),
      ),
      position: PopupMenuPosition.under,
      offset: const Offset(0, 8),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (accion) {
        switch (accion) {
          case _MenuMovil.inicio:
            onDestinationSelected(AppDestination.inicio);
          case _MenuMovil.explorar:
            onDestinationSelected(AppDestination.explorar);
          case _MenuMovil.impacto:
            onDestinationSelected(AppDestination.impacto);
          case _MenuMovil.miPanel:
            onDestinationSelected(AppDestination.miPanel);
          case _MenuMovil.compartirLibro:
            abrirCompartirLibro(context);
          case _MenuMovil.miPerfil:
            onOpenProfile();
          case _MenuMovil.salir:
            onLogout();
        }
      },
      itemBuilder: (context) => [
        _itemMovilNav(AppDestination.inicio, 'Inicio', Icons.home_outlined),
        _itemMovilNav(AppDestination.explorar, 'Explorar', Icons.search),
        _itemMovilNav(AppDestination.impacto, 'Impacto', Icons.trending_up),
        _itemMovilNav(
          AppDestination.miPanel,
          'Mi panel',
          Icons.menu_book_outlined,
        ),
        const PopupMenuDivider(),
        PopupMenuItem<_MenuMovil>(
          value: _MenuMovil.compartirLibro,
          child: ListTile(
            dense: true,
            leading: Icon(
              Icons.add_circle_outline,
              color: brandGreen.withValues(alpha: 0.95),
            ),
            title: const Text(
              'Compartir un libro',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        PopupMenuItem<_MenuMovil>(
          value: _MenuMovil.miPerfil,
          child: const ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 14,
              backgroundColor: Color(0xFFE0E0E0),
              child: Text(
                'A',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
            title: Text(
              'Mi perfil',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<_MenuMovil>(
          value: _MenuMovil.salir,
          child: ListTile(
            dense: true,
            leading: Icon(Icons.logout, color: Colors.red.shade700),
            title: Text(
              'Salir',
              style: TextStyle(
                color: Colors.red.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  PopupMenuItem<_MenuMovil> _itemMovilNav(
    AppDestination dest,
    String titulo,
    IconData icono,
  ) {
    final activo = current == dest;
    return PopupMenuItem<_MenuMovil>(
      value: _menuMovilValueForDestination(dest),
      child: ListTile(
        dense: true,
        leading: Icon(icono, color: activo ? brandGreen : Colors.black87),
        title: Text(
          titulo,
          style: TextStyle(
            fontWeight: activo ? FontWeight.w700 : FontWeight.w500,
            color: activo ? brandGreen : Colors.black87,
          ),
        ),
        trailing: activo
            ? const Icon(Icons.check, size: 20, color: brandGreen)
            : null,
      ),
    );
  }
}

enum _MenuMovil {
  inicio,
  explorar,
  impacto,
  miPanel,
  compartirLibro,
  miPerfil,
  salir,
}

_MenuMovil _menuMovilValueForDestination(AppDestination d) {
  switch (d) {
    case AppDestination.inicio:
      return _MenuMovil.inicio;
    case AppDestination.explorar:
      return _MenuMovil.explorar;
    case AppDestination.impacto:
      return _MenuMovil.impacto;
    case AppDestination.miPanel:
      return _MenuMovil.miPanel;
  }
}
