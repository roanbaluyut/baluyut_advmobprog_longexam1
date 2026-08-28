import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/post.dart';

class PostPage {
  final List<Post> posts;
  final int total;
  final int skip;
  final int limit;
  PostPage({
    required this.posts,
    required this.total,
    required this.skip,
    required this.limit,
  });

  bool get hasMore => skip + limit < total;
}

class PostService {
  /// GET https://dummyjson.com/posts?limit=&skip=
  /// Newsfeed always loads at least 30 posts per page, and callers can
  /// keep paginating past 30 as the user scrolls.
  static Future<PostPage> getPosts({int limit = 30, int skip = 0}) async {
    final response = await http.get(
      Uri.parse('$API_BASE_URL/posts?limit=$limit&skip=$skip'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load posts');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final posts = (json['posts'] as List<dynamic>)
        .map((e) => Post.fromJson(e as Map<String, dynamic>))
        .toList();
    return PostPage(
      posts: posts,
      total: json['total'] as int,
      skip: json['skip'] as int,
      limit: json['limit'] as int,
    );
  }

  /// GET https://dummyjson.com/posts/user/{userId}
  /// Used on the profile screen to show only the logged-in user's posts.
  static Future<List<Post>> getPostsByUser(int userId) async {
    final response = await http.get(
      Uri.parse('$API_BASE_URL/posts/user/$userId'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load posts for user $userId');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return (json['posts'] as List<dynamic>)
        .map((e) => Post.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET https://dummyjson.com/posts/{id}
  static Future<Post> getPostById(int id) async {
    final response = await http.get(Uri.parse('$API_BASE_URL/posts/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load post $id');
    }
    return Post.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
