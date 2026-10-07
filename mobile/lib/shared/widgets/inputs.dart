import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'app_icons.dart';

/// Labelled text field of the design system: 48px, 1.5px #E6E2D6 border,
/// radius 10, pomme border + 4px halo when focused.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.prefix,
    this.prefixIcon,
    this.suffix,
    this.verified = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.showCounter = false,
    this.helperText,
    this.helperColor,
    this.helperIcon,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.autofocus = false,
    this.height = AppSizes.inputHeight,
    this.radius = AppRadius.input,
    this.fontSize = 15,
    this.labelSize = 14,
    this.labelGap = 6,
    this.fillColor = AppColors.surface,
    this.alwaysHighlighted = false,
    this.textCapitalization = TextCapitalization.none,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;

  /// Leading segment inside the box (e.g. the `+261` country code).
  final Widget? prefix;
  final IconData? prefixIcon;
  final Widget? suffix;

  /// Shows a green "Vérifié" marker at the end of the field.
  final bool verified;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final bool showCounter;
  final String? helperText;
  final Color? helperColor;
  final IconData? helperIcon;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool autofocus;
  final double height;
  final double radius;
  final double fontSize;
  final double labelSize;
  final double labelGap;
  final Color fillColor;

  /// Keeps the focused look (used for the field the mockups highlight).
  final bool alwaysHighlighted;
  final TextCapitalization textCapitalization;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  // Created only when the widget does not provide its own.
  FocusNode? _ownFocusNode;
  TextEditingController? _ownController;
  bool _focused = false;

  FocusNode get _focusNode => widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController(text: widget.initialValue));

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocus);
    if (widget.showCounter) _controller.addListener(_handleText);
  }

  /// This state can be reused for another field (e.g. when a field is
  /// inserted before it): follow the controller and focus node of the new
  /// widget instead of keeping the previous ones.
  @override
  void didUpdateWidget(AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownFocusNode)?.removeListener(_handleFocus);
      _focusNode.addListener(_handleFocus);
      _focused = _focusNode.hasFocus;
    }
    if (oldWidget.controller != widget.controller || oldWidget.showCounter != widget.showCounter) {
      (oldWidget.controller ?? _ownController)?.removeListener(_handleText);
      if (widget.showCounter) _controller.addListener(_handleText);
    }
  }

  void _handleFocus() => setState(() => _focused = _focusNode.hasFocus);

  void _handleText() => setState(() {});

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocus);
    _controller.removeListener(_handleText);
    _ownFocusNode?.dispose();
    _ownController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final highlighted = _focused || widget.alwaysHighlighted;
    final borderColor = hasError
        ? AppColors.dangerFg
        : (highlighted ? AppColors.pomme600 : AppColors.lineStrong);
    final multiline = widget.maxLines > 1;

    final field = TextField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      keyboardType: multiline ? TextInputType.multiline : widget.keyboardType,
      textInputAction: widget.textInputAction,
      inputFormatters: [
        if (widget.maxLength != null) LengthLimitingTextInputFormatter(widget.maxLength),
        ...?widget.inputFormatters,
      ],
      obscureText: widget.obscureText,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      minLines: widget.minLines,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      textCapitalization: widget.textCapitalization,
      cursorColor: AppColors.pomme700,
      textAlignVertical: multiline ? TextAlignVertical.top : TextAlignVertical.center,
      style: AppTypography.body(size: widget.fontSize, height: multiline ? 1.4 : null),
      decoration: InputDecoration(
        isCollapsed: true,
        border: InputBorder.none,
        hintText: widget.hint,
        hintStyle: AppTypography.body(size: widget.fontSize, color: AppColors.disabled),
      ),
    );

    final box = Container(
      height: multiline ? null : widget.height,
      padding: multiline
          ? const EdgeInsets.all(12)
          : EdgeInsets.only(left: widget.prefix != null ? 0 : 12, right: widget.suffix != null ? 4 : 12),
      decoration: BoxDecoration(
        color: widget.fillColor,
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: highlighted && !hasError ? AppShadows.focusRing : null,
      ),
      child: multiline
          ? field
          : Row(
              children: [
                if (widget.prefix != null) widget.prefix!,
                if (widget.prefixIcon != null) ...[
                  Icon(widget.prefixIcon, size: 18, color: AppColors.pomme700),
                  const SizedBox(width: 8),
                ],
                Expanded(child: field),
                if (widget.verified) ...[
                  const SizedBox(width: 8),
                  const _VerifiedMark(),
                ],
                if (widget.suffix != null) widget.suffix!,
              ],
            ),
    );

    final helper = widget.errorText ?? widget.helperText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: AppTypography.body(size: widget.labelSize, weight: FontWeight.w600)),
          SizedBox(height: widget.labelGap),
        ],
        box,
        if (helper != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              if (widget.helperIcon != null) ...[
                Icon(widget.helperIcon, size: 13, color: widget.helperColor ?? AppColors.muted),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  helper,
                  style: AppTypography.body(
                    size: 12,
                    color: hasError ? AppColors.dangerFg : (widget.helperColor ?? AppColors.muted),
                  ),
                ),
              ),
            ],
          ),
        ],
        if (widget.showCounter && widget.maxLength != null) ...[
          const SizedBox(height: 6),
          Text(
            '${_controller.text.characters.length} / ${widget.maxLength}',
            textAlign: TextAlign.right,
            style: AppTypography.body(size: 12, color: AppColors.muted),
          ),
        ],
      ],
    );
  }
}

