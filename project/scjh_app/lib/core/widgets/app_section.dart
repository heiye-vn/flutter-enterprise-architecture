import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';
import 'app_card.dart';

/// 分组卡片。
///
/// 标题在卡片外、内容在卡片内，子项之间自动插 0.5px 分隔线。
/// 企业应用里 90% 的详情页都是这个结构，手写会把
/// `Divider(indent: 16, endIndent: 16)` 抄得到处都是。
class AppSection extends StatelessWidget {
  const AppSection({
    super.key,
    required this.title,
    required this.children,
    this.action,
  });

  final String title;
  final List<Widget> children;

  /// 右侧操作，一般是 `AppButton(variant: ghost, size: small)`。
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxs,
            0,
            AppSpacing.xxs,
            AppSpacing.xs,
          ),
          child: Row(
            children: [
              Text(title, style: theme.textTheme.titleSmall),
              const Spacer(),
              ?action,
            ],
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 0.5,
                    indent: AppSpacing.md,
                    endIndent: AppSpacing.md,
                  ),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}
