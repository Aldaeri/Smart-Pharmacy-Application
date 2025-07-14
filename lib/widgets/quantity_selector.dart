import 'package:flutter/material.dart';
import '../constants/colors.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            onPressed: onDecrement,
          ),
          Text('$quantity', style: const TextStyle(fontSize: 16)),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: onIncrement,
          ),
        ],
      ),
    );
  }
}