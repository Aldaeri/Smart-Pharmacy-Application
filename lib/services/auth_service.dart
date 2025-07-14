import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _userEmailKey = 'user_email';
  static const String _userPasswordKey = 'user_password';

  // تسجيل الدخول وحفظ البيانات
  static Future<UserCredential?> login(String email, String password) async {
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // حفظ بيانات تسجيل الدخول محلياً
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userEmailKey, email);
      await prefs.setString(_userPasswordKey, password);

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // تسجيل الخروج وحذف البيانات المحفوظة
  static Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();

      // حذف بيانات تسجيل الدخول المحفوظة
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userEmailKey);
      await prefs.remove(_userPasswordKey);
    } catch (e) {
      rethrow;
    }
  }

  // التحقق من وجود بيانات تسجيل دخول محفوظة
  static Future<Map<String, String>?> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_userEmailKey);
    final password = prefs.getString(_userPasswordKey);

    if (email != null && password != null) {
      return {'email': email, 'password': password};
    }
    return null;
  }
}