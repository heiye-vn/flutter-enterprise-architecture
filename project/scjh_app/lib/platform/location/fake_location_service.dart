import '../permission/capability_permission.dart';
import 'location_service.dart';

/// 定位能力的假实现。
///
/// 返回一个固定点位 + 轻微抖动，模拟真实 GPS 的漂移，
/// 方便验证"精度不足时给出提示"这类业务分支。
class FakeLocationService implements LocationService {
  const FakeLocationService();

  @override
  Future<CapabilityPermission> ensurePermission() async {
    return CapabilityPermission.granted;
  }

  @override
  Future<LocationReading> currentReading() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final jitter = (DateTime.now().millisecond % 30) / 100000;
    return LocationReading(
      point: GeoPoint(
        latitude: 30.5928 + jitter,
        longitude: 114.3055 + jitter,
        address: '湖北省武汉市洪山区示例路 1 号',
      ),
      accuracyMeters: 12 + (DateTime.now().millisecond % 20),
      capturedAt: DateTime.now(),
    );
  }
}
