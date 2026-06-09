import 'package:flutter/material.dart';

class CustomTextfield extends StatefulWidget {
  final String hinttext;
  final TextEditingController mycontroller;
  final bool isObscure;
  final IconData iconData;
  final String? Function(String?)? validator;

  const CustomTextfield({
    super.key,
    required this.hinttext,
    required this.mycontroller,
    required this.validator,
    required this.isObscure,
    required this.iconData,
  });

  @override
  State<CustomTextfield> createState() => _CustomTextfieldState();
}

class _CustomTextfieldState extends State<CustomTextfield> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isObscure;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: widget.validator,
      controller: widget.mycontroller,
      obscureText: _obscureText,
      decoration: InputDecoration(
        hintText: widget.hinttext,
        hintStyle: TextStyle(color: Colors.grey[800], fontSize: 15),
        fillColor: Colors.white,
        filled: true,
        suffixIcon: widget.isObscure
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : Icon(widget.iconData),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 194, 193, 193),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 208, 207, 207),
          ),
        ),
      ),
    );
  }
}
