import 'package:flutter_test/flutter_test.dart';
import 'package:scjh_app/core/utils/formatters.dart';

void main() {
  group('formatDate', () {
    test('补零到 yyyy-MM-dd', () {
      expect(formatDate(DateTime(2026, 1, 5)), '2026-01-05');
    });

    test('空值返回占位符', () {
      expect(formatDate(null), '—');
      expect(formatDate(null, placeholder: '暂无'), '暂无');
    });
  });

  group('formatRelative', () {
    test('一天内显示小时', () {
      final value = DateTime.now().subtract(const Duration(hours: 3));
      expect(formatRelative(value), '3 小时前');
    });

    test('超过 30 天退回绝对日期', () {
      final value = DateTime.now().subtract(const Duration(days: 45));
      expect(formatRelative(value), formatDate(value));
    });

    test('空值返回占位文案', () {
      expect(formatRelative(null), '暂无跟进');
    });
  });
}
