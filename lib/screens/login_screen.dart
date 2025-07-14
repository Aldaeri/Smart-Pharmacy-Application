import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../providers/user_provider.dart';
import '../widgets/custom_button.dart';

import '../constants/styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureText = true;

  Future<void> _login() async {
    print('بدء عملية تسجيل الدخول');

    if (!_formKey.currentState!.validate()) {
      print('النموذج غير صالح');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // final userCredential = await AuthService.login(
      //   _emailController.text.trim(),
      //   _passwordController.text.trim(),
      // );
      print('جاري تسجيل الدخول...');
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      print('تم تسجيل الدخول بنجاح: ${userCredential.user?.uid}');

      // جلب بيانات المستخدم من Firestore
      await _fetchUserDataAndNavigate(userCredential.user!.uid);

        // Navigator.pushReplacementNamed(context, '/home');

    } on FirebaseAuthException catch (e) {
      String message = 'حدث خطأ، حاول مرة أخرى.';

      if (e.code == 'user-not-found') {
        message = 'لا يوجد مستخدم بهذا البريد الإلكتروني.';
      } else if (e.code == 'wrong-password') {
        message = 'كلمة المرور غير صحيحة.';
      } else if (e.code == 'invalid-email') {
        message = 'بريد إلكتروني غير صالح.';
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      print('خطأ غير متوقع: $e');
      ScaffoldMessenger.of(context,).showSnackBar(SnackBar(content: Text('حدث خطأ غير متوقع: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      // setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchUserDataAndNavigate(String userId) async {
    try{

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.setUserFromFirestore(userId);

      if (userProvider.user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        throw Exception('فشل في تحميل بيانات المستخدم');
      }
      // جلب بيانات المستخدم الرئيسية
      // DocumentSnapshot userDoc = await FirebaseFirestore.instance
      //     .collection('users')
      //     .doc(userId)
      //     .get();

      // if (!userDoc.exists) {
      //   throw Exception('المستخدم غير موجود في قاعدة البيانات');
      // }

      // جلب قائمة المفضلة إذا كانت موجودة
      // List<Map<String, dynamic>> favorites = [];
      // QuerySnapshot favoritesSnapshot = await FirebaseFirestore.instance
      //     .collection('users')
      //     .doc(userId)
      //     .collection('favorites')
      //     .get();

      // favorites = favoritesSnapshot.docs.map((doc) {
      //   return {
      //     'medicineId': doc['medicineId'],
      //     'addedAt': doc['addedAt'],
      //   };
      // }).toList();

      // List<Map<String, dynamic>> favorites = favoritesSnapshot.docs.map((doc) {
      //   return {
      //     'medicineId': doc['medicineId'],
      //     'addedAt': doc['addedAt'],
      //   };
      // }).toList();

      // إنشاء نموذج المستخدم
      // UserModel userData = UserModel.fromMap({
      //   ...userDoc.data() as Map<String, dynamic>,
      //   'favorites': favorites,
      // });

      // تحضير بيانات المستخدم للإرسال
      // Map<String, dynamic> userData = {
      //   'userId': userDoc['userId'],
      //   'name': userDoc['name'],
      //   'Email': userDoc['Email'],
      //   'address': userDoc['address'],
      //   'phone': userDoc['phone'],
      //   'userType': userDoc['userType'],
      //   'favorites': favorites,
      // };

      // الانتقال إلى الصفحة الرئيسية مع البيانات

      // تعيين المستخدم في الـ Provider
      // Provider.of<UserProvider>(context, listen: false).setUser(userData);
      //
      // Navigator.pushReplacementNamed(context, '/home');
      // Navigator.pushReplacementNamed(context, '/home', arguments: userData,);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: ${e.toString()}'))
      );
      await FirebaseAuth.instance.signOut();

      // print('خطأ في جلب بيانات المستخدم: $e');
      // ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('حدث خطأ في جلب بيانات المستخدم: $e'))
      // );
      // await FirebaseAuth.instance.signOut(); // تسجيل الخروج في حالة الخطأ

    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.05,
          vertical: screenSize.height * 0.02,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Image.asset('images/pharmacy_logo.png', height: 100),
              Center(
                child: CircleAvatar(
                  radius: screenSize.width * 0.15, // 15% من عرض الشاشة
                  backgroundColor: AppColors.secondary,
                  backgroundImage: AssetImage('assets/logos/pharmacy_logo2.png'),
                  // child: const Text('Osama'),
                ),
              ),
              SizedBox(height: screenSize.height * 0.03),
              Text(
                'تسجيل الدخول',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: screenSize.height * 0.03),
              Text(
                'اكتشف الأدوية والفيتامينات والمزيد.',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenSize.height * 0.05),

              // حقل البريد الإلكتروني
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration("البريد الإلكتروني", Icons.email),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال البريد الإلكتروني';
                  }
                  if (!value.contains('@')) return 'بريد غير صالح';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // كلمة المرور
              TextFormField(
                controller: _passwordController,
                obscureText: _obscureText,
                decoration: _inputDecoration(
                  "كلمة المرور", Icons.lock,).copyWith(suffixIcon: IconButton(
                  icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility,),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                ),),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'أدخل كلمة المرور';
                  if (value.length < 6) return 'كلمة المرور يجب أن تكون على الأقل 6 أحرف';
                  return null;
                },
              ),

              const SizedBox(height: 10),

              // نسيت كلمة المرور؟
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text('تذكرني', style: AppTextStyles.bodyMedium),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed:
                          () =>
                              Navigator.pushReplacementNamed(context, '/forget_password'),
                      child: const Text("نسيت كلمة المرور؟"),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenSize.height * 0.03),
              // زر الدخول
              SizedBox(
                width: double.infinity,
                height: 50,
                child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : CustomButton(onPressed: _login, text: 'تسجيل الدخول'),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(342, 50),
                  side: BorderSide(color: AppColors.borderGray),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                onPressed: () => Navigator.pushReplacementNamed(context, '/signup'),
                child: Text(
                  "ليس لديك حساب؟ سجل الآن",
                  style: AppTextStyles.bodyMedium,
                ),
              ),

              const SizedBox(height: 20),
              // تسجيل الدخول بالوسائل الاجتماعية
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'أو قم بتسجيل الدخول باستخدام',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Image.asset(
                      'assets/images/Googleicon.png',
                      width: 50,
                      height: 50,
                    ),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: Image.asset(
                      'assets/images/Facebook-icon.png',
                      width: 50,
                      height: 50,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
