import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/injection.dart';
import '../domain/entity/customer.dart';
import '../domain/repository/customer_repository.dart';

/// 客户详情。
///
/// 纯读取、无交互 → 用 `FutureProvider.family` 就够了，
/// 不需要为它单独建一个 Notifier。
final customerDetailProvider = FutureProvider.family<Customer, String>((
  ref,
  id,
) {
  return getIt<CustomerRepository>().fetchDetail(id);
});
