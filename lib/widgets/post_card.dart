import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../constants.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../services/local_storage_service.dart';
import 'custom_font.dart';
import '../screens/detail_screen.dart';

class PostCard extends StatefulWidget {
  // Real post mode
  final Post? post;
  final User? author;
  final User? currentUser;

  // Sponsored/ad mode (purely decorative, no like/comment actions)
  final bool isAds;
  final String adsMarket;
  final String adsPostContent;
  final String? adsImage;
  final String? adsProfileImage;

  const PostCard({
    super.key,
    required this.post,
    required this.author,
    required this.currentUser,
  }) : isAds = false,
       adsMarket = '',
       adsPostContent = '',
       adsImage = null,
       adsProfileImage = null;

  const PostCard.ad({
    super.key,
    required this.adsMarket,
    required this.adsPostContent,
    this.adsImage,
    this.adsProfileImage,
  }) : isAds = true,
       post = null,
       author = null,
       currentUser = null;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLiked = false;
  int likesCount = 0;

  @override
  void initState() {
    super.initState();
    if (!widget.isAds && widget.post != null) {
      likesCount = widget.post!.likes;
      _loadLikeState();
    }
  }

  Future<void> _loadLikeState() async {
    final liked = await LocalStorageService.isPostLiked(widget.post!.id);
    if (!mounted) return;
    setState(() {
      isLiked = liked;
      likesCount = widget.post!.likes + (liked ? 1 : 0);
    });
  }

  Future<void> toggleLike() async {
    final nowLiked = await LocalStorageService.togglePostLike(widget.post!.id);
    if (!mounted) return;
    setState(() {
      isLiked = nowLiked;
      likesCount = widget.post!.likes + (nowLiked ? 1 : 0);
    });
  }

  void openDetailScreen() {
    if (widget.isAds) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(
          post: widget.post!,
          author: widget.author!,
          currentUser: widget.currentUser!,
        ),
      ),
    ).then((_) {
      // Likes may have changed while on the detail screen.
      _loadLikeState();
    });
  }

  ImageProvider? _avatar(String? path) {
    if (path == null || path.isEmpty) return null;
    return CachedNetworkImageProvider(path);
  }

  @override
  Widget build(BuildContext context) {
    final textColor = primaryTextColor(context);

    if (widget.isAds) {
      return _buildAdCard(textColor);
    }

    final post = widget.post!;
    final author = widget.author!;
    final currentUser = widget.currentUser!;

    return GestureDetector(
      onTap: openDetailScreen,
      child: Card(
        color: cardColor(context),
        margin: EdgeInsets.all(10.sp),
        child: Padding(
          padding: EdgeInsets.all(10.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18.sp,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _avatar(author.image),
                    child: author.image == null
                        ? Icon(Icons.person, size: 18.sp, color: Colors.white)
                        : null,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomFont(
                          text: author.fullName,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        Row(
                          children: [
                            CustomFont(
                              text: post.tags.isNotEmpty
                                  ? '#${post.tags.first}'
                                  : 'post',
                              fontSize: 12.sp,
                              color: secondaryTextColor(context),
                            ),
                            SizedBox(width: 3.w),
                            Icon(
                              Icons.public,
                              size: 15.sp,
                              color: const Color.fromARGB(255, 135, 153, 182),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.more_horiz, color: textColor),
                ],
              ),

              SizedBox(height: 5.h),

              CustomFont(
                text: post.title,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              SizedBox(height: 3.h),
              CustomFont(text: post.body, fontSize: 12.sp, color: textColor),

              SizedBox(height: 10.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: toggleLike,
                    child: Row(
                      children: [
                        Icon(
                          isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
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
                  GestureDetector(
                    onTap: openDetailScreen,
                    child: Row(
                      children: [
                        Icon(
                          Icons.comment_outlined,
                          size: 18.sp,
                          color: textColor,
                        ),
                        SizedBox(width: 4.w),
                        CustomFont(
                          text: 'Comment',
                          fontSize: 12.sp,
                          color: textColor,
                        ),
                      ],
                    ),
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
                        text: '${post.views}',
                        fontSize: 12.sp,
                        color: textColor,
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 10.h),
              Row(
                children: [
                  CircleAvatar(
                    radius: 15.sp,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _avatar(currentUser.image),
                    child: currentUser.image == null
                        ? Icon(Icons.person, size: 15.sp, color: Colors.white)
                        : null,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: openDetailScreen,
                      child: Container(
                        height: 25.h,
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: isDark(context)
                              ? Colors.white10
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(10.sp),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12.sp),
                        child: CustomFont(
                          text: 'Write a comment...',
                          fontSize: 11.sp,
                          color: secondaryTextColor(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 7.h),
              GestureDetector(
                onTap: openDetailScreen,
                child: CustomFont(
                  text: 'View Comments',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdCard(Color textColor) {
    return Card(
      color: cardColor(context),
      margin: EdgeInsets.all(10.sp),
      child: Padding(
        padding: EdgeInsets.all(10.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18.sp,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _avatar(widget.adsProfileImage),
                ),
                SizedBox(width: 10.w),
                CustomFont(
                  text: 'Sponsored',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ],
            ),
            SizedBox(height: 8.h),
            if (widget.adsImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8.sp),
                child: CachedNetworkImage(
                  imageUrl: widget.adsImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 140.h,
                  placeholder: (_, __) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (_, __, ___) => const Icon(Icons.error),
                ),
              ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomFont(
                        text: 'SPONSORED',
                        fontSize: 11.sp,
                        color: secondaryTextColor(context),
                      ),
                      CustomFont(
                        text: widget.adsMarket,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      CustomFont(
                        text: widget.adsPostContent,
                        fontSize: 12.sp,
                        color: textColor,
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Learn More'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
