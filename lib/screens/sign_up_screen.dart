import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_pharmacy_app/constants/colors.dart';
import 'package:smart_pharmacy_app/constants/styles.dart';
import 'package:smart_pharmacy_app/widgets/custom_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم إنشاء الحساب بنجاح")),
      );

      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String message = "حدث خطأ، حاول لاحقًا.";
      if (e.code == 'email-already-in-use') {
        message = 'البريد الإلكتروني مستخدم بالفعل.';
      } else if (e.code == 'weak-password') {
        message = 'كلمة المرور ضعيفة، يجب أن تكون 6 أحرف على الأقل.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        // padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                'قم بإنشاء حسابك',
                style: AppTextStyles.header.copyWith(
                    color: AppColors.textDark,
                    fontSize: 24,
                    fontWeight: FontWeight.bold
                ),
              ),
              // Image.asset('assets/images/pharmacy_logo.png', height: 100),
              // const SizedBox(height: 16),
              // const Text(
              //   'إنشاء حساب جديد',
              //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              // ),
              const SizedBox(height: 30),

              Row(
                children: const [
                  Expanded(
                    child: CustomTextField(
                      hintText: 'الاسم الأول',
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      hintText: 'الاسم الأخير',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              CustomTextField(
                // controller: _emailController,
                hintText: 'البريد الإلكتروني',
                prefixIcon: Icons.email,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: _inputDecoration("البريد الإلكتروني", Icons.email),
                keyboardType: TextInputType.emailAddress,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGray),
                // enabled: true,
                // cursorColor: Colors.white,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'أدخل البريد الإلكتروني';
                  if (!value.contains('@')) return 'بريد غير صالح';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const CustomTextField(
                // controller: _phoneController,
                hintText: 'رقم الهاتف',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _passwordController,
                obscureText: _obscureText,
                decoration: _inputDecoration("كلمة المرور", Icons.lock).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'أدخل كلمة المرور';
                  if (value.length < 6) return 'كلمة المرور قصيرة جدًا';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const CustomTextField(
                hintText: 'كلمة المرور',
                prefixIcon: Icons.lock,
                isPassword: true,
              ),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("تسجيل", style: TextStyle(fontSize: 18)),
                ),
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("لديك حساب؟ تسجيل الدخول"),
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
