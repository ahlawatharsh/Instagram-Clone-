import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram/resources/auth_methods.dart';
import 'package:instagram/responsive/mobile_screen_layout.dart';
import 'package:instagram/responsive/responsive_layout.dart';
import 'package:instagram/responsive/web_screen_layout.dart';
import 'package:instagram/screens/signup_screen.dart';
import 'package:instagram/utils/colors.dart';
import 'package:instagram/utils/global_variables.dart';
import 'package:instagram/utils/utils.dart';
import 'package:instagram/widgets/text_field_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isLoading = false;

  void loginUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().loginUser(
      email: _emailController.text.trim(),
      password: _passController.text.trim(),
    );
    setState(() {
      _isLoading = false;
    });
    if (res == 'success') {
      //after login what to do
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ResponsiveLayout(
            webScreenLayout: WebScreenLayout(),
            mobileScreenLayout: MobileScreenLayout(),
          ),
        ),
      );
    } else {
      showSnackBar(res, context);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: MediaQuery.of(context).size.width > webScreenSize
              ? EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 3,
                )
              : EdgeInsets.symmetric(horizontal: 28),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Flexible(flex: 2, child: Container()),

              //logo
              SvgPicture.asset(
                "assets/ic_instagram.svg",
                colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
                height: 60,
              ),
              const SizedBox(height: 64),

              //text field for email
              TextFieldInput(
                hintText: "Enter your email",
                controller: _emailController,
                textInputType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),

              //text field for password
              TextFieldInput(
                hintText: "Password",
                controller: _passController,
                textInputType: TextInputType.visiblePassword,
                obscureText: true,
              ),
              const SizedBox(height: 12),

              //button for login
              GestureDetector(
                onTap: loginUser,
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: const ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    color: blueColor,
                  ),
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(color: primaryColor),
                        )
                      : Text("Log in"),
                ),
              ),

              const SizedBox(height: 12),
              Flexible(flex: 2, child: Container()),

              //Transtion to signup
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => SignupScreen()),
                      );
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
            ],
          ),
        ),
      ),
    );
  }
}
