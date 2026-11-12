import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// 搜索条。
///
/// 对标 uview 的 `u-search`。比直接写 TextField 多做了三件事：
/// 胶囊外形、清除按钮的显隐跟随输入、可选的扫码入口。
///
/// 注意清除按钮用 `ValueListenableBuilder` 监听 controller，
/// 而不是靠父级重建 —— 否则用户输入时要等一次业务状态变更，
/// 按钮才会出现，手感会"慢半拍"。
class AppSearchBar extends StatefulWidget {
  const AppSearchBar({
    super.key,
    required this.controller,
    this.hintText = '搜索',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onScan,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;

  /// 传了才会显示扫码按钮。
  final VoidCallback? onScan;
  final bool autofocus;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: colors.hairline, width: 0.5),
      ),
      child: Row(
        children: [
          const SizedBox(width: AppSpacing.sm),
          Icon(Icons.search, size: 18, color: colors.textTertiary),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: TextField(
              controller: widget.controller,
              autofocus: widget.autofocus,
              textInputAction: TextInputAction.search,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: widget.hintText,
                filled: false,
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.textTertiary,
                ),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: widget.controller,
            builder: (context, value, child) {
              if (value.text.isEmpty) {
                return const SizedBox(width: AppSpacing.sm);
              }
              return InkResponse(
                onTap: () {
                  widget.controller.clear();
                  widget.onClear?.call();
                },
                radius: 16,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.cancel,
                    size: 16,
                    color: colors.textTertiary,
                  ),
                ),
              );
            },
          ),
          if (widget.onScan != null) ...[
            Container(width: 0.5, height: 18, color: colors.hairline),
            InkResponse(
              onTap: widget.onScan,
              radius: 18,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 6,
                ),
                child: Icon(
                  Icons.qr_code_scanner,
                  size: 20,
                  color: colors.brand,
                ),
              ),
            ),
          ] else
            const SizedBox(width: AppSpacing.sm),
        ],
      ),
    );
  }
}
