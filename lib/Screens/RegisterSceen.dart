import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grantgo/Screens/LoginScreen.dart';
import 'package:grantgo/Screens/OtpScreen.dart';
import 'package:grantgo/cubit/register/register_cubit.dart';
import 'package:grantgo/cubit/register/register_state.dart';
import 'package:grantgo/widgets/customTextField.dart';

class Registersceen extends StatefulWidget {
  const Registersceen({super.key});

  @override
  State<Registersceen> createState() => _RegistersceenState();
}

class _RegistersceenState extends State<Registersceen>
    with SingleTickerProviderStateMixin {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  GlobalKey<FormState> formstate = GlobalKey();

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
    name.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color bgDark = Color(0xFF0A0F1E);
    const Color bgCard = Color(0xFF0D1426);
    const Color blue = Color(0xFF2563EB);
    const Color purple = Color(0xFF7C3AED);
    const Color blueLight = Color(0xFF60A5FA);
    const Color purpleLight = Color(0xFFA78BFA);

    return BlocProvider(
      create: (context) => RegisterCubit(),
      child: BlocConsumer<RegisterCubit, RegisterState>(
        listener: (context, state) {
          if (state is RegisterOtpRequired) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => OtpScreen(email: state.email)),
            );
          }
          if (state is RegisterFailure) {
            AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              animType: AnimType.rightSlide,
              title: 'Error',
              desc: state.error,
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
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(24, 56, 24, 32),
                            decoration: BoxDecoration(
                              color: bgCard,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(32),
                                bottomRight: Radius.circular(32),
                              ),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.06),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const Loginscreen(),
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
                                const SizedBox(height: 20),
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                        colors: [blueLight, purpleLight],
                                      ).createShader(bounds),
                                  child: const Text(
                                    "Create profile",
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: -0.8,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  '"Join Scholara to achieve a bright future."',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0x66FFFFFF),
                                    fontStyle: FontStyle.italic,
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
                                  _buildLabel("Name"),
                                  const SizedBox(height: 8),
                                  CustomTextfield(
                                    hinttext: "Enter your Name :",
                                    mycontroller: name,
                                    isObscure: false,
                                    iconData: Icons.person,
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return "Name is required";
                                      }
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 20),
                                  _buildLabel("Email"),
                                  const SizedBox(height: 8),
                                  CustomTextfield(
                                    hinttext: "Enter your email :",
                                    mycontroller: email,
                                    isObscure: false,
                                    iconData: Icons.email,
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
                                    hinttext: "Enter your password :",
                                    mycontroller: password,
                                    isObscure: true,
                                    iconData: Icons.visibility,
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return "Password is required";
                                      }
                                      if (val.length < 6) {
                                        return "Password must be at least 6 characters";
                                      }
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 20),
                                  _buildLabel("Confirm Password"),
                                  const SizedBox(height: 8),
                                  CustomTextfield(
                                    hinttext: "Enter your confirm password :",
                                    mycontroller: confirmPassword,
                                    isObscure: true,
                                    iconData: Icons.visibility,
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return "Confirm Password is required";
                                      }
                                      if (val != password.text) {
                                        return "Passwords do not match";
                                      }
                                      return null;
                                    },
                                  ),

                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {},
                                      child: const Text(
                                        "Terms & Conditions",
                                        style: TextStyle(
                                          color: Color(0xFF60A5FA),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  GestureDetector(
                                    onTap: state is RegisterLoading
                                        ? null
                                        : () {
                                            if (formstate.currentState!
                                                .validate()) {
                                              context
                                                  .read<RegisterCubit>()
                                                  .register(
                                                    name.text,
                                                    email.text,
                                                    password.text,
                                                  );
                                            }
                                          },
                                    child: Container(
                                      width: double.infinity,
                                      height: 58,
                                      decoration: BoxDecoration(
                                        gradient: state is RegisterLoading
                                            ? null
                                            : const LinearGradient(
                                                colors: [blue, purple],
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                              ),
                                        color: state is RegisterLoading
                                            ? Colors.white12
                                            : null,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: state is RegisterLoading
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
                                        child: state is RegisterLoading
                                            ? const CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              )
                                            : const Text(
                                                "Register",
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

                                  const SizedBox(height: 20),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Already have an account? ",
                                        style: TextStyle(
                                          color: Color(0x66FFFFFF),
                                          fontSize: 14,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const Loginscreen(),
                                            ),
                                            (route) => false,
                                          );
                                        },
                                        child: const Text(
                                          "Login",
                                          style: TextStyle(
                                            color: Color(0xFF60A5FA),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
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
              ],
            ),
          );
        },
      ),
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
