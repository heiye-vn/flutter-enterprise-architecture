import 'package:flutter/material.dart';

import '../permission/capability_permission.dart';
import 'scanner_service.dart';

/// 扫码能力的假实现。
///
/// 用途有三：
/// 1. 骨架阶段没有接真实插件，App 也要能跑通全流程；
/// 2. Widget 测试里替换成它，不依赖真机相机；
/// 3. 给真实实现树一个"照着写"的模板。
///
/// 接真实插件时，新建 `MobileScannerService implements ScannerService`，
/// 在 DI 里换一行注册即可。
class FakeScannerService implements ScannerService {
  const FakeScannerService();

  @override
  Future<CapabilityPermission> ensurePermission() async {
    return CapabilityPermission.granted;
  }

  /// 与 Mock 客户数据中的第一条编号对齐，
  /// 扫描后能直接过滤出一条记录，方便验证"扫码 → 查询"完整链路。
  static const String demoCode = 'KH20261000';

  @override
  Future<ScanResult?> scan(BuildContext context) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return const ScanResult(code: demoCode, format: 'CODE_128');
  }
}
