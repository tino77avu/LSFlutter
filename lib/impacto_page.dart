import 'package:flutter/material.dart';

import 'app_top_bar.dart';
import 'books_service.dart';
import 'compartir_libro_page.dart';

/// Pantalla Impacto: impacto social, personal, donaciones, categorías e institucional.
class ImpactoPage extends StatefulWidget {
  const ImpactoPage({super.key});

  @override
  State<ImpactoPage> createState() => _ImpactoPageState();
}

class _ImpactoPageState extends State<ImpactoPage> {
  static const Color _brand = AppTopBar.brandGreen;
  bool _loading = true;
  String? _error;
  ImpactData _data = const ImpactData(
    totalPublished: 0,
    totalDonated: 0,
    totalConnections: 0,
    totalAvailable: 0,
    myDonated: 0,
    myReceived: 0,
    myImpactedLives: 0,
    myDonatedBooks: [],
    categories: [],
    institutionalTotal: 0,
    institutionalDonated: 0,
    institutionalAvailable: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadImpactData();
  }

  Future<void> _loadImpactData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await BooksService.instance.loadImpactData();
      if (!mounted) return;
      setState(() => _data = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 34,
              ),
              const SizedBox(height: 10),
              Text(
                'No se pudo cargar la sección de impacto.\n$_error',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _loadImpactData,
                style: FilledButton.styleFrom(backgroundColor: _brand),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _impactoSocial(_data),
              const SizedBox(height: 28),
              _tuImpactoPersonal(_data),
              const SizedBox(height: 28),
              _misLibrosDonados(_data),
              const SizedBox(height: 28),
              _librosPorCategoria(_data),
              const SizedBox(height: 28),
              _impactoInstitucional(context, _data),
            ],
          ),
        ),
      ),
    );
  }

  Widget _impactoSocial(ImpactData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.35),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite, size: 16, color: Color(0xFF2E7D32)),
              SizedBox(width: 8),
              Text(
                'IMPACTO SOCIAL',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'El poder de compartir',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
            height: 1.15,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Cada libro donado en LibroSolidario representa una historia. Aquí el impacto real que hemos generado juntos.',
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: Colors.black.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: 22),
        LayoutBuilder(
          builder: (context, c) {
            final narrow = c.maxWidth < 560;
            final stats = [
              _SocialStat(
                icon: Icons.menu_book_outlined,
                value: '${data.totalPublished}',
                label: 'Libros publicados',
                bgColor: const Color(0xFF1F5D44),
              ),
              _SocialStat(
                icon: Icons.card_giftcard_outlined,
                value: '${data.totalDonated}',
                label: 'Donaciones completas',
                bgColor: const Color(0xFF2E7D32),
              ),
              _SocialStat(
                icon: Icons.favorite_border,
                value: '${data.totalConnections}',
                label: 'Conexiones hechas',
                bgColor: const Color(0xFF2C6B5A),
              ),
              _SocialStat(
                icon: Icons.people_outline,
                value: '${data.totalAvailable}',
                label: 'Disponibles ahora',
                bgColor: const Color(0xFF3A7F6A),
              ),
            ];
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stats.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: narrow ? 2 : 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (context, i) => stats[i],
            );
          },
        ),
      ],
    );
  }

  Widget _tuImpactoPersonal(ImpactData data) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tu impacto personal',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Lo que has aportado a la comunidad',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFFC107),
                      width: 2,
                    ),
                    color: const Color(0xFFFFF8E1),
                  ),
                  child: const Center(
                    child: Text('🏅', style: TextStyle(fontSize: 22)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            LayoutBuilder(
              builder: (context, c) {
                final narrow = c.maxWidth < 640;
                final tiles = <_ImpactMetricTile>[
                  _ImpactMetricTile(
                    iconBackground: const Color(0xFFE8F5E9),
                    iconBorder: const Color(0xFFC8E6C9),
                    iconChild: const Text('🎁', style: TextStyle(fontSize: 26)),
                    value: '${data.myDonated}',
                    label: 'Libros donados',
                  ),
                  _ImpactMetricTile(
                    iconBackground: const Color(0xFFE8F5EC),
                    iconBorder: const Color(0xFFB2DFDB),
                    iconChild: const Text('📚', style: TextStyle(fontSize: 26)),
                    value: '${data.myReceived}',
                    label: 'Libros recibidos',
                  ),
                  _ImpactMetricTile(
                    iconBackground: const Color(0xFFFFF9E6),
                    iconBorder: const Color(0xFFFFE082),
                    iconChild: const Text('✨', style: TextStyle(fontSize: 24)),
                    value: '${data.myImpactedLives}',
                    label: 'Total de vidas tocadas',
                  ),
                  _ImpactMetricTile(
                    iconBackground: const Color(0xFFE8F5E9),
                    iconBorder: const Color(0xFFC8E6C9),
                    iconChild: const Text('💬', style: TextStyle(fontSize: 24)),
                    value: '—',
                    valueIsPlaceholder: true,
                    label: 'Impacto en palabras',
                  ),
                ];
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tiles.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: narrow ? 2 : 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.0,
                  ),
                  itemBuilder: (context, i) => tiles[i],
                );
              },
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5EC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🌱', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tu impacto sigue creciendo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Has donado ${data.myDonated} libro(s) y generado ${data.myImpactedLives} oportunidad(es) de acceso al conocimiento.',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.45,
                            color: Colors.black.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _misLibrosDonados(ImpactData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mis libros donados',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 14),
        if (data.myDonatedBooks.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Text(
              'Aún no tienes libros donados.',
              style: TextStyle(color: Colors.black.withValues(alpha: 0.55)),
            ),
          )
        else
          Column(
            children: [
              for (var i = 0; i < data.myDonatedBooks.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  elevation: 1,
                  shadowColor: Colors.black12,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFE8F0FE),
                      child: Icon(
                        Icons.menu_book_outlined,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    title: Text(
                      data.myDonatedBooks[i].title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      data.myDonatedBooks[i].author,
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.45),
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.card_giftcard,
                                size: 14,
                                color: Color(0xFF666666),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Donado',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF555555),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatMonthYear(data.myDonatedBooks[i].createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black.withValues(alpha: 0.38),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
      ],
    );
  }

  Widget _librosPorCategoria(ImpactData data) {
    final items = data.categories.map((c) {
      final style = _styleForCategory(c.category);
      return _CatItem(
        c.category,
        c.count == 1 ? '1 libro' : '${c.count} libros',
        _iconForCategory(c.category),
        bgColor: style.bgColor,
        iconColor: style.iconColor,
        borderColor: style.borderColor,
      );
    }).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Libros por categoría',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 14),
        if (items.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Text(
              'No hay categorías para mostrar.',
              style: TextStyle(color: Colors.black.withValues(alpha: 0.55)),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, c) {
              final n = c.maxWidth < 420 ? 2 : 3;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: n,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: n == 2 ? 1.15 : 1.05,
                ),
                itemBuilder: (context, i) => _CategoryCard(item: items[i]),
              );
            },
          ),
      ],
    );
  }

  Widget _impactoInstitucional(BuildContext context, ImpactData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFFE8F5EC),
              child: Icon(Icons.apartment, color: _brand, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Impacto institucional',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Libros dirigidos a colegios, bibliotecas y ONGs',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, c) {
            final narrow = c.maxWidth < 520;
            final cards = [
              _InstitutionalMetricRow(
                icon: Icons.school_outlined,
                value: '${data.institutionalTotal}',
                label: 'Libros para instituciones',
              ),
              _InstitutionalMetricRow(
                icon: Icons.check_rounded,
                value: '${data.institutionalDonated}',
                label: 'Donados a instituciones',
              ),
              _InstitutionalMetricRow(
                icon: Icons.menu_book_outlined,
                value: '${data.institutionalAvailable}',
                label: 'Disponibles ahora',
              ),
            ];
            if (narrow) {
              return Column(
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(height: 10),
                    cards[i],
                  ],
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < cards.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  Expanded(child: cards[i]),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5EC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFC8E6C9)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.apartment, color: _brand, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: Colors.black.withValues(alpha: 0.65),
                    ),
                    children: const [
                      TextSpan(
                        text:
                            'Las donaciones institucionales tienen un impacto multiplicado: un libro en una biblioteca puede llegar a ',
                      ),
                      TextSpan(
                        text: 'cientos de lectores.',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: const BoxDecoration(
            color: _brand,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
              bottom: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.menu_book_outlined,
                color: Colors.white,
                size: 40,
              ),
              const SizedBox(height: 16),
              const Text(
                'Sé parte del cambio',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Cada libro que donas puede abrir una nueva puerta de conocimiento. Únete a quienes ya están haciendo la diferencia.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: () => abrirCompartirLibro(context),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.card_giftcard_outlined, size: 20),
                label: const Text('Compartir un libro'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatMonthYear(DateTime? date) {
    if (date == null) return '--';
    const months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  IconData _iconForCategory(String category) {
    final c = category.toLowerCase().trim();
    if (c.contains('infantil')) return Icons.toys_outlined;
    if (c.contains('literatura')) return Icons.menu_book_outlined;
    if (c.contains('ciencia')) return Icons.science_outlined;
    if (c.contains('historia')) return Icons.account_balance_outlined;
    if (c.contains('arte')) return Icons.palette_outlined;
    if (c.contains('tecnologia')) return Icons.computer_outlined;
    if (c.contains('idioma')) return Icons.translate;
    return Icons.inventory_2_outlined;
  }

  _CategoryStyle _styleForCategory(String category) {
    final c = category.toLowerCase().trim();
    if (c.contains('infantil')) {
      return const _CategoryStyle(
        bgColor: Color(0xFFFFF3E0),
        iconColor: Color(0xFFEF6C00),
        borderColor: Color(0xFFFFE0B2),
      );
    }
    if (c.contains('literatura')) {
      return const _CategoryStyle(
        bgColor: Color(0xFFEDE7F6),
        iconColor: Color(0xFF5E35B1),
        borderColor: Color(0xFFD1C4E9),
      );
    }
    if (c.contains('ciencia')) {
      return const _CategoryStyle(
        bgColor: Color(0xFFE3F2FD),
        iconColor: Color(0xFF1565C0),
        borderColor: Color(0xFFBBDEFB),
      );
    }
    if (c.contains('historia')) {
      return const _CategoryStyle(
        bgColor: Color(0xFFFBE9E7),
        iconColor: Color(0xFFBF360C),
        borderColor: Color(0xFFFFCCBC),
      );
    }
    if (c.contains('arte')) {
      return const _CategoryStyle(
        bgColor: Color(0xFFFCE4EC),
        iconColor: Color(0xFFC2185B),
        borderColor: Color(0xFFF8BBD0),
      );
    }
    return const _CategoryStyle(
      bgColor: Color(0xFFE8F5E9),
      iconColor: Color(0xFF2E7D32),
      borderColor: Color(0xFFC8E6C9),
    );
  }
}

class _SocialStat extends StatelessWidget {
  const _SocialStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.bgColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 24),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Georgia',
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryStyle {
  const _CategoryStyle({
    required this.bgColor,
    required this.iconColor,
    required this.borderColor,
  });

  final Color bgColor;
  final Color iconColor;
  final Color borderColor;
}

class _CatItem {
  const _CatItem(
    this.title,
    this.subtitle,
    this.icon, {
    required this.bgColor,
    required this.iconColor,
    required this.borderColor,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final Color borderColor;
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.item});

  final _CatItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.bgColor,
      borderRadius: BorderRadius.circular(14),
      elevation: 0,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: item.borderColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Icon(item.icon, size: 26, color: item.iconColor),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.black.withValues(alpha: 0.25),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fila de métrica institucional: mismo patrón visual que [_CategoryCard] (fondo tintado, borde, fila).
class _InstitutionalMetricRow extends StatelessWidget {
  const _InstitutionalMetricRow({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  static const Color _bg = Color(0xFFE8F5E9);
  static const Color _border = Color(0xFFC8E6C9);
  static const Color _iconColor = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _bg,
      borderRadius: BorderRadius.circular(14),
      elevation: 0,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 26, color: _iconColor),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withValues(alpha: 0.45),
                        height: 1.25,
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

/// Tarjeta cuadrada para «Tu impacto personal» (grilla con aspect ratio fijo).
class _ImpactMetricTile extends StatelessWidget {
  const _ImpactMetricTile({
    required this.iconBackground,
    required this.iconBorder,
    required this.iconChild,
    required this.value,
    required this.label,
    this.valueIsPlaceholder = false,
  });

  final Color iconBackground;
  final Color iconBorder;
  final Widget iconChild;
  final String value;
  final String label;
  final bool valueIsPlaceholder;

  static const Color _border = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
              border: Border.all(color: iconBorder, width: 1.5),
            ),
            alignment: Alignment.center,
            child: iconChild,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: valueIsPlaceholder ? 22 : 26,
              fontWeight: FontWeight.w800,
              height: 1.1,
              color: valueIsPlaceholder
                  ? Colors.black.withValues(alpha: 0.35)
                  : const Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black.withValues(alpha: 0.5),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
