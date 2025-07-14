import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/styles.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../services/email_verification_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _verificationCodeController = TextEditingController();
  final EmailVerificationService _verificationService = EmailVerificationService();

  bool _isCodeVerified = false;
  bool _isSendingCode = false;
  bool _isVerificationSent = false;
  bool _isPasswordVisible = false;
  bool _isEditing = false;
  bool _changesSaved = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    setState(() {
      _nameController = TextEditingController(text: user?.name ?? '');
      _emailController = TextEditingController(text: user?.email ?? '');
      _phoneController = TextEditingController(text: user?.phone.toString() ?? '');
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.secondary,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.primary,
                padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // IconButton(
                        //   icon: const Icon(Icons.arrow_back, color: Colors.white),
                        //   onPressed: () => Navigator.pop(context),
                        // ),
                        Text('تعديل الحساب', style: AppTextStyles.header),
                        _isEditing
                            ? IconButton(
                          icon: const Icon(Icons.save, color: Colors.white),
                          onPressed: _saveChanges,
                        )
                            : const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _changeProfileImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: AssetImage('assets/images/spa.png')
                            // user?.photoUrl != null
                            //     ? NetworkImage(user!.photoUrl) as ImageProvider
                            //     : const AssetImage('assets/images/default_profile.png'),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit, size: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        label: 'الاسم الكامل',
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال الاسم الكامل';
                          }
                          return null;
                        },
                        onChanged: (_) => _setEditing(true),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _emailController,
                        label: 'البريد الإلكتروني',
                        icon: Icons.email_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال البريد الإلكتروني';
                          }
                          if (!value.contains('@')) {
                            return 'البريد الإلكتروني غير صالح';
                          }
                          return null;
                        },
                        onChanged: (_) => _setEditing(true),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _phoneController,
                        label: 'رقم الهاتف',
                        icon: Icons.phone_android_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال رقم الهاتف';
                          }
                          if (value.length < 9) {
                            return 'رقم الهاتف يجب أن يكون 9 أرقام على الأقل';
                          }
                          return null;
                        },
                        onChanged: (_) => _setEditing(true),
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(),

                      if (_isVerificationSent) ...[
                        const SizedBox(height: 16),
                        _buildVerificationCodeField(),
                      ],

                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _isSendingCode ? null : _submitForm,
                          child: _isSendingCode
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                            _isVerificationSent
                                ? (_isCodeVerified
                                ? (_changesSaved ? 'تم الحفظ' : 'حفظ التغييرات')
                                : 'تأكيد الكود')
                                : 'إرسال كود التحقق',
                            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                      if (_changesSaved) ...[
                        const SizedBox(height: 16),
                        Text(
                          'تم حفظ التغييرات بنجاح',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
      // bottomNavigationBar: CustomBottomNavBar(
      //   selectedIndex: _currentIndex,
      //   onItemSelected: _onItemTapped,
      // ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.pushReplacementNamed(context, '/home');
      //   },
      //   backgroundColor: AppColors.primary,
      //   child: const Icon(Icons.home, color: Colors.white),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textAlign: TextAlign.right,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDark),
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.accent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.accent),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      textAlign: TextAlign.right,
      onChanged: (_) => _setEditing(true),
      decoration: InputDecoration(
        labelText: 'كلمة المرور الجديدة',
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDark),
        prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.accent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.accent),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (_passwordController.text.isNotEmpty && (value == null || value.length < 6)) {
          return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
        }
        return null;
      },
    );
  }

  // Widget _buildVerificationCodeField() {
  //   return TextFormField(
  //     controller: _verificationCodeController,
  //     keyboardType: TextInputType.number,
  //     textAlign: TextAlign.right,
  //     onChanged: (_) => _setEditing(true),
  //     decoration: InputDecoration(
  //       labelText: 'كود التحقق',
  //       labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDark),
  //       prefixIcon: Icon(Icons.verified_user_outlined, color: AppColors.primary),
  //       border: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(12),
  //         borderSide: BorderSide(color: AppColors.accent),
  //       ),
  //       enabledBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(12),
  //         borderSide: BorderSide(color: AppColors.accent),
  //       ),
  //       filled: true,
  //       fillColor: Colors.white,
  //     ),
  //     validator: (value) {
  //       if (_isVerificationSent && (value == null || value.isEmpty)) {
  //         return 'الرجاء إدخال كود التحقق';
  //       }
  //       return null;
  //     },
  //   );
  // }

  Widget _buildVerificationCodeField() {
    return Column(
      children: [
        TextFormField(
          controller: _verificationCodeController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.right,
          onChanged: (_) => _setEditing(true),
          decoration: InputDecoration(
            labelText: 'كود التحقق',
            labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDark),
            prefixIcon: Icon(Icons.verified_user_outlined, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.accent),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.accent),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (value) {
            if (_isVerificationSent && !_isCodeVerified && (value == null || value.isEmpty)) {
              return 'الرجاء إدخال كود التحقق';
            }
            return null;
          },
        ),
        if (_isVerificationSent && !_isCodeVerified)
          TextButton(
            onPressed: _isSendingCode ? null : _sendVerificationCode,
            child: _isSendingCode
                ? CircularProgressIndicator()
                : Text('إعادة إرسال الكود', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary)),
          ),
      ],
    );
  }

  void _changeProfileImage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تغيير صورة الملف الشخصي', style: AppTextStyles.header),
        content: Text('اختر طريقة لتحميل الصورة', style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _setEditing(true);
              // TODO: Implement camera
            },
            child: Text('الكاميرا', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _setEditing(true);
              // TODO: Implement gallery
            },
            child: Text('معرض الصور', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (!_isVerificationSent) {
        // إرسال كود التحقق
        await _sendVerificationCode();
      } else if (!_isCodeVerified) {
        // التحقق من صحة الكود
        await _verifyCode();
      } else {
        // حفظ التغييرات بعد التحقق
        await _saveChanges();
      }
    }
    // if (_formKey.currentState!.validate()) {
    //   if (!_isVerificationSent) {
    //     // إرسال كود التحقق
    //     setState(() {
    //       _isVerificationSent = true;
    //       _isEditing = true;
    //     });
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text('تم إرسال كود التحقق إلى بريدك الإلكتروني', style: AppTextStyles.bodyMedium),
    //         backgroundColor: AppColors.success,
    //       ),
    //     );
    //   } else {
    //     // التحقق وحفظ التغييرات
    //     await _saveChanges();
    //   }
    // }
  }

  Future<void> _sendVerificationCode() async {
    setState(() => _isSendingCode = true);

    try {
      await _verificationService.sendVerificationCode(_emailController.text);

      setState(() {
        _isVerificationSent = true;
        _isEditing = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إرسال كود التحقق إلى بريدك الإلكتروني', style: AppTextStyles.bodyMedium),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في إرسال كود التحقق: $e', style: AppTextStyles.bodyMedium),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSendingCode = false);
    }
  }

  Future<void> _verifyCode() async {
    try {
      bool isVerified = await _verificationService.verifyCode(
        _emailController.text,
        _verificationCodeController.text,
      );

      if (isVerified) {
        setState(() => _isCodeVerified = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم التحقق من الكود بنجاح', style: AppTextStyles.bodyMedium),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في التحقق: $e', style: AppTextStyles.bodyMedium),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate() && _isCodeVerified) {
      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final authUser = FirebaseAuth.instance.currentUser;
        final currentUser = userProvider.user;

        if (authUser != null && currentUser != null) {
          // التحقق إذا كان البريد الإلكتروني قد تغير
          if (_emailController.text != currentUser.email) {
            await authUser.verifyBeforeUpdateEmail(_emailController.text);
          }

          // تحديث البيانات في Firebase
          await FirebaseFirestore.instance.collection('users').doc(authUser.uid).update({
            'name': _nameController.text,
            'email': _emailController.text,
            'phone': _phoneController.text,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          // تحديث بيانات المستخدم في Provider
          final updatedUser = UserModel(
            userId: currentUser.userId,
            name: _nameController.text,
            email: _emailController.text,
            phone: int.parse(_phoneController.text),
            address: currentUser.address,
            password: '',
            userType: currentUser.userType,
            favorites: currentUser.favorites,
          );
          userProvider.setUser(updatedUser);

          // تحديث كلمة المرور إذا تم إدخالها
          if (_passwordController.text.isNotEmpty) {
            await authUser.updatePassword(_passwordController.text);
          }

          setState(() {
            _changesSaved = true;
            _isEditing = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حفظ التغييرات بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'حدث خطأ أثناء حفظ التغييرات';
        if (e.code == 'requires-recent-login') {
          errorMessage = 'يجب تسجيل الدخول حديثاً لإجراء هذا التغيير';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ غير متوقع: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveChanges2() async {
    if (_formKey.currentState!.validate()) {
      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final authUser = FirebaseAuth.instance.currentUser;
        final currentUser = userProvider.user;

        if (authUser != null && currentUser != null) {
          // تحديث البيانات في Firebase
          await FirebaseFirestore.instance.collection('users').doc(authUser.uid).update({
            'name': _nameController.text,
            'phone': _phoneController.text,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          // تحديث بيانات المستخدم في Provider
          final updatedUser = UserModel(
            userId: currentUser.userId,
            name: _nameController.text,
            email: currentUser.email ?? _emailController.text,
            phone: int.parse(_phoneController.text),
            address: '',
            password: '',
            userType: '',
            favorites: [],
            // photoUrl: currentUser.photoUrl,
          );
          userProvider.setUser(updatedUser);

          // تحديث كلمة المرور إذا تم إدخالها
          if (_passwordController.text.isNotEmpty) {
            await authUser.updatePassword(_passwordController.text);
          }

          setState(() {
            _changesSaved = true;
            _isEditing = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حفظ التغييرات بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _setEditing(bool editing) {
    if (editing != _isEditing) {
      setState(() {
        _isEditing = editing;
        if (editing) {
          _changesSaved = false;
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }
}