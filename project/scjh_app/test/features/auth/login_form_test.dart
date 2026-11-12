import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scjh_app/core/di/injection.dart';
import 'package:scjh_app/core/storage/prefs_repository.dart';
import 'package:scjh_app/features/auth/presentation/login/login_form.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    if (getIt.isRegistered<PrefsRepository>()) {
      await getIt.unregister<PrefsRepository>();
    }
    getIt.registerSingleton<PrefsRepository>(PrefsRepository(prefs));
  });

  tearDown(() async {
    if (getIt.isRegistered<PrefsRepository>()) {
      await getIt.unregister<PrefsRepository>();
    }
  });

  testWidgets('空表单提交时给出必填提示', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: LoginForm())),
      ),
    );

    await tester.tap(find.text('登 录'));
    await tester.pump();

    expect(find.text('账号不能为空'), findsOneWidget);
    expect(find.text('密码不能为空'), findsOneWidget);
  });

  testWidgets('账号长度不足时提示', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: LoginForm())),
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'ab');
    await tester.tap(find.text('登 录'));
    await tester.pump();

    expect(find.text('账号至少 3 个字符'), findsOneWidget);
  });
}
