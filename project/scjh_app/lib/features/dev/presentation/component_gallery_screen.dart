import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_widgets.dart';

/// 组件预览页。
///
/// 设计系统的"活文档"：改令牌或组件后，在这里一眼就能看出
/// 亮色/暗色两套主题下有没有跑偏。新增组件先在这里加一块。
class ComponentGalleryScreen extends ConsumerStatefulWidget {
  const ComponentGalleryScreen({super.key});

  @override
  ConsumerState<ComponentGalleryScreen> createState() =>
      _ComponentGalleryScreenState();
}

class _ComponentGalleryScreenState
    extends ConsumerState<ComponentGalleryScreen> {
  final _textController = TextEditingController();
  final _searchController = TextEditingController(text: '长江存储');

  @override
  void dispose() {
    _textController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('组件预览')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.xxl,
        ),
        children: [
          _Block(
            title: '语义色 · AppColors',
            child: Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                _Swatch(label: '品牌', color: colors.brand),
                _Swatch(label: '成功', color: colors.success),
                _Swatch(label: '警告', color: colors.warning),
                _Swatch(label: '危险', color: colors.danger),
                _Swatch(label: '描边', color: colors.hairline),
                _Swatch(label: '二级文字', color: colors.textSecondary),
                _Swatch(label: '三级文字', color: colors.textTertiary),
              ],
            ),
          ),
          _Block(
            title: '按钮 · AppButton',
            child: Column(
              children: [
                AppButton(label: '主要操作', onPressed: () {}),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: '次要操作',
                  variant: AppButtonVariant.secondary,
                  icon: Icons.download_outlined,
                  onPressed: () {},
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: '危险操作',
                  variant: AppButtonVariant.danger,
                  onPressed: () {},
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: '小号',
                        size: AppButtonSize.small,
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppButton(
                        label: '加载中',
                        size: AppButtonSize.small,
                        loading: true,
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppButton(
                        label: '禁用',
                        size: AppButtonSize.small,
                        onPressed: null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Align(
                  alignment: Alignment.centerLeft,
                  child: AppButton(
                    label: '文字操作',
                    variant: AppButtonVariant.ghost,
                    size: AppButtonSize.small,
                    expand: false,
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
          _Block(
            title: '标签 · AppTag',
            child: Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                const AppTag('品牌', tone: AppTagTone.brand),
                const AppTag('成功', tone: AppTagTone.success),
                const AppTag('警告', tone: AppTagTone.warning),
                const AppTag('危险', tone: AppTagTone.danger),
                const AppTag('中性'),
                const AppTag(
                  '描边等级',
                  tone: AppTagTone.brand,
                  variant: AppTagVariant.outline,
                ),
                const AppTag(
                  '已归档',
                  tone: AppTagTone.success,
                  variant: AppTagVariant.outline,
                  icon: Icons.check_circle_outline,
                ),
              ],
            ),
          ),
          _Block(
            title: '头像 · AppAvatar',
            child: Row(
              children: [
                const AppAvatar(name: '张伟'),
                const SizedBox(width: AppSpacing.sm),
                const AppAvatar(name: '李静'),
                const SizedBox(width: AppSpacing.sm),
                const AppAvatar(name: '王强'),
                const SizedBox(width: AppSpacing.sm),
                const AppAvatar(name: 'Alex'),
                const SizedBox(width: AppSpacing.sm),
                const AppAvatar(name: '陈晨', size: 36),
              ],
            ),
          ),
          _Block(
            title: '表单 · AppTextField / AppSearchBar',
            child: Column(
              children: [
                AppTextField(
                  controller: _textController,
                  label: '客户名称',
                  hint: '请输入客户名称',
                  isRequired: true,
                  prefixIcon: Icons.person_outline,
                ),
                const SizedBox(height: AppSpacing.md),
                AppSearchBar(
                  controller: _searchController,
                  hintText: '搜索客户名称 / 编号',
                  onChanged: (_) {},
                  onScan: () {},
                ),
              ],
            ),
          ),
          _Block(
            title: '列表项 · AppListTile',
            child: Column(
              children: [
                AppCard(
                  padding: EdgeInsets.zero,
                  onTap: () {},
                  child: AppListTile(
                    leading: const AppAvatar(name: '长江存储科技'),
                    title: Row(
                      children: [
                        const Flexible(child: Text('长江存储科技')),
                        const SizedBox(width: 6),
                        const AppTag(
                          '战略客户',
                          tone: AppTagTone.brand,
                          variant: AppTagVariant.outline,
                          dense: true,
                        ),
                      ],
                    ),
                    subtitle: 'KH20261000 · 半导体',
                    meta: '湖北省武汉市 · 张伟 · 3 天前',
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                AppCard(
                  padding: EdgeInsets.zero,
                  onTap: () {},
                  child: AppListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.success.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(
                        Icons.check_circle_outline,
                        size: 20,
                        color: colors.success,
                      ),
                    ),
                    title: const Text('巡检记录已提交'),
                    subtitle: '2026-11-12 09:20',
                    showChevron: false,
                  ),
                ),
              ],
            ),
          ),
          _Block(
            title: '信息行 · AppSection / AppInfoRow',
            child: AppSection(
              title: '基本信息',
              children: const [
                AppInfoRow(label: '所属行业', value: '半导体'),
                AppInfoRow(label: '所属区域', value: '湖北省武汉市'),
                AppInfoRow(label: '客户经理', value: '张伟'),
                AppInfoRow(label: '空值示例', value: ''),
              ],
            ),
          ),
          _Block(
            title: '加载态 · AppSkeleton',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppSkeleton(width: 180, height: 16),
                const SizedBox(height: AppSpacing.xs),
                const AppSkeleton(width: 240, height: 12),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    child: const AppSkeletonList(itemCount: 2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 76,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                color: AppColors.of(context).hairline,
                width: 0.5,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}
