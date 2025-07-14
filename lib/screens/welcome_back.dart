import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/styles.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class WelcomeBack extends StatelessWidget {
  const WelcomeBack({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(

          children: [
            const SizedBox(height: 40),
            Column(
              children: [
                const Center(
                  child: CircleAvatar(
                    radius: 64,
                    backgroundImage: AssetImage("assets/images/spa.png"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              'مرحبًا،',
              style: AppTextStyles.header.copyWith(color: AppColors.textDark),
            ),
            const SizedBox(height: 10),
            Text(
              'اكتشف الأدوية والفيتامينات والمزيد.',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textGray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
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
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'هل نسيت كلمة المرور؟',
                style: AppTextStyles.bodySmall,
              ),
            ),
            const SizedBox(height: 30),
            CustomButton(
              text: 'تسجيل الدخول',
              onPressed: () => Navigator.pushNamed(context, '/home'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: Divider(color: AppColors.borderGray)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'أو قم بتسجيل الدخول باستخدام',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
                Expanded(child: Divider(color: AppColors.borderGray)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Image.asset('assets/images/Googleicon.png'),
                  onPressed: () {},
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: Image.asset('assets/images/Facebookico.png'),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              child: Text(
                'إنشاء حساب',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Column(
  //     children: [
  //       Text(
  //         'مرحبًا،',
  //         textAlign: TextAlign.right,
  //         style: TextStyle(
  //           color: Colors.black,
  //           fontSize: 25,
  //           fontFamily: 'Inter',
  //           fontWeight: FontWeight.w400,
  //         ),
  //       ),
  //       Opacity(
  //         opacity: 0.50,
  //         child: Container(
  //           width: 342,
  //           height: 56,
  //           decoration: ShapeDecoration(
  //             color: Colors.white,
  //             shape: RoundedRectangleBorder(
  //               side: BorderSide(width: 1, color: const Color(0xFF707070)),
  //               borderRadius: BorderRadius.circular(13),
  //             ),
  //           ),
  //         ),
  //       ),
  //       Opacity(
  //         opacity: 0.50,
  //         child: Container(
  //           width: 342,
  //           height: 56,
  //           decoration: ShapeDecoration(
  //             color: Colors.white,
  //             shape: RoundedRectangleBorder(
  //               side: BorderSide(width: 1, color: const Color(0xFF707070)),
  //               borderRadius: BorderRadius.circular(13),
  //             ),
  //           ),
  //         ),
  //       ),
  //       Container(
  //         width: 342,
  //         height: 56,
  //         decoration: ShapeDecoration(
  //           color: const Color(0xFF00676C),
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(13),
  //           ),
  //         ),
  //       ),
  //       Container(
  //         width: 342,
  //         height: 56,
  //         decoration: ShapeDecoration(
  //           color: Colors.white,
  //           shape: RoundedRectangleBorder(
  //             side: BorderSide(width: 1, color: const Color(0xFF707070)),
  //             borderRadius: BorderRadius.circular(13),
  //           ),
  //         ),
  //       ),
  //       Opacity(
  //         opacity: 0.50,
  //         child: Container(
  //           transform:
  //               Matrix4.identity()
  //                 ..translate(0.0, 0.0)
  //                 ..rotateZ(0.01),
  //           width: 93,
  //           height: 1,
  //           decoration: ShapeDecoration(
  //             shape: RoundedRectangleBorder(
  //               side: BorderSide(
  //                 width: 1,
  //                 strokeAlign: BorderSide.strokeAlignCenter,
  //                 color: const Color(0xFF707070),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //       Text(
  //         'إنشاء حساب',
  //         textAlign: TextAlign.right,
  //         style: TextStyle(
  //           color: Colors.black,
  //           fontSize: 20,
  //           fontFamily: 'Inter',
  //           fontWeight: FontWeight.w400,
  //         ),
  //       ),
  //       Text(
  //         'تسجيل الدخول',
  //         textAlign: TextAlign.right,
  //         style: TextStyle(
  //           color: Colors.white,
  //           fontSize: 19,
  //           fontFamily: 'Inter',
  //           fontWeight: FontWeight.w400,
  //         ),
  //       ),
  //       Text(
  //         'البريد الإلكتروني',
  //         textAlign: TextAlign.right,
  //         style: TextStyle(
  //           color: Colors.black,
  //           fontSize: 19,
  //           fontFamily: 'Inter',
  //           fontWeight: FontWeight.w400,
  //         ),
  //       ),
  //       Text(
  //         'كلمة المرور',
  //         textAlign: TextAlign.right,
  //         style: TextStyle(
  //           color: Colors.black,
  //           fontSize: 19,
  //           fontFamily: 'Inter',
  //           fontWeight: FontWeight.w400,
  //         ),
  //       ),
  //       Opacity(
  //         opacity: 0.50,
  //         child: Text(
  //           'هل نسيت كلمة المرور؟',
  //           textAlign: TextAlign.right,
  //           style: TextStyle(
  //             color: Colors.black,
  //             fontSize: 14,
  //             fontFamily: 'Inter',
  //             fontWeight: FontWeight.w400,
  //           ),
  //         ),
  //       ),
  //       Text(
  //         'ذكرني',
  //         textAlign: TextAlign.right,
  //         style: TextStyle(
  //           color: Colors.black,
  //           fontSize: 17,
  //           fontFamily: 'Inter',
  //           fontWeight: FontWeight.w400,
  //         ),
  //       ),
  //       Text(
  //         'اكتشف الأدوية والفيتامينات والمزيد.',
  //         textAlign: TextAlign.right,
  //         style: TextStyle(
  //           color: const Color(0xFF968989),
  //           fontSize: 18,
  //           fontFamily: 'Inter',
  //           fontWeight: FontWeight.w400,
  //         ),
  //       ),
  //       SizedBox(
  //         width: 248,
  //         height: 24,
  //         child: Opacity(
  //           opacity: 0.50,
  //           child: Text(
  //             'أو قم بتسجيل الدخول باستخدام',
  //             textAlign: TextAlign.right,
  //             style: TextStyle(
  //               color: Colors.black,
  //               fontSize: 18,
  //               fontFamily: 'Inter',
  //               fontWeight: FontWeight.w400,
  //             ),
  //           ),
  //         ),
  //       ),
  //       Opacity(
  //         opacity: 0.50,
  //         child: Container(
  //           transform:
  //               Matrix4.identity()
  //                 ..translate(0.0, 0.0)
  //                 ..rotateZ(0.01),
  //           width: 93,
  //           height: 1,
  //           decoration: ShapeDecoration(
  //             shape: RoundedRectangleBorder(
  //               side: BorderSide(
  //                 width: 1,
  //                 strokeAlign: BorderSide.strokeAlignCenter,
  //                 color: const Color(0xFF707070),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //       Container(
  //         width: 47,
  //         height: 47,
  //         decoration: ShapeDecoration(
  //           color: Colors.white,
  //           shape: OvalBorder(
  //             side: BorderSide(width: 1, color: const Color(0xFF707070)),
  //           ),
  //         ),
  //       ),
  //       Container(
  //         width: 47,
  //         height: 47,
  //         decoration: ShapeDecoration(
  //           color: Colors.white,
  //           shape: OvalBorder(
  //             side: BorderSide(width: 1, color: const Color(0xFF707070)),
  //           ),
  //         ),
  //       ),
  //       Container(
  //         width: 29,
  //         height: 29,
  //         decoration: BoxDecoration(
  //           image: DecorationImage(
  //             image: NetworkImage("https://placehold.co/29x29"),
  //             fit: BoxFit.cover,
  //           ),
  //           border: Border.all(width: 1),
  //         ),
  //       ),
  //       Container(
  //         width: 29,
  //         height: 29,
  //         decoration: BoxDecoration(
  //           image: DecorationImage(
  //             image: NetworkImage("https://placehold.co/29x29"),
  //             fit: BoxFit.cover,
  //           ),
  //           border: Border.all(width: 1),
  //         ),
  //       ),
  //       Container(
  //         width: 127,
  //         height: 127,
  //         decoration: BoxDecoration(
  //           image: DecorationImage(
  //             image: NetworkImage("https://placehold.co/127x127"),
  //             fit: BoxFit.cover,
  //           ),
  //           border: Border.all(width: 1),
  //         ),
  //       ),
  //       Opacity(
  //         opacity: 0.50,
  //         child: SizedBox(width: 20.50, height: 21.50, child: Stack()),
  //       ),
  //       Opacity(
  //         opacity: 0.50,
  //         child: SizedBox(width: 17.90, height: 18, child: Stack()),
  //       ),
  //       Opacity(
  //         opacity: 0.50,
  //         child: SizedBox(width: 21.49, height: 21.49, child: Stack()),
  //       ),
  //     ],
  //   );
  // }
}
