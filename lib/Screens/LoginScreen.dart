import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grantgo/Screens/HomePage.dart';
import 'package:grantgo/Screens/RegisterSceen.dart';
import 'package:grantgo/Screens/WelcomeScreen.dart';
import 'package:grantgo/cubit/login/login_cubit.dart';
import 'package:grantgo/cubit/login/login_state.dart';
import 'package:grantgo/cubit/scholarship/cubit/saved_scholarship_cubit.dart';
import 'package:grantgo/Services/token_storage.dart';
import 'package:grantgo/widgets/customTextField.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final GlobalKey<FormState> formstate = GlobalKey<FormState>();

  static const Color bgDark = Color(0xFF0A0F1E);
  static const Color blue = Color(0xFF2563EB);
  static const Color purple = Color(0xFF7C3AED);
  static const Color blueLight = Color(0xFF60A5FA);
  static const Color purpleLight = Color(0xFFA78BFA);

  AnimationController? _controller;
  Animation<double>? _fadeAnim;
  Animation<Offset>? _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _controller!, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller!, curve: Curves.easeOut));
    _controller!.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) async {
        if (state is LoginSuccess) {
          final token = await TokenStorage.getToken();
          if (token != null && context.mounted) {
            context.read<SavedScholarshipsCubit>().updateToken(token);
          }
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.rightSlide,
            title: 'Success',
            titleTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            desc: 'Welcome Back to Scholara!',
            descTextStyle: const TextStyle(color: Colors.white70),
          ).show();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        }
        if (state is LoginFailure) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.rightSlide,
            title: 'Error',
            titleTextStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            desc: state.error,
            descTextStyle: const TextStyle(color: Colors.black),
          ).show();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: bgDark,
          body: Stack(
            children: [
              Positioned(
                top: -60,
                right: -60,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [blue.withOpacity(0.2), Colors.transparent],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 80,
                left: -40,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [purple.withOpacity(0.18), Colors.transparent],
                    ),
                  ),
                ),
              ),

              FadeTransition(
                opacity: _fadeAnim ?? const AlwaysStoppedAnimation(1.0),
                child: SlideTransition(
                  position:
                      _slideAnim ?? const AlwaysStoppedAnimation(Offset.zero),
                  child: SafeArea(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 16, top: 8),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Welcomescreen(),
                                  ),
                                  (route) => false,
                                );
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: blue.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: blue.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.waving_hand_rounded,
                                        size: 14,
                                        color: blueLight,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        "WELCOME BACK",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF93C5FD),
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                        colors: [blueLight, purpleLight],
                                      ).createShader(bounds),
                                  child: const Text(
                                    "Let's Sign\nYou In",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 38,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -1.0,
                                      height: 1.15,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "Welcome back, you've been missed!",
                                  style: TextStyle(
                                    color: Color(0x66FFFFFF),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          Form(
                            key: formstate,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel("Email Address"),
                                  const SizedBox(height: 8),
                                  CustomTextfield(
                                    hinttext: "name@example.com",
                                    mycontroller: email,
                                    isObscure: false,
                                    iconData: Icons.mail_outline_rounded,
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return "Email is required";
                                      }
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 20),
                                  _buildLabel("Password"),
                                  const SizedBox(height: 8),
                                  CustomTextfield(
                                    hinttext: "••••••••",
                                    mycontroller: password,
                                    isObscure: true,
                                    iconData: Icons.lock_outline_rounded,
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return "Password is required";
                                      }
                                      return null;
                                    },
                                  ),

                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {},
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                      ),
                                      child: const Text(
                                        "Forgot Password?",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: blueLight,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  GestureDetector(
                                    onTap: state is LoginLoading
                                        ? null
                                        : () {
                                            if (formstate.currentState!
                                                .validate()) {
                                              context.read<LoginCubit>().login(
                                                email.text,
                                                password.text,
                                              );
                                            }
                                          },
                                    child: Container(
                                      width: double.infinity,
                                      height: 58,
                                      decoration: BoxDecoration(
                                        gradient: state is LoginLoading
                                            ? null
                                            : const LinearGradient(
                                                colors: [blue, purple],
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                              ),
                                        color: state is LoginLoading
                                            ? Colors.white12
                                            : null,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: state is LoginLoading
                                            ? []
                                            : [
                                                BoxShadow(
                                                  color: blue.withOpacity(0.4),
                                                  blurRadius: 20,
                                                  offset: const Offset(0, 8),
                                                ),
                                              ],
                                      ),
                                      child: Center(
                                        child: state is LoginLoading
                                            ? const SizedBox(
                                                width: 24,
                                                height: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2.5,
                                                    ),
                                              )
                                            : const Text(
                                                "Login",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: -0.3,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 28),

                                  Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "Don't have an account? ",
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.4,
                                            ),
                                            fontSize: 14,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const Registersceen(),
                                              ),
                                              (route) => false,
                                            );
                                          },
                                          child: const Text(
                                            "Sign Up",
                                            style: TextStyle(
                                              color: blueLight,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFFB0B8CC),
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );
  }
}
