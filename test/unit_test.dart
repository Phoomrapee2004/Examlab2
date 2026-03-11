import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:toolmaster_pro/data/services/ai_assistant_service.dart';

import 'unit_test.mocks.dart';
// ต้องสร้างไฟล์ mock ด้วย build_runner ก่อน
@GenerateMocks([AIAssistantService])
void main() {
  test('ทดสอบว่า API ส่งคำแนะนำกลับมาได้', () async {
    final mockService = MockAIAssistantService();
    when(mockService.getToolRecommendation("ตอกตะปู"))
        .thenAnswer((_) async => "ค้อน");

    final result = await mockService.getToolRecommendation("ตอกตะปู");
    expect(result, "ค้อน");
  });
}