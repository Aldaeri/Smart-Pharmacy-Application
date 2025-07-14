import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/colors.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  Future<void> _checkAuthStatus(BuildContext context) async {
    // التحقق من الاتصال أولاً
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      Navigator.pushReplacementNamed(context, '/no_internet');
      return;
    }

    // التحقق من وجود مستخدم مسجل دخوله حالياً
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // إذا كان هناك مستخدم مسجل دخوله، جلب بياناته والانتقال للصفحة الرئيسية
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.setUserFromFirestore(currentUser.uid);
      Navigator.pushReplacementNamed(context, '/home');
      return;
    }

    // التحقق من وجود بيانات تسجيل دخول محفوظة
    final savedCredentials = await AuthService.getSavedCredentials();
    if (savedCredentials != null) {
      try {
        // محاولة تسجيل الدخول تلقائياً
        final userCredential = await AuthService.login(
          savedCredentials['email']!,
          savedCredentials['password']!,
        );

        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.setUserFromFirestore(userCredential!.user!.uid);
        Navigator.pushReplacementNamed(context, '/home');
        return;
      } catch (e) {
        // في حالة فشل تسجيل الدخول التلقائي، ننتقل لصفحة تسجيل الدخول
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      // إذا لم يكن هناك بيانات محفوظة، ننتقل لصفحة الترحيب
      Navigator.pushReplacementNamed(context, '/signup');
    }
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 1), () {
      _checkAuthStatus(context);
    });
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Image.asset(
          'assets/logos/pharmacy_logo_v3.png',
          width: 200,
          height: 200,
        ),
      ),
      // children: [
      //   Container(
      //     width: 393,
      //     height: 852,
      //     clipBehavior: Clip.antiAlias,
      //     decoration: BoxDecoration(color: Colors.white),
      //     child: Stack(
      //       alignment: Alignment.topLeft,
      //       children: [
      //         Positioned(
      //           left: 97,
      //           top: 326,
      //           child: Container(
      //             width: 200,
      //             height: 200,
      //             decoration: BoxDecoration(
      //               image: DecorationImage(
      //                 image: NetworkImage("https://placehold.co/200x200"),
      //                 fit: BoxFit.cover,
      //               ),
      //               border: Border.all(width: 1),
      //             ),
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      // ],
    );
  }
}
