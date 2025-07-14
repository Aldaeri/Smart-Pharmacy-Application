import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/styles.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'email_sent.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  _ForgetPasswordScreenState createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _sendResetPasswordEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EmailSent(email: _emailController.text.trim()),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'لا يوجد حساب مرتبط بهذا البريد الإلكتروني';
          break;
        case 'invalid-email':
          errorMessage = 'البريد الإلكتروني غير صالح';
          break;
        default:
          errorMessage = 'حدث خطأ، يرجى المحاولة مرة أخرى';
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
                'نسيت كلمة المرور',
                style: AppTextStyles.header.copyWith(color: AppColors.textDark),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 20),
              Text(
                'لا تقلق، أدخل بريدك الإلكتروني\nوسنرسل لك رابط إعادة تعيين كلمة المرور.',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 40),

              // حقل البريد الإلكتروني
              CustomTextField(
                controller: _emailController,
                hintText: 'البريد الإلكتروني',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال البريد الإلكتروني';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'البريد الإلكتروني غير صالح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.red),
                  textAlign: TextAlign.right,
                ),

              const SizedBox(height: 10),

              // زر الإرسال
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : CustomButton(
                text: 'ارسال',
                onPressed: _sendResetPasswordEmail,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}

// class ForgetPasswordScreen extends StatelessWidget {
//   const ForgetPasswordScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//         backgroundColor: AppColors.background,
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             Text(
//               'نسيت كلمة المرور',
//               style: AppTextStyles.header.copyWith(color: AppColors.textDark),
//               textAlign: TextAlign.right,
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'لا تقلق، أدخل بريدك الإلكتروني\nوسنرسل لك رابط إعادة تعيين كلمة المرور.',
//               style: AppTextStyles.bodySmall,
//               textAlign: TextAlign.right,
//             ),
//             const SizedBox(height: 40),
//
//             // حقل البريد الإلكتروني
//             const CustomTextField(
//               hintText: 'البريد الإلكتروني',
//             ),
//             const SizedBox(height: 30),
//
//             // زر الإرسال
//             CustomButton(
//               text: 'ارسال',
//               onPressed: () {
//                 // إرسال رابط إعادة التعيين
//                 Navigator.pushNamed(context, '/email_sent');
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(const FigmaToCodeApp());
// }
//
// // Generated by: https://www.figma.com/community/plugin/842128343887142055/
// class FigmaToCodeApp extends StatelessWidget {
//   const FigmaToCodeApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData.dark().copyWith(
//         scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
//       ),
//       home: Scaffold(body: ListView(children: [ForgetPassword()])),
//     );
//   }
// }
//
// class ForgetPassword extends StatelessWidget {
//   const ForgetPassword({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           width: 393,
//           height: 852,
//           clipBehavior: Clip.antiAlias,
//           decoration: BoxDecoration(color: Colors.white),
//           child: Stack(
//             children: [
//               Positioned(
//                 left: 26,
//                 top: 221,
//                 child: Opacity(
//                   opacity: 0.50,
//                   child: Container(
//                     width: 342,
//                     height: 56,
//                     decoration: ShapeDecoration(
//                       color: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         side: BorderSide(
//                           width: 1,
//                           color: const Color(0xFF707070),
//                         ),
//                         borderRadius: BorderRadius.circular(13),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 left: 197,
//                 top: 235,
//                 child: Text(
//                   'البريد الإلكتروني',
//                   textAlign: TextAlign.right,
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontSize: 19,
//                     fontFamily: 'Inter',
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//               ),
//               Positioned(
//                 left: 26,
//                 top: 309,
//                 child: Container(
//                   width: 342,
//                   height: 56,
//                   decoration: ShapeDecoration(
//                     color: const Color(0xFF00676C),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(13),
//                     ),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 left: 174,
//                 top: 325,
//                 child: Text(
//                   'ارسال',
//                   textAlign: TextAlign.right,
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 19,
//                     fontFamily: 'Inter',
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//               ),
//               Positioned(
//                 left: 187,
//                 top: 80,
//                 child: Text(
//                   'نسيت كلمة المرور',
//                   textAlign: TextAlign.right,
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontSize: 25,
//                     fontFamily: 'Inter',
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//               ),
//               Positioned(
//                 left: 119,
//                 top: 131,
//                 child: Text(
//                   'لا تقلق، أدخل بريدك الإلكتروني \nوسنرسل لك رابط إعادة تعيين كلمة المرور.',
//                   textAlign: TextAlign.right,
//                   style: TextStyle(
//                     color: const Color(0xFF968989),
//                     fontSize: 15,
//                     fontFamily: 'Inter',
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//               ),
//               Positioned(
//                 left: 165,
//                 top: 403,
//                 child: Text(
//                   'Submit',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 19,
//                     fontFamily: 'Inter',
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
