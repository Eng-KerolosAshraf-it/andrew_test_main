// lib/ai/services/python_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class PythonService {
  // لو شغال locally
  static const String _baseUrl = 'http://127.0.0.1:8000';

  static Future<Map<String, dynamic>> analyzeRequest(Map<String, dynamic> data) async {
    try {
      final token = Supabase.instance.client.auth.currentSession?.accessToken;

      final response = await http.post(
        Uri.parse('$_baseUrl/analyze'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to Python: $e');
    }
  }
}