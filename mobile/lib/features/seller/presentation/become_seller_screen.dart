import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets.dart';
import '../../auth/auth_controller.dart';
import '../data/seller_repository.dart';

/// M-Become-Seller — 3-step onboarding (Boutique · Vérification · Prête).
class BecomeSellerScreen extends ConsumerStatefulWidget {
  const BecomeSellerScreen({super.key});

  @override
  ConsumerState<BecomeSellerScreen> createState() => _BecomeSellerScreenState();
}

class _BecomeSellerScreenState extends ConsumerState<BecomeSellerScreen> {
  static const _kindOptions = ['Maraîchage', 'Fruits', 'Apiculture', 'Élevage & laitiers', 'Transformation', 'Artisanat', 'Cosmétiques'];

  int _step = 1;
  Set<String> _kinds = {'Maraîchage', 'Fruits'};
  final _name = TextEditingController(text: 'Le Jardin de Hery');
  final _location = TextEditingController(text: 'Antsirabe, Vakinankaratra');
  final _description = TextEditingController();
  final Set<String> _documents = {};
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_step == 2) {
      setState(() => _saving = true);
      final shop = await ref.read(sellerRepositoryProvider).openShop(
            name: _name.text.trim(),
            location: _location.text.trim(),
            description: _description.text.trim(),
            kinds: _kinds,
          );
      ref.read(authControllerProvider.notifier).becameSeller(_name.text.trim(), shopSlug: shop.slug);
      if (!mounted) return;
      setState(() => _saving = false);
    }
    setState(() => _step = _step < 3 ? _step + 1 : 3);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTopBar(
            title: 'Ouvrir ma boutique',
            leading: TopBarLeading.close,
            fallback: AppRoutes.profile,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            actions: [Text('Étape $_step / 3', style: AppTypography.body(size: 13, color: AppColors.muted))],
            bottom: StepProgressBar(
              labels: const ['Boutique', 'Vérification', 'Prête'],
              filledCount: _step,
              activeIndex: _step - 1,
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              children: [
                InfoBanner(
                  icon: AppIcons.user,
                  background: AppColors.pomme100,
                  iconColor: AppColors.pomme700,
                  textColor: AppColors.pommeInk,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  radius: 16,
                  padding: const EdgeInsets.all(14),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(text: 'Vous gardez '),
                        TextSpan(text: 'le même compte', style: AppTypography.body(size: 14, weight: FontWeight.w700, color: AppColors.pommeInk)),
                        const TextSpan(text: ' : vos achats, favoris et messages restent là. Un onglet « Mes ventes » s’ajoute.'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                if (_step == 1) _stepShop(),
                if (_step == 2) _stepVerification(),
                if (_step == 3) _stepReady(),
              ],
            ),
          ),
          if (_step < 3)
            BottomActionBar(
              child: Row(
                children: [
                  AppButton(
                    label: 'Retour',
                    variant: AppButtonVariant.outline,
                    fontSize: 15,
                    onPressed: _step == 1 ? () => popOrGo(context, AppRoutes.profile) : () => setState(() => _step--),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: AppButton(label: 'Continuer', expand: true, loading: _saving, onPressed: _continue)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _stepShop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SizedBox(
              width: 84,
              height: 84,
              child: DashedBorderBox(
                background: AppColors.pomme50,
                radius: 22,
                onTap: () => showAppToast(context, 'Choisissez un logo', icon: AppIcons.camera),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(AppIcons.camera, size: 22, color: AppColors.pomme800),
                      const SizedBox(height: 4),
                      Text('Logo', style: AppTypography.body(size: 11, weight: FontWeight.w700, color: AppColors.pomme800)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Une photo de vous, de votre ferme ou de votre atelier inspire confiance.',
                style: AppTypography.body(size: 13, color: AppColors.muted, height: 19 / 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Nom de la boutique',
          controller: _name,
          helperText: 'Nom disponible',
          helperColor: AppColors.pomme700,
          helperIcon: AppIcons.checkCircle,
        ),
        const SizedBox(height: 16),
        Text('Ce que vous produisez', style: AppTypography.body(size: 14, weight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final k in _kindOptions)
              AppChoiceChip(
                label: k,
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                selected: _kinds.contains(k),
                onTap: () => setState(() {
                  _kinds = Set<String>.of(_kinds);
                  if (!_kinds.remove(k)) _kinds.add(k);
                }),
              ),
          ],
        ),
        const SizedBox(height: 16),
        AppTextField(label: 'Lieu de production', controller: _location, prefixIcon: AppIcons.pin),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Présentez-vous en quelques mots',
          hint: 'Votre histoire, vos méthodes de culture, ce qui rend vos produits uniques…',
          controller: _description,
          maxLines: 4,
          minLines: 4,
        ),
      ],
    );
  }

  Widget _stepVerification() {
    Widget doc(String key, String title, String subtitle, IconData icon) {
      final added = _documents.contains(key);
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: AppCard(
          radius: 14,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(added ? AppIcons.checkCircle : icon, size: 22, color: AppColors.pomme700),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.body(size: 14, weight: FontWeight.w700)),
                    Text(added ? 'Ajouté' : subtitle, style: AppTypography.body(size: 12, color: AppColors.muted)),
                  ],
                ),
              ),
              AppButton(
                label: added ? 'Modifier' : 'Ajouter',
                variant: AppButtonVariant.outline,
                size: AppButtonSize.small,
                onPressed: () => setState(() => _documents.add(key)),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Vérification', style: AppTypography.body(size: 17, weight: FontWeight.w700)),
        const SizedBox(height: 14),
        doc('id', 'Pièce d’identité', 'CIN ou passeport · photo recto verso', AppIcons.user),
        doc('photos', 'Photos de l’exploitation', '2 à 5 photos', AppIcons.camera),
      ],
    );
  }

  Widget _stepReady() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(color: AppColors.pomme500, shape: BoxShape.circle),
            child: const Icon(AppIcons.store, size: 40, color: AppColors.onPrimary),
          ),
          const SizedBox(height: 14),
          Text('Votre boutique est prête', style: AppTypography.display(size: 24, weight: FontWeight.w700)),
          const SizedBox(height: 14),
          Text(
            'Publiez votre premier produit. Il sera relu par l’équipe In my bush sous 24 h.',
            textAlign: TextAlign.center,
            style: AppTypography.body(size: 15, color: AppColors.body, height: 22 / 15),
          ),
          const SizedBox(height: 14),
          AppButton(
            label: 'Ajouter mon premier produit',
            icon: AppIcons.plus,
            expand: true,
            onPressed: () => context.pushReplacement(AppRoutes.addProduct),
          ),
          const SizedBox(height: 8),
          AppTextLink(label: 'Voir mon espace vendeur', fontSize: 15, minHeight: 44, onTap: () => context.go(AppRoutes.sell)),
        ],
      ),
    );
  }
}
