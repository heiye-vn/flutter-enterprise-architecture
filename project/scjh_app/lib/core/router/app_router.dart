import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/application/auth_state.dart';
import '../../features/auth/presentation/login/login_screen.dart';
import '../../features/customer/presentation/detail/customer_detail_screen.dart';
import '../../features/customer/presentation/list/customer_list_screen.dart';
import '../../features/dev/presentation/component_gallery_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import 'home_shell.dart';

/// 根导航 Key，用于让详情页盖在底部导航之上（而不是嵌在 Tab 里）。
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

/// 把"登录态变化"翻译成"路由需要重新计算"。
///
/// go_router 的 `refreshListenable` 只认 Listenable，
/// 所以需要这层适配器，并且**只在布尔值真的变化时**才通知，
/// 否则每次用户信息变动都会触发一次全量重定向计算。
class RouterRefreshNotifier extends ChangeNotifier {
  bool _isAuthenticated = false;

  void update(bool isAuthenticated) {
    if (_isAuthenticated == isAuthenticated) return;
    _isAuthenticated = isAuthenticated;
    notifyListeners();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = RouterRefreshNotifier();
  ref.onDispose(refreshNotifier.dispose);

  ref.listen<AuthState>(
    authControllerProvider,
    (previous, next) => refreshNotifier.update(next.isAuthenticated),
    fireImmediately: true,
  );

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/customers',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final isAuthenticated = ref
          .read(authControllerProvider)
          .isAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isAuthenticated) {
        return isLoginRoute ? null : '/login';
      }
      if (isLoginRoute) {
        return '/customers';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dev/components',
        builder: (context, state) => const ComponentGalleryScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/customers',
                builder: (context, state) => const CustomerListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/customers/:id',
        builder: (context, state) => CustomerDetailScreen(
          customerId: state.pathParameters['id'] ?? '',
        ),
      ),
    ],
  );
});
