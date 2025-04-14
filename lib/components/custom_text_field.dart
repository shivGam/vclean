import 'package:flutter/material.dart';

class CustomTextformField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final int? maxLength;
  final bool isPhoneField;

  const CustomTextformField({
    super.key,
    this.controller,
    required this.hintText,
    required this.onSaved,
    required this.validator,
    this.maxLength,
    this.isPhoneField = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: isPhoneField ? TextInputType.phone : TextInputType.text,
      validator: validator,
      onSaved: onSaved,
      maxLength: maxLength,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.blue),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: 15.0,
          horizontal: 12.0,
        ),
      ),
    );
  }
}
