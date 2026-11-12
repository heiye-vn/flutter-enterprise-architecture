import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// 通用错误态。
///
/// 同样要保证可滚动，否则错误态下无法触发下拉刷新重试。
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

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
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: colors.danger.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.cloud_off_outlined,
                        size: 34,
                        color: colors.danger,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    if (onRetry != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        width: 140,
                        child: OutlinedButton.icon(
                          onPressed: onRetry,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('重新加载'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
