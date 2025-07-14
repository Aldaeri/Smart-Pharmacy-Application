import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/styles.dart';
import '../services/email_verification_service.dart';
import '../widgets/custom_button.dart';

class EmailSent extends StatefulWidget {
  final String email;

  const EmailSent({super.key, required this.email});

  @override
  _EmailSentState createState() => _EmailSentState();
}

class _EmailSentState extends State<EmailSent> {
  final EmailVerificationService _verificationService = EmailVerificationService();
  bool _isLoading = false;
  String _message = '';

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      await _verificationService.sendVerificationCode(widget.email);
      setState(() {
        _message = 'تم إعادة إرسال كود التحقق بنجاح';
      });
    } catch (e) {
      setState(() {
        _message = e.toString();
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                'https://via.placeholder.com/256',
                width: 256,
                height: 256,
              ),
              const SizedBox(height: 30),
              Text(
                'تم إرسال بريد إلكتروني\nلإعادة تعيين كلمة المرور',
                style: AppTextStyles.header.copyWith(color: AppColors.textDark),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(widget.email, style: AppTextStyles.bodyLarge),
              const SizedBox(height: 20),
              Text(
                'أمان حسابك هو أولويتنا! لقد أرسلنا لك رابط آمن لتغيير كلمة المرور\nالخاصة بك بأمان والحفاظ على حسابك محمي.',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
              if (_message.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  _message,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _message.contains('نجاح') ? Colors.green : Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 30),
              _isLoading
                  ? CircularProgressIndicator()
                  : CustomButton(
                text: 'تم',
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _isLoading ? null : _resendVerificationEmail,
                child: Text(
                  'إعادة إرسال البريد الإلكتروني',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: _isLoading ? Colors.grey : AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//
// class EmailSent3 extends StatefulWidget {
//   final String email;
//
//   const EmailSent3({super.key, required this.email});
//
//   @override
//   State<EmailSent3> createState() => _EmailSent3State();
// }
//
// class _EmailSent3State extends State<EmailSent3> {
//   final EmailVerificationService _verificationService = EmailVerificationService();
//   bool _isLoading = false;
//
//   Future<void> _resendVerificationEmail() async {
//     setState(() => _isLoading = true);
//
//     await _verificationService.sendVerificationCode(
//       email: widget.email,
//       onSuccess: () {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('تم إعادة إرسال رمز التحقق إلى ${widget.email}')),
//         );
//       },
//       onError: (error) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('حدث خطأ: $error')),
//         );
//       },
//     );
//
//     setState(() => _isLoading = false);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Image.network(
//                 'https://via.placeholder.com/256',
//                 width: 256,
//                 height: 256,
//               ),
//               const SizedBox(height: 30),
//               Text(
//                 'تم إرسال بريد إلكتروني\nلإعادة تعيين كلمة المرور',
//                 style: AppTextStyles.header.copyWith(color: AppColors.textDark),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 20),
//               Text(widget.email, style: AppTextStyles.bodyLarge),
//               const SizedBox(height: 20),
//               Text(
//                 'أمان حسابك هو أولويتنا! لقد أرسلنا لك رابط آمن لتغيير كلمة المرور\nالخاصة بك بأمان والحفاظ على حسابك محمي.',
//                 style: AppTextStyles.bodySmall,
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 50),
//               CustomButton(
//                 text: 'تم',
//                 onPressed: () => Navigator.pop(context),
//               ),
//               const SizedBox(height: 20),
//               TextButton(
//                 onPressed: _isLoading ? null : _resendVerificationEmail,
//                 child: _isLoading
//                     ? const CircularProgressIndicator()
//                     : Text(
//                   'إعادة إرسال البريد الإلكتروني',
//                   style: AppTextStyles.bodyMedium.copyWith(
//                     color: AppColors.primary,
//                     decoration: TextDecoration.underline,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class EmailSent2 extends StatelessWidget {
//   const EmailSent2({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Image.network(
//                 'https://via.placeholder.com/256',
//                 width: 256,
//                 height: 256,
//               ),
//               const SizedBox(height: 30),
//               Text(
//                 'تم إرسال بريد إلكتروني\nلإعادة تعيين كلمة المرور',
//                 style: AppTextStyles.header.copyWith(color: AppColors.textDark),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 20),
//               Text('example@gmail.com', style: AppTextStyles.bodyLarge),
//               const SizedBox(height: 20),
//               Text(
//                 'أمان حسابك هو أولويتنا! لقد أرسلنا لك رابط آمن لتغيير كلمة المرور\nالخاصة بك بأمان والحفاظ على حسابك محمي.',
//                 style: AppTextStyles.bodySmall,
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 50),
//               CustomButton(text: 'تم', onPressed: () => Navigator.pop(context)),
//               const SizedBox(height: 20),
//               TextButton(
//                 onPressed: () {},
//                 child: Text(
//                   'إعادة إرسال البريد الإلكتروني',
//                   style: AppTextStyles.bodyMedium.copyWith(
//                     color: AppColors.primary,
//                     decoration: TextDecoration.underline,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
