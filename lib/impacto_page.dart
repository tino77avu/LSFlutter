import 'package:flutter/material.dart';

import 'app_top_bar.dart';
import 'compartir_libro_page.dart';

/// Pantalla Impacto: impacto social, personal, donaciones, categorías e institucional.
class ImpactoPage extends StatelessWidget {
  const ImpactoPage({super.key});

  static const Color _brand = AppTopBar.brandGreen;
  static const Color _blueInst = Color(0xFF1E5A8A);
  static const Color _blueLight = Color(0xFFE8F2FA);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _impactoSocial(),
              const SizedBox(height: 28),
              _tuImpactoPersonal(),
              const SizedBox(height: 28),
              _misLibrosDonados(),
              const SizedBox(height: 28),
              _librosPorCategoria(),
              const SizedBox(height: 28),
              _impactoInstitucional(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _impactoSocial() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.35)),
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
              _SocialStat(icon: Icons.menu_book_outlined, value: '12', label: 'Libros publicados'),
              _SocialStat(icon: Icons.card_giftcard_outlined, value: '2', label: 'Donaciones completas'),
              _SocialStat(icon: Icons.favorite_border, value: '2', label: 'Conexiones hechas'),
              _SocialStat(icon: Icons.people_outline, value: '17', label: 'Disponibles ahora'),
            ];
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              decoration: BoxDecoration(
                color: _brand,
                borderRadius: BorderRadius.circular(20),
              ),
              child: narrow
                  ? Wrap(
                      alignment: WrapAlignment.center,
                      runSpacing: 24,
                      spacing: 12,
                      children: stats
                          .map(
                            (s) => SizedBox(
                              width: (c.maxWidth - 12) / 2,
                              child: s,
                            ),
                          )
                          .toList(),
                    )
                  : Row(
                      children: [
                        for (var i = 0; i < stats.length; i++) ...[
                          if (i > 0) const SizedBox(width: 8),
                          Expanded(child: stats[i]),
                        ],
                      ],
                    ),
            );
          },
        ),
      ],
    );
  }

  Widget _tuImpactoPersonal() {
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
                        style: TextStyle(fontSize: 14, color: Colors.black.withValues(alpha: 0.5)),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFFC107), width: 2),
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
                final cards = [
                  _PersonalMiniCard(
                    bg: Colors.white,
                    border: true,
                    icon: const Text('🎁', style: TextStyle(fontSize: 28)),
                    value: '1',
                    label: 'Libros donados',
                  ),
                  _PersonalMiniCard(
                    bg: const Color(0xFFE8F5EC),
                    icon: const Text('📚', style: TextStyle(fontSize: 28)),
                    value: '1',
                    label: 'Libros recibidos',
                  ),
                  _PersonalMiniCard(
                    bg: const Color(0xFFFFF9E6),
                    icon: const Text('✨', style: TextStyle(fontSize: 26)),
                    value: '2',
                    label: 'Total de vidas tocadas',
                  ),
                  _PersonalMiniCard(
                    bg: const Color(0xFFF3EDE5),
                    icon: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('💬', style: TextStyle(fontSize: 16)),
                        Text('⭐', style: TextStyle(fontSize: 22)),
                      ],
                    ),
                    value: '',
                    label: 'Impacto en palabras',
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
                          'Donaste 1 libro y abriste una puerta',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tu contribución ayuda a que el conocimiento llegue a quienes más lo necesitan. Gracias por ser parte de esta comunidad.',
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

  Widget _misLibrosDonados() {
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
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          elevation: 1,
          shadowColor: Colors.black12,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFE8F0FE),
              child: Icon(Icons.menu_book_outlined, color: Colors.blue.shade700),
            ),
            title: const Text(
              'Ciudad y Los Perros',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            subtitle: Text(
              'Vargas Llosa',
              style: TextStyle(color: Colors.black.withValues(alpha: 0.45)),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.card_giftcard, size: 14, color: Color(0xFF666666)),
                      SizedBox(width: 4),
                      Text('Donado', style: TextStyle(fontSize: 12, color: Color(0xFF555555))),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'abr 2026',
                  style: TextStyle(fontSize: 12, color: Colors.black.withValues(alpha: 0.38)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _librosPorCategoria() {
    const items = [
      _CatItem('Infantil', '6 libros', Icons.toys_outlined),
      _CatItem('Otro', '5 libros', Icons.inventory_2_outlined),
      _CatItem('Literatura', '3 libros', Icons.menu_book_outlined),
      _CatItem('Ciencia', '2 libros', Icons.science_outlined),
      _CatItem('terror', '1 libro', Icons.inventory_2_outlined),
      _CatItem('Historia', '1 libro', Icons.account_balance_outlined),
    ];

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

  Widget _impactoInstitucional(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFFE3F2FD),
              child: Icon(Icons.apartment, color: Colors.blue.shade700, size: 24),
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
                    style: TextStyle(fontSize: 14, color: Colors.black.withValues(alpha: 0.5)),
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
              _InstStatCard(
                icon: Icons.school_outlined,
                value: '4',
                label: 'Libros para instituciones',
              ),
              _InstStatCard(
                icon: Icons.check_rounded,
                value: '0',
                label: 'Donados a instituciones',
                iconColor: Colors.white,
                iconBg: const Color(0xFF2E7D32),
              ),
              _InstStatCard(
                icon: Icons.menu_book_outlined,
                value: '4',
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
            color: _blueLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.apartment, color: Colors.blue.shade700, size: 28),
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
                          color: _blueInst,
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(20), bottom: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const Icon(Icons.menu_book_outlined, color: Colors.white, size: 40),
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
}

class _SocialStat extends StatelessWidget {
  const _SocialStat({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.85), size: 28),
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
            color: Colors.white.withValues(alpha: 0.82),
            height: 1.25,
          ),
        ),
      ],
    );
  }
}

class _PersonalMiniCard extends StatelessWidget {
  const _PersonalMiniCard({
    required this.bg,
    required this.icon,
    required this.value,
    required this.label,
    this.border = false,
  });

  final Color bg;
  final Widget icon;
  final String value;
  final String label;
  final bool border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: border ? Border.all(color: const Color(0xFFE0E0E0)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: icon),
          if (value.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
            ),
          ] else
            const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.black.withValues(alpha: 0.5), height: 1.2),
          ),
        ],
      ),
    );
  }
}

class _CatItem {
  const _CatItem(this.title, this.subtitle, this.icon);
  final String title;
  final String subtitle;
  final IconData icon;
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.item});

  final _CatItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 1,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Icon(item.icon, size: 26, color: const Color(0xFF555555)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    Text(
                      item.subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.black.withValues(alpha: 0.45)),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.black.withValues(alpha: 0.25)),
            ],
          ),
        ),
      ),
    );
  }
}

class _InstStatCard extends StatelessWidget {
  const _InstStatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor,
    this.iconBg,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color? iconColor;
  final Color? iconBg;

  @override
  Widget build(BuildContext context) {
    final ic = iconColor ?? Colors.blue.shade700;
    final bg = iconBg ?? Colors.blue.shade50;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: ic, size: 26),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.blue.shade800, height: 1.25),
          ),
        ],
      ),
    );
  }
}
