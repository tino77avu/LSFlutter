import 'package:flutter/material.dart';

import 'app_destination.dart';
import 'app_top_bar.dart';
import 'auth_service.dart';
import 'explore_page.dart';
import 'impacto_page.dart';
import 'inicio_page.dart';
import 'mi_panel_page.dart';
import 'compartir_libro_page.dart';
import 'mi_perfil_page.dart';
import 'mis_favoritos_page.dart';
import 'recomendaciones_page.dart';

/// Contenedor con barra superior y cuerpo según la sección elegida.
class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialDestination = AppDestination.inicio});

  final AppDestination initialDestination;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late AppDestination _dest = widget.initialDestination;

  void _onNav(AppDestination d) => setState(() => _dest = d);

  Future<void> _logout(BuildContext context) async {
    try {
      await AuthService.instance.logout();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cerrar sesión.')),
      );
    }
  }

  void _openRecomendaciones(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const RecomendacionesPage()),
    );
  }

  void _openMiPerfil(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (pageContext) => MiPerfilPage(
          actions: MiPerfilActions(
            cerrarSesion: () {
              Navigator.of(pageContext).pop();
              _logout(context);
            },
            irImpactoCompleto: () {
              Navigator.of(pageContext).pop();
              setState(() => _dest = AppDestination.impacto);
            },
            publicarLibro: () {
              Navigator.of(pageContext).pop();
              abrirCompartirLibro(context);
            },
            explorarCatalogo: () {
              Navigator.of(pageContext).pop();
              setState(() => _dest = AppDestination.explorar);
            },
            misFavoritos: () {
              Navigator.of(pageContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Próximamente: favoritos.')),
              );
            },
            verImpacto: () {
              Navigator.of(pageContext).pop();
              setState(() => _dest = AppDestination.impacto);
            },
          ),
        ),
      ),
    );
  }

  void _openMisFavoritos(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const MisFavoritosPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = _dest == AppDestination.explorar
        ? Colors.white
        : const Color(0xFFF5F0E8);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTopBar(
              current: _dest,
              onDestinationSelected: _onNav,
              onLogout: () {
                _logout(context);
              },
              onOpenProfile: () => _openMiPerfil(context),
              onOpenRecomendaciones: () => _openRecomendaciones(context),
              onOpenFavorites: () => _openMisFavoritos(context),
            ),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    switch (_dest) {
      case AppDestination.inicio:
        return InicioPage(onIrExplorar: () => _onNav(AppDestination.explorar));
      case AppDestination.explorar:
        return const ExplorePage();
      case AppDestination.impacto:
        return const ImpactoPage();
      case AppDestination.miPanel:
        return const MiPanelPage();
    }
  }
}
