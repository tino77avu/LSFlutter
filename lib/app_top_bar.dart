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
  });

  static const Color brandGreen = Color(0xFF1A533E);

  final AppDestination current;
  final ValueChanged<AppDestination> onDestinationSelected;
  final VoidCallback onLogout;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final barContentWidth = screenW < 900 ? 900.0 : screenW;

    return Material(
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: barContentWidth,
            child: Row(
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/images/libro_solidario.png',
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'LibroSolidario',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: brandGreen,
                      ),
                    ),
                  ],
                ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Compartir un libro'),
                ),
                const SizedBox(width: 12),
                IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_outlined)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border)),
                InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onOpenProfile,
                  child: const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFFE0E0E0),
                    child: Text('A', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
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
      ),
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
}
