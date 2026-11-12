import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../platform/location/location_service.dart';
import '../../../../platform/permission/capability_permission.dart';
import '../../../../platform/permission/permission_gate.dart';
import '../../../../platform/scanner/scanner_service.dart';
import '../../application/customer_detail_provider.dart';
import '../../domain/entity/customer.dart';

/// 客户详情页。
///
/// 除了展示，还演示了两条原生能力的接入方式：
/// 扫码（无权限 → 提示）与定位（无权限 → 走 PermissionGate 降级 UI）。
class CustomerDetailScreen extends ConsumerStatefulWidget {
  const CustomerDetailScreen({super.key, required this.customerId});

  final String customerId;

  @override
  ConsumerState<CustomerDetailScreen> createState() =>
      _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends ConsumerState<CustomerDetailScreen> {
  CapabilityPermission _locationPermission = CapabilityPermission.granted;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _probePermission();
  }

  Future<void> _probePermission() async {
    final permission = await getIt<LocationService>().ensurePermission();
    if (!mounted) return;
    setState(() => _locationPermission = permission);
  }

  Future<void> _verifyByScan() async {
    final scanner = getIt<ScannerService>();
    final permission = await scanner.ensurePermission();
    if (!mounted) return;

    if (permission != CapabilityPermission.granted) {
      _toast('没有相机权限，请到系统设置开启后重试');
      return;
    }

    final result = await scanner.scan(context);
    if (!mounted || result == null) return;
    _toast('核验通过：${result.code}');
  }

  Future<void> _punchIn() async {
    setState(() => _locating = true);
    try {
      final reading = await getIt<LocationService>().currentReading();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('定位成功'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '坐标：${reading.point.latitude.toStringAsFixed(5)}, '
                '${reading.point.longitude.toStringAsFixed(5)}',
              ),
              const SizedBox(height: AppSpacing.xs),
              Text('精度：±${reading.accuracyMeters.toStringAsFixed(0)} 米'),
              const SizedBox(height: AppSpacing.xs),
              Text(reading.point.address ?? '未解析地址'),
              if (reading.accuracyMeters > 50) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '精度不足，真实业务应提示用户到开阔处重试，'
                  '而不是直接放行打卡。',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('知道了'),
            ),
          ],
        ),
      );
    } on Object catch (error) {
      if (mounted) _toast(readableMessage(error));
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final asyncCustomer = ref.watch(customerDetailProvider(widget.customerId));

    return Scaffold(
      appBar: AppBar(title: const Text('客户详情')),
      body: asyncCustomer.when(
        loading: () => const _DetailSkeleton(),
        error: (error, _) => ErrorView(
          message: readableMessage(error),
          onRetry: () =>
              ref.invalidate(customerDetailProvider(widget.customerId)),
        ),
        data: (customer) => _DetailBody(customer: customer),
      ),
      bottomNavigationBar: asyncCustomer.hasValue ? _buildActionBar() : null,
    );
  }

  Widget _buildActionBar() {
    final colors = AppColors.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.hairline, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  label: '扫码核验',
                  variant: AppButtonVariant.secondary,
                  icon: Icons.qr_code_scanner,
                  onPressed: _verifyByScan,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: PermissionGate(
                  permission: _locationPermission,
                  deniedBuilder: (context) => AppButton(
                    label: '定位未授权',
                    variant: AppButtonVariant.secondary,
                    icon: Icons.lock_outline,
                    onPressed: () => _toast('定位权限被拒绝，请在系统设置中开启'),
                  ),
                  child: AppButton(
                    label: _locating ? '定位中' : '定位打卡',
                    icon: Icons.my_location,
                    loading: _locating,
                    onPressed: _punchIn,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      children: [
        AppCard(
          child: AppAvatarHeader(
            name: customer.name,
            title: customer.name,
            subtitle: '${customer.code} · ${customer.industry}',
            trailing: AppTag(
              customer.levelLabel,
              tone: _toneForLevel(customer.level),
              variant: AppTagVariant.outline,
              dense: true,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppSection(
          title: '基本信息',
          children: [
            AppInfoRow(label: '所属行业', value: customer.industry),
            AppInfoRow(label: '所属区域', value: customer.regionName),
            AppInfoRow(label: '客户经理', value: customer.ownerName),
            AppInfoRow(
              label: '最近跟进',
              value: customer.lastFollowUpAt == null
                  ? '暂无跟进'
                  : formatDate(customer.lastFollowUpAt),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        AppSection(
          title: '联系人',
          children: [
            AppInfoRow(label: '姓名', value: customer.contactName),
            AppInfoRow(
              label: '电话',
              value: customer.contactPhone,
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('这里可以接 url_launcher 拨号')),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        AppSection(
          title: '备注',
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                customer.remark.isEmpty ? '—' : customer.remark,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static AppTagTone _toneForLevel(String level) => switch (level) {
    'A' => AppTagTone.brand,
    'B' => AppTagTone.warning,
    'C' => AppTagTone.neutral,
    _ => AppTagTone.neutral,
  };
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: const [
        AppCard(
          child: Row(
            children: [
              AppSkeleton(width: 48, height: 48, radius: 14),
              SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSkeleton(width: 140, height: 16),
                  SizedBox(height: AppSpacing.xs),
                  AppSkeleton(width: 180, height: 12),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        AppSkeleton(width: double.infinity, height: 180, radius: AppRadius.lg),
        SizedBox(height: AppSpacing.lg),
        AppSkeleton(width: double.infinity, height: 120, radius: AppRadius.lg),
      ],
    );
  }
}
