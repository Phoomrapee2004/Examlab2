import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toolmaster_pro/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ทดสอบเปิดแอปและกดเข้าหน้ารายละเอียด', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // หาอุปกรณ์ชิ้นแรกแล้วแตะ
    final firstTool = find.byType(ListTile).first;
    await tester.tap(firstTool);
    await tester.pumpAndSettle(); // รอให้ Animation (Hero) ทำงานเสร็จ

    // ตรวจสอบว่าเปลี่ยนหน้าแล้ว
    expect(find.text('รายละเอียดอุปกรณ์'), findsOneWidget);
  });
}