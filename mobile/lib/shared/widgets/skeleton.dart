import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Shimmering placeholder block (`.sk` in the mockups: #EFECE3 → #F8F6F0).
class Skeleton extends StatefulWidget {
  const Skeleton({super.key, this.width, this.height, this.radius = 6, this.aspectRatio});

  final double? width;
  final double? height;
  final double radius;
  final double? aspectRatio;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget box = AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_controller.value);
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-3 + 4 * t, 0),
              end: Alignment(-1 + 4 * t, 0),
              colors: const [AppColors.skeleton, AppColors.skeletonHighlight, AppColors.skeleton],
              stops: const [0, 0.5, 1],
            ),
          ),
        );
      },
    );
    if (widget.aspectRatio != null) {
      box = AspectRatio(aspectRatio: widget.aspectRatio!, child: box);
    }
    return ExcludeSemantics(child: box);
  }
}

/// Loading placeholder with the product card silhouette.
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Skeleton(aspectRatio: 1 / 0.86, radius: 0),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FractionallySizedBox(widthFactor: 0.6, child: Skeleton(height: 10)),
                SizedBox(height: 8),
                FractionallySizedBox(widthFactor: 0.9, child: Skeleton(height: 14)),
                SizedBox(height: 8),
                FractionallySizedBox(widthFactor: 0.5, child: Skeleton(height: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading placeholder for list rows (conversations, orders…).
class ListRowSkeleton extends StatelessWidget {
  const ListRowSkeleton({super.key, this.leadingSize = 48, this.circle = true});

  final double leadingSize;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Skeleton(width: leadingSize, height: leadingSize, radius: circle ? leadingSize / 2 : 12),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FractionallySizedBox(widthFactor: 0.5, child: Skeleton(height: 14)),
                SizedBox(height: 8),
                FractionallySizedBox(widthFactor: 0.85, child: Skeleton(height: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Vertical list of [ListRowSkeleton]s.
class ListSkeleton extends StatelessWidget {
  const ListSkeleton({super.key, this.count = 5, this.leadingSize = 48, this.circle = true});

  final int count;
  final double leadingSize;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < count; i++) ListRowSkeleton(leadingSize: leadingSize, circle: circle),
      ],
    );
  }
}
