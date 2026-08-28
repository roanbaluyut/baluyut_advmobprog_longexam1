import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/user.dart';

class UserResult {
  final User? user;
  final String? error;
  UserResult.success(this.user) : error = null;
  UserResult.failure(this.error) : user = null;
}

class UserService {
  /// POST https://dummyjson.com/user/login
  /// (see https://dummyjson.com/docs/users#users-login)
  static Future<UserResult> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$API_BASE_URL/user/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'expiresInMins': 60,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        var user = User.fromJson(json);

        // Enrich with the full profile (address, phone, university, etc.)
        final full = await getUserById(user.id);
        if (full.user != null) {
          user = user.copyWith(full.user!);
        }
        return UserResult.success(user);
      } else {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return UserResult.failure(
          json['message']?.toString() ?? 'Invalid username or password',
        );
      }
    } catch (e) {
      return UserResult.failure('Could not reach the server. $e');
    }
  }

  /// GET https://dummyjson.com/users/{id}
  static Future<UserResult> getUserById(int id) async {
    try {
      final response = await http.get(Uri.parse('$API_BASE_URL/users/$id'));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return UserResult.success(User.fromJson(json));
      }
      return UserResult.failure('User not found');
    } catch (e) {
      return UserResult.failure('Could not reach the server. $e');
    }
  }

  /// GET https://dummyjson.com/users?limit=0&select=...
  /// Fetches every user (used to resolve a post's author name/avatar
  /// without firing one request per post).
  static Future<Map<int, User>> getAllUsersMap() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$API_BASE_URL/users?limit=0&select=id,firstName,lastName,username,image',
        ),
      );
      if (response.statusCode != 200) return {};
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final users = (json['users'] as List<dynamic>)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList();
      return {for (final u in users) u.id: u};
    } catch (_) {
      return {};
    }
  }

  /// POST https://dummyjson.com/users/add
  /// dummyjson does not persist this, it just echoes back a "created" user.
  static Future<UserResult> addUser({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$API_BASE_URL/users/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'username': username,
          'email': email,
          'password': password,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return UserResult.success(User.fromJson(json));
      }
      return UserResult.failure('Registration failed');
    } catch (e) {
      return UserResult.failure('Could not reach the server. $e');
    }
  }
}
