/// 分页结果的统一形状。
///
/// 所有列表接口都收敛成这一个结构，列表 Controller 才能复用同一套分页逻辑。
class PageResult<T> {
  const PageResult({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  final List<T> items;
  final int page;
  final int pageSize;
  final int total;

  /// 还有下一页吗。
  bool get hasMore => page * pageSize < total;

  static PageResult<T> empty<T>({int pageSize = 20}) =>
      PageResult<T>(items: const [], page: 1, pageSize: pageSize, total: 0);
}
