import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../platform/permission/capability_permission.dart';
import '../../../../platform/scanner/scanner_service.dart';
import '../../application/customer_list_controller.dart';

/// 客户列表页。
///
/// 这一个页面覆盖了 5 个通用能力，后面 50 多个列表页都可以照抄：
/// 下拉刷新、上拉加载更多、搜索防抖、空态、错误重试。
class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    try {
      await ref.read(customerListProvider.notifier).loadMore();
    } on Object catch (error) {
      _toast(readableMessage(error));
    }
  }

  Future<void> _onRefresh() async {
    try {
      await ref.read(customerListProvider.notifier).refresh();
    } on Object catch (error) {
      _toast(readableMessage(error));
    }
  }

  /// 搜索防抖：每敲一个字就请求一次会把后端打穿。
  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      ref.read(customerListProvider.notifier).search(value.trim());
    });
  }

  Future<void> _onScan() async {
    final scanner = getIt<ScannerService>();
    final permission = await scanner.ensurePermission();
    if (!mounted) return;

    if (permission != CapabilityPermission.granted) {
      _toast('没有相机权限，请到系统设置开启后重试');
      return;
    }

    final result = await scanner.scan(context);
    if (!mounted || result == null) return;

    _searchController.text = result.code;
    await ref.read(customerListProvider.notifier).search(result.code);
    if (!mounted) return;
    _toast('已扫描：${result.code}');
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('客户'),
        actions: [
          IconButton(
            tooltip: '扫码查询',
            onPressed: _onScan,
            icon: const Icon(Icons.qr_code_scanner),
          ),
          const SizedBox(width: AppSpacing.xxs),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: AppSearchBar(
              controller: _searchController,
              hintText: '搜索客户名称 / 编号',
              onChanged: _onSearchChanged,
              onSubmitted: (value) =>
                  ref.read(customerListProvider.notifier).search(value.trim()),
              onClear: () =>
                  ref.read(customerListProvider.notifier).search(''),
              onScan: _onScan,
            ),
          ),
          Expanded(
            child: state.when(
              // 首屏用骨架屏，形状和真实列表对齐，加载完不跳版
              loading: () => const AppSkeletonList(),
              error: (error, _) => ErrorView(
                message: readableMessage(error),
                onRetry: () => ref.invalidate(customerListProvider),
              ),
              data: (data) => _buildList(data),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(CustomerListState data) {
    if (data.isEmpty) {
      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: EmptyView(
          icon: data.keyword.isEmpty
              ? Icons.people_outline
              : Icons.search_off_outlined,
          message: data.keyword.isEmpty
              ? '还没有客户数据'
              : '没有匹配「${data.keyword}」的客户',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xxs,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        itemCount: data.items.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
        itemBuilder: (context, index) {
          if (index == data.items.length) {
            return _ListFooter(
              loading: data.loadingMore,
              hasMore: data.hasMore,
              total: data.items.length,
            );
          }
          final customer = data.items[index];
          return AppCard(
            padding: EdgeInsets.zero,
            onTap: () => context.push('/customers/${customer.id}'),
            child: AppListTile(
              leading: AppAvatar(name: customer.name),
              title: Row(
                children: [
                  Flexible(
                    child: Text(
                      customer.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  AppTag(
                    customer.levelLabel,
                    tone: _toneForLevel(customer.level),
                    variant: AppTagVariant.outline,
                    dense: true,
                  ),
                ],
              ),
              subtitle: '${customer.code} · ${customer.industry}',
              meta:
                  '${customer.regionName} · ${customer.ownerName} · '
                  '${formatRelative(customer.lastFollowUpAt)}',
            ),
          );
        },
      ),
    );
  }

  static AppTagTone _toneForLevel(String level) => switch (level) {
    'A' => AppTagTone.brand,
    'B' => AppTagTone.warning,
    'C' => AppTagTone.neutral,
    _ => AppTagTone.neutral,
  };
}

class _ListFooter extends StatelessWidget {
  const _ListFooter({
    required this.loading,
    required this.hasMore,
    required this.total,
  });

  final bool loading;
  final bool hasMore;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Center(
        child: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                hasMore ? '上拉加载更多' : '已加载全部 $total 条',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.textTertiary,
                ),
              ),
      ),
    );
  }
}
