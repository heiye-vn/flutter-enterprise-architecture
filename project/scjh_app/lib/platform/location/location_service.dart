import '../permission/capability_permission.dart';

/// 一个坐标点。
class GeoPoint {
  const GeoPoint({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  final double latitude;
  final double longitude;

  /// 逆地理编码结果。真实实现里由高德/腾讯地图 SDK 反查得到。
  final String? address;

  @override
  String toString() =>
      'GeoPoint($latitude, $longitude${address == null ? '' : ', $address'})';
}

/// 一次定位结果。
class LocationReading {
  const LocationReading({
    required this.point,
    required this.accuracyMeters,
    required this.capturedAt,
  });

  final GeoPoint point;

  /// 精度半径（米）。打卡类业务必须校验这个值，
  /// 否则 GPS 漂移会导致"人在公司却打不上卡"。
  final double accuracyMeters;

  final DateTime capturedAt;
}

/// 定位能力抽象。
///
/// 注意：这里返回的坐标是 **WGS84**。
/// 如果要叠到高德/腾讯地图上，必须先转成 GCJ-02，
/// 否则会偏移几百米 —— 这是国内地图接入最常见的坑。
abstract interface class LocationService {
  Future<CapabilityPermission> ensurePermission();

  Future<LocationReading> currentReading();
}
