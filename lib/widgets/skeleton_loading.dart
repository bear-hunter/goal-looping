import 'package:flutter/material.dart';
import '../core/theme/theme.dart';

/// A shimmer effect widget for skeleton loading states
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.isLoading = true,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return widget.child;

    final baseColor = widget.baseColor ?? AppColors.surfaceLight;
    final highlightColor = widget.highlightColor ?? AppColors.surface;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                0.0,
                0.5 + (_animation.value * 0.25),
                1.0,
              ],
              transform: _SlidingGradientTransform(_animation.value),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform(this.slidePercent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

/// Pre-built skeleton shapes for common UI elements
class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    );
  }
}

/// Skeleton for a task card
class SkeletonTaskCard extends StatelessWidget {
  const SkeletonTaskCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SkeletonBox(width: 24, height: 24, borderRadius: BorderRadius.circular(6)),
                const SizedBox(width: 12),
                const Expanded(child: SkeletonBox(width: double.infinity, height: 20)),
                const SizedBox(width: 12),
                SkeletonBox(width: 60, height: 24, borderRadius: BorderRadius.circular(12)),
              ],
            ),
            const SizedBox(height: 12),
            const SkeletonBox(width: double.infinity, height: 14),
            const SizedBox(height: 8),
            const SkeletonBox(width: 200, height: 14),
            const SizedBox(height: 16),
            Row(
              children: [
                SkeletonBox(width: 80, height: 32, borderRadius: BorderRadius.circular(8)),
                const SizedBox(width: 8),
                SkeletonBox(width: 80, height: 32, borderRadius: BorderRadius.circular(8)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for a habit card
class SkeletonHabitCard extends StatelessWidget {
  const SkeletonHabitCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            SkeletonBox(width: 48, height: 48, borderRadius: BorderRadius.circular(12)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonBox(width: 150, height: 18),
                  const SizedBox(height: 8),
                  const SkeletonBox(width: 100, height: 14),
                ],
              ),
            ),
            SkeletonBox(width: 40, height: 40, borderRadius: BorderRadius.circular(20)),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for a list of items
class SkeletonList extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;

  const SkeletonList({
    super.key,
    this.itemCount = 3,
    required this.itemBuilder,
  });

  /// Factory for task list skeleton
  factory SkeletonList.tasks({int count = 3}) {
    return SkeletonList(
      itemCount: count,
      itemBuilder: (_, _) => const SkeletonTaskCard(),
    );
  }

  /// Factory for habit list skeleton
  factory SkeletonList.habits({int count = 3}) {
    return SkeletonList(
      itemCount: count,
      itemBuilder: (_, _) => const SkeletonHabitCard(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => itemBuilder(context, index),
      ),
    );
  }
}

/// Skeleton for stats/metrics display
class SkeletonStats extends StatelessWidget {
  const SkeletonStats({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatColumn(),
            _buildStatColumn(),
            _buildStatColumn(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn() {
    return Column(
      children: [
        SkeletonBox(width: 40, height: 40, borderRadius: BorderRadius.circular(20)),
        const SizedBox(height: 8),
        const SkeletonBox(width: 60, height: 16),
        const SizedBox(height: 4),
        const SkeletonBox(width: 40, height: 12),
      ],
    );
  }
}
