class CommentAuthor {
  final int id;
  final String username;
  final String fullName;

  CommentAuthor({
    required this.id,
    required this.username,
    required this.fullName,
  });

  factory CommentAuthor.fromJson(Map<String, dynamic> json) {
    return CommentAuthor(
      id: json['id'] as int,
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'fullName': fullName,
  };
}

class Comment {
  final int id;
  final String body;
  final int postId;
  final int likes;
  final CommentAuthor user;

  /// True when this comment was added locally by the current user
  /// (dummyjson doesn't actually persist new comments server-side).
  final bool isLocal;

  Comment({
    required this.id,
    required this.body,
    required this.postId,
    required this.likes,
    required this.user,
    this.isLocal = false,
  });

  factory Comment.fromJson(Map<String, dynamic> json, {bool isLocal = false}) {
    return Comment(
      id: json['id'] as int,
      body: json['body'] ?? '',
      postId: json['postId'] as int,
      likes: json['likes'] ?? 0,
      user: CommentAuthor.fromJson(json['user'] as Map<String, dynamic>),
      isLocal: isLocal,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'body': body,
    'postId': postId,
    'likes': likes,
    'user': user.toJson(),
  };
}
