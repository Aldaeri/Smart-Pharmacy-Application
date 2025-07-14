import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/colors.dart';
import '../../constants/styles.dart';
import '../../providers/user_provider.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'edit_profile_screen.dart';
import 'address_list_screen.dart';
import 'notifications.dart';
import 'support_screen.dart';
import '../login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 3;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/favorites');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/reminders');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/cart');
        break;
      case 3:
        // Navigator.pushReplacementNamed(context, '/profile');
        break;
      case 4:
        Navigator.pushNamed(context, '/home');
        break;
    }
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      Provider.of<UserProvider>(context, listen: false).clearUser();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء تسجيل الخروج: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final isSmallScreen = screenWidth < 400;

    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: isSmallScreen ? 220 : 300,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.primary,
                padding: EdgeInsets.only(
                  top: MediaQuery
                      .of(context)
                      .padding
                      .top + 20,
                  left: 10,
                  right: 10,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // spacing: 50,
                      children: [
                        IconButton(
                          // alignment: Alignment.center,
                          icon: const Icon(Icons.settings, color: Colors.white),
                          onPressed:
                              () =>
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const EditProfileScreen(),
                                ),
                              ),
                        ),
                        Text(
                          'حسابي',
                          style: AppTextStyles.header.copyWith(
                            fontSize: isSmallScreen ? 20 : 24,
                          ),
                        ),
                        // IconButton(
                        //   icon: const Icon(Icons.logout, color: Colors.white),
                        //   onPressed:
                        //       () => Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //           builder:
                        //               (context) => const EditProfileScreen(),
                        //         ),
                        //       ),
                        // ),
                        // SizedBox(
                        //   child: IconButton(
                        //     icon: const Icon(Icons.logout, color: Colors.white),
                        //     // onPressed: _signOut,
                        //     onPressed: () { _signOut(); },
                        //   ),
                        // ),
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.white),
                          // onPressed: _signOut,
                          onPressed: () {
                            _signOut();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    CircleAvatar(
                      radius: isSmallScreen ? 35 : 45,
                      backgroundColor: Colors.white,
                      backgroundImage: const AssetImage(
                        'assets/images/spa.png',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user?.name ?? 'مستخدم جديد',
                      style: AppTextStyles.subHeader.copyWith(
                        fontSize: isSmallScreen ? 18 : 20,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? 'لا يوجد بريد إلكتروني',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textLight,
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  _buildProfileItem(
                    icon: Icons.person_outline,
                    title: 'إعدادات الحساب',
                    page: const EditProfileScreen(),
                    isSmallScreen: isSmallScreen,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildProfileItem(
                    icon: Icons.location_on_outlined,
                    title: 'قوائم العناوين',
                    page: const AddressListScreen(),
                    isSmallScreen: isSmallScreen,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildProfileItem(
                    icon: Icons.payment,
                    title: 'الدفع الفوري',
                    onTap: () => _showComingSoon(context),
                    isSmallScreen: isSmallScreen,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildProfileItem(
                    icon: Icons.account_balance,
                    title: 'حساب بنكي',
                    onTap: () => _showComingSoon(context),
                    isSmallScreen: isSmallScreen,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildProfileItem(
                    icon: Icons.security,
                    title: 'أمان الحسابات',
                    onTap: () => _showComingSoon(context),
                    isSmallScreen: isSmallScreen,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildProfileItem(
                    icon: Icons.notifications_none,
                    title: 'الإشعارات',
                    page: const NotificationsScreen(),
                    isSmallScreen: isSmallScreen,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildProfileItem(
                    icon: Icons.help_outline,
                    title: 'المساعدة والدعم',
                    page: const SupportScreen(),
                    isSmallScreen: isSmallScreen,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildProfileItem(
                    icon: Icons.location_pin,
                    title: 'الموقع الجغرافي',
                    onTap: () => _showComingSoon(context),
                    isSmallScreen: isSmallScreen,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error.withOpacity(0.1),
                        foregroundColor: AppColors.error,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      onPressed: _signOut,
                      child: Text(
                        'تسجيل الخروج',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _currentIndex,
        onItemSelected: _onItemTapped,
      ),
      // floatingActionButton: FloatingHomeButton(
      //   isSelected: _currentIndex == 4,
      //   onPressed: () => _onItemTapped(4),
      //   btnHomeColor: AppColors.btnDark,
      //   backgroundColor: AppColors.secondary,
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم تفعيل هذه الميزة قريباً'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    Widget? page,
    VoidCallback? onTap,
    required bool isSmallScreen,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      minLeadingWidth: 32,
      leading: Icon(
        icon,
        color: AppColors.primary,
        size: isSmallScreen ? 22 : 24,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          fontSize: isSmallScreen ? 14 : 16,
        ),
      ),
      // trailing: Icon(
      //   Icons.arrow_forward_ios,
      //   size: isSmallScreen ? 14 : 16,
      //   color: Colors.grey.shade400,
      // ),
      onTap:
      onTap ??
              () {
            if (page != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => page),
              );
            }
          },
    );
  }
}
