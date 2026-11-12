import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/env_config.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/application/auth_controller.dart';
import '../application/theme_controller.dart';

/// 设置页。
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final authState = ref.watch(authControllerProvider);
    final themeMode = ref.watch(themeControllerProvider);
    final user = authState.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        children: [
          AppCard(
            child: AppAvatarHeader(
              name: user?.name ?? '?',
              title: user?.name ?? '未登录',
              subtitle: [user?.orgName, user?.roleLabel]
                  .whereType<String>()
                  .where((e) => e.isNotEmpty)
                  .join(' · '),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSection(
            title: '外观',
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(value: ThemeMode.system, label: Text('跟随系统')),
                      ButtonSegment(value: ThemeMode.light, label: Text('浅色')),
                      ButtonSegment(value: ThemeMode.dark, label: Text('深色')),
                    ],
                    selected: {themeMode},
                    showSelectedIcon: false,
                    onSelectionChanged: (selection) {
                      ref
                          .read(themeControllerProvider.notifier)
                          .setMode(selection.first);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSection(
            title: '运行环境',
            children: [
              AppInfoRow(label: '环境', value: EnvConfig.flavor),
              AppInfoRow(
                label: '数据来源',
                value: EnvConfig.useMock ? '内存 Mock' : '远程接口',
              ),
              AppInfoRow(label: '接口地址', value: EnvConfig.baseUrl),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSection(
            title: '开发者',
            children: [
              AppListTile(
                leading: _IconBox(
                  icon: Icons.widgets_outlined,
                  color: colors.brand,
                ),
                title: const Text('组件预览'),
                subtitle: '设计系统全部组件与令牌',
                onTap: () => context.push('/dev/components'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppButton(
            label: '退出登录',
            variant: AppButtonVariant.danger,
            onPressed: () => _confirmLogout(context, ref),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'scjh_app · Flutter 3.47 / Dart 3.13',
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('退出后需要重新输入账号密码，确定继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定退出'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await ref.read(authControllerProvider.notifier).logout();
    // 路由守卫会自动把页面切回 /login。
  }
}

/// 列表项左侧的图标容器。放在这里而不是做成公共组件，
/// 是因为它只有 20 行，且只在这一种场景用得上。
class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}
