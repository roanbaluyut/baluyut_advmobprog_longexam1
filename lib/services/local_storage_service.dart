import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/comment.dart';

/// Centralizes every shared_preferences read/write used across the app:
/// - the logged in user's session (Enhancement 1)
/// - the theme mode (light/dark)
/// - liked posts & liked comments (Enhancement 3)
/// - comments added locally by the user (Enhancement 3)
class LocalStorageService {
  static const _kIsLoggedIn = 'isLoggedIn';
  static const _kSessionUser = 'session_user';
  static const _kIsDarkMode = 'isDarkMode';
  static const _kLikedPosts = 'liked_posts';
  static const _kLikedComments = 'liked_comments';
  static const _kLocalComments = 'local_comments';
  static const _kLocalCommentSeq = 'local_comment_seq';

  /// -------------------------------------------------------------------
  /// Session (Enhancement 1)
  /// -------------------------------------------------------------------
  static Future<void> saveSession(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsLoggedIn, true);
    await prefs.setString(_kSessionUser, jsonEncode(user.toJson()));
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kIsLoggedIn) ?? false;
  }

  static Future<User?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kSessionUser);
    if (raw == null) return null;
    return User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsLoggedIn, false);
    await prefs.remove(_kSessionUser);
  }

  /// -------------------------------------------------------------------
  /// Theme
  /// -------------------------------------------------------------------
  static Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kIsDarkMode) ?? false;
  }

  static Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsDarkMode, value);
  }

  /// -------------------------------------------------------------------
  /// Liked posts
  /// -------------------------------------------------------------------
  static Future<Set<int>> getLikedPostIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kLikedPosts) ?? [];
    return list.map(int.parse).toSet();
  }

  static Future<bool> isPostLiked(int postId) async {
    final liked = await getLikedPostIds();
    return liked.contains(postId);
  }

  /// Returns the new liked state (true = now liked).
  static Future<bool> togglePostLike(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final liked = await getLikedPostIds();
    final nowLiked = !liked.contains(postId);
    if (nowLiked) {
      liked.add(postId);
    } else {
      liked.remove(postId);
    }
    await prefs.setStringList(
      _kLikedPosts,
      liked.map((e) => e.toString()).toList(),
    );
    return nowLiked;
  }

  /// -------------------------------------------------------------------
  /// Liked comments
  /// -------------------------------------------------------------------
  static Future<Set<int>> getLikedCommentIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kLikedComments) ?? [];
    return list.map(int.parse).toSet();
  }

  static Future<bool> isCommentLiked(int commentId) async {
    final liked = await getLikedCommentIds();
    return liked.contains(commentId);
  }

  static Future<bool> toggleCommentLike(int commentId) async {
    final prefs = await SharedPreferences.getInstance();
    final liked = await getLikedCommentIds();
    final nowLiked = !liked.contains(commentId);
    if (nowLiked) {
      liked.add(commentId);
    } else {
      liked.remove(commentId);
    }
    await prefs.setStringList(
      _kLikedComments,
      liked.map((e) => e.toString()).toList(),
    );
    return nowLiked;
  }

  /// -------------------------------------------------------------------
  /// Locally-added comments, keyed by postId
  /// -------------------------------------------------------------------
  static Future<Map<String, dynamic>> _readLocalCommentsMap() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kLocalComments);
    if (raw == null) return {};
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<void> _writeLocalCommentsMap(Map<String, dynamic> map) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocalComments, jsonEncode(map));
  }

  static Future<List<Comment>> getLocalComments(int postId) async {
    final map = await _readLocalCommentsMap();
    final list = (map[postId.toString()] as List<dynamic>?) ?? [];
    return list
        .map(
          (e) => Comment.fromJson(e as Map<String, dynamic>, isLocal: true),
        )
        .toList();
  }

  static Future<int> _nextLocalCommentId() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_kLocalCommentSeq) ?? 1000000;
    final next = current + 1;
    await prefs.setInt(_kLocalCommentSeq, next);
    return next;
  }

  static Future<Comment> addLocalComment({
    required int postId,
    required String body,
    required CommentAuthor author,
  }) async {
    final id = await _nextLocalCommentId();
    final comment = Comment(
      id: id,
      body: body,
      postId: postId,
      likes: 0,
      user: author,
      isLocal: true,
    );

    final map = await _readLocalCommentsMap();
    final list = (map[postId.toString()] as List<dynamic>?) ?? [];
    list.add(comment.toJson());
    map[postId.toString()] = list;
    await _writeLocalCommentsMap(map);

    return comment;
  }
}
