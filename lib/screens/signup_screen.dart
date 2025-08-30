import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/resources/auth_methods.dart';
import 'package:instagram/responsive/mobile_screen_layout.dart';
import 'package:instagram/responsive/responsive_layout.dart';
import 'package:instagram/responsive/web_screen_layout.dart';
import 'package:instagram/screens/login_screen.dart';
import 'package:instagram/utils/colors.dart';
import 'package:instagram/utils/utils.dart';
import 'package:instagram/widgets/text_field_input.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _usernameContoller = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  Uint8List? _image;
  bool _isLoading = false;

  void selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  void signUpUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().signUpUser(
      email: _emailController.text,
      password: _passController.text,
      bio: _bioController.text,
      username: _usernameContoller.text,
      file: _image!,
    );
    setState(() {
      _isLoading = false;
    });
    if (res != 'success') {
      showSnackBar(res, context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ResponsiveLayout(
            webScreenLayout: WebScreenLayout(),
            mobileScreenLayout: MobileScreenLayout(),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passController.dispose();
    _usernameContoller.dispose();
    _bioController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 28),
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                //logo
                SvgPicture.asset(
                  "assets/ic_instagram.svg",
                  colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
                  height: 60,
                ),
                const SizedBox(height: 40),

                //circular widget to accept and show our selected file
                Stack(
                  children: [
                    _image != null
                        ? CircleAvatar(
                            radius: 64,
                            backgroundImage: MemoryImage(_image!),
                          )
                        : CircleAvatar(
                            radius: 64,
                            backgroundImage: AssetImage("assets/user_demo.png"),
                          ),
                    Positioned(
                      bottom: -10,
                      left: 80,
                      child: IconButton(
                        onPressed: selectImage,
                        icon: Icon(Icons.add_a_photo, color: blueColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                //Text field for username
                TextFieldInput(
                  hintText: "Enter your email",
                  controller: _emailController,
                  textInputType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),

                //text field for email
                TextFieldInput(
                  hintText: "Enter your username",
                  controller: _usernameContoller,
                  textInputType: TextInputType.text,
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

                //Confirm Password
                TextFieldInput(
                  hintText: "Write you bio",
                  controller: _bioController,
                  textInputType: TextInputType.text,
                ),
                const SizedBox(height: 12),

                //button for login
                GestureDetector(
                  onTap: signUpUser,
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
                            child: CircularProgressIndicator(
                              color: primaryColor,
                            ),
                          )
                        : Text("Sign Up"),
                  ),
                ),

                const SizedBox(height: 12),

                //Transtion to signup
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Sign in",
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
      ),
    );
  }
}
