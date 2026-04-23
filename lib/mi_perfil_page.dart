import 'package:flutter/material.dart';

import 'app_top_bar.dart';
import 'mis_gustos_lectura_page.dart';
import 'profile_service.dart';
import 'recomendaciones_page.dart';

/// Acciones que requieren el contexto del [AppShell] (pestañas, login, etc.).
class MiPerfilActions {
  const MiPerfilActions({
    required this.cerrarSesion,
    required this.irImpactoCompleto,
    required this.publicarLibro,
    required this.explorarCatalogo,
    required this.misFavoritos,
    required this.verImpacto,
  });

  final VoidCallback cerrarSesion;
  final VoidCallback irImpactoCompleto;
  final VoidCallback publicarLibro;
  final VoidCallback explorarCatalogo;
  final VoidCallback misFavoritos;
  final VoidCallback verImpacto;
}

/// Perfil del usuario (avatar en la barra superior).
class MiPerfilPage extends StatefulWidget {
  const MiPerfilPage({super.key, required this.actions});

  final MiPerfilActions actions;

  static const Color _brand = AppTopBar.brandGreen;
  static const Color _bg = Color(0xFFF5F0E8);

  @override
  State<MiPerfilPage> createState() => _MiPerfilPageState();

  static Widget _whiteCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _MiPerfilPageState extends State<MiPerfilPage> {
  final _cityCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _loadingProfile = true;
  bool _saving = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _cityCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loadingProfile = true;
      _loadError = null;
    });
    try {
      final p = await ProfileService.instance.getMyProfile();
      if (!mounted) return;
      _cityCtrl.text = p.city ?? '';
      _phoneCtrl.text = p.phone ?? '';
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  Future<void> _saveCityPhone() async {
    setState(() => _saving = true);
    try {
      await ProfileService.instance.updateMyProfile(
        city: _cityCtrl.text,
        phone: _phoneCtrl.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ciudad y teléfono guardados en tu perfil.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo guardar: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MiPerfilPage._bg,
      appBar: AppBar(
        backgroundColor: MiPerfilPage._bg,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: const SizedBox.shrink(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Mi perfil',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: MiPerfilPage._brand,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Resumen de tu actividad en LibroSolidario',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black.withValues(alpha: 0.52),
                  ),
                ),
                const SizedBox(height: 24),
                MiPerfilPage._whiteCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.menu_book_outlined,
                            color: MiPerfilPage._brand,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Mis gustos de lectura',
                              style: TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: MiPerfilPage._brand,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.of(context).push<void>(
                                MaterialPageRoute<void>(
                                  builder: (_) => const MisGustosLecturaPage(),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: MiPerfilPage._brand.withValues(alpha: 0.9),
                            ),
                            label: Text(
                              'Ver y modificar',
                              style: TextStyle(
                                color: MiPerfilPage._brand.withValues(
                                  alpha: 0.95,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _chipGusto(
                            icon: Icons.nightlight_round,
                            label: 'Terror',
                            bg: const Color(0xFFF3E8FF),
                          ),
                          _chipGusto(
                            icon: Icons.rocket_launch_outlined,
                            label: 'Ficción',
                            bg: const Color(0xFFE3F2FD),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '«Me gustan las novelas de terror y ficcion»',
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.black.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Material(
                  color: const Color(0xFFE8F5EC),
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => const RecomendacionesPage(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4EDDA),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.auto_awesome,
                              color: MiPerfilPage._brand,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Recomendaciones con IA',
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Descubre libros disponibles que coinciden con tus gustos',
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.35,
                                    color: Colors.black.withValues(alpha: 0.52),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.black.withValues(alpha: 0.35),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                MiPerfilPage._whiteCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: const Color(0xFFDFF5E8),
                            child: const Text(
                              'A',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: MiPerfilPage._brand,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Albertino Villar',
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: MiPerfilPage._brand,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.email_outlined,
                                      size: 18,
                                      color: Colors.black.withValues(
                                        alpha: 0.45,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'tinovillar74@gmail.com',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black.withValues(
                                            alpha: 0.6,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_outlined,
                                      size: 16,
                                      color: Colors.black.withValues(
                                        alpha: 0.45,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Desde marzo 2026',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black.withValues(
                                          alpha: 0.6,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 16,
                                      color: Colors.green.shade700,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Activo',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.green.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                MiPerfilPage._whiteCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: MiPerfilPage._brand,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Ciudad y teléfono',
                              style: TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: MiPerfilPage._brand,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Se guardan en tu perfil de Supabase (tabla profiles).',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black.withValues(alpha: 0.48),
                        ),
                      ),
                      if (_loadError != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _loadError!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      if (_loadingProfile)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else ...[
                        TextField(
                          controller: _cityCtrl,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: 'Ciudad',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Teléfono',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _saving ? null : _saveCityPhone,
                          style: FilledButton.styleFrom(
                            backgroundColor: MiPerfilPage._brand,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Guardar ciudad y teléfono'),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                MiPerfilPage._whiteCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        color: MiPerfilPage._brand,
                        size: 28,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Tu impacto',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: MiPerfilPage._brand,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: Colors.black.withValues(alpha: 0.65),
                          ),
                          children: [
                            const TextSpan(text: 'Has contribuido a que '),
                            const TextSpan(
                              text: '2 personas',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            TextSpan(
                              text:
                                  ' accedan al conocimiento. Cada libro compartido construye una sociedad más equitativa.',
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.5,
                                color: Colors.black.withValues(alpha: 0.65),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextButton.icon(
                        onPressed: widget.actions.irImpactoCompleto,
                        icon: Icon(
                          Icons.trending_up,
                          size: 20,
                          color: MiPerfilPage._brand.withValues(alpha: 0.9),
                        ),
                        label: Text(
                          'Ver tu impacto completo',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: MiPerfilPage._brand.withValues(alpha: 0.95),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Divider(color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Center(
                  child: TextButton.icon(
                    onPressed: widget.actions.cerrarSesion,
                    icon: Icon(Icons.logout, color: Colors.grey.shade700),
                    label: Text(
                      'Cerrar sesión',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _chipGusto({
  required IconData icon,
  required String label,
  required Color bg,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF444444)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    ),
  );
}

Widget _statMini({
  required IconData icon,
  required String value,
  required String label,
  required Color color,
  Color? iconBg,
}) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE8E8E8)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: iconBg ?? const Color(0xFFE8F5E9),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black.withValues(alpha: 0.5),
          ),
        ),
      ],
    ),
  );
}

Widget _accionRapida({
  required IconData icon,
  required String titulo,
  required String subtitulo,
  required VoidCallback onTap,
  required double pad,
}) {
  return Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: EdgeInsets.all(pad),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 26, color: AppTopBar.brandGreen),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitulo,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black.withValues(alpha: 0.48),
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
