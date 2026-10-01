import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'app_icons.dart';

enum TimelineState { done, current, upcoming }

class TimelineStep {
  const TimelineStep({required this.title, this.subtitle, required this.state});

  final String title;
  final String? subtitle;
  final TimelineState state;
}

/// Vertical order tracking timeline ("Suivi").
class OrderTimeline extends StatelessWidget {
  const OrderTimeline({super.key, required this.steps, this.dotSize = 22});

  final List<TimelineStep> steps;
  final double dotSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < steps.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: dotSize,
                  child: Column(
                    children: [
                      _Dot(state: steps[i].state, size: dotSize),
                      Expanded(
                        child: Container(
                          width: 2,
                          constraints: const BoxConstraints(minHeight: 16),
                          color: i == steps.length - 1
                              ? Colors.transparent
                              : (steps[i].state == TimelineState.done &&
                                      steps[i + 1].state == TimelineState.done
                                  ? AppColors.pomme500
                                  : AppColors.lineStrong),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: i == steps.length - 1 ? 0 : 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          steps[i].title,
                          style: AppTypography.body(
                            size: 14,
                            weight: FontWeight.w700,
                            color: steps[i].state == TimelineState.upcoming &&
                                    (i == 0 || steps[i - 1].state != TimelineState.done)
                                ? AppColors.muted
                                : AppColors.ink,
                          ),
                        ),
                        if (steps[i].subtitle != null) ...[
                          const SizedBox(height: 1),
                          Text(steps[i].subtitle!, style: AppTypography.body(size: 12, color: AppColors.muted)),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.state, required this.size});

  final TimelineState state;
  final double size;

  @override
  Widget build(BuildContext context) {
    final done = state == TimelineState.done;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? AppColors.pomme500 : AppColors.surface,
        border: done
            ? null
            : Border.all(
                color: state == TimelineState.current ? AppColors.pomme600 : AppColors.switchOff,
                width: state == TimelineState.current ? 2 : 1.5,
              ),
      ),
      alignment: Alignment.center,
      child: done ? Icon(AppIcons.check, size: size * 0.58, color: AppColors.onPrimary) : null,
    );
  }
}

/// Horizontal segmented progress with labels (Panier › Livraison ›
/// Paiement › Confirmation, onboarding steps, delivery progress).
class StepProgressBar extends StatelessWidget {
  const StepProgressBar({
    super.key,
    required this.labels,
    required this.filledCount,
    this.activeIndex,
    this.partialIndex,
    this.checkCompleted = false,
    this.labelSize = 12,
    this.gap = 6,
    this.labelGap = 6,
  });

  final List<String> labels;

  /// Number of green bars from the start.
  final int filledCount;

  /// Bold ink label.
  final int? activeIndex;

  /// Light-green bar (step in progress).
  final int? partialIndex;

  /// Completed labels become green with a ✓ (checkout).
  final bool checkCompleted;
  final double labelSize;
  final double gap;
  final double labelGap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0) SizedBox(width: gap),
          Expanded(child: _segment(i)),
        ],
      ],
    );
  }

  Widget _segment(int i) {
    final filled = i < filledCount;
    final partial = i == partialIndex;
    final barColor = filled ? AppColors.pomme500 : (partial ? AppColors.pomme300 : AppColors.lineStrong);

    var label = labels[i];
    Color color = AppColors.muted;
    var weight = FontWeight.w500;
    if (i == activeIndex || partial) {
      color = AppColors.ink;
      weight = FontWeight.w700;
    } else if (filled) {
      if (checkCompleted) {
        color = AppColors.pomme700;
        weight = FontWeight.w600;
        label = '$label ✓';
      } else {
        color = AppColors.ink;
        weight = FontWeight.w700;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(height: 4, decoration: BoxDecoration(color: barColor, borderRadius: BorderRadius.circular(4))),
        SizedBox(height: labelGap),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.body(size: labelSize, weight: weight, color: color),
        ),
      ],
    );
  }
}

/// Bars only (no labels): account "Commande en cours", add-product progress.
class ProgressBars extends StatelessWidget {
  const ProgressBars({super.key, required this.count, required this.filled, this.gap = 4});

  final int count;
  final int filled;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) SizedBox(width: gap),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: i < filled ? AppColors.pomme500 : AppColors.lineStrong,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
