import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'app_icons.dart';

enum QuantityStepperSize {
  /// 44px buttons, 12px radius (product page, edit product).
  large,

  /// 36px buttons, 10px radius (cart lines, stock list).
  small,
}

/// − value + stepper with bordered container.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max,
    this.size = QuantityStepperSize.large,
    this.valueWidth,
    this.label,
    this.borderColor = AppColors.lineStrong,
    this.valueColor = AppColors.ink,
    this.decreaseLabel = 'Diminuer',
    this.increaseLabel = 'Augmenter',
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int? max;
  final QuantityStepperSize size;
  final double? valueWidth;

  /// Custom text for the value (e.g. `"42 bottes"`).
  final String? label;
  final Color borderColor;
  final Color valueColor;
  final String decreaseLabel;
  final String increaseLabel;

  @override
  Widget build(BuildContext context) {
    final large = size == QuantityStepperSize.large;
    final button = large ? 44.0 : 36.0;
    final iconSize = large ? 18.0 : 16.0;
    final canDecrease = value > min;
    final canIncrease = max == null || value < max!;

    Widget stepButton(IconData icon, String semantic, bool enabled, int delta) {
      return Semantics(
        button: true,
        enabled: enabled,
        label: semantic,
        child: InkWell(
          onTap: enabled ? () => onChanged(value + delta) : null,
          borderRadius: BorderRadius.circular(large ? 12 : 10),
          child: SizedBox(
            width: button,
            height: button,
            child: Icon(icon, size: iconSize, color: enabled ? AppColors.ink : AppColors.disabled),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(large ? 12 : 10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          stepButton(AppIcons.minus, decreaseLabel, canDecrease, -1),
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: valueWidth ?? (large ? 36 : 28)),
            child: Text(
              label ?? '$value',
              textAlign: TextAlign.center,
              style: AppTypography.body(
                size: large ? 16 : 14,
                weight: FontWeight.w700,
                color: valueColor,
                fontFeatures: AppTypography.tabular,
              ),
            ),
          ),
          stepButton(AppIcons.plus, increaseLabel, canIncrease, 1),
        ],
      ),
    );
  }
}
