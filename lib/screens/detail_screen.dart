import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../constants.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../models/comment.dart';
import '../services/comment_service.dart';
import '../services/local_storage_service.dart';
import '../widgets/custom_font.dart';

/// Enhancement 3: renders every comment for this specific post
/// (https://dummyjson.com/docs/comments#comments-post), lets the user
/// like the post and individual comments, and add new comments — all
/// persisted locally since dummyjson doesn't actually save writes.
class DetailScreen extends StatefulWidget {
  final Post post;
  final User author;
  final User currentUser;

  const DetailScreen({
    super.key,
    required this.post,
    required this.author,
    required this.currentUser,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool isLiked = false;
  int likesCount = 0;

  List<Comment> _comments = [];
  Set<int> _likedCommentIds = {};
  bool _isLoadingComments = true;
  String? _commentsError;

  final TextEditingController _commentController = TextEditingController();
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    likesCount = widget.post.likes;
    _loadLikeState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadLikeState() async {
    final liked = await LocalStorageService.isPostLiked(widget.post.id);
    if (!mounted) return;
    setState(() {
      isLiked = liked;
      likesCount = widget.post.likes + (liked ? 1 : 0);
    });
  }

  Future<void> _toggleLike() async {
    final nowLiked = await LocalStorageService.togglePostLike(widget.post.id);
    if (!mounted) return;
    setState(() {
      isLiked = nowLiked;
      likesCount = widget.post.likes + (nowLiked ? 1 : 0);
    });
  }

  /// Loads remote comments filtered by this post's id, merges in any
  /// comments added locally by the user, and restores which comments
  /// they've liked.
  Future<void> _loadComments() async {
    setState(() {
      _isLoadingComments = true;
      _commentsError = null;
    });
    try {
      final remote = await CommentService.getCommentsByPost(widget.post.id);
      final local = await LocalStorageService.getLocalComments(widget.post.id);
      final liked = await LocalStorageService.getLikedCommentIds();
      if (!mounted) return;
      setState(() {
        // Filtration: only comments for THIS post — already guaranteed by
        // the /comments/post/{id} endpoint and the local per-post store,
        // but double-checked here for safety.
        _comments = [
          ...remote.where((c) => c.postId == widget.post.id),
          ...local.where((c) => c.postId == widget.post.id),
        ];
        _likedCommentIds = liked;
        _isLoadingComments = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _commentsError = 'Could not load comments. $e';
        _isLoadingComments = false;
      });
    }
  }

  Future<void> _toggleCommentLike(Comment comment) async {
    final nowLiked = await LocalStorageService.toggleCommentLike(comment.id);
    if (!mounted) return;
    setState(() {
      if (nowLiked) {
        _likedCommentIds.add(comment.id);
      } else {
        _likedCommentIds.remove(comment.id);
      }
    });
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isPosting = true);

    // Fire-and-forget the documented endpoint for realism (it won't
    // persist server-side), and save the real, persistent copy locally.
    await CommentService.addCommentRemote(
      postId: widget.post.id,
      userId: widget.currentUser.id,
      body: text,
    );

    final saved = await LocalStorageService.addLocalComment(
      postId: widget.post.id,
      body: text,
      author: CommentAuthor(
        id: widget.currentUser.id,
        username: widget.currentUser.username,
        fullName: widget.currentUser.fullName,
      ),
    );

    if (!mounted) return;
    setState(() {
      _comments = [..._comments, saved];
      _commentController.clear();
      _isPosting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textColor = primaryTextColor(context);

    return Scaffold(
      backgroundColor: bgColor(context),
      appBar: AppBar(title: const Text('Post'), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(ScreenUtil().setSp(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Author row
                    Row(
                      children: [
                        CircleAvatar(
                          radius: ScreenUtil().setSp(18),
                          backgroundColor: Colors.grey[300],
                          backgroundImage: widget.author.image != null
                              ? CachedNetworkImageProvider(widget.author.image!)
                              : null,
                          child: widget.author.image == null
                              ? Icon(
                                  Icons.person,
                                  size: ScreenUtil().setSp(18),
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        SizedBox(width: ScreenUtil().setWidth(10)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomFont(
                              text: widget.author.fullName,
                              fontSize: ScreenUtil().setSp(15),
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            Row(
                              children: [
                                CustomFont(
                                  text: widget.post.tags.isNotEmpty
                                      ? widget.post.tags.join(', ')
                                      : 'post',
                                  fontSize: ScreenUtil().setSp(12),
                                  color: secondaryTextColor(context),
                                ),
                                SizedBox(width: ScreenUtil().setWidth(3)),
                                Icon(
                                  Icons.public,
                                  color: const Color.fromARGB(
                                    255,
                                    135,
                                    153,
                                    182,
                                  ),
                                  size: ScreenUtil().setSp(15),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: ScreenUtil().setHeight(10)),

                    CustomFont(
                      text: widget.post.title,
                      fontSize: ScreenUtil().setSp(16),
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    SizedBox(height: ScreenUtil().setHeight(5)),
                    CustomFont(
                      text: widget.post.body,
                      fontSize: ScreenUtil().setSp(13),
                      color: textColor,
                    ),

                    SizedBox(height: ScreenUtil().setHeight(10)),

                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: _toggleLike,
                          child: Row(
                            children: [
                              Icon(
                                isLiked
                                    ? Icons.thumb_up
                                    : Icons.thumb_up_outlined,
                                color: const Color.fromARGB(255, 14, 108, 185),
                                size: 18.sp,
                              ),
                              SizedBox(width: 4.w),
                              CustomFont(
                                text: likesCount.toString(),
                                fontSize: 12.sp,
                                color: const Color.fromARGB(255, 14, 108, 185),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.comment_outlined,
                              size: 18.sp,
                              color: textColor,
                            ),
                            SizedBox(width: 4.w),
                            CustomFont(
                              text: '${_comments.length} comments',
                              fontSize: 12.sp,
                              color: textColor,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.remove_red_eye_outlined,
                              size: 18.sp,
                              color: textColor,
                            ),
                            SizedBox(width: 4.w),
                            CustomFont(
                              text: '${widget.post.views}',
                              fontSize: 12.sp,
                              color: textColor,
                            ),
                          ],
                        ),
                      ],
                    ),

                    Divider(color: secondaryTextColor(context)),

                    CustomFont(
                      text: 'Comments',
                      fontSize: ScreenUtil().setSp(14),
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    SizedBox(height: ScreenUtil().setHeight(8)),

                    _buildCommentsList(textColor),
                  ],
                ),
              ),
            ),
          ),

          // Comment input pinned at the bottom
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(10),
                vertical: ScreenUtil().setHeight(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: ScreenUtil().setSp(15),
                    backgroundColor: Colors.grey[300],
                    backgroundImage: widget.currentUser.image != null
                        ? CachedNetworkImageProvider(widget.currentUser.image!)
                        : null,
                    child: widget.currentUser.image == null
                        ? Icon(
                            Icons.person,
                            size: ScreenUtil().setSp(15),
                            color: Colors.white,
                          )
                        : null,
                  ),
                  SizedBox(width: ScreenUtil().setWidth(10)),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        hintStyle: TextStyle(
                          color: secondaryTextColor(context),
                        ),
                        filled: true,
                        fillColor: isDark(context)
                            ? Colors.white10
                            : Colors.grey[200],
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setSp(12),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            ScreenUtil().setSp(20),
                          ),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _submitComment(),
                    ),
                  ),
                  SizedBox(width: ScreenUtil().setWidth(6)),
                  _isPosting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send, color: FB_DARK_PRIMARY),
                          onPressed: _submitComment,
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList(Color textColor) {
    if (_isLoadingComments) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_commentsError != null) {
      return Column(
        children: [
          Text(_commentsError!, style: TextStyle(color: textColor)),
          TextButton(onPressed: _loadComments, child: const Text('Retry')),
        ],
      );
    }
    if (_comments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'No comments yet. Be the first to comment!',
          style: TextStyle(color: secondaryTextColor(context)),
        ),
      );
    }

    return Column(
      children: _comments.map((comment) {
        final liked = _likedCommentIds.contains(comment.id);
        final likeCount = comment.likes + (liked ? 1 : 0);
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 6.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 15.sp,
                backgroundColor: FB_DARK_PRIMARY,
                child: Text(
                  comment.user.fullName.isNotEmpty
                      ? comment.user.fullName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.sp,
                    vertical: 8.sp,
                  ),
                  decoration: BoxDecoration(
                    color: isDark(context) ? Colors.white10 : Colors.grey[100],
                    borderRadius: BorderRadius.circular(10.sp),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CustomFont(
                            text: comment.user.fullName,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          if (comment.isLocal) ...[
                            SizedBox(width: 6.w),
                            CustomFont(
                              text: '(you)',
                              fontSize: 10.sp,
                              color: secondaryTextColor(context),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 3.h),
                      CustomFont(
                        text: comment.body,
                        fontSize: 12.sp,
                        color: textColor,
                      ),
                      SizedBox(height: 5.h),
                      GestureDetector(
                        onTap: () => _toggleCommentLike(comment),
                        child: Row(
                          children: [
                            Icon(
                              liked ? Icons.thumb_up : Icons.thumb_up_outlined,
                              size: 14.sp,
                              color: FB_DARK_PRIMARY,
                            ),
                            SizedBox(width: 4.w),
                            CustomFont(
                              text: '$likeCount',
                              fontSize: 11.sp,
                              color: FB_DARK_PRIMARY,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
