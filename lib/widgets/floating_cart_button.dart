import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class FloatingCartButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? elevation;
  final double? size;

  const FloatingCartButton({
    super.key,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.elevation,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: true);
    final totalItems = cartProvider.totalItems;

    return FloatingActionButton(
      onPressed: onPressed ?? () {
        // التنقل إلى صفحة السلة إذا لم يتم توفير onPressed
        Navigator.pushNamed(context, '/cart');
      },
      backgroundColor: backgroundColor ?? Colors.orange,
      elevation: elevation ?? 6.0,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            Icons.shopping_cart,
            color: iconColor ?? Colors.white,
            size: size ?? 24,
          ),
          if (totalItems > 0)
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Text(
                  totalItems.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// class FloatingCartButton2 extends StatelessWidget {
//   const FloatingCartButton2({super.key});
//
//
//   @override
//   Widget build(BuildContext context) {
//     final cart = Provider.of<CartProvider>(context);
//
//     return Positioned(
//       bottom: 20,
//       right: 20,
//       child: GestureDetector(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const CartScreen()),
//           );
//         },
//         child: Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: Colors.blue,
//             borderRadius: BorderRadius.circular(50),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.2),
//                 blurRadius: 8,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               const Icon(Icons.shopping_cart, color: Colors.white, size: 28),
//               if (cart.itemCount > 0)
//                 Positioned(
//                   top: 0,
//                   right: 0,
//                   child: Container(
//                     padding: const EdgeInsets.all(4),
//                     decoration: const BoxDecoration(
//                       color: Colors.red,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Text(
//                       cart.itemCount.toString(),
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
