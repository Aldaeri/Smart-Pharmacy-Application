import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/styles.dart';
import '../widgets/custom_button.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _agreeToTerms = false;
  bool _isLoading = false;
  bool _obscureText = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      _showSnackBar('يجب الموافقة على الشروط والأحكام');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authResult = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final uid = authResult.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'userId': uid,
        'name': "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}",
        'Email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'password': _passwordController.text.trim(),
        'userType': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/account_created');
    } on FirebaseAuthException catch (e) {
      _showSnackBar(_getFirebaseError(e.code));
      print('FirebaseAuth Exception: ${e.code}');
    } catch (e) {
      _showSnackBar('حدث خطأ غير متوقع أثناء إنشاء الحساب');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _getFirebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';
      default:
        return 'فشل في إنشاء الحساب. حاول مرة أخرى.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text('إنشاء حساب', style: AppTextStyles.header.copyWith(color: AppColors.textDark)),
              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      keyboardType: TextInputType.name,
                      decoration: _inputDecoration("الاسم الأول", Icons.text_fields),
                      // hintText: 'الاسم الأول',
                      // autofillHints: 'الاسم الأول',
                      validator: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال الاسم الأول' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      keyboardType: TextInputType.name,
                      decoration: _inputDecoration('الاسم الأخير',Icons.text_fields),
                      validator: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال الاسم الأخير' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _emailController,
                decoration: _inputDecoration('البريد الإلكتروني',Icons.email),
                // prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'الرجاء إدخال البريد الإلكتروني';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'صيغة البريد الإلكتروني غير صحيحة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _phoneController,
                decoration: _inputDecoration('رقم الهاتف' , Icons.phone),
                // prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) =>
                value == null || value.trim().isEmpty ? 'الرجاء إدخال رقم الهاتف' : null,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _passwordController,
                obscureText: _obscureText,
                decoration: _inputDecoration(
                  "كلمة المرور", Icons.lock,).copyWith(suffixIcon: IconButton(
                  icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility,),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                ),),
                // prefixIcon: Icons.lock,
                // isPassword: true,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'الرجاء إدخال كلمة المرور';
                  if (value.length < 6) return 'كلمة المرور يجب أن تحتوي على 6 أحرف على الأقل';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    onChanged: (value) => setState(() => _agreeToTerms = value!),
                  ),
                  const Text('أوافق على الشروط والأحكام'),
                ],
              ),
              const SizedBox(height: 20),

              // CustomButton(
              //   text: 'إنشاء حساب',
              //   onPressed: _signUp,
              //   isLoading: _isLoading,
              // ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(onPressed: _signUp, text: 'إنشاء حساب',),
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
                onPressed: () => Navigator.pushReplacementNamed(context, '/welcome'),
                child: Text(
                  "لدي حساب تسجيل الدخول",
                  style: AppTextStyles.bodyMedium,
                ),
              ),
              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Divider(color: AppColors.borderGray)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('أو سجل باستخدام', style: AppTextStyles.bodySmall),
                  ),
                  Expanded(child: Divider(color: AppColors.borderGray)),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Image.asset('assets/images/Googleicon.png', width: 50, height: 50,),
                    onPressed: _isLoading ? null : () => _signInWithGoogle(context),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: Image.asset('assets/images/Facebook-icon.png', width: 50, height: 50,),
                    onPressed: _isLoading ? null : () => _signInWithFacebook(context),
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

  Future<void> _signInWithGoogle(BuildContext context) async {
    // TODO: Implement Google sign-in
  }

  Future<void> _signInWithFacebook(BuildContext context) async {
    // TODO: Implement Facebook sign-in
  }
}
