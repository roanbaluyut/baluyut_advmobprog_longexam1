import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../services/post_service.dart';
import '../services/user_service.dart';
import '../widgets/post_card.dart';

/// Enhancement 2 / general requirement: renders posts straight from
/// https://dummyjson.com/docs/posts, loading 30 at a time and fetching
/// more as the user scrolls past them ("render post 30 pataas").
class NewsFeedScreen extends StatefulWidget {
  final User currentUser;
  const NewsFeedScreen({super.key, required this.currentUser});

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  static const int _pageSize = 30;

  final ScrollController _scrollController = ScrollController();
  final List<Post> _posts = [];
  Map<int, User> _usersById = {};

  int _skip = 0;
  int _total = 0;
  bool _isLoadingFirstPage = true;
  bool _isLoadingMore = false;
  String? _error;

  final List<Map<String, String>> _ads = const [
    {
      'adsMarket': 'WolfGanger',
      'postContent': 'Book your dinner reservation now!',
      'image':
          'https://images.pexels.com/photos/1267320/pexels-photo-1267320.jpeg?auto=compress&cs=tinysrgb&w=1600',
      'profileImage': 'https://i.pravatar.cc/50?img=32',
    },
    {
      'adsMarket': 'Klook',
      'postContent': 'Book your next adventure with Klook!',
      'image':
          'https://images.pexels.com/photos/210186/pexels-photo-210186.jpeg?auto=compress&cs=tinysrgb&w=1600',
      'profileImage': 'https://i.pravatar.cc/50?img=34',
    },
    {
      'adsMarket': 'Flights.com',
      'postContent': 'Dreamy locations await you!',
      'image':
          'https://images.pexels.com/photos/414171/pexels-photo-414171.jpeg?auto=compress&cs=tinysrgb&w=1600',
      'profileImage': 'https://i.pravatar.cc/50?img=35',
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitial();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore || _isLoadingFirstPage) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isLoadingFirstPage = true;
      _error = null;
    });
    try {
      final usersMap = await UserService.getAllUsersMap();
      final page = await PostService.getPosts(limit: _pageSize, skip: 0);
      if (!mounted) return;
      setState(() {
        _usersById = usersMap;
        _posts
          ..clear()
          ..addAll(page.posts);
        _skip = page.skip;
        _total = page.total;
        _isLoadingFirstPage = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load the newsfeed. $e';
        _isLoadingFirstPage = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_skip + _pageSize >= _total && _posts.length >= _total) return;
    setState(() => _isLoadingMore = true);
    try {
      final nextSkip = _skip + _pageSize;
      final page = await PostService.getPosts(
        limit: _pageSize,
        skip: nextSkip,
      );
      if (!mounted) return;
      setState(() {
        _posts.addAll(page.posts);
        _skip = page.skip;
        _total = page.total;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  User _authorFor(Post post) {
    return _usersById[post.userId] ??
        User(
          id: post.userId,
          firstName: 'User',
          lastName: '#${post.userId}',
          username: 'user${post.userId}',
          email: '',
        );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingFirstPage) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadInitial,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInitial,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(vertical: 10.h),
        itemCount: _posts.length + 1,
        itemBuilder: (context, index) {
          if (index == _posts.length) {
            if (_skip + _pageSize < _total) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Center(
                child: Text(
                  "You're all caught up ✨",
                  style: TextStyle(color: secondaryTextColor(context)),
                ),
              ),
            );
          }

          final post = _posts[index];
          final card = PostCard(
            post: post,
            author: _authorFor(post),
            currentUser: widget.currentUser,
          );

          // Slip a sponsored card in every 5 posts for the same feel as
          // the original static feed.
          if (index != 0 && index % 5 == 0) {
            final ad = _ads[(index ~/ 5 - 1) % _ads.length];
            return Column(
              children: [
                PostCard.ad(
                  adsMarket: ad['adsMarket']!,
                  adsPostContent: ad['postContent']!,
                  adsImage: ad['image'],
                  adsProfileImage: ad['profileImage'],
                ),
                card,
              ],
            );
          }

          return card;
        },
      ),
    );
  }
}
