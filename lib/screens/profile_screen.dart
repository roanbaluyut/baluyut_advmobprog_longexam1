import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../constants.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../services/post_service.dart';
import '../widgets/custom_font.dart';
import '../widgets/post_card.dart';
import '../screens/settings_screen.dart';

/// Enhancement 2: renders this user's posts by userID
/// (https://dummyjson.com/docs/posts#posts-user) — always the currently
/// logged-in user's own id — and links out to the settings screen.
class ProfileScreen extends StatefulWidget {
  final User currentUser;
  const ProfileScreen({super.key, required this.currentUser});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Post> _posts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final posts = await PostService.getPostsByUser(widget.currentUser.id);
      if (!mounted) return;
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load your posts. $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.currentUser;
    final textColor = primaryTextColor(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: bgColor(context),
        body: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(height: 130.h, color: FB_DARK_PRIMARY),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: -50,
                  left: 20.w,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: user.image != null
                        ? CachedNetworkImageProvider(user.image!)
                        : null,
                    child: user.image == null
                        ? const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
              ],
            ),
            SizedBox(height: 55.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomFont(
                    text: user.fullName,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                    color: textColor,
                  ),
                  CustomFont(
                    text: '@${user.username}',
                    fontSize: 13.sp,
                    color: secondaryTextColor(context),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      CustomFont(
                        text: '${_posts.length}',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: FB_TEXT_COLOR_WHITE,
                      ),
                      SizedBox(width: 5.w),
                      CustomFont(
                        text: 'posts',
                        fontSize: 15.sp,
                        color: secondaryTextColor(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 10.h),

            TabBar(
              indicatorColor: FB_DARK_PRIMARY,
              labelColor: textColor,
              unselectedLabelColor: secondaryTextColor(context),
              tabs: const [Tab(text: 'Posts'), Tab(text: 'About')],
            ),

            Expanded(
              child: TabBarView(
                children: [_buildPostsTab(textColor), _buildAboutTab(textColor)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsTab(Color textColor) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _loadPosts, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_posts.isEmpty) {
      return Center(
        child: Text(
          "You haven't posted anything yet.",
          style: TextStyle(color: secondaryTextColor(context)),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadPosts,
      child: ListView.builder(
        padding: EdgeInsets.all(10.w),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          return PostCard(
            post: _posts[index],
            author: widget.currentUser,
            currentUser: widget.currentUser,
          );
        },
      ),
    );
  }

  Widget _buildAboutTab(Color textColor) {
    final user = widget.currentUser;
    return ListView(
      padding: EdgeInsets.all(20.w),
      children: [
        CustomFont(
          text: 'Contact Info',
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: FB_DARK_PRIMARY,
        ),
        ListTile(
          leading: const Icon(Icons.email, color: FB_DARK_PRIMARY),
          title: CustomFont(
            text: user.email,
            fontSize: 15.sp,
            color: textColor,
          ),
        ),
        if (user.phone != null)
          ListTile(
            leading: const Icon(Icons.phone, color: FB_DARK_PRIMARY),
            title: CustomFont(
              text: user.phone!,
              fontSize: 15.sp,
              color: textColor,
            ),
          ),
        Divider(color: secondaryTextColor(context)),

        CustomFont(
          text: 'Basic Info',
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: FB_DARK_PRIMARY,
        ),
        if (user.gender != null)
          ListTile(
            leading: const Icon(Icons.person, color: FB_DARK_PRIMARY),
            title: CustomFont(
              text: user.gender!,
              fontSize: 15.sp,
              color: textColor,
            ),
          ),
        if (user.age != null)
          ListTile(
            leading: const Icon(Icons.cake, color: FB_DARK_PRIMARY),
            title: CustomFont(
              text: '${user.age} years old',
              fontSize: 15.sp,
              color: textColor,
            ),
          ),
        if (user.university != null)
          ListTile(
            leading: const Icon(Icons.school, color: FB_DARK_PRIMARY),
            title: CustomFont(
              text: user.university!,
              fontSize: 15.sp,
              color: textColor,
            ),
          ),
        if (user.city != null || user.country != null)
          ListTile(
            leading: const Icon(Icons.location_on, color: FB_DARK_PRIMARY),
            title: CustomFont(
              text: [
                user.city,
                user.country,
              ].where((e) => e != null).join(', '),
              fontSize: 15.sp,
              color: textColor,
            ),
          ),
      ],
    );
  }
}
