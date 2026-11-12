import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// 按钮语义。
enum AppButtonVariant {
  /// 主操作，一屏最多一个
  primary,

  /// 次操作（描边）
  secondary,

  /// 文字操作（取消、查看更多）
  ghost,

  /// 危险操作（删除、退出）
  danger,
}

enum AppButtonSize { medium, small }

/// 统一按钮。
///
/// 收口三件事：尺寸梯度、加载态、禁用态。
/// 业务代码不应该再出现 `FilledButton(style: ...)` 这种一次性样式。
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.loading = false,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;

  /// 加载中：按钮内容换成菊花，同时自动禁用点击。
  final bool loading;
  final IconData? icon;

  /// 是否撑满可用宽度。行内并排时传 false。
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    final isMedium = size == AppButtonSize.medium;
    final height = isMedium ? 48.0 : 36.0;
    final fontSize = isMedium ? 15.0 : 13.0;
    final enabled = onPressed != null && !loading;

    final minimumSize = Size(expand ? double.infinity : 0, height);
    final padding = EdgeInsets.symmetric(horizontal: isMedium ? 20 : 14);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    );

    final foreground = switch (variant) {
      AppButtonVariant.primary || AppButtonVariant.danger => Colors.white,
      AppButtonVariant.secondary => theme.colorScheme.onSurface,
      AppButtonVariant.ghost => colors.brand,
    };

    final child = loading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foreground),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: isMedium ? 18 : 16),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontSize: fontSize,
                    color: foreground,
                  ),
                ),
              ),
            ],
          );

    return switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: colors.brand,
          minimumSize: minimumSize,
          padding: padding,
          shape: shape,
        ),
        child: child,
      ),
      AppButtonVariant.danger => FilledButton(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: colors.danger,
          minimumSize: minimumSize,
          padding: padding,
          shape: shape,
        ),
        child: child,
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          minimumSize: minimumSize,
          padding: padding,
          shape: shape,
          side: BorderSide(color: colors.hairline, width: 0.5),
        ),
        child: child,
      ),
      AppButtonVariant.ghost => TextButton(
        onPressed: enabled ? onPressed : null,
        style: TextButton.styleFrom(
          minimumSize: minimumSize,
          padding: padding,
          shape: shape,
        ),
        child: child,
      ),
    };
  }
}
