import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/user_model.dart';
import '../utils/app_constants.dart';

class Paged<T> {
  final List<T> items;
  final int page;
  final int limit;
  final int total;
  Paged({required this.items, required this.page, required this.limit, required this.total});
}

typedef TokenGetter = Future<String?> Function();

class UserService {
  final TokenGetter getAccessToken;
  final Duration timeout;
  UserService({required this.getAccessToken, this.timeout = const Duration(seconds: 20)});

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = AppConstants.baseUrl;
    final uri = Uri.parse('$base$path');
    if (query == null || query.isEmpty) return uri;
    return uri.replace(queryParameters: {...uri.queryParameters, ...query});
  }

  Future<Map<String, String>> _headers() async {
    final token = await getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  dynamic _decode(http.Response r) => r.body.isEmpty ? null : jsonDecode(r.body);

  Exception _httpError(http.Response r, [dynamic data]) {
    final msg = (data is Map && data['message'] != null)
        ? data['message'].toString()
        : 'HTTP ${r.statusCode}';
    return Exception(msg);
  }

  // ------------------ SELF ------------------

  Future<UserModel> getMe() async {
    final res = await http.get(_uri(UsersApi.me), headers: await _headers()).timeout(timeout);
    final data = _decode(res);

    if (res.statusCode == 200) {
      final payload = (data is Map && data['data'] != null) ? data['data'] : data;
      return UserModel.fromJson((payload ?? {}) as Map<String, dynamic>);
    }
    throw _httpError(res, data);
  }

  Future<UserModel> updateMe(Map<String, dynamic> patch) async {
    patch.remove('role');
    patch.remove('isVerified');
    final res = await http
        .patch(_uri(UsersApi.me), headers: await _headers(), body: jsonEncode(patch))
        .timeout(timeout);
    final data = _decode(res);
    if (res.statusCode == 200) {
      final payload = (data is Map && data['data'] != null) ? data['data'] : data;
      return UserModel.fromJson((payload ?? {}) as Map<String, dynamic>);
    }
    throw _httpError(res, data);
  }

  Future<void> deleteMeSoft() async {
    final res = await http.delete(_uri(UsersApi.me), headers: await _headers()).timeout(timeout);
    if (res.statusCode == 200 || res.statusCode == 204) return;
    final data = _decode(res);
    throw _httpError(res, data);
  }

  // ------------------ ADMIN ------------------

  Future<UserModel> createUser(Map<String, dynamic> body) async {
    final res = await http
        .post(_uri(UsersApi.users), headers: await _headers(), body: jsonEncode(body))
        .timeout(timeout);
    final data = _decode(res);
    if (res.statusCode == 201 || res.statusCode == 200) {
      final payload = (data is Map && data['data'] != null) ? data['data'] : data;
      return UserModel.fromJson((payload ?? {}) as Map<String, dynamic>);
    }
    throw _httpError(res, data);
  }

  Future<Paged<UserModel>> listUsers(UserQuery query) async {
    final res = await http
        .get(_uri(UsersApi.users, query.toQuery()), headers: await _headers())
        .timeout(timeout);
    final data = _decode(res);
    if (res.statusCode == 200) {
      if (data is Map && data['data'] is List) {
        final items = UserModel.listFrom(data['data']);
        final meta = data['meta'] as Map<String, dynamic>? ?? {};
        return Paged<UserModel>(
          items: items,
          page: (meta['page'] ?? query.page) as int,
          limit: (meta['limit'] ?? query.limit) as int,
          total: (meta['total'] ?? items.length) as int,
        );
      }
      if (data is List) {
        final items = UserModel.listFrom(data);
        return Paged<UserModel>(items: items, page: query.page, limit: query.limit, total: items.length);
      }
    }
    throw _httpError(res, data);
  }

  Future<List<UserModel>> listDeletedUsers() async {
    final res = await http.get(_uri(UsersApi.deletedAll), headers: await _headers()).timeout(timeout);
    final data = _decode(res);
    if (res.statusCode == 200) {
      final payload = (data is Map && data['data'] is List) ? data['data'] : data;
      return UserModel.listFrom(payload);
    }
    throw _httpError(res, data);
  }

  Future<UserModel> getUserById(String id) async {
    final res = await http.get(_uri(UsersApi.byId(id)), headers: await _headers()).timeout(timeout);
    final data = _decode(res);
    if (res.statusCode == 200) {
      final payload = (data is Map && data['data'] != null) ? data['data'] : data;
      return UserModel.fromJson((payload ?? {}) as Map<String, dynamic>);
    }
    throw _httpError(res, data);
  }

  Future<UserModel> updateUserById(String id, Map<String, dynamic> patch) async {
    final res = await http
        .patch(_uri(UsersApi.byId(id)), headers: await _headers(), body: jsonEncode(patch))
        .timeout(timeout);
    final data = _decode(res);
    if (res.statusCode == 200) {
      final payload = (data is Map && data['data'] != null) ? data['data'] : data;
      return UserModel.fromJson((payload ?? {}) as Map<String, dynamic>);
    }
    throw _httpError(res, data);
  }

  Future<void> deleteUserSoft(String id) async {
    final res = await http.delete(_uri(UsersApi.byId(id)), headers: await _headers()).timeout(timeout);
    if (res.statusCode == 200 || res.statusCode == 204) return;
    final data = _decode(res);
    throw _httpError(res, data);
  }

  Future<UserModel> restoreUser(String id) async {
    final res = await http.patch(_uri(UsersApi.restore(id)), headers: await _headers()).timeout(timeout);
    final data = _decode(res);
    if (res.statusCode == 200) {
      final payload = (data is Map && data['data'] != null) ? data['data'] : data;
      return UserModel.fromJson((payload ?? {}) as Map<String, dynamic>);
    }
    throw _httpError(res, data);
  }

  Future<void> deleteUserHard(String id) async {
    final res =
    await http.delete(_uri(UsersApi.hardDelete(id)), headers: await _headers()).timeout(timeout);
    if (res.statusCode == 200 || res.statusCode == 204) return;
    final data = _decode(res);
    throw _httpError(res, data);
  }
}