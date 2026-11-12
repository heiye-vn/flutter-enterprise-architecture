import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// 键值行。
///
/// 标签列固定宽度，保证同一张卡片里所有值左对齐 ——
/// 这点小事对"表格感"影响很大，手写很容易左右错位。
class AppInfoRow extends StatelessWidget {
  const AppInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.labelWidth = 88,
    this.trailing,
    this.onTap,
    this.valueColor,
  });

  final String label;
  final String value;
  final double labelWidth;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);

    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 13,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: theme.textTheme.bodyMedium?.copyWith(color: valueColor),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.xs),
            trailing!,
          ],
        ],
      ),
    );

    if (onTap == null) return content;
    return InkWell(onTap: onTap, child: content);
  }
}
