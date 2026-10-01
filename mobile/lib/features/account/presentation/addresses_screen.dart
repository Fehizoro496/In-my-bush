import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets.dart';
import '../data/account_models.dart';
import '../data/account_repository.dart';

/// M-Addresses — saved addresses + new address form.
class AddressesScreen extends ConsumerStatefulWidget {
  const AddressesScreen({super.key});

  @override
  ConsumerState<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends ConsumerState<AddressesScreen> {
  static const _labels = ['Domicile', 'Bureau', 'Autre'];
  String _label = 'Autre';
  final _line1 = TextEditingController();
  final _district = TextEditingController();
  final _city = TextEditingController();
  final _landmark = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _line1.dispose();
    _district.dispose();
    _city.dispose();
    _landmark.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_line1.text.trim().isEmpty || _city.text.trim().isEmpty) {
      showAppToast(context, 'Renseignez au moins l’adresse et la ville', icon: AppIcons.alert);
      return;
    }
    setState(() => _saving = true);
    await ref.read(accountRepositoryProvider).saveAddress(Address(
          id: '',
          label: _label,
          recipient: '',
          phone: '',
          line1: _line1.text.trim(),
          district: _district.text.trim(),
          city: _city.text.trim(),
          landmark: _landmark.text.trim(),
        ));
    ref.invalidate(addressesProvider);
    for (final c in [_line1, _district, _city, _landmark]) {
      c.clear();
    }
    if (mounted) {
      setState(() => _saving = false);
      showAppToast(context, 'Adresse enregistrée');
    }
  }

  Future<void> _setDefault(Address a) async {
    await ref.read(accountRepositoryProvider).setDefaultAddress(a.id);
    ref.invalidate(addressesProvider);
  }

  Future<void> _delete(Address a) async {
    await ref.read(accountRepositoryProvider).deleteAddress(a.id);
    ref.invalidate(addressesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final addresses = ref.watch(addressesProvider);
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppTopBar(title: 'Mes adresses', fallback: AppRoutes.settings),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                AsyncValueView<List<Address>>(
                  value: addresses,
                  onRetry: () => ref.invalidate(addressesProvider),
                  loading: () => const ListSkeleton(count: 2, circle: false, leadingSize: 40),
                  data: (list) => Column(
                    children: [
                      for (final a in list) ...[
                        _AddressCard(address: a, onDefault: () => _setDefault(a), onDelete: () => _delete(a)),
                        const SizedBox(height: 14),
                      ],
                    ],
                  ),
                ),
                DashedBorderBox(
                  background: AppColors.surface,
                  radius: 18,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(AppIcons.plus, size: 18, color: AppColors.pomme700),
                          const SizedBox(width: 8),
                          Text('Nouvelle adresse', style: AppTypography.body(size: 16, weight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          for (final l in _labels)
                            AppChoiceChip(label: l, height: 38, selected: _label == l, onTap: () => setState(() => _label = l)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        label: 'Utiliser ma position actuelle',
                        icon: AppIcons.pin,
                        size: AppButtonSize.medium,
                        variant: AppButtonVariant.soft,
                        foregroundColor: AppColors.infoFg,
                        expand: true,
                        onPressed: () {
                          _district.text = 'Analakely';
                          _city.text = 'Antananarivo';
                          showAppToast(context, 'Position détectée : Analakely', icon: AppIcons.pin);
                        },
                      ),
                      const SizedBox(height: 12),
                      AppTextField(label: 'Adresse', hint: 'Lot, rue', controller: _line1, height: 46, labelSize: 13, labelGap: 5),
                      const SizedBox(height: 12),
                      AppTextField(label: 'Quartier', hint: 'Ex. : Ambohijatovo', controller: _district, height: 46, labelSize: 13, labelGap: 5),
                      const SizedBox(height: 12),
                      AppTextField(label: 'Ville', hint: 'Antananarivo', controller: _city, height: 46, labelSize: 13, labelGap: 5),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Repère',
                        hint: 'Ex. : maison jaune après la pharmacie',
                        controller: _landmark,
                        height: 46,
                        labelSize: 13,
                        labelGap: 5,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Le repère aide le livreur à vous trouver (portail, commerce voisin, couleur de la maison…).',
                        style: AppTypography.body(size: 12, color: AppColors.muted, height: 17 / 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          BottomActionBar(
            child: AppButton(label: 'Enregistrer l’adresse', expand: true, loading: _saving, onPressed: _save),
          ),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address, required this.onDefault, required this.onDelete});

  final Address address;
  final VoidCallback onDefault;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final a = address;
    return AppCard(
      borderColor: a.isDefault ? AppColors.pomme500 : AppColors.line,
      borderWidth: a.isDefault ? 1.5 : 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconTile(icon: AppIcons.byKey(a.icon)),
              const SizedBox(width: 10),
              Expanded(child: Text(a.label, style: AppTypography.body(size: 16, weight: FontWeight.w700))),
              if (a.isDefault)
                const AppTag(label: 'Par défaut', background: AppColors.pommeSelected, foreground: AppColors.pomme800),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${a.recipient} · ${a.phone}\n${a.fullLine}',
            style: AppTypography.body(size: 14, color: AppColors.bodyStrong, height: 21 / 14),
          ),
          if (a.landmark.isNotEmpty)
            Text('Repère : ${a.landmark}', style: AppTypography.body(size: 14, color: AppColors.muted, height: 21 / 14)),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Modifier',
                  icon: AppIcons.edit,
                  variant: AppButtonVariant.outline,
                  height: 40,
                  radius: 10,
                  fontSize: 14,
                  expand: true,
                  onPressed: () => showAppToast(context, 'Modifiez les champs ci-dessous puis enregistrez', icon: AppIcons.edit),
                ),
              ),
              if (!a.isDefault) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: AppButton(
                    label: 'Par défaut',
                    variant: AppButtonVariant.soft,
                    height: 40,
                    radius: 10,
                    fontSize: 14,
                    expand: true,
                    onPressed: onDefault,
                  ),
                ),
              ],
              const SizedBox(width: 8),
              AppIconButton(
                icon: AppIcons.trash,
                size: 40,
                iconSize: 16,
                radius: 10,
                style: AppIconButtonStyle.outline,
                iconColor: AppColors.dangerFg,
                semanticLabel: 'Supprimer ${a.label}',
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
