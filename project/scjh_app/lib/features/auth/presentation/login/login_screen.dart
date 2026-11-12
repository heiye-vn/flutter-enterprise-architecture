import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import 'login_form.dart';

/// 登录页。
///
/// 页面本体只负责布局，表单状态和校验都在 [LoginForm] 里 ——
/// 这样 Widget 测试可以单独测表单，不用启动整个页面。
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.xxl,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 品牌标识：色块 + 柔光底，比单个图标更有分量
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: colors.brand.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: colors.brand,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: const Icon(
                          Icons.apartment_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    '企业应用骨架',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'scjh_app · Flutter 企业级架构实践',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  const LoginForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
