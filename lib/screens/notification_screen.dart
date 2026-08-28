import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../services/post_service.dart';
import '../services/user_service.dart';
import '../services/local_storage_service.dart';
import '../widgets/custom_info.dart';
import 'detail_screen.dart';

/// Notifications are built from real recent posts (dummyjson) so each one
/// is genuinely clickable: tapping a notification opens that post's real
/// DetailScreen — same as tapping the post in the newsfeed — with working
/// likes and comments underneath.
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _isLoading = true;
  String? _error;
  List<Post> _posts = [];
  Map<int, User> _usersById = {};
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final currentUser = await LocalStorageService.getSession();
      final page = await PostService.getPosts(limit: 15, skip: 0);
      final usersById = await UserService.getAllUsersMap();

      if (!mounted) return;
      setState(() {
        _currentUser = currentUser;
        _posts = page.posts;
        _usersById = usersById;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load notifications: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dividerColor = secondaryTextColor(context);

    return Scaffold(
      backgroundColor: bgColor(context),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? ListView(
                children: [
                  SizedBox(height: 100.h),
                  Center(child: Text(_error!)),
                ],
              )
            : ListView.separated(
                padding: EdgeInsets.all(10.w),
                itemCount: _posts.length,
                separatorBuilder: (_, __) => Divider(color: dividerColor),
                itemBuilder: (context, index) {
                  final post = _posts[index];
                  final author = _usersById[post.userId];
                  final authorName = author != null
                      ? '${author.firstName} ${author.lastName}'
                      : 'User #${post.userId}';

                  return CustomInfo(
                    name: authorName,
                    post: 'shared a new post',
                    description: post.body.length > 80
                        ? '${post.body.substring(0, 80)}...'
                        : post.body,
                    date: 'Post #${post.id} · ${post.views} views',
                    numOfLikes: post.likes,
                    profileImageUrl: author?.image,
                    onTap: () {
                      if (author == null || _currentUser == null) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(
                            post: post,
                            author: author,
                            currentUser: _currentUser!,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
