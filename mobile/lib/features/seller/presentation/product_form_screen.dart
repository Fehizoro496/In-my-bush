import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets.dart';
import '../../catalog/data/models/models.dart';
import '../data/models/models.dart';
import '../seller_providers.dart';

const _units = ['Botte', 'Kg', 'Pièce', 'Pot', 'Barquette', 'Litre', 'Lot', 'Panier'];
const _categoryPaths = [
  'Fruits & légumes › Herbes & brèdes',
  'Fruits & légumes › Légumes',
  'Fruits & légumes › Fruits',
  'Miel & confitures',
  'Produits laitiers',
  'Épicerie',
  'Boissons',
  'Céréales',
  'Produits artisanaux',
  'Cosmétiques bio',
];

/// M-Add-Product — new product form (photos, info, price & stock, origin,
/// delivery options).
class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _name = TextEditingController(text: 'Brèdes mafana');
  final _description = TextEditingController();
  final _price = TextEditingController(text: '1000');
  final _stock = TextEditingController(text: '40');
  final _threshold = TextEditingController(text: '5');
  final _origin = TextEditingController(text: 'Antsirabe, Vakinankaratra');
  String _category = _categoryPaths.first;
  String _unit = _units.first;
  bool _home = true;
  bool _pickup = true;
  bool _national = false;
  bool _saving = false;
  int _photos = 2;

  static const _commissionRate = 0.10;

  @override
  void initState() {
    super.initState();
    _price.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    for (final c in [_name, _description, _price, _stock, _threshold, _origin]) {
      c.dispose();
    }
    super.dispose();
  }

  int? get _priceValue => int.tryParse(_price.text.replaceAll(RegExp(r'\D'), ''));

  int get _filledSections {
    var n = 0;
    if (_photos > 0) n++;
    if (_name.text.trim().isNotEmpty) n++;
    if (_priceValue != null) n++;
    if (_origin.text.trim().isNotEmpty) n++;
    if (_home || _pickup || _national) n++;
    return n;
  }

  Future<void> _publish() async {
    if (_name.text.trim().isEmpty || _priceValue == null) {
      showAppToast(context, 'Renseignez au moins le nom et le prix', icon: AppIcons.alert);
      return;
    }
    setState(() => _saving = true);
    await ref.read(sellerProductsProvider.notifier).save(ProductDraft(
          name: _name.text.trim(),
          categoryPath: _category,
          description: _description.text.trim(),
          price: _priceValue,
          unitLabel: _unit,
          stock: int.tryParse(_stock.text),
          lowStockThreshold: int.tryParse(_threshold.text),
          origin: _origin.text.trim(),
          homeDelivery: _home,
          pickup: _pickup,
          nationalShipping: _national,
        ));
    if (!mounted) return;
    setState(() => _saving = false);
    showAppToast(context, 'Produit envoyé en relecture (sous 24 h)');
    context.go(AppRoutes.myProducts);
  }

  Widget _checkOption(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        radius: 14,
        borderColor: value ? AppColors.pomme300 : AppColors.line,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        onTap: () => onChanged(!value),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCheckboxBox(checked: value),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.body(size: 15, weight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTypography.body(size: 13, color: AppColors.muted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final net = _priceValue == null ? null : (_priceValue! * (1 - _commissionRate)).round();
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTopBar(
            title: 'Nouveau produit',
            leading: TopBarLeading.close,
            fallback: AppRoutes.sell,
            bottomGap: 10,
            actions: [
              const Icon(AppIcons.checkCircle, size: 14, color: AppColors.muted),
              const SizedBox(width: 4),
              Text('Brouillon enregistré', style: AppTypography.body(size: 12, color: AppColors.muted)),
            ],
            bottom: ProgressBars(count: 5, filled: _filledSections),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              children: [
                SubTitle('Photos', trailing: Text('$_photos / 8', style: AppTypography.body(size: 13, color: AppColors.muted))),
                const SizedBox(height: 10),
                _PhotoGrid(count: _photos, onAdd: () => setState(() => _photos = _photos < 8 ? _photos + 1 : 8), onRemoveMain: () => setState(() => _photos = _photos > 0 ? _photos - 1 : 0)),
                const SizedBox(height: 10),
                Text(
                  'Lumière naturelle et fond clair : les photos nettes vendent 2× mieux.',
                  style: AppTypography.body(size: 12, color: AppColors.muted),
                ),
                const SizedBox(height: 26),
                const SubTitle('Informations'),
                const SizedBox(height: 14),
                AppTextField(label: 'Nom du produit', controller: _name, onChanged: (_) => setState(() {})),
                const SizedBox(height: 14),
                SelectField(
                  label: 'Catégorie',
                  value: _category,
                  onTap: () async {
                    final v = await showOptionsSheet<String>(context, title: 'Catégorie', options: _categoryPaths, labelOf: (s) => s, selected: _category);
                    if (v != null) setState(() => _category = v);
                  },
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Description',
                  hint: 'Variété, mode de culture, goût, conseils de préparation…',
                  controller: _description,
                  maxLines: 4,
                  minLines: 4,
                ),
                const SizedBox(height: 26),
                const SubTitle('Prix & stock'),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 12,
                      child: AppTextField(
                        label: 'Prix',
                        controller: _price,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        suffix: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text('Ar', style: AppTypography.body(size: 14, weight: FontWeight.w600, color: AppColors.muted)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 10,
                      child: SelectField(
                        label: 'Unité',
                        value: _unit,
                        onTap: () async {
                          final v = await showOptionsSheet<String>(context, title: 'Unité', options: _units, labelOf: (s) => s, selected: _unit);
                          if (v != null) setState(() => _unit = v);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Quantité disponible',
                        controller: _stock,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppTextField(
                        label: 'Alerte stock à',
                        controller: _threshold,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(color: AppColors.sand, borderRadius: BorderRadius.circular(10)),
                  child: Text.rich(
                    TextSpan(
                      style: AppTypography.body(size: 13, color: AppColors.body),
                      children: [
                        const TextSpan(text: 'Vous recevrez '),
                        TextSpan(
                          text: net == null ? '—' : formatAriary(net),
                          style: AppTypography.body(size: 13, weight: FontWeight.w700, color: AppColors.body),
                        ),
                        TextSpan(text: ' par ${_unit.toLowerCase()} après commission.'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                const SubTitle('Origine'),
                const SizedBox(height: 14),
                AppTextField(label: 'Lieu de production', controller: _origin, prefixIcon: AppIcons.pin),
                const SizedBox(height: 26),
                const SubTitle('Livraison'),
                const SizedBox(height: 10),
                _checkOption('Livraison à domicile', 'Antananarivo et 30 km autour · frais : 3 000 Ar', _home, (v) => setState(() => _home = v)),
                _checkOption('Retrait sur place', 'À la ferme, Antsirabe · mer. et sam. 8h–12h', _pickup, (v) => setState(() => _pickup = v)),
                _checkOption('Expédition nationale', 'Par transporteur partenaire · produits non périssables', _national, (v) => setState(() => _national = v)),
              ],
            ),
          ),
          BottomActionBar(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 10,
                      child: AppButton(
                        label: 'Aperçu',
                        variant: AppButtonVariant.outline,
                        fontSize: 15,
                        expand: true,
                        onPressed: () => context.push(AppRoutes.product('bredes-mafana')),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 14,
                      child: AppButton(label: 'Publier le produit', fontSize: 15, expand: true, loading: _saving, onPressed: _publish),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Vérifié par l’équipe In my bush avant mise en ligne (sous 24 h)',
                  textAlign: TextAlign.center,
                  style: AppTypography.body(size: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid({required this.count, required this.onAdd, required this.onRemoveMain});

  final int count;
  final VoidCallback onAdd;
  final VoidCallback onRemoveMain;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cell = (constraints.maxWidth - 16) / 3;
        final addButton = SizedBox(
          width: cell,
          height: cell,
          child: DashedBorderBox(
            background: AppColors.pomme50,
            onTap: onAdd,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(AppIcons.camera, size: 24, color: AppColors.pomme800),
                  const SizedBox(height: 6),
                  Text('Ajouter', style: AppTypography.body(size: 12, weight: FontWeight.w700, color: AppColors.pomme800)),
                ],
              ),
            ),
          ),
        );
        final uploading = Container(
          width: cell,
          height: cell,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.sand, borderRadius: BorderRadius.circular(14)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Envoi… 64 %', style: AppTypography.body(size: 11, weight: FontWeight.w700, color: AppColors.body)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: const LinearProgressIndicator(
                  value: 0.64,
                  minHeight: 4,
                  backgroundColor: AppColors.lineStrong,
                  color: AppColors.pomme500,
                ),
              ),
            ],
          ),
        );
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: cell * 2 + 8,
              height: cell * 2 + 8,
              child: count == 0
                  ? addButton
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        const ProductThumb(visual: Visual(tint: '#DDEBC9', ink: '#365A10'), size: double.infinity, radius: 14, iconSize: 56),
                        const Positioned(
                          left: 8,
                          top: 8,
                          child: AppTag(label: 'Principale', background: AppColors.ink, foreground: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                        ),
                        Positioned(
                          right: 4,
                          top: 4,
                          child: AppIconButton(
                            icon: AppIcons.close,
                            size: 36,
                            iconSize: 16,
                            style: AppIconButtonStyle.glass,
                            semanticLabel: 'Retirer la photo',
                            onPressed: onRemoveMain,
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                if (count > 1)
                  ProductThumb(visual: const Visual(tint: '#E6F3CC', ink: '#365A10'), size: cell, radius: 14, iconSize: 28)
                else
                  addButton,
                const SizedBox(height: 8),
                if (count > 1) uploading else SizedBox(width: cell, height: cell),
                const SizedBox(height: 8),
                if (count > 1) addButton,
              ],
            ),
          ],
        );
      },
    );
  }
}

/// M-Edit-Product — edit an existing product (stats, photos, stock stepper,
/// visibility, delete with confirmation sheet).
class EditProductScreen extends ConsumerStatefulWidget {
  const EditProductScreen({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends ConsumerState<EditProductScreen> {
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _description = TextEditingController();
  String _unit = 'Botte';
  int _stock = 0;
  bool _visible = true;
  bool _loaded = false;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _description.dispose();
    super.dispose();
  }

  void _fill(Product p) {
    if (_loaded) return;
    _loaded = true;
    _name.text = p.name;
    _price.text = formatThousands(p.price);
    _description.text = p.description;
    _unit = p.unitLabel.isEmpty ? 'Botte' : '${p.unitLabel[0].toUpperCase()}${p.unitLabel.substring(1)}';
    _stock = p.stock;
    _visible = p.visible;
  }

  Future<void> _save(Product p) async {
    setState(() => _saving = true);
    await ref.read(sellerProductsProvider.notifier).save(ProductDraft(
          id: p.id,
          name: _name.text.trim(),
          price: int.tryParse(_price.text.replaceAll(RegExp(r'\D'), '')),
          unitLabel: _unit,
          stock: _stock,
          description: _description.text.trim(),
          visible: _visible,
        ));
    if (!mounted) return;
    setState(() => _saving = false);
    showAppToast(context, 'Modifications enregistrées');
    popOrGo(context, AppRoutes.myProducts);
  }

  Future<void> _askDelete(Product p) async {
    await showAppSheet<void>(
      context,
      (sheetContext) => ConfirmSheet(
        title: 'Supprimer « ${p.name} » ?',
        message:
            'Le produit disparaît de la marketplace. Les commandes en cours restent à honorer. Vous pouvez plutôt le masquer temporairement.',
        confirmLabel: 'Supprimer définitivement',
        cancelLabel: 'Masquer plutôt',
        onConfirm: () async {
          Navigator.of(sheetContext).pop();
          await ref.read(sellerProductsProvider.notifier).delete(p.id);
          if (mounted) context.go(AppRoutes.myProducts);
        },
        onCancel: () {
          Navigator.of(sheetContext).pop();
          setState(() => _visible = false);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = ref.watch(sellerProductProvider(widget.productId));
    return Scaffold(
      body: product.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Column(
          children: [
            const AppTopBar(title: 'Modifier', fallback: AppRoutes.myProducts),
            Expanded(child: ErrorState(error: e)),
          ],
        ),
        data: (p) {
          _fill(p);
          final since = p.createdAt == null ? '' : ' depuis le ${p.createdAt!.day} ${FrenchDates.months[p.createdAt!.month - 1]}';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTopBar(
                title: 'Modifier',
                fallback: AppRoutes.myProducts,
                actions: [
                  AppTextLink(
                    label: 'Aperçu',
                    icon: AppIcons.eye,
                    minHeight: 40,
                    onTap: () => context.push(AppRoutes.product('bredes-mafana')),
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    Row(
                      children: [
                        ProductThumb(visual: p.visual, size: 60, radius: 14, iconSize: 26),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name, style: AppTypography.body(size: 17, weight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              StatusPill(
                                label: p.status == ProductStatus.published ? 'En ligne$since' : p.status.label,
                                tone: p.status == ProductStatus.published ? StatusTone.success : StatusTone.neutral,
                                dense: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        _Stat(value: formatThousands(1240), label: 'vues (30 j)'),
                        const SizedBox(width: 8),
                        _Stat(value: '${p.soldCount}', label: 'ventes'),
                        const SizedBox(width: 8),
                        const _Stat(value: '38', label: 'favoris'),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text('Photos', style: AppTypography.body(size: 14, weight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Stack(
                          children: [
                            _photoBox(AppColors.pomme200),
                            const Positioned(
                              left: 4,
                              top: 4,
                              child: AppTag(
                                label: '1re',
                                background: AppColors.ink,
                                foreground: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                radius: 4,
                                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        _photoBox(AppColors.pommeSelected),
                        const SizedBox(width: 8),
                        _photoBox(AppColors.pomme100),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: DashedBorderBox(
                            background: AppColors.pomme50,
                            radius: 12,
                            onTap: () => showAppToast(context, 'Choisissez une photo', icon: AppIcons.camera),
                            child: const Center(child: Icon(AppIcons.plus, size: 22, color: AppColors.pomme800)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppTextField(label: 'Nom', labelSize: 13, labelGap: 5, height: 46, controller: _name),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: AppTextField(
                                  label: 'Prix (Ar)',
                                  labelSize: 13,
                                  labelGap: 5,
                                  height: 46,
                                  controller: _price,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: SelectField(
                                  label: 'Unité',
                                  labelSize: 13,
                                  height: 46,
                                  value: _unit,
                                  onTap: () async {
                                    final v = await showOptionsSheet<String>(context, title: 'Unité', options: _units, labelOf: (s) => s, selected: _unit);
                                    if (v != null) setState(() => _unit = v);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text('Stock disponible', style: AppTypography.body(size: 13, weight: FontWeight.w600)),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              QuantityStepper(
                                value: _stock,
                                min: 0,
                                valueWidth: 48,
                                decreaseLabel: 'Moins',
                                increaseLabel: 'Plus',
                                onChanged: (v) => setState(() => _stock = v),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '${p.stockUnitLabel ?? p.unitLabel} · alerte à ${p.lowStockThreshold}',
                                  style: AppTypography.body(size: 13, color: AppColors.muted),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          AppTextField(label: 'Description', labelSize: 13, labelGap: 5, controller: _description, maxLines: 4, minLines: 4),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    SettingsGroup(
                      children: [
                        SettingsTile(
                          icon: AppIcons.pin,
                          iconColor: AppColors.pomme700,
                          title: 'Origine',
                          value: p.originRegion,
                          minHeight: 54,
                          onTap: () {},
                        ),
                        SettingsTile(
                          icon: AppIcons.truck,
                          iconColor: AppColors.pomme700,
                          title: 'Livraison',
                          value: 'Domicile · Retrait',
                          minHeight: 54,
                          onTap: () {},
                        ),
                        SettingsSwitchTile(
                          icon: AppIcons.eye,
                          iconColor: AppColors.pomme700,
                          title: 'Visible sur la marketplace',
                          value: _visible,
                          onChanged: (v) => setState(() => _visible = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    AppButton(
                      label: 'Supprimer ce produit',
                      icon: AppIcons.trash,
                      variant: AppButtonVariant.dangerOutline,
                      height: 48,
                      fontSize: 15,
                      expand: true,
                      onPressed: () => _askDelete(p),
                    ),
                  ],
                ),
              ),
              BottomActionBar(
                child: AppButton(label: 'Enregistrer les modifications', expand: true, loading: _saving, onPressed: () => _save(p)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _photoBox(Color color) => Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        radius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: AppTypography.display(size: 20, weight: FontWeight.w700)),
            Text(label, style: AppTypography.body(size: 12, color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}
