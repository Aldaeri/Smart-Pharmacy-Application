import 'package:flutter/material.dart';
import '../constants/colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        height: 72, // زيادة الارتفاع قليلاً
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              // index: 0,
              icon: Icons.favorite_outline,
              activeIcon: Icons.favorite,
              label: 'المفضلة',
              context,
              index: 0,
              // icon: Icons.medical_services_outlined,
              // activeIcon: Icons.medical_services,
              // label: 'صرف وصفة',
              isSelected: selectedIndex == 0,
            ),

            _buildNavItem(
              context,
              index: 1,
              // icon: Icons.category_outlined,
              // activeIcon: Icons.category,
              // label: 'الاقسام',
              isSelected: selectedIndex == 1,
              // index: 1,
              icon: Icons.notifications_outlined,
              activeIcon: Icons.notifications,
              label: 'التذكيرات',
            ),

            _buildNavItem(
              context,
              index: 4,
              // icon: Icons.medication_outlined,
              // activeIcon: Icons.medication,
              // label: 'منبه الدواء',
              isSelected: selectedIndex == 4,
              isCenter: true,
              // index: 2,
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              // label: 'السلة',
              label: 'الرئيسية',
            ),

            _buildNavItem(
              context,
              index: 2,
              // icon: Icons.medication_outlined,
              // activeIcon: Icons.medication,
              // label: 'منبه الدواء',
              isSelected: selectedIndex == 2,
              // isCenter: true,
              // index: 2,
              icon: Icons.shopping_cart_outlined,
              activeIcon: Icons.shopping_cart,
              // label: 'السلة',
              label: 'مشترياتي',
            ),
            // _buildNavItem(
            //   context,
            //   index: 4,
            //   // icon: Icons.medication_outlined,
            //   // activeIcon: Icons.medication,
            //   // label: 'منبه الدواء',
            //   isSelected: selectedIndex == 4,
            //   // isCenter: true,
            //   // index: 2,
            //   icon: Icons.home_outlined,
            //   activeIcon: Icons.home,
            //   // label: 'السلة',
            //   label: 'مشترياتي',
            // ),

            // عنصر "حسابي"
            _buildNavItem(
              context,
              index: 3,
              // icon: Icons.person_outline,
              // activeIcon: Icons.person,
              // label: 'حسابي',
              isSelected: selectedIndex == 3,
              // index: 3,
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'حسابي',
            ),

            // عنصر "المفضلة" (إضافي)
            // _buildNavItem(
            //   context,
            //   index: 4,
            //   icon: Icons.favorite_outline,
            //   activeIcon: Icons.favorite,
            //   label: 'المفضلة',
            //   isSelected: selectedIndex == 4,
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, {
        required int index,
        required IconData icon,
        required IconData activeIcon,
        String? label,
        required bool isSelected,
        bool isCenter = false,
      }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            onItemSelected(index);
            _navigateToPage(context, index);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: isCenter ? 50 : 40,
                height: isCenter ? 50 : 40,
                decoration: isCenter
                    ? BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                )
                    : null,
                child: Icon(
                  isSelected ? activeIcon : icon,
                  color: isCenter
                      ? Colors.white
                      : isSelected
                      ? AppColors.primary
                      : AppColors.textGray,
                  size: isCenter ? 24 : 22,
                ),
              ),
              SizedBox(height: 4),
              Text(
                label!,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? AppColors.primary : AppColors.textGray,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/favorites');
        break;
      case 1:
        Navigator.pushNamed(context, '/reminders');
        break;
      case 2:
        Navigator.pushNamed(context, '/cart');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
      case 4:
        Navigator.pushNamed(context, '/home');
        break;
    }
  }
}