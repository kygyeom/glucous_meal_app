import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:glucous_meal_app/models/models.dart';

Future<List<Recommendation>> fetchRecommendations(UserProfile profile) async {
  final url = Uri.parse("http://127.0.0.1:8000/recommend");

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(profile.toJson()),
  );

  print('🔵 statusCode: ${response.statusCode}');
  print('📦 response.body: ${response.body}');

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((item) => Recommendation.fromJson(item)).toList();
  } else {
    throw Exception("Failed to load recommendations");
  }
}
