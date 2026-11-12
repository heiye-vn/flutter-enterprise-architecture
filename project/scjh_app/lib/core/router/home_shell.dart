import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 底部导航壳。
///
/// `StatefulShellRoute.indexedStack` 会让每个 Tab 拥有独立的导航栈 ——
/// 从"客户"进详情、切到"我的"再切回来，详情页还在。
/// 用普通 `IndexedStack` + `Navigator` 手工实现要写一堆，这里一行就够。
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            // 再次点击当前 Tab 时回到该分支的初始页。
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: '客户',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
