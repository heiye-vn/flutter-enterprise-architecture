import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/injection.dart';
import '../domain/entity/customer.dart';
import '../domain/repository/customer_repository.dart';

/// 客户列表状态。
///
/// `loadingMore` 和 `AsyncValue.loading` 是两件事：
/// 前者是"底部加载下一页"（已有数据，不该整页转圈），
/// 后者是"首屏加载"（没有数据，应该显示骨架）。
class CustomerListState {
  const CustomerListState({
    required this.items,
    required this.page,
    required this.hasMore,
    this.loadingMore = false,
    this.keyword = '',
  });

  final List<Customer> items;
  final int page;
  final bool hasMore;
  final bool loadingMore;
  final String keyword;

  bool get isEmpty => items.isEmpty;

  CustomerListState copyWith({
    List<Customer>? items,
    int? page,
    bool? hasMore,
    bool? loadingMore,
    String? keyword,
  }) {
    return CustomerListState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
      keyword: keyword ?? this.keyword,
    );
  }
}

/// 客户列表控制器。
class CustomerListController extends AsyncNotifier<CustomerListState> {
  static const int pageSize = 20;

  @override
  Future<CustomerListState> build() => _loadFirstPage('');

  Future<CustomerListState> _loadFirstPage(String keyword) async {
    final result = await getIt<CustomerRepository>().fetchPage(
      page: 1,
      pageSize: pageSize,
      keyword: keyword.isEmpty ? null : keyword,
    );
    return CustomerListState(
      items: result.items,
      page: 1,
      hasMore: result.hasMore,
      keyword: keyword,
    );
  }

  /// 下拉刷新。失败时抛出，由 UI 决定怎么提示（保留旧数据）。
  Future<void> refresh() async {
    final keyword = state.value?.keyword ?? '';
    state = AsyncValue.data(await _loadFirstPage(keyword));
  }

  /// 加载下一页。
  ///
  /// 三重防抖：没有更多、正在加载、首屏还没回来，都不触发。
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.loadingMore) return;

    state = AsyncValue.data(current.copyWith(loadingMore: true));
    try {
      final next = await getIt<CustomerRepository>().fetchPage(
        page: current.page + 1,
        pageSize: pageSize,
        keyword: current.keyword.isEmpty ? null : current.keyword,
      );
      state = AsyncValue.data(
        current.copyWith(
          items: [...current.items, ...next.items],
          page: current.page + 1,
          hasMore: next.hasMore,
          loadingMore: false,
        ),
      );
    } on Object {
      state = AsyncValue.data(current.copyWith(loadingMore: false));
      rethrow;
    }
  }

  /// 关键字搜索（从第一页重新开始）。
  Future<void> search(String keyword) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadFirstPage(keyword));
  }
}

final customerListProvider =
    AsyncNotifierProvider<CustomerListController, CustomerListState>(
      CustomerListController.new,
    );
