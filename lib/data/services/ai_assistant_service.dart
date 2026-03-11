import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/di/injection.dart';

class AIAssistantService {
  final Dio _dio = sl<Dio>();

  Future<String> getToolRecommendation(String taskDescription) async {
    final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
    
    print('🔑 ตรวจสอบ API Key: ${apiKey.isNotEmpty ? "เจอ Key แล้ว" : "ไม่พบ Key!"}');
    if (apiKey.isEmpty) return "กรุณาใส่ GROQ_API_KEY ในไฟล์ .env แล้วปิดแอปเปิดใหม่";

    final String url = 'https://api.groq.com/openai/v1/chat/completions';

    try {
      print('🚀 กำลังส่งคำถามไปที่ Groq...'); // เช็คว่ามาถึงตรงนี้ไหม
      
      final response = await _dio.post(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          sendTimeout: const Duration(seconds: 10), // ป้องกันมันค้างตลอดกาล
          receiveTimeout: const Duration(seconds: 15),
        ),
        data: {
          "model": "llama-3.1-8b-instant", 
          "messages": [
            {"role": "system", "content": "คุณคือช่างผู้เชี่ยวชาญ ตอบคำถามสั้นๆ เข้าใจง่ายเป็นภาษาไทย"},
            {"role": "user", "content": "แนะนำอุปกรณ์สำหรับ: $taskDescription"}
          ],
          "temperature": 0.5,
        },
      );

      print('✅ ส่งสำเร็จ! รหัสสถานะ: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        final String aiText = response.data['choices'][0]['message']['content'];
        return aiText.trim();
      } else {
         return "Groq ไม่สามารถตอบกลับได้ในขณะนี้";
      }
      
    } catch (e) {
      print('❌ เกิดข้อผิดพลาด: $e'); // ปริ้น Error ออกมาดู
      if (e is DioException) {
         if (e.response?.statusCode == 400 && e.response?.data.toString().contains('decommissioned') == true) {
            return "โมเดล AI นี้ถูกยกเลิกการใช้งานแล้ว";
         }
      }
      return "ขณะนี้ระบบเชื่อมต่อ AI ขัดข้อง";
    }
  } 
}