import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService userService;

  UserProvider({required this.userService});

  // ---- state ----
  UserModel? _me;
  bool _loading = false;
  String? _error;

  // admin lists
  List<UserModel> _users = [];
  int _page = 1, _limit = 20, _total = 0;

  List<UserModel> _deletedUsers = [];

  // ---- getters ----
  UserModel? get me => _me;
  bool get isLoading => _loading;
  String? get error => _error;

  List<UserModel> get users => _users;
  int get page => _page;
  int get limit => _limit;
  int get total => _total;
  List<UserModel> get deletedUsers => _deletedUsers;

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void _setError(String? e) {
    _error = e;
    notifyListeners();
  }

  // ------------------ SELF ------------------

  Future<void> fetchMe() async {
    try {
      _setLoading(true);
      _setError(null);
      _me = await userService.getMe();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateMe(Map<String, dynamic> patch) async {
    try {
      _setLoading(true);
      _setError(null);
      final updated = await userService.updateMe(patch);
      _me = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteMeSoft() async {
    try {
      _setLoading(true);
      _setError(null);
      await userService.deleteMeSoft();
      // tuỳ UX: có thể set _me = _me.copyWith(deletedAt: DateTime.now());
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ------------------ ADMIN ------------------

  Future<bool> createUser(Map<String, dynamic> body) async {
    try {
      _setLoading(true);
      _setError(null);
      final _ = await userService.createUser(body);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchUsers(UserQuery query) async {
    try {
      _setLoading(true);
      _setError(null);
      final pageResp = await userService.listUsers(query);
      _users = pageResp.items;
      _page = pageResp.page;
      _limit = pageResp.limit;
      _total = pageResp.total;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<UserModel?> fetchUserById(String id) async {
    try {
      _setLoading(true);
      _setError(null);
      return await userService.getUserById(id);
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }
  Future<bool> updateUserById(String id, Map<String, dynamic> patch) async {
    try {
      _setLoading(true);
      _setError(null);
      final updated = await userService.updateUserById(id, patch);
      // sync list nếu có:
      final idx = _users.indexWhere((u) => u.id == id);
      if (idx >= 0) {
        _users[idx] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteUserSoft(String id) async {
    try {
      _setLoading(true);
      _setError(null);
      await userService.deleteUserSoft(id);
      _users.removeWhere((u) => u.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> restoreUser(String id) async {
    try {
      _setLoading(true);
      _setError(null);
      final restored = await userService.restoreUser(id);
      // nếu đang ở list deleted -> bỏ ra; nếu ở list active -> update
      _deletedUsers.removeWhere((u) => u.id == id);
      final idx = _users.indexWhere((u) => u.id == id);
      if (idx >= 0) _users[idx] = restored;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteUserHard(String id) async {
    try {
      _setLoading(true);
      _setError(null);
      await userService.deleteUserHard(id);
      _users.removeWhere((u) => u.id == id);
      _deletedUsers.removeWhere((u) => u.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchDeletedUsers() async {
    try {
      _setLoading(true);
      _setError(null);
      _deletedUsers = await userService.listDeletedUsers();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
}