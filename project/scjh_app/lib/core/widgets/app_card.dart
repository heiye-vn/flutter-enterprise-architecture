import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// 统一卡片容器。
///
/// 为什么不用 Material 的 `Card`：默认 Card 带 elevation 阴影，
/// 在深色模式下会发灰发脏。这里统一改成 **0.5px 描边 + 无阴影**，
/// 亮暗两套主题下都干净，也更接近国内 To B 应用的观感。
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.hairline, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
