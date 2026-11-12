import '../../../../core/network/page_result.dart';
import '../entity/customer.dart';

/// 客户仓库契约。
///
/// 分页参数用 page / pageSize 而不是 offset / limit：
/// 业务代码说业务语言，翻页是业务概念，offset 是实现细节。
abstract interface class CustomerRepository {
  Future<PageResult<Customer>> fetchPage({
    required int page,
    required int pageSize,
    String? keyword,
  });

  Future<Customer> fetchDetail(String id);
}
