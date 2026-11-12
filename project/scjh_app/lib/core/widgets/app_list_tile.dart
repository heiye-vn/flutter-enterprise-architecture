import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// 通用列表行。
///
/// 结构固定为 `leading + 三行文本 + trailing + chevron`，
/// 覆盖了企业应用里 80% 的列表项：客户、合同、工单、审批记录。
/// 标题接受 Widget 而不是 String，是为了能在标题行里塞标签。
class AppListTile extends StatelessWidget {
  const AppListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.meta,
    this.trailing,
    this.onTap,
    this.showChevron = true,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
  });

  final Widget? leading;
  final Widget title;
  final String? subtitle;

  /// 第三行：区域、负责人、时间这类次要信息。
  final String? meta;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: AppSpacing.sm),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DefaultTextStyle.merge(
                          style: theme.textTheme.titleSmall!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          child: title,
                        ),
                      ),
                      if (trailing != null) ...[
                        const SizedBox(width: AppSpacing.xs),
                        trailing!,
                      ],
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                  if (meta != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      meta!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showChevron) ...[
              const SizedBox(width: AppSpacing.xxs),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: colors.textTertiary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
