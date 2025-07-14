import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/colors.dart';
import '../constants/styles.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class PasswordResetScreen extends StatefulWidget {
  final String email;

  const PasswordResetScreen({super.key, required this.email});

  @override
  _PasswordResetScreenState createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String _errorMessage = '';

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'كلمتا المرور غير متطابقتين';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // إذا كنت تستخدم كود التحقق، تأكد من التحقق منه أولاً هنا

      // تسجيل الدخول بالمستخدم (للتأكد من صحة البريد الإلكتروني)
      final credential = EmailAuthProvider.credential(
        email: widget.email,
        password: _passwordController.text,
      );

      await FirebaseAuth.instance.currentUser?.reauthenticateWithCredential(credential);

      // أو إذا كنت تريد تغيير كلمة المرور مباشرة:
      await FirebaseAuth.instance.currentUser?.updatePassword(_passwordController.text);

      // إظهار رسالة نجاح والعودة إلى صفحة تسجيل الدخول
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تغيير كلمة المرور بنجاح')),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'كلمة المرور ضعيفة جدًا';
          break;
        case 'requires-recent-login':
          errorMessage = 'يجب تسجيل الدخول مرة أخرى لإكمال هذه العملية';
          break;
        default:
          errorMessage = 'حدث خطأ: ${e.message}';
      }
      setState(() {
        _errorMessage = errorMessage;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ غير متوقع';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'إعادة تعيين كلمة المرور',
                style: AppTextStyles.header.copyWith(color: AppColors.textDark),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 20),
              Text(
                'الرجاء إدخال كلمة المرور الجديدة',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 40),

              // حقل كلمة المرور الجديدة
              CustomTextField(
                controller: _passwordController,
                hintText: 'كلمة المرور الجديدة',
                obscureText: !_isPasswordVisible,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال كلمة المرور';
                  }
                  if (value.length < 8) {
                    return 'يجب أن تكون كلمة المرور 8 أحرف على الأقل';
                  }
                  return null;
                },
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),

              // حقل تأكيد كلمة المرور
              CustomTextField(
                controller: _confirmPasswordController,
                hintText: 'تأكيد كلمة المرور',
                obscureText: !_isConfirmPasswordVisible,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء تأكيد كلمة المرور';
                  }
                  return null;
                },
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),

              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.red),
                  textAlign: TextAlign.right,
                ),

              const SizedBox(height: 30),

              // زر إعادة التعيين
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : CustomButton(
                text: 'إعادة تعيين كلمة المرور',
                onPressed: _resetPassword,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}