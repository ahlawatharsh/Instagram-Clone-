import 'package:flutter/material.dart';

class TextFieldInput extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType textInputType;

  const TextFieldInput({
    super.key,
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    required this.textInputType,
  });

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderSide: Divider.createBorderSide(context),
    );
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        border: inputBorder,
        focusedBorder: inputBorder,
        enabledBorder: inputBorder,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      ),
      keyboardType: textInputType,
      obscureText: obscureText,
    );
  }
}
