import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'capability_permission.dart';

/// 权限门：没权限时展示降级视图，而不是弹个 Toast 就结束。
///
/// 这是原生能力最重要的设计约束 —— **每个能力都必须想清楚
/// "用户不给权限时业务还能怎么走"**：
/// - 扫码不可用 → 退回手动输入编号
/// - 定位不可用 → 允许手工选择点位
/// - 相机不可用 → 允许从相册选图
class PermissionGate extends StatelessWidget {
  const PermissionGate({
    super.key,
    required this.permission,
    required this.child,
    required this.deniedBuilder,
  });

  final CapabilityPermission permission;
  final Widget child;

  /// 未授权时展示什么。由调用方决定降级策略。
  final WidgetBuilder deniedBuilder;

  @override
  Widget build(BuildContext context) {
    if (permission == CapabilityPermission.granted) return child;
    return deniedBuilder(context);
  }
}

/// 通用降级提示条。
class CapabilityDeniedNotice extends StatelessWidget {
  const CapabilityDeniedNotice({
    super.key,
    required this.message,
    this.actionLabel = '去设置',
    this.onAction,
  });

  final String message;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline, size: 18, color: theme.colorScheme.outline),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (onAction != null)
            TextButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}
