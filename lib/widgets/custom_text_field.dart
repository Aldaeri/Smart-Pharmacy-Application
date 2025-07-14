import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/styles.dart';

class CustomTextField extends StatelessWidget {
  // final String hintText;
  final IconData? prefixIcon;
  final bool isPassword;
  // final TextInputType? keyboardType;
  // final TextEditingController controller;
  final TextEditingController? controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  // final Widget? prefixIcon;
  final void Function(String)? onChanged;
  final int? maxLines;
  final int? minLines;
  final bool readOnly;
  final void Function()? onTap;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.prefixIcon,
    this.isPassword = false,
    this.keyboardType,
    this.controller,
    this.obscureText = false,
    this.validator,
    this.suffixIcon,
    this.onChanged,
    this.maxLines = 1,
    this.minLines,
    this.readOnly = false,
    this.onTap,
    // required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      // controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGray),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: AppColors.borderGray, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: AppColors.borderGray, width: 1),
        ),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }
}
