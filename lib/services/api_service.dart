import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show compute;
import 'package:http/http.dart' as http;
import 'package:glucous_meal_app/models/models.dart';
import 'uuid_service.dart';

// ✅ 검색 결과 한 건(이름+ID)
class FoodHit {
  final String id;
  final String name;
  const FoodHit({required this.id, required this.name});
}

class FoodDetail {
  final String id;
  final String name;
  final Map<String, double>
  nutrients; // keys: calories_kcal, carbohydrate_g, ...
  final List<String> ingredients; // 식재료 리스트
  final String? imageUrl; // ✅ 추가: 이미지 URL

  FoodDetail({
    required this.id,
    required this.name,
    required this.nutrients,
    required this.ingredients,
    required this.imageUrl,
  });

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  factory FoodDetail.fromJson(Map<String, dynamic> j) {
    final rawNutrients = (j['nutrients'] as Map?) ?? const {};
    final n = <String, double>{};
    rawNutrients.forEach((k, v) {
      n[k.toString()] = _toDouble(v);
    });

    // 서버: image_url, 혹은 향후 imageUrl 로 올 수도 있으니 둘 다 체크
    final img = (j['image_url'] ?? j['imageUrl'])?.toString();
    return FoodDetail(
      id: j['food_id']?.toString() ?? '',
      name: j['food_name']?.toString() ?? '',
      nutrients: n,
      ingredients:
          (j['ingredients'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      imageUrl: (img != null && img.trim().isNotEmpty) ? img.trim() : null,
    );
  }
}

// Lightweight LRU cache for search results
class _LruCache<K, V> {
  final int capacity;
  final _map = <K, V>{};
  final _queue = <K>[];
  _LruCache(this.capacity);

  V? get(K key) {
    if (!_map.containsKey(key)) return null;
    _queue.remove(key);
    _queue.insert(0, key);
    return _map[key];
  }

  void set(K key, V value) {
    if (_map.containsKey(key)) {
      _queue.remove(key);
    } else if (_map.length >= capacity) {
      final last = _queue.removeLast();
      _map.remove(last);
    }
    _queue.insert(0, key);
    _map[key] = value;
  }
}

// ✅ 서버가 {"food_names":[...], "food_ids":[...]} 형태로 보낼 때 파싱
List<Map<String, String>> _decodeFoodPairs(String body) {
  final data = json.decode(body);
  final names = List<String>.from(data['food_names'].map((e) => e.toString()));
  final ids = List<String>.from(data['food_ids'].map((e) => e.toString()));
  final len = names.length < ids.length ? names.length : ids.length;
  return List.generate(len, (i) => {'id': ids[i], 'name': names[i]});
}

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000'; // 로컬 서버 주소
  static final http.Client _client = http.Client();

  // 공통 헤더
  static const Map<String, String> _jsonHeaders = {
    HttpHeaders.acceptHeader: 'application/json',
    HttpHeaders.acceptEncodingHeader: 'gzip',
    HttpHeaders.connectionHeader: 'keep-alive',
  };

  // 공통 GET (timeout, headers 통일)
  static Future<http.Response> _get(Uri uri, {required Duration timeout}) {
    return _client.get(uri, headers: _jsonHeaders).timeout(timeout);
  }

  // Simple in-memory cache
  static final _LruCache<String, List<FoodHit>> _searchCacheHits = _LruCache(
    50,
  );
  static int _searchToken = 0;

  // 상세 캐시
  static final Map<String, FoodDetail> _foodDetailCache = {};

  // ✅ 상세 조회 (이미지 포함)
  static Future<FoodDetail> fetchFoodDetail(
    String foodId, {
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final cached = _foodDetailCache[foodId];
    if (cached != null) return cached;

    final uri = Uri.parse(
      '$baseUrl/food',
    ).replace(queryParameters: {'food_id': foodId});
    final resp = await _get(uri, timeout: timeout);

    if (resp.statusCode != 200 || resp.body.isEmpty) {
      throw Exception('Failed to fetch food detail: ${resp.statusCode}');
    }

    // utf8 안전 디코딩
    final Map<String, dynamic> data = json.decode(utf8.decode(resp.bodyBytes));
    final detail = FoodDetail.fromJson(data);

    _foodDetailCache[foodId] = detail;
    return detail;
  }

  // ✅ 이름+ID를 함께 반환 (최적화 유지)
  static Future<List<FoodHit>> searchFoodsWithIds(
    String query, {
    Duration timeout = const Duration(seconds: 6),
  }) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return const [];

    // 1) cache hit
    final cached = _searchCacheHits.get(trimmed);
    if (cached != null) return cached;

    // 2) fire request (with token to drop stale)
    final myToken = ++_searchToken;
    final uri = Uri.parse(
      '$baseUrl/search',
    ).replace(queryParameters: {'query': trimmed});

    late http.Response resp;
    try {
      resp = await _get(uri, timeout: timeout);
    } on TimeoutException {
      return const [];
    } on SocketException {
      return const [];
    }

    if (myToken != _searchToken) {
      // A newer request was issued; ignore this response
      return const [];
    }

    if (resp.statusCode != 200 || resp.body.isEmpty) {
      return const [];
    }

    // 3) offload JSON decoding off the UI thread
    final List<Map<String, String>> raw = await compute(
      _decodeFoodPairs,
      resp.body,
    );

    // 4) to model
    final hits = raw
        .map((m) => FoodHit(id: m['id']!, name: m['name']!))
        .toList(growable: false);

    // 5) cache & return
    _searchCacheHits.set(trimmed, hits);
    return hits;
  }

  // ✅ 기존 메서드는 유지(호환성). 내부적으로 새 메서드 호출해 이름만 반환
  static Future<List<String>> searchFoods(
    String query, {
    Duration timeout = const Duration(seconds: 6),
  }) async {
    final hits = await searchFoodsWithIds(query, timeout: timeout);
    return hits.map((h) => h.name).toList(growable: false);
  }

  // 추천 식단 받아오기
  static Future<List<Recommendation>> fetchRecommendations(
    UserProfile profile,
  ) async {
    final url = Uri.parse('$baseUrl/recommend');

    final response = await _client.post(
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

    final response = await _client.post(
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

  // 유저 정보 확인
  static Future<void> getUserInfo() async {
    final uuid = await UUIDService.getOrCreateUUID();

    final response = await _client.get(
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
