import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets.dart';
import '../catalog_providers.dart';
import '../data/models/models.dart';

/// M-Categories.
class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
          children: [
            LargeTitleBar(
              title: 'Catégories',
              leading: context.canPop()
                  ? const Padding(padding: EdgeInsets.only(right: 4), child: AppBackButton())
                  : null,
            ),
            const SizedBox(height: 16),
            SearchBarButton(
              placeholder: 'Rechercher une catégorie ou un produit',
              onTap: () => context.push(AppRoutes.search),
            ),
            const SizedBox(height: 16),
            AsyncValueView<List<Category>>(
              value: categories,
              onRetry: () => ref.invalidate(categoriesProvider),
              loading: () => const TwoColumnGrid(children: [
                Skeleton(height: 150, radius: 20),
                Skeleton(height: 150, radius: 20),
                Skeleton(height: 150, radius: 20),
                Skeleton(height: 150, radius: 20),
              ]),
              data: (list) => _CategoryGrid(
                categories: list,
                onTap: (c) {
                  ref.read(catalogQueryProvider.notifier).selectCategory(c.slug);
                  context.go(AppRoutes.home);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.categories, required this.onTap});

  final List<Category> categories;
  final ValueChanged<Category> onTap;

  bool _isWide(int index) => index == 0 || index == categories.length - 1;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    var i = 0;
    while (i < categories.length) {
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 12));
      if (_isWide(i)) {
        rows.add(_CategoryTile(category: categories[i], onTap: onTap));
        i++;
      } else {
        final first = categories[i];
        final second = i + 1 < categories.length && !_isWide(i + 1) ? categories[i + 1] : null;
        rows.add(Row(
          children: [
            Expanded(child: _CategoryTile(category: first, onTap: onTap)),
            const SizedBox(width: 12),
            Expanded(child: second == null ? const SizedBox.shrink() : _CategoryTile(category: second, onTap: onTap)),
          ],
        ));
        i += second == null ? 1 : 2;
      }
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.onTap});

  final Category category;
  final ValueChanged<Category> onTap;

  @override
  Widget build(BuildContext context) {
    final fg = category.foreground == null ? AppColors.ink : hexColor(category.foreground!);
    final ink = category.visual.inkColor;
    final icon = AppIcons.byKey(category.visual.icon);
    return Material(
      color: category.visual.tintColor,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onTap(category),
        child: SizedBox(
          height: 150,
          child: Stack(
            children: [
              Positioned(
                right: -8,
                bottom: -8,
                child: Opacity(opacity: 0.35, child: Icon(icon, size: 84, color: ink)),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: const Color(0xBFFFFFFF), borderRadius: BorderRadius.circular(12)),
                      alignment: Alignment.center,
                      child: Icon(icon, size: 22, color: ink),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(category.name, style: AppTypography.display(size: 18, weight: FontWeight.w700, color: fg, height: 1.15)),
                        const SizedBox(height: 2),
                        Opacity(
                          opacity: 0.8,
                          child: Text('${category.productCount} produits', style: AppTypography.body(size: 12, color: fg)),
                        ),
                      ],
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
