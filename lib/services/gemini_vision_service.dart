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
              'inline_data': {
                'mime_type': mimeType,
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

    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: requestBody,
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      // jsonDecode สองชั้น:
      // ชั้นที่ 1: แปลง response body จาก API เป็น Map
      final data = jsonDecode(response.body);
      final candidates = data['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception('Gemini ไม่สามารถวิเคราะห์ภาพสินค้าได้ในครั้งนี้');
      }
      final parts = candidates.first['content']['parts'] as List<dynamic>;
      final text = parts.first['text'] as String;

      // ชั้นที่ 2: แปลงข้อความ JSON ที่ Gemini ส่งกลับมาเป็น Map แล้วแปลงเป็น ListingDraft
      final jsonMap = jsonDecode(text) as Map<String, dynamic>;
      return ListingDraft.fromJson(jsonMap);
    } else if (response.statusCode == 429) {
      throw Exception('ใช้งานเกินโควตาที่กำหนดในขณะนี้ กรุณาลองใหม่ภายหลัง');
    } else {
      throw Exception(
        'เซิร์ฟเวอร์ Gemini ตอบกลับผิดพลาด (รหัส ${response.statusCode})',
      );
    }
  }
}
