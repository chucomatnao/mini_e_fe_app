import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../utils/app_constants.dart';
import 'api_client.dart'; // THÊM

class UserQuery {
  final int page;
  final int limit;
  final String? search;
  final String? role;
  final bool? isVerified;

  UserQuery({
    this.page = 1,
    this.limit = 20,
    this.search,
    this.role,
    this.isVerified,
  });

  Map<String, String> toQuery() {
    final map = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (search != null && search!.isNotEmpty) map['search'] = search!;
    if (role != null && role!.isNotEmpty) map['role'] = role!;
    if (isVerified != null) map['isVerified'] = isVerified.toString();
    return map;
  }
}

class Paged<T> {
  final List<T> items;
  final int page;
  final int limit;
  final int total;
  Paged({required this.items, required this.page, required this.limit, required this.total});
}

class UserService {
  final Dio _dio = ApiClient().dio;

  Future<UserModel> getMe() async {
    final res = await _dio.get(UsersApi.me);
    return UserModel.fromJson(res.data['data']);
  }

  Future<UserModel> updateMe(Map<String, dynamic> patch) async {
    patch.remove('role');
    patch.remove('isVerified');
    final res = await _dio.patch(UsersApi.me, data: patch);
    return UserModel.fromJson(res.data['data']);
  }

  Future<void> deleteMeSoft() async {
    await _dio.delete(UsersApi.me);
  }

  Future<Paged<UserModel>> listUsers(UserQuery query) async {
    final res = await _dio.get(UsersApi.users, queryParameters: query.toQuery());
    final data = res.data;
    final items = UserModel.listFrom(data['data'] ?? []);
    final meta = data['meta'] ?? {};
    return Paged<UserModel>(
      items: items,
      page: query.page,
      limit: query.limit,
      total: meta['total'] ?? items.length,
    );
  }

  Future<List<UserModel>> listDeletedUsers() async {
    final res = await _dio.get(UsersApi.deletedAll);
    return UserModel.listFrom(res.data['data'] ?? []);
  }

  Future<UserModel> getUserById(String id) async {
    final res = await _dio.get(UsersApi.byId(id));
    return UserModel.fromJson(res.data['data']);
  }

  Future<UserModel> updateUserById(String id, Map<String, dynamic> patch) async {
    final res = await _dio.patch(UsersApi.byId(id), data: patch);
    return UserModel.fromJson(res.data['data']);
  }

  Future<void> deleteUserSoft(String id) async {
    await _dio.delete(UsersApi.byId(id));
  }

  Future<UserModel> restoreUser(String id) async {
    final res = await _dio.patch(UsersApi.restore(id));
    return UserModel.fromJson(res.data['data']);
  }

  Future<void> deleteUserHard(String id) async {
    await _dio.delete(UsersApi.hardDelete(id));
  }

  Future<UserModel> createUser(Map<String, dynamic> body) async {
    final res = await _dio.post(UsersApi.users, data: body);
    return UserModel.fromJson(res.data['data']);
  }
}