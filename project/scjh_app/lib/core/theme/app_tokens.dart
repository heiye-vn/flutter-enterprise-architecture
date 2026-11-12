import 'package:flutter/material.dart';

/// 设计令牌 —— 间距。
///
/// 4 的倍数阶梯。业务代码里不要出现魔法数字（`SizedBox(height: 13)`），
/// 全部走令牌，后期整体调密度只改这一处。
class AppSpacing {
  const AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double huge = 40;
}

/// 设计令牌 —— 圆角。
class AppRadius {
  const AppRadius._();

  /// 标签、小徽章
  static const double xs = 4;

  /// 按钮、输入框
  static const double sm = 8;

  /// 中等容器
  static const double md = 12;

  /// 卡片
  static const double lg = 16;

  /// 弹层、底部面板
  static const double xl = 20;

  /// 胶囊
  static const double pill = 999;
}

/// 设计令牌 —— 动效时长。
class AppDuration {
  const AppDuration._();

  /// 点击反馈、颜色变化
  static const Duration fast = Duration(milliseconds: 150);

  /// 展开收起、页面内过渡
  static const Duration base = Duration(milliseconds: 240);

  /// 骨架屏呼吸、较大位移
  static const Duration slow = Duration(milliseconds: 420);
}

/// 品牌与功能色。
///
/// 和 [AppColors] 的区别：这里是不依赖 BuildContext 的常量，
/// 用于 ThemeData 构建、需要写死颜色的场景。
class AppPalette {
  const AppPalette._();

  static const Color brand = Color(0xFF1677FF);
  static const Color success = Color(0xFF52C41A);
  static const Color warning = Color(0xFFFAAD14);
  static const Color danger = Color(0xFFFF4D4F);
  static const Color info = Color(0xFF1677FF);
}

/// 语义色扩展。
///
/// 为什么不直接用 `ColorScheme`：Material 的 scheme 里没有
/// "成功 / 警告" 这类业务语义，也没有"卡片表面 / 分隔线"这种
/// 在三层嵌套布局里必须区分的层级。挂在 ThemeExtension 上，
/// 切换亮暗主题时会自动跟着走。
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.brand,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
    required this.surface,
    required this.surfaceMuted,
    required this.hairline,
    required this.textSecondary,
    required this.textTertiary,
  });

  final Color brand;
  final Color success;
  final Color warning;
  final Color danger;
  final Color info;

  /// 卡片、AppBar 等一级表面
  final Color surface;

  /// 页面背景、输入框填充等二级表面
  final Color surfaceMuted;

  /// 0.5px 分隔线与描边。比纯色更耐看，也让深色模式过渡更自然。
  final Color hairline;

  /// 次要文字
  final Color textSecondary;

  /// 三级文字 / 占位
  final Color textTertiary;

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>() ?? light;

  static const AppColors light = AppColors(
    brand: AppPalette.brand,
    success: AppPalette.success,
    warning: AppPalette.warning,
    danger: AppPalette.danger,
    info: AppPalette.info,
    surface: Colors.white,
    surfaceMuted: Color(0xFFF4F6F9),
    hairline: Color(0x14000000),
    textSecondary: Color(0xFF5F6672),
    textTertiary: Color(0xFF9AA1AC),
  );

  static const AppColors dark = AppColors(
    brand: Color(0xFF3C89FF),
    success: Color(0xFF5BC236),
    warning: Color(0xFFF7B733),
    danger: Color(0xFFFF6B6D),
    info: Color(0xFF3C89FF),
    surface: Color(0xFF1A1D23),
    surfaceMuted: Color(0xFF111317),
    hairline: Color(0x1FFFFFFF),
    textSecondary: Color(0xFFA8AEB8),
    textTertiary: Color(0xFF737A85),
  );

  @override
  AppColors copyWith({
    Color? brand,
    Color? success,
    Color? warning,
    Color? danger,
    Color? info,
    Color? surface,
    Color? surfaceMuted,
    Color? hairline,
    Color? textSecondary,
    Color? textTertiary,
  }) {
    return AppColors(
      brand: brand ?? this.brand,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      info: info ?? this.info,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      hairline: hairline ?? this.hairline,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      brand: Color.lerp(brand, other.brand, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      info: Color.lerp(info, other.info, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
    );
  }
}

/// 字号阶梯。
///
/// 中文和拉丁文的视觉重量不一样：同样 14px，中文看起来更"实"。
/// 所以正文行高给到 1.55，标题给 1.35，避免大段中文挤在一起。
class AppTypography {
  const AppTypography._();

  static TextTheme textTheme(ColorScheme scheme) {
    final base = TextStyle(color: scheme.onSurface);
    return TextTheme(
      headlineSmall: base.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      titleLarge: base.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.35,
      ),
      titleMedium: base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      titleSmall: base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      bodyLarge: base.copyWith(fontSize: 15, height: 1.55),
      bodyMedium: base.copyWith(fontSize: 14, height: 1.55),
      bodySmall: base.copyWith(fontSize: 12, height: 1.5),
      labelLarge: base.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
      labelMedium: base.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall: base.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.2,
      ),
    );
  }
}
