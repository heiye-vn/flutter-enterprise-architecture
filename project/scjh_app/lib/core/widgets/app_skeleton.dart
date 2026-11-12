import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// 骨架块。
///
/// 用移动的高光带做 shimmer，比"透明度呼吸"更像真实加载态。
/// 只在首屏加载时使用 —— 已经有数据时加载下一页不要用骨架屏，
/// 那会让用户以为内容被清空了。
class AppSkeleton extends StatefulWidget {
  const AppSkeleton({
    super.key,
    this.width,
    this.height = 14,
    this.radius = 6,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
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
    final colors = AppColors.of(context);
    final base = colors.textTertiary.withValues(alpha: 0.10);
    final highlight = colors.textTertiary.withValues(alpha: 0.02);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              colors: [base, highlight, base],
              stops: const [0.1, 0.5, 0.9],
              begin: Alignment(-1.6 + 3.2 * t, 0),
              end: Alignment(-0.6 + 3.2 * t, 0),
            ),
          ),
        );
      },
    );
  }
}

/// 列表骨架屏，形状和 [AppListTile] 对齐，加载完成时不会"跳版"。
class AppSkeletonList extends StatelessWidget {
  const AppSkeletonList({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colors.hairline, width: 0.5),
          ),
          child: Row(
            children: [
              const AppSkeleton(width: 44, height: 44, radius: 14),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppSkeleton(width: 150, height: 14),
                    const SizedBox(height: AppSpacing.xs),
                    AppSkeleton(
                      width: index.isEven ? 210 : 170,
                      height: 11,
                    ),
                    const SizedBox(height: 6),
                    const AppSkeleton(width: 120, height: 11),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
