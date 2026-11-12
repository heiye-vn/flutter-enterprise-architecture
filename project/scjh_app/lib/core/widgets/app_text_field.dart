import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// 带外置标签的输入框。
///
/// 为什么把 label 放到输入框外面，而不用 Material 的 `labelText`：
/// 中文表单在聚焦时 label 会上浮缩小，视觉跳动明显；
/// 外置标签在整个页面里形成统一的对齐线，表单看起来更"整齐"。
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffix,
    this.onSubmitted,
    this.onChanged,
    this.validator,
    this.autofillHints,
    this.isRequired = false,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final IconData? prefixIcon;
  final Widget? suffix;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final Iterable<String>? autofillHints;
  final bool isRequired;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colors.textSecondary,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colors.danger,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          onChanged: onChanged,
          validator: validator,
          autofillHints: autofillHints,
          enabled: enabled,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, size: 18),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
