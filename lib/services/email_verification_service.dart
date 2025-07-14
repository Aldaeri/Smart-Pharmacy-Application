import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

class EmailVerificationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // إرسال كود التحقق إلى البريد الإلكتروني
  Future<String> sendVerificationCode(String email) async {
    try {
      // توليد كود تحقق عشوائي مكون من 6 أرقام
      String verificationCode = generateRandomCode(6);

      // حفظ الكود في Firestore مع وقت انتهاء الصلاحية (10 دقائق)
      await _firestore.collection('emailVerifications').doc(email).set({
        'code': verificationCode,
        'createdAt': Timestamp.now(),
        'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(minutes: 10))),
        'verified': false,
      });

      // إرسال البريد الإلكتروني (في الواقع العملي، استخدم خدمة بريدية حقيقية)
      await _sendEmail(email, verificationCode);

      return verificationCode; // يمكنك إرجاع الكود لأغراض الاختبار
    } catch (e) {
      throw 'فشل في إرسال كود التحقق: ${e.toString()}';
    }
  }

  // التحقق من صحة الكود المدخل
  Future<bool> verifyCode(String email, String userEnteredCode) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('emailVerifications').doc(email).get();

      if (!doc.exists) {
        throw 'لم يتم إرسال كود تحقق لهذا البريد الإلكتروني';
      }

      // التحقق من انتهاء صلاحية الكود
      Timestamp expiresAt = doc['expiresAt'];
      if (DateTime.now().isAfter(expiresAt.toDate())) {
        throw 'انتهت صلاحية كود التحقق، يرجى طلب كود جديد';
      }

      // التحقق من تطابق الكود
      if (doc['code'] == userEnteredCode) {
        // تحديث الحالة إلى تم التحقق
        await _firestore.collection('emailVerifications').doc(email).update({
          'verified': true,
        });
        return true;
      } else {
        throw 'كود التحقق غير صحيح';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  // توليد كود عشوائي
  String generateRandomCode(int length) {
    Random random = Random();
    String code = '';
    for (int i = 0; i < length; i++) {
      code += random.nextInt(10).toString();
    }
    return code;
  }

  // دالة محاكاة لإرسال البريد الإلكتروني
  Future<void> _sendEmail(String email, String code) async {
    // في التطبيق الحقيقي، استخدم خدمة مثل SendGrid أو Mailgun أو Firebase Cloud Functions
    print('تم إرسال كود التحقق $code إلى $email');
    // يمكنك تفعيل هذا الجزء عند توصيل خدمة البريد الإلكتروني الحقيقية
    /*
    final response = await http.post(
      Uri.parse('https://your-email-service.com/api/send'),
      body: {
        'email': email,
        'subject': 'كود التحقق لتعديل الملف الشخصي',
        'message': 'كود التحقق الخاص بك هو: $code',
      },
    );
    if (response.statusCode != 200) {
      throw 'فشل في إرسال البريد الإلكتروني';
    }
    */
  }
}

class EmailVerificationService3 {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // إرسال كود التحقق إلى البريد الإلكتروني
  Future<String> sendVerificationCode(String email) async {
    try {
      // توليد كود تحقق عشوائي مكون من 6 أرقام
      String verificationCode = generateRandomCode(6);

      // حفظ الكود في Firestore مع وقت انتهاء الصلاحية (10 دقائق)
      await _firestore.collection('emailVerifications').doc(email).set({
        'code': verificationCode,
        'createdAt': Timestamp.now(),
        'expiresAt': Timestamp.fromDate(DateTime.now().add(Duration(minutes: 10))),
        'verified': false,
      });

      // في الواقع العملي، هنا ستقوم بإرسال البريد الإلكتروني باستخدام خدمة بريدية
      // هذا مثال بسيط للتوضيح فقط
      await _sendEmail(email, verificationCode);

      return 'تم إرسال كود التحقق إلى بريدك الإلكتروني';
    } catch (e) {
      throw 'فشل في إرسال كود التحقق: ${e.toString()}';
    }
  }

  // التحقق من صحة الكود المدخل
  Future<bool> verifyCode(String email, String userEnteredCode) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('emailVerifications').doc(email).get();

