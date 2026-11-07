import 'package:flutter_test/flutter_test.dart';
import 'package:the_ielts_spells_mobile/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Home screen smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    // Pump and wait for initial dashboard load
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.text('The IELTS Spells'), findsOneWidget);
    expect(find.text('Mục tiêu học tập hôm nay'), findsOneWidget);
    expect(find.text('Sổ từ Thông minh (SRS)'), findsOneWidget);
    expect(find.text('Đấu trường Mini-Games'), findsOneWidget);
    expect(find.text('Luyện Quick Speaking AI'), findsOneWidget);
  });
}
