import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/styles.dart';
import '../services/email_verification_service.dart';
import 'password_reset_screen.dart';

class VerificationCodeScreen extends StatefulWidget {
  final String email;

  const VerificationCodeScreen({super.key, required this.email});

  @override
  _VerificationCodeScreenState createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  final EmailVerificationService _verificationService = EmailVerificationService();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _verifyCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      bool isVerified = await _verificationService.verifyCode(
        widget.email,
        _codeController.text,
      );

      if (isVerified) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PasswordResetScreen(email: widget.email),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
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
        title: Text('تحقق من البريد الإلكتروني'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'أدخل كود التحقق',
              style: AppTextStyles.header,
            ),
            SizedBox(height: 10),
            Text(
              'لقد أرسلنا كود التحقق إلى ${widget.email}',
              style: AppTextStyles.bodyMedium,
            ),
            SizedBox(height: 30),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'كود التحقق',
                border: OutlineInputBorder(),
              ),
            ),
            if (_errorMessage.isNotEmpty) ...[
              SizedBox(height: 20),
              Text(
                _errorMessage,
                style: AppTextStyles.bodySmall.copyWith(color: Colors.red),
              ),
            ],
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyCode,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('تحقق'),
            ),
            TextButton(
              onPressed: () {
                // إعادة إرسال الكود
              },
              child: Text('إعادة إرسال الكود'),
            ),
          ],
        ),
      ),
    );
  }
}

// class VerificationCodeScreen extends StatefulWidget {
//   final String email;
//
//   const VerificationCodeScreen({super.key, required this.email});
//
//   @override
//   State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
// }
//
// class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
//   final EmailVerificationService _verificationService = EmailVerificationService();
//   final TextEditingController _codeController = TextEditingController();
//   bool _isLoading = false;
//
//   Future<void> _verifyCode() async {
//     setState(() => _isLoading = true);
//
//     final isValid = await _verificationService.verifyCode(
//       email: widget.email,
//       code: _codeController.text.trim(),
//     );
//
//     setState(() => _isLoading = false);
//
//     if (isValid) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => EmailSent(email: widget.email),
//         ),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('رمز التحقق غير صحيح أو انتهت صلاحيته')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: const Text('تحقق من البريد الإلكتروني'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             Text(
//               'أدخل رمز التحقق المكون من 6 أرقام الذي تم إرساله إلى ${widget.email}',
//               style: AppTextStyles.bodyLarge,
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 30),
//             TextField(
//               controller: _codeController,
//               keyboardType: TextInputType.number,
//               maxLength: 6,
//               decoration: InputDecoration(
//                 labelText: 'رمز التحقق',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             CustomButton(
//               text: 'تحقق',
//               onPressed: _isLoading ? null : _verifyCode,
//               isLoading: _isLoading,
//             ),
//             const SizedBox(height: 20),
//             TextButton(
//               onPressed: () {
//                 // إعادة إرسال الرمز
//                 _verificationService.sendVerificationCode(
//                   email: widget.email,
//                   onSuccess: () {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('تم إعادة إرسال رمز التحقق إلى ${widget.email}')),
//                     );
//                   },
//                   onError: (error) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('حدث خطأ: $error')),
//                     );
//                   },
//                 );
//               },
//               child: Text(
//                 'إعادة إرسال الرمز',
//                 style: AppTextStyles.bodyMedium.copyWith(
//                   color: AppColors.primary,
//                   decoration: TextDecoration.underline,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }