import 'package:flutter/material.dart';


class FloatingHomeButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onPressed;
  final Color btnHomeColor;
  final Color backgroundColor;


  const FloatingHomeButton({
    super.key,
    required this.isSelected,
    required this.onPressed,
    required this.btnHomeColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      elevation: 4,
      child: Icon(
        isSelected ? Icons.home : Icons.home_outlined,
        color: btnHomeColor,
        size: screenWidth * 0.07,
      ),
    );
  }
}