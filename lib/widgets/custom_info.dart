import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants.dart';

/// A notification row (profile updates, new posts, account activity, etc.).
/// Tappable via [onTap] — e.g. to open the related post's DetailScreen.
class CustomInfo extends StatelessWidget {
  const CustomInfo({
    super.key,
    required this.name,
    required this.post,
    required this.description,
    required this.date,
    required this.numOfLikes,
    this.profileImagePath,
    this.profileImageUrl,
    this.imageUrl,
    this.onTap,
  });

  final String name;
  final String post;
  final String description;
  final String date;
  final int numOfLikes;
  final String? profileImagePath;
  final String? profileImageUrl;
  final String? imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = primaryTextColor(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(ScreenUtil().setSp(15)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: ScreenUtil().setSp(25),
              backgroundColor: Colors.grey[300],
              backgroundImage:
                  profileImageUrl != null && profileImageUrl!.isNotEmpty
                  ? NetworkImage(profileImageUrl!)
                  : (profileImagePath != null
                        ? AssetImage(profileImagePath!) as ImageProvider
                        : null),
              child:
                  (profileImageUrl == null || profileImageUrl!.isEmpty) &&
                      profileImagePath == null
                  ? Icon(
                      Icons.person,
                      size: ScreenUtil().setSp(25),
                      color: Colors.white,
                    )
                  : null,
            ),
            SizedBox(width: ScreenUtil().setWidth(10)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                  Text(
                    'Posted: $post',
                    style: TextStyle(fontSize: 13.sp, color: textColor),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontStyle: FontStyle.italic,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: secondaryTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, color: secondaryTextColor(context)),
          ],
        ),
      ),
    );
  }
}
