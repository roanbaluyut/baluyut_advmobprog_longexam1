import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants.dart';
import '../services/local_storage_service.dart';
import '../widgets/custom_font.dart';

/// Enhancement 1: instantiates the app by checking, via shared_preferences,
/// whether the user is already logged in — and routes straight to /home if
/// so, or to /login otherwise.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Small delay so the splash branding is actually visible.
    await Future.delayed(const Duration(milliseconds: 900));

    final loggedIn = await LocalStorageService.isLoggedIn();
    final session = loggedIn ? await LocalStorageService.getSession() : null;

    if (!mounted) return;

    if (loggedIn && session != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FB_DARK_PRIMARY,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/visacool_logo.png',
              height: ScreenUtil().setHeight(120),
              errorBuilder: (_, __, ___) => Icon(
                Icons.people_alt_rounded,
                size: ScreenUtil().setSp(80),
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20.h),
            CustomFont(
              text: 'Visacool',
              fontSize: 26.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Klavika',
            ),
            SizedBox(height: 30.h),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
