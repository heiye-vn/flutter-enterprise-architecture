import '../../../../core/config/env_config.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/page_result.dart';
import '../dto/customer_dto.dart';
import 'customer_api.dart';

/// 客户接口的内存假实现。
///
/// 生成 48 条确定性数据：足够翻 3 页（pageSize=20），
/// 能验证分页、下拉刷新、加载更多、空态四条链路。
class CustomerApiMock implements CustomerApi {
  CustomerApiMock() : _data = _seed();

  final List<CustomerDto> _data;

  /// 与 [FakeScannerService] 的演示码对齐，用来验证"扫码 → 过滤"闭环。
  static const String demoScannableCode = 'KH20261000';

  static const _baseNames = <String>[
    '武汉钢铁集团',
    '长江存储科技',
    '湖北中烟工业',
    '东风汽车零部件',
    '光谷信息技术',
    '华中数控',
    '宜昌兴发集团',
    '襄阳轴承股份',
    '九州通医药',
    '人福医药集团',
    '马应龙药业',
    '武汉光迅科技',
    '华工科技产业',
    '湖北宜化集团',
    '三环集团',
    '武汉天喻信息',
  ];

  static const _industries = <String>['钢铁冶金', '半导体', '烟草', '汽车制造', '软件服务', '装备制造', '化工', '机械'];

  static const _regions = <String>['湖北省武汉市', '湖北省宜昌市', '湖北省襄阳市', '湖北省黄石市'];

  static const _owners = <String>['张伟', '李静', '王强', '刘洋', '陈晨'];

  static const _levels = <String>['A', 'B', 'C'];

  static List<CustomerDto> _seed() {
    final now = DateTime.now();
    return List<CustomerDto>.generate(48, (i) {
      final baseName = _baseNames[i % _baseNames.length];
      final round = i ~/ _baseNames.length + 1;
      return CustomerDto(
        id: 'CUS-${1000 + i}',
        name: round == 1 ? baseName : '$baseName（$round 期）',
        code: 'KH2026${1000 + i}',
        level: _levels[i % _levels.length],
        industry: _industries[i % _industries.length],
        contactName: _owners[i % _owners.length],
        contactPhone: '138${10000000 + i * 137}',
        regionName: _regions[i % _regions.length],
        ownerName: _owners[i % _owners.length],
        lastFollowUpAt: now.subtract(Duration(days: i * 3)).toIso8601String(),
        remark: '示例数据：用于验证列表分页、骨架屏与详情渲染。',
      );
    }, growable: false);
  }

  @override
  Future<PageResult<CustomerDto>> fetchPage({
    required int page,
    required int pageSize,
    String? keyword,
  }) async {
    await Future<void>.delayed(EnvConfig.mockLatency);

    final trimmed = keyword?.trim() ?? '';
    final filtered = trimmed.isEmpty
        ? _data
        : _data
              .where(
                (c) => c.name.contains(trimmed) || c.code.contains(trimmed),
              )
              .toList(growable: false);

    final start = (page - 1) * pageSize;
    final end = (start + pageSize).clamp(0, filtered.length);
    final items = start >= filtered.length
        ? const <CustomerDto>[]
        : filtered.sublist(start, end);

    return PageResult<CustomerDto>(
      items: items,
      page: page,
      pageSize: pageSize,
      total: filtered.length,
    );
  }

  @override
  Future<CustomerDto> fetchDetail(String id) async {
    await Future<void>.delayed(EnvConfig.mockLatency);
    for (final item in _data) {
      if (item.id == id) return item;
    }
    throw const BusinessException(code: 404, message: '客户不存在或已删除');
  }
}
