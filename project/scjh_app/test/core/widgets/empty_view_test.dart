import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scjh_app/core/widgets/empty_view.dart';

void main() {
  testWidgets('空态可以渲染文案与操作按钮', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmptyView(
            message: '还没有客户数据',
            action: TextButton(onPressed: () {}, child: const Text('去新建')),
          ),
        ),
      ),
    );

    expect(find.text('还没有客户数据'), findsOneWidget);
    expect(find.text('去新建'), findsOneWidget);
  });

  testWidgets('空态在默认约束下不会溢出', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: EmptyView())),
    );
    expect(tester.takeException(), isNull);
  });
}
