import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// 标签语义。业务语义和颜色解耦，换主题时只改 [AppColors]。
enum AppTagTone { brand, success, warning, danger, neutral }

/// 标签样式。soft 用于状态，outline 用于等级、分类这类需要弱化的信息。
enum AppTagVariant { soft, outline }

/// 业务标签。
///
/// 对标 uview 的 `u-tag` / wot 的 `wd-tag`。只做一件事：
/// 把"业务语义 → 颜色"的映射收在一处，避免每个页面自己写
/// `Container + BoxDecoration + 自定义颜色`。
class AppTag extends StatelessWidget {
  const AppTag(
    this.label, {
    super.key,
    this.tone = AppTagTone.neutral,
    this.variant = AppTagVariant.soft,
    this.icon,
    this.dense = false,
  });

  final String label;
  final AppTagTone tone;
  final AppTagVariant variant;
  final IconData? icon;

  /// 更紧凑的尺寸，用于列表右侧。
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    final color = switch (tone) {
      AppTagTone.brand => colors.brand,
      AppTagTone.success => colors.success,
      AppTagTone.warning => colors.warning,
      AppTagTone.danger => colors.danger,
      AppTagTone.neutral => colors.textSecondary,
    };
    final isSoft = variant == AppTagVariant.soft;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 6 : 8,
        vertical: dense ? 1 : 2,
      ),
      decoration: BoxDecoration(
        color: isSoft ? color.withValues(alpha: 0.10) : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: isSoft
            ? null
            : Border.all(color: color.withValues(alpha: 0.35), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
