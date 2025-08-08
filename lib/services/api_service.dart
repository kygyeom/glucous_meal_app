import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:glucous_meal_app/models/models.dart';
import 'uuid_service.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000'; // 로컬 서버 주소

  // 음식 검색 결과
  static Future<List<String>> searchFoods(String query) async {
    final url = Uri.parse('$baseUrl/search?query=$query');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => item.toString()).toList(); // 문자열 리스트 반환
    } else {
      print("❌ 검색 실패: ${response.body}");
      return [];
    }
  }

  // 추천 식단 받아오기
  static Future<List<Recommendation>> fetchRecommendations(UserProfile profile) async {
    final url = Uri.parse('$baseUrl/recommend');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(profile.toJson()),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Recommendation.fromJson(item)).toList();
    } else {
      throw Exception("Failed to load recommendations");
    }
  }

  // UUID 기반 유저 등록
  static Future<void> registerUser(UserProfile profile) async {
    final uuid = await UUIDService.getOrCreateUUID();

    final Map<String, dynamic> jsonData = profile.toJson();
    jsonData['uuid'] = uuid;

    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(jsonData),
    );

    if (response.statusCode == 200) {
      print("✅ 유저 등록 성공");
    } else {
      print("❌ 등록 실패: ${response.body}");
    }
  }

  // 3. 유저 정보 확인
  static Future<void> getUserInfo() async {
    final uuid = await UUIDService.getOrCreateUUID();

    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: {'X-Device-ID': uuid},
    );

    if (response.statusCode == 200) {
      print("👤 사용자 정보: ${response.body}");
    } else {
      print("❌ 사용자 인증 실패: ${response.body}");
    }
  }
}
