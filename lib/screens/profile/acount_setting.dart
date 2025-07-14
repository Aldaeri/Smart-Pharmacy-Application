import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/styles.dart';

class EditProfile extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfile({super.key, required this.userData});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['name'] ?? '');
    _emailController = TextEditingController(text: widget.userData['Email'] ?? '');
    _phoneController = TextEditingController(text: widget.userData['phone'] ?? '');
    _addressController = TextEditingController(text: widget.userData['address'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد التحديث'),
        content: const Text('هل أنت متأكد أنك تريد حفظ التغييرات؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('تأكيد')),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final newEmail = _emailController.text.trim();
        final name = _nameController.text.trim();
        final phone = _phoneController.text.trim();
        final address = _addressController.text.trim();

        // Only update email if changed
        if (newEmail != user.email) {
          await user.verifyBeforeUpdateEmail(newEmail);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إرسال رابط التحقق إلى البريد الإلكتروني الجديد')),
          );
        }

        // Update Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'name': name,
          'Email': newEmail,
          'phone': phone,
          'address': address,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث البيانات بنجاح')),
        );

        Navigator.pop(context); // Go back
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'حدث خطأ أثناء التحديث';
      if (e.code == 'requires-recent-login') {
        errorMessage = 'يجب تسجيل الدخول مرة أخرى لتحديث البريد الإلكتروني';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'البريد الإلكتروني مستخدم بالفعل';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$errorMessage: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ غير متوقع: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إعدادات الحساب', style: AppTextStyles.header),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage('https://via.placeholder.com/100'),
              ),
              const SizedBox(height: 20),
              _buildTextField(_nameController, 'الاسم الكامل', TextInputType.name),
              const SizedBox(height: 15),
              _buildTextField(_emailController, 'البريد الإلكتروني', TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'الرجاء إدخال البريد الإلكتروني';
                    if (!value.contains('@')) return 'بريد إلكتروني غير صالح';
                    return null;
                  }),
              const SizedBox(height: 15),
              _buildTextField(_phoneController, 'رقم الهاتف', TextInputType.phone),
              const SizedBox(height: 15),
              _buildTextField(_addressController, 'العنوان', TextInputType.text, maxLines: 2),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('حفظ التغييرات', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, TextInputType type,
      {int maxLines = 1, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: type,
      maxLines: maxLines,
      validator: validator ??
              (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال $label';
            }
            return null;
          },
    );
  }
}