class _VerifiedMark extends StatelessWidget {
  const _VerifiedMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(AppIcons.checkCircle, size: 14, color: AppColors.pomme700),
        const SizedBox(width: 4),
        Text('Vérifié', style: AppTypography.body(size: 12, weight: FontWeight.w700, color: AppColors.pomme700)),
      ],
    );
  }
}

/// Field-looking button that opens the search screen (Home, Categories).
class SearchBarButton extends StatelessWidget {
  const SearchBarButton({
    super.key,
    required this.placeholder,
    required this.onTap,
    this.height = 50,
    this.radius = 14,
    this.background = AppColors.surface,
    this.iconSize = 20,
    this.fontSize = 15,
  });

  final String placeholder;
  final VoidCallback onTap;
  final double height;
  final double radius;
  final Color background;
  final double iconSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: placeholder,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: AppColors.lineStrong, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Icon(AppIcons.search, size: iconSize, color: AppColors.muted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      placeholder,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body(size: fontSize, color: AppColors.muted),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Live search input (Search screen): focused look, clear button.
class SearchInput extends StatelessWidget {
  const SearchInput({
    super.key,
    required this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.hint = 'Rechercher',
    this.autofocus = true,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final String hint;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.only(left: 12, right: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.pomme600, width: 1.5),
        boxShadow: const [BoxShadow(color: Color(0x388CC63F), spreadRadius: 4)],
      ),
      child: Row(
        children: [
          const Icon(AppIcons.search, size: 19, color: AppColors.muted),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: autofocus,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              textInputAction: TextInputAction.search,
              cursorColor: AppColors.pomme700,
              style: AppTypography.body(size: 16),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: hint,
                hintStyle: AppTypography.body(size: 16, color: AppColors.disabled),
              ),
            ),
          ),
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              tooltip: 'Effacer',
              padding: EdgeInsets.zero,
              onPressed: onClear,
              icon: const Icon(AppIcons.close, size: 18, color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}

/// Select-looking button with a chevron ("Botte ⌄", category picker).
class SelectField extends StatelessWidget {
  const SelectField({
    super.key,
    required this.value,
    this.label,
    this.onTap,
    this.height = AppSizes.inputHeight,
    this.labelSize = 14,
  });

  final String value;
  final String? label;
  final VoidCallback? onTap;
  final double height;
  final double labelSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTypography.body(size: labelSize, weight: FontWeight.w600)),
          const SizedBox(height: 6),
        ],
        Material(
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
            side: const BorderSide(color: AppColors.lineStrong, width: 1.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              height: height,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body(size: 15),
                      ),
                    ),
                    const Icon(AppIcons.chevronDown, size: 18, color: AppColors.ink),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// iOS-like switch of the mockups (46×28, #74AE2C on / #D8D3C4 off).
class AppSwitch extends StatelessWidget {
  const AppSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.small = false,
    this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool small;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final width = small ? 42.0 : 46.0;
    final height = small ? 26.0 : 28.0;
    final knob = small ? 20.0 : 22.0;
    return Semantics(
      toggled: value,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: width,
          height: height,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: value ? AppColors.pomme600 : AppColors.switchOff,
            borderRadius: BorderRadius.circular(999),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: knob,
              height: knob,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Color(0x401F2318), blurRadius: 3, offset: Offset(0, 1))],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A full-width row with a label (and optional description) and a switch.
class SwitchRow extends StatelessWidget {
  const SwitchRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.titleWeight = FontWeight.w400,
    this.minHeight = 48,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final FontWeight titleWeight;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: AppTypography.body(size: 15, weight: titleWeight)),
                  if (subtitle != null)
                    Text(subtitle!, style: AppTypography.body(size: 13, color: AppColors.muted)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AppSwitch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

/// Radio dot (22px) of the design system.
class AppRadioDot extends StatelessWidget {
  const AppRadioDot({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.pomme600 : AppColors.lineDashed,
          width: selected ? 2 : 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? AppColors.pomme600 : Colors.transparent,
        ),
      ),
    );
  }
}

/// Checkbox square (22px, radius 6) of the design system.
class AppCheckboxBox extends StatelessWidget {
  const AppCheckboxBox({super.key, required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: checked ? AppColors.pomme500 : AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: checked ? null : Border.all(color: AppColors.lineDashed, width: 1.5),
      ),
      alignment: Alignment.center,
      child: checked ? const Icon(AppIcons.check, size: 15, color: AppColors.onPrimary) : null,
    );
  }
}
