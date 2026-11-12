import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// 姓名头像。
///
/// 没有头像图时用姓名首字 + **由姓名哈希决定的稳定底色**：
/// 同一个人在任何页面颜色都一样，列表里扫一眼就能认出，
/// 比清一色灰底更有辨识度。
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.name,
    this.size = 44,
    this.imageUrl,
  });

  final String name;
  final double size;
  final String? imageUrl;

  static const _palette = <Color>[
    Color(0xFF1677FF),
    Color(0xFF7C4DFF),
    Color(0xFF00A870),
    Color(0xFFE37318),
    Color(0xFFD4380D),
    Color(0xFF0FA5C4),
  ];

  Color get _color {
    if (name.isEmpty) return _palette.first;
    final hash = name.codeUnits.fold<int>(0, (sum, unit) => sum + unit);
    return _palette[hash % _palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    final radius = BorderRadius.circular(size * 0.32);
    final theme = Theme.of(context);

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: radius,
      ),
      child: imageUrl == null || imageUrl!.isEmpty
          ? Text(
              name.isEmpty ? '?' : name.substring(0, 1),
              style: theme.textTheme.titleMedium?.copyWith(
                color: color,
                fontSize: size * 0.4,
                height: 1,
              ),
            )
          : Image.network(
              imageUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Icon(
                Icons.person_outline,
                size: size * 0.5,
                color: color,
              ),
            ),
    );
  }
}

/// 头像一个色块也不够时，用"标题 + 副标题 + 头像"的组合。
/// 这里只提供布局骨架，内容由调用方给。
class AppAvatarHeader extends StatelessWidget {
  const AppAvatarHeader({
    super.key,
    required this.name,
    required this.title,
    this.subtitle,
    this.trailing,
    this.imageUrl,
    this.avatarSize = 48,
  });

  final String name;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final String? imageUrl;
  final double avatarSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);

    return Row(
      children: [
        AppAvatar(name: name, size: avatarSize, imageUrl: imageUrl),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.xs),
          trailing!,
        ],
      ],
    );
  }
}