      if (!doc.exists) {
        throw 'لم يتم إرسال كود تحقق لهذا البريد الإلكتروني';
      }

      // التحقق من انتهاء صلاحية الكود
      Timestamp expiresAt = doc['expiresAt'];
      if (DateTime.now().isAfter(expiresAt.toDate())) {
        throw 'انتهت صلاحية كود التحقق، يرجى طلب كود جديد';
      }

      // التحقق من تطابق الكود
      if (doc['code'] == userEnteredCode) {
        // تحديث الحالة إلى تم التحقق
        await _firestore.collection('emailVerifications').doc(email).update({
          'verified': true,
        });
        return true;
      } else {
        throw 'كود التحقق غير صحيح';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  // توليد كود عشوائي
  String generateRandomCode(int length) {
    Random random = Random();
    String code = '';
    for (int i = 0; i < length; i++) {
      code += random.nextInt(10).toString();
    }
    return code;
  }

  // دالة محاكاة لإرسال البريد الإلكتروني (في الواقع ستستخدم خدمة بريدية حقيقية)
  Future<void> _sendEmail(String email, String code) async {
    // في التطبيق الحقيقي، استخدم خدمة مثل SendGrid أو Mailgun أو Firebase Cloud Functions
    print('تم إرسال كود التحقق $code إلى $email');
    // مثال باستخدام API خارجي (تعديله حسب احتياجاتك):

    final response = await http.post(
      Uri.parse('https://your-email-service.com/api/send'),
      body: {
        'email': email,
        'subject': 'كود التحقق',
        'message': 'كود التحقق الخاص بك هو: $code',
      },
    );
    if (response.statusCode != 200) {
      throw 'فشل في إرسال البريد الإلكتروني';
    }

  }
}

// class EmailVerificationService2 {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   // إرسال رمز التحقق إلى البريد الإلكتروني
//   Future<void> sendVerificationCode({
//     required String email,
//     required VoidCallback onSuccess,
//     required Function(String) onError,
//   }) async {
//     try {
//       // إنشاء رمز تحقق عشوائي مكون من 6 أرقام
//       final verificationCode = _generateVerificationCode();
//
//       // تخزين الرمز في Firestore مع وقت انتهاء الصلاحية (10 دقائق)
//       await _firestore.collection('emailVerifications').doc(email).set({
//         'code': verificationCode,
//         'createdAt': FieldValue.serverTimestamp(),
//         'expiresAt': FieldValue.serverTimestamp(),
//       });
//
//       // هنا يمكنك إضافة خدمة إرسال البريد الإلكتروني الفعلية
//       // في هذا المثال سنستخدم إرسال البريد من Firebase Auth كمثال
//       await _auth.sendPasswordResetEmail(email: email);
//
//       onSuccess();
//     } catch (e) {
//       onError(e.toString());
//     }
//   }
//
//   // التحقق من صحة رمز التحقق
//   Future<bool> verifyCode({
//     required String email,
//     required String code,
//   }) async {
//     try {
//       final doc = await _firestore.collection('emailVerifications').doc(email).get();
//
//       if (!doc.exists) {
//         return false;
//       }
//
//       final storedCode = doc.data()?['code'] as String?;
//       final expiresAt = (doc.data()?['expiresAt'] as Timestamp?)?.toDate();
//
//       if (storedCode == null || expiresAt == null) {
//         return false;
//       }
//
//       // التحقق من تطابق الرمز وانتهاء الصلاحية
//       if (storedCode == code && DateTime.now().isBefore(expiresAt)) {
//         // حذف الرمز بعد التحقق منه بنجاح
//         await _firestore.collection('emailVerifications').doc(email).delete();
//         return true;
//       }
//
//       return false;
//     } catch (e) {
//       debugPrint('Verification error: $e');
//       return false;
//     }
//   }
//
//   // إنشاء رمز تحقق عشوائي مكون من 6 أرقام
//   String _generateVerificationCode() {
//     final random = Random();
//     return List.generate(6, (index) => random.nextInt(10)).join();
//   }
// }
