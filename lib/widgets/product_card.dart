import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  // final String name;
  // final String price;
  // final String imageUrl;
  // final bool isFavorite;
  final String id;
  final String name;
  final String price;
  final String imageUrl;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const ProductCard({
    super.key,
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  // @override
  // Widget build(BuildContext context) {
  //   return Container(
  //     width: 148,
  //     height: 217,
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(20),
  //       boxShadow: [
  //         BoxShadow(
  //           // ignore: deprecated_member_use
  //           color: Colors.grey.withOpacity(0.1),
  //           spreadRadius: 1,
  //           blurRadius: 5,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.end,
  //       children: [
  //         Container(
  //           width: 144,
  //           height: 120,
  //           margin: const EdgeInsets.all(2),
  //           decoration: BoxDecoration(
  //             color: AppColors.secondary,
  //             borderRadius: BorderRadius.circular(19),
  //           ),
  //           child: Center(
  //             child: Image.network(
  //               imageUrl,
  //               width: 80,
  //               height: 80,
  //               fit: BoxFit.contain,
  //             ),
  //           ),
  //         ),
  //         Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 8),
  //           child: Text(
  //             name,
  //             style: AppTextStyles.productTitle,
  //             textAlign: TextAlign.right,
  //           ),
  //         ),
  //         const Spacer(),
  //         Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 8),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Text(price, style: AppTextStyles.price),
  //               Container(
  //                 width: 45,
  //                 height: 46,
  //                 decoration: BoxDecoration(
  //                   color: AppColors.primary,
  //                   borderRadius: const BorderRadius.only(
  //                     topLeft: Radius.circular(16),
  //                     bottomLeft: Radius.circular(22),
  //                   ),
  //                 ),
  //                 child: const Icon(Icons.add, color: Colors.white),
  //               ),
  //             ],
  //           ),
  //         ),
  //         const SizedBox(height: 8),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.network(
                  imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.medication),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: onFavoriteToggle,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
