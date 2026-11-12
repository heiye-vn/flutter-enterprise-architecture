import '../../../../core/network/page_result.dart';
import '../../domain/entity/customer.dart';
import '../../domain/repository/customer_repository.dart';
import '../datasource/customer_api.dart';
import '../dto/customer_dto.dart';

/// 客户仓库实现。
///
/// 唯一的职责是"防腐"：把 DTO 转成实体，
/// 让上层永远看不到 `lastFollowUpAt` 这种字符串时间。
class CustomerRepositoryImpl implements CustomerRepository {
  CustomerRepositoryImpl(this._api);

  final CustomerApi _api;

  @override
  Future<PageResult<Customer>> fetchPage({
    required int page,
    required int pageSize,
    String? keyword,
  }) async {
    final dtoPage = await _api.fetchPage(
      page: page,
      pageSize: pageSize,
      keyword: keyword,
    );

    return PageResult<Customer>(
      items: dtoPage.items.map((e) => e.toEntity()).toList(growable: false),
      page: dtoPage.page,
      pageSize: dtoPage.pageSize,
      total: dtoPage.total,
    );
  }

  @override
  Future<Customer> fetchDetail(String id) async {
    final dto = await _api.fetchDetail(id);
    return dto.toEntity();
  }
}
