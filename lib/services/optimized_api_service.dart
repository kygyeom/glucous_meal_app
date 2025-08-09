import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show compute;
import 'package:http/http.dart' as http;

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

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  // Reuse a single HTTP client for connection pooling + keep-alive
  static final http.Client _client = http.Client();

  // Simple in-memory cache (stores last ~50 queries)
  static final _LruCache<String, List<String>> _searchCache = _LruCache(50);

  // Cancel-stale-requests: track the latest token
  static int _searchToken = 0;

  static Future<List<String>> searchFoods(
    String query, {
    Duration timeout = const Duration(seconds: 6),
  }) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return const [];

    // 1) cache hit
    final cached = _searchCache.get(trimmed);
    if (cached != null) return cached;

    // 2) fire request (with token to drop stale)
    final myToken = ++_searchToken;
    final uri = Uri.parse(
      '$baseUrl/search',
    ).replace(queryParameters: {'query': trimmed});
    final headers = {
      HttpHeaders.acceptHeader: 'application/json',
      HttpHeaders.acceptEncodingHeader: 'gzip',
      HttpHeaders.connectionHeader: 'keep-alive',
    };

    late http.Response resp;
    try {
      resp = await _client.get(uri, headers: headers).timeout(timeout);
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
    final List<dynamic> decoded = await compute(_decodeJsonList, resp.body);
    final List<String> items = decoded
        .map((e) => e.toString())
        .toList(growable: false);

    // 4) cache & return
    _searchCache.set(trimmed, items);
    return items;
  }
}
