import 'package:flutter_test/flutter_test.dart';
import 'package:scjh_app/features/customer/data/datasource/customer_api_mock.dart';

void main() {
  group('CustomerApiMock 分页', () {
    test('第一页返回 20 条且还有下一页', () async {
      final api = CustomerApiMock();
      final page = await api.fetchPage(page: 1, pageSize: 20);

      expect(page.items.length, 20);
      expect(page.total, 48);
      expect(page.hasMore, isTrue);
    });

    test('最后一页条数正确且没有下一页', () async {
      final api = CustomerApiMock();
      final page = await api.fetchPage(page: 3, pageSize: 20);

      expect(page.items.length, 8);
      expect(page.hasMore, isFalse);
    });

    test('关键字可以按编号精确命中', () async {
      final api = CustomerApiMock();
      final page = await api.fetchPage(
        page: 1,
        pageSize: 20,
        keyword: CustomerApiMock.demoScannableCode,
      );

      expect(page.total, 1);
      expect(page.items.single.code, CustomerApiMock.demoScannableCode);
    });

    test('越界页码返回空列表而不是抛错', () async {
      final api = CustomerApiMock();
      final page = await api.fetchPage(page: 99, pageSize: 20);

      expect(page.items, isEmpty);
      expect(page.hasMore, isFalse);
    });
  });
}
