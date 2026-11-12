import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/storage/prefs_repository.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../application/auth_controller.dart';

/// 登录表单。
///
/// 关键设计：**错误回流到表单内**，而不是弹一个 Toast。
/// Toast 会消失，用户回头就不知道刚才为什么失败；
/// 内联错误条能一直挂在那里，直到下次提交。
class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscure = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // 记住上次登录账号，减少重复输入。
    final last = getIt<PrefsRepository>().lastAccount;
    if (last != null && last.isNotEmpty) {
      _accountController.text = last;
    }
  }

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await ref
          .read(authControllerProvider.notifier)
          .login(
            account: _accountController.text.trim(),
            password: _passwordController.text,
          );
      // 登录成功后由路由守卫自动跳转，这里不需要 Navigator。
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _error = readableMessage(error));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _accountController,
            label: '账号',
            hint: '请输入账号',
            isRequired: true,
            prefixIcon: Icons.person_outline,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username],
            validator: (value) {
              final v = value?.trim() ?? '';
              if (v.isEmpty) return '账号不能为空';
              if (v.length < 3) return '账号至少 3 个字符';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _passwordController,
            label: '密码',
            hint: '请输入密码',
            isRequired: true,
            obscureText: _obscure,
            prefixIcon: Icons.lock_outline,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onSubmitted: (_) => _submit(),
            suffix: IconButton(
              tooltip: _obscure ? '显示密码' : '隐藏密码',
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(
                _obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
              ),
            ),
            validator: (value) {
              final v = value ?? '';
              if (v.isEmpty) return '密码不能为空';
              if (v.length < 6) return '密码至少 6 位';
              return null;
            },
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: colors.danger.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline, size: 16, color: colors.danger),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      _error!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.danger,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          AppButton(label: '登 录', onPressed: _submit, loading: _submitting),
          const SizedBox(height: AppSpacing.md),
          Text(
            '演示环境：任意账号 + 6 位以上密码',
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
