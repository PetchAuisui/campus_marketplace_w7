import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const _model = 'gemini-3.5-flash';
  static const _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';
  static const _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  Future<String> generateText(String prompt) async {
    final uri = Uri.parse('$_baseUrl?key=$_apiKey');
    final requestBody = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt},
          ],
        },
      ],
    });

    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: requestBody,
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final candidates = data['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception('Gemini ไม่สามารถสร้างคำตอบได้ในครั้งนี้');
      }
      final parts = candidates.first['content']['parts'] as List<dynamic>;
      return parts.first['text'] as String;
    } else if (response.statusCode == 429) {
      throw Exception('ใช้งานเกินโควตาที่กำหนดในขณะนี้ กรุณาลองใหม่ภายหลัง');
    } else {
      throw Exception(
        'เซิร์ฟเวอร์ Gemini ตอบกลับผิดพลาด (รหัส ${response.statusCode})',
      );
    }
  }
}
// ผลลัพธ์: สวัสดีค่ะ ยินดีต้อนรับสู่ร้านของเรานะคะ 😊 มีอะไรให้ช่วยดูสินค้าไหมคะ?
// หมายเหตุ: รันซ้ำด้วย Prompt เดิม ข้อความที่ได้อาจไม่เหมือนเดิมทุกตัวอักษร (ดูตอนที่ 1)