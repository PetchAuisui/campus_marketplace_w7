import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/listing_draft.dart';

class GeminiVisionService {
  static const _model = 'gemini-3.5-flash';
  static const _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';
  static const _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  String _getMimeType(String path) {
    final ext = path.toLowerCase().split('.').last;
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      case 'heif':
        return 'image/heif';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  Future<ListingDraft> analyzeProductImage(File imageFile) async {
    final uri = Uri.parse('$_baseUrl?key=$_apiKey');

    // 1. อ่านไฟล์ภาพเป็นไบต์ และเข้ารหัสเป็น Base64
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    final mimeType = _getMimeType(imageFile.path);

    // 2. ส่งพร้อม Prompt ใน parts เดียวกัน และใช้ responseSchema บังคับให้ได้ JSON
    final requestBody = jsonEncode({
      'contents': [
        {
          'parts': [
            {
              'text':
                  'วิเคราะห์ภาพสินค้านี้เพื่อสร้างข้อมูลสำหรับลงประกาศขายสินค้ามือสอง โดยระบุชื่อสินค้า (title), หมวดหมู่สินค้า (category), และคำอธิบายสินค้าสั้นๆ (description)',
            },
            {
              'inlineData': {
                'mimeType': mimeType,
                'data': base64Image,
              },
            },
          ],
        },
      ],
      'generationConfig': {
        'responseMimeType': 'application/json',
        'responseSchema': {
          'type': 'OBJECT',
          'properties': {
            'title': {'type': 'STRING'},
            'category': {'type': 'STRING'},
            'description': {'type': 'STRING'},
          },
          'required': ['title', 'category', 'description'],
        },
      },
    });

    http.Response? response;
    // กรณีที่เซิร์ฟเวอร์ตอบ 503 (Service Unavailable ชั่วคราว) ให้ลองส่งซ้ำอัตโนมัติ
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        response = await http
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: requestBody,
            )
            .timeout(const Duration(seconds: 60));

        if (response.statusCode == 200) {
          break;
        } else if (response.statusCode == 503 && attempt < 2) {
          await Future.delayed(Duration(seconds: 2 * (attempt + 1)));
          continue;
        } else {
          break;
        }
      } catch (e) {
        if (attempt == 2) rethrow;
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    if (response != null && response.statusCode == 200) {
      // jsonDecode สองชั้น:
      // ชั้นที่ 1: แปลง response body จาก API เป็น Map
      final data = jsonDecode(response.body);
      final candidates = data['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception('Gemini ไม่สามารถวิเคราะห์ภาพสินค้าได้ในครั้งนี้');
      }
      final parts = candidates.first['content']['parts'] as List<dynamic>;
      var text = parts.first['text'] as String;

      // ลบ markdown formatting ถ้ามี
      text = text.trim();
      if (text.startsWith('```json')) {
        text = text.substring(7);
      } else if (text.startsWith('```')) {
        text = text.substring(3);
      }
      if (text.endsWith('```')) {
        text = text.substring(0, text.length - 3);
      }
      text = text.trim();

      // ชั้นที่ 2: แปลงข้อความ JSON ที่ Gemini ส่งกลับมาเป็น Map แล้วแปลงเป็น ListingDraft
      final jsonMap = jsonDecode(text) as Map<String, dynamic>;
      return ListingDraft.fromJson(jsonMap);
    } else if (response != null && response.statusCode == 429) {
      throw Exception('ใช้งานเกินโควตาที่กำหนดในขณะนี้ กรุณาลองใหม่ภายหลัง');
    } else if (response != null && response.statusCode == 503) {
      throw Exception('เซิร์ฟเวอร์ Gemini กำลังมีผู้ใช้งานหนาแน่นชั่วคราว (รหัส 503) กรุณากดลองใหม่อีกครั้ง');
    } else {
      final code = response?.statusCode ?? 'No response';
      throw Exception(
        'เซิร์ฟเวอร์ Gemini ตอบกลับผิดพลาด (รหัส $code)',
      );
    }
  }
}
