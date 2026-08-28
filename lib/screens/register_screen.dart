import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants.dart';
import '../services/user_service.dart';
import '../widgets/custom_font.dart';
import '../widgets/custom_inkwell_button.dart';
import '../widgets/custom_textformfield.dart';
import '../widgets/custom_dialogs.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmpasswordController = TextEditingController();

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    if (passwordController.text != confirmpasswordController.text) {
      CustomDialogs.showErrorDialog(context, 'Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    // dummyjson.com/docs/users#users-add — simulated, not persisted server
    // side, but keeps registration flowing through the documented API.
    final result = await UserService.addUser(
      firstName: firstnameController.text.trim(),
      lastName: lastnameController.text.trim(),
      username: usernameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.user != null) {
      CustomDialogs.showSuccessDialog(
        context,
        'Registration successful! You can now log in with an existing '
        'dummyjson.com account (e.g. "emilys" / "emilyspass") since new '
        'accounts are simulated only, not stored on the server.',
        onPressed: () {
          Navigator.popAndPushNamed(context, '/login');
        },
      );
    } else {
      CustomDialogs.showErrorDialog(
        context,
        result.error ?? 'Registration failed',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(25),
            vertical: ScreenUtil().setHeight(20),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 40),
                    CustomFont(
                      text: "Register Here",
                      fontSize: ScreenUtil().setSp(30),
                      fontWeight: FontWeight.bold,
                      color: FB_DARK_PRIMARY,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        size: 28.sp,
                        color: FB_DARK_PRIMARY,
                      ),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                    ),
                  ],
                ),

                SizedBox(height: ScreenUtil().setHeight(25)),

                CustomTextFormField(
                  controller: firstnameController,
                  hintText: 'First name',
                  validator: (v) => v!.isEmpty ? 'First name required' : null,
                  fontSize: ScreenUtil().setSp(15),
                  hintTextSize: ScreenUtil().setSp(15),
                ),

                SizedBox(height: ScreenUtil().setHeight(10)),

                CustomTextFormField(
                  controller: lastnameController,
                  hintText: 'Last name',
                  validator: (v) => v!.isEmpty ? 'Last name required' : null,
                  fontSize: ScreenUtil().setSp(15),
                  hintTextSize: ScreenUtil().setSp(15),
                ),

                SizedBox(height: ScreenUtil().setHeight(10)),

                CustomTextFormField(
                  controller: emailController,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty ? 'Email required' : null,
                  fontSize: ScreenUtil().setSp(15),
                  hintTextSize: ScreenUtil().setSp(15),
                ),

                SizedBox(height: ScreenUtil().setHeight(10)),

                CustomTextFormField(
                  controller: usernameController,
                  hintText: 'Username',
                  validator: (v) => v!.isEmpty ? 'Username required' : null,
                  fontSize: ScreenUtil().setSp(15),
                  hintTextSize: ScreenUtil().setSp(15),
                ),

                SizedBox(height: ScreenUtil().setHeight(10)),

                CustomTextFormField(
                  controller: passwordController,
                  isObscure: true,
                  hintText: 'Password',
                  validator: (v) =>
                      v!.length < 8 ? 'Minimum 8 characters' : null,
                  fontSize: ScreenUtil().setSp(15),
                  hintTextSize: ScreenUtil().setSp(15),
                ),

                SizedBox(height: ScreenUtil().setHeight(10)),

                CustomTextFormField(
                  controller: confirmpasswordController,
                  isObscure: true,
                  hintText: 'Confirm Password',
                  validator: (v) => v!.isEmpty ? 'Confirm password' : null,
                  fontSize: ScreenUtil().setSp(15),
                  hintTextSize: ScreenUtil().setSp(15),
                ),

                SizedBox(height: ScreenUtil().setHeight(25)),

                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: FB_DARK_PRIMARY,
                        ),
                      )
                    : CustomInkwellButton(
                        onTap: register,
                        height: ScreenUtil().setHeight(45),
                        width: double.infinity,
                        buttonName: "Submit",
                        fontSize: ScreenUtil().setSp(15),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
