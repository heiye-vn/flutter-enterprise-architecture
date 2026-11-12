import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// 通用空态。
///
/// 注意 `SingleChildScrollView + ConstrainedBox` 这个组合：
/// RefreshIndicator 要求子节点可滚动，纯 `Center` 会导致空态下无法下拉刷新，
/// 这是列表页最常见的体验缺陷之一。
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    this.message = '暂无数据',
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  final String message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 图标做成柔光盘，比单个灰色图标更像"设计过的空态"
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.hairline, width: 0.5),
                    ),
                    child: Icon(icon, size: 34, color: colors.textTertiary),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  if (action != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    action!,
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
