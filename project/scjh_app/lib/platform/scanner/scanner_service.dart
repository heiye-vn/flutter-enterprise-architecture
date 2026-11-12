import 'package:flutter/material.dart';

import '../permission/capability_permission.dart';

/// 一次扫码的结果。
class ScanResult {
  const ScanResult({required this.code, this.format = 'unknown'});

  final String code;
  final String format;

  @override
  String toString() => 'ScanResult($code, $format)';
}

/// 扫码能力抽象。
///
/// **业务层只依赖这个接口，不 import 任何具体插件。**
/// 将来换成 `mobile_scanner`、或工业手持机的硬件扫码头，
/// 都只是新增一个实现类，页面代码一行都不用改。
abstract interface class ScannerService {
  Future<CapabilityPermission> ensurePermission();

  /// 返回 null 表示用户取消。
  Future<ScanResult?> scan(BuildContext context);
}
