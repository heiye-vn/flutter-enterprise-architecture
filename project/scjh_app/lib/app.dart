import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/application/theme_controller.dart';

/// 根组件。
///
/// 只做三件事：装配主题、装配路由、装配本地化。
/// 任何业务逻辑都不应该出现在这里。
class ScjhApp extends ConsumerWidget {
  const ScjhApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeControllerProvider);

    return MaterialApp.router(
      title: '企业应用骨架',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      // 企业应用通常只做中文，强制 locale 可以避免
      // 英文系统上出现英文日期选择器这种割裂体验。
      locale: const Locale('zh', 'CN'),
      supportedLocales: const [Locale('zh', 'CN'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
