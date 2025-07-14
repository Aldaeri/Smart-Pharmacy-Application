import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/styles.dart';
import '../widgets/custom_button.dart';

class CartScreen2 extends StatelessWidget {
  const CartScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('السلة', style: AppTextStyles.header),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _buildCartItem(
                    'ون تو ثري اقراص',
                    '900 ر.ي',
                    'https://via.placeholder.com/80',
                    quantity: 1,
                  ),
                  const SizedBox(height: 20),
                  _buildCartItem(
                    'ارجيفيت كلاسيك متعدد الفينامينات',
                    '3,500 ر.ي',
                    'https://via.placeholder.com/80',
                    quantity: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('الإجمالي', style: AppTextStyles.sectionTitle),
                Text('4,400 ر.ي', style: AppTextStyles.sectionTitle),
              ],
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'إتمام الشراء',
              onPressed: () {},
            ),
          ],
        ),
      ),
      // bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 0),
    );
  }

  Widget _buildCartItem(String name, String price, String imageUrl, {int quantity = 1}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(name, style: AppTextStyles.productTitle),
                const SizedBox(height: 8),
                Text(price, style: AppTextStyles.price),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _buildQuantityControl(quantity),
        ],
      ),
    );
  }

  Widget _buildQuantityControl(int quantity) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () {},
          ),
          Text('$quantity', style: AppTextStyles.bodyMedium),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}