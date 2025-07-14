import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/styles.dart';

class CategoryItem extends StatelessWidget {
  final IconData icon;
  final String title;
  // final IconData icon;
  // final String title;
  final VoidCallback? onTap;

  const CategoryItem({
    super.key,
    required this.icon,
    required this.title,
    this.onTap, required double iconSize
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            // width: 60,
            // height: 60,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(title, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
