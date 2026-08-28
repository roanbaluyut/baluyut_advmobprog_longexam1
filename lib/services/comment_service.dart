import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/comment.dart';

class CommentService {
  /// GET https://dummyjson.com/comments/post/{postId}
  /// Comments are always filtered so only the ones belonging to this
  /// specific post are returned/rendered.
  static Future<List<Comment>> getCommentsByPost(int postId) async {
    final response = await http.get(
      Uri.parse('$API_BASE_URL/comments/post/$postId'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load comments for post $postId');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return (json['comments'] as List<dynamic>)
        .map((e) => Comment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST https://dummyjson.com/comments/add
  /// dummyjson simulates the add and does not persist it server-side, so
  /// the caller is responsible for also saving it locally (see
  /// LocalStorageService.addLocalComment) so it survives app restarts.
  static Future<void> addCommentRemote({
    required int postId,
    required int userId,
    required String body,
  }) async {
    try {
      await http.post(
        Uri.parse('$API_BASE_URL/comments/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'body': body, 'postId': postId, 'userId': userId}),
      );
    } catch (_) {
      // Non-fatal: the comment is still saved locally regardless.
    }
  }
}
