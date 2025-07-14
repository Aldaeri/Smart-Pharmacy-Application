import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/styles.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _signInWithEmailPassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'يرجى إدخال البريد الإلكتروني وكلمة المرور.';
        _isLoading = false;
      });
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ غير متوقع.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

// Future<void> _signInWithEmailPassword() async {
  //   setState(() {
  //     _isLoading = true;
  //     _errorMessage = null;
  //   });
  //
  //   if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
  //     setState(() {
  //       _errorMessage = 'يرجى إدخال البريد الإلكتروني وكلمة المرور.';
  //       _isLoading = false;
  //     });
  //     return;
  //   }

    // try {
    //   await FirebaseAuth.instance.signInWithEmailAndPassword(
    //     email: _emailController.text.trim(),
    //     password: _passwordController.text,
    //   );
    //   Navigator.pushReplacementNamed(context, '/home');
    // } on FirebaseAuthException catch (e) {
    //   setState(() {
    //     _errorMessage = e.message;
    //   });
    // } catch (e) {
    //   setState(() {
    //     _errorMessage = 'حدث خطأ غير متوقع.';
    //   });
    // } finally {
    //   setState(() {
    //     _isLoading = false;
    //   });
    // }
  // }

  @override
  Widget build(BuildContext context) {
    // احصل على حجم الشاشة مرة واحدة في بداية الـ build لتجنب التكرار
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        // padding: const EdgeInsets.all(20),
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.05,
          // 5% من عرض الشاشة كـ padding أفقي
          vertical:
              20, // يمكن ترك العمودي ثابتًا أو جعله نسبيًا أيضًا screenSize.height * 0.02
        ),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Center(
              child: CircleAvatar(
                radius: screenSize.width * 0.15, // 15% من عرض الشاشة
                backgroundColor: AppColors.secondary,
                backgroundImage: AssetImage('images.png'),
                child: const Text('Osama'),
              ),
            ),
            // const SizedBox(height: 30),
            SizedBox(height: screenSize.height * 0.03),

            Text(
              'مرحباً،',
              // قد تحتاج لتعديل AppTextStyles لتقبل تغيير الحجم أو استخدام copyWith
              style: AppTextStyles.header.copyWith(
                fontSize: screenSize.width * 0.08, // مثال: 6% من عرض الشاشة
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(height: screenSize.height * 0.01),
            // 1% من ارتفاع الشاشة
            Text(
              'اكتشف الأدوية والفيتامينات والمزيد.',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            // const SizedBox(height: 40),
            SizedBox(height: screenSize.height * 0.03),
            // 3% من ارتفاع الشاشة
            // حقول الإدخال
            const CustomTextField(
              hintText: 'البريد الإلكتروني',
              prefixIcon: Icons.email,
            ),
            const SizedBox(height: 20),
            const CustomTextField(
              hintText: 'كلمة المرور',
              prefixIcon: Icons.lock,
              isPassword: true,
            ),
            const SizedBox(height: 10),

            // تذكرني ونسيت كلمة المرور
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text('تذكرني', style: AppTextStyles.bodyMedium),
                ),
                TextButton(
                  onPressed:
                      () => Navigator.pushNamed(context, '/forget_password'),
                  child: Text(
                    'هل نسيت كلمة المرور؟',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              ],
            ),
            // const SizedBox(height: 30),
            SizedBox(height: screenSize.height * 0.03),
            // 3% من ارتفاع الشاشة

            // زر تسجيل الدخول
            CustomButton(
              text: 'تسجيل الدخول',
              onPressed: () => Navigator.pushNamed(context, '/home'),
            ),
            const SizedBox(height: 20),
            // زر إنشاء حساب
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(342, 56),
                side: BorderSide(color: AppColors.borderGray),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              child: Text('إنشاء حساب', style: AppTextStyles.bodyMedium),
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
    );
  }
}
