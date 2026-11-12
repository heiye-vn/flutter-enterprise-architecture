import '../../../../core/network/api_client.dart';
import '../../../../core/network/page_result.dart';
import '../dto/customer_dto.dart';

/// 客户接口契约。
abstract interface class CustomerApi {
  Future<PageResult<CustomerDto>> fetchPage({
    required int page,
    required int pageSize,
    String? keyword,
  });

  Future<CustomerDto> fetchDetail(String id);
}

/// 真实实现。
class CustomerApiRemote implements CustomerApi {
  CustomerApiRemote(this._client);

  final ApiClient _client;

  @override
  Future<PageResult<CustomerDto>> fetchPage({
    required int page,
    required int pageSize,
    String? keyword,
  }) async {
    final json = await _client.getJson<Map<String, dynamic>>(
      '/customers',
      query: {
        'page': page,
        'pageSize': pageSize,
        if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
      },
    );

    final records = (json['records'] as List<dynamic>? ?? const [])
        .map((e) => CustomerDto.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);

    return PageResult<CustomerDto>(
      items: records,
      page: (json['page'] as num?)?.toInt() ?? page,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? pageSize,
      total: (json['total'] as num?)?.toInt() ?? records.length,
    );
  }

  @override
  Future<CustomerDto> fetchDetail(String id) async {
    final json = await _client.getJson<Map<String, dynamic>>(
      '/customers/$id',
    );
    return CustomerDto.fromJson(json);
  }
}
