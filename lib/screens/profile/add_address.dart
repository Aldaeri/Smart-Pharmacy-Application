import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/styles.dart';

class AddAddress extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdd;

  const AddAddress({super.key, required this.onAdd});

  @override
  State<AddAddress> createState() => _AddAddressState();
}

class _AddAddressState extends State<AddAddress> {
  final TextEditingController _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onAdd({'address': _addressController.text});
      Navigator.pop(context, {'address': _addressController.text});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        title: Text('إضافة عنوان', style: AppTextStyles.header),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'أدخل عنوانك',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال عنوان صالح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: Text('حفظ العنوان', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddAddress2 extends StatefulWidget {
  final Function(Map<String, String>) onAdd;

  const AddAddress2({super.key, required this.onAdd});

  @override
  State<AddAddress2> createState() => _AddAddress2State();
}

class _AddAddress2State extends State<AddAddress2> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        title: Text('إضافة عنوان جديد', style: AppTextStyles.header),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
            _buildTextField(
            controller: _titleController,
            label: 'اسم العنوان',
            icon: Icons.title,
            validator: (value) => value!.isEmpty ? 'الرجاء إدخال اسم العنوان' : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _addressController,
            label: 'العنوان التفصيلي',
            icon: Icons.location_city,
            validator: (value) => value!.isEmpty ? 'الرجاء إدخال العنوان' : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _cityController,
            label: 'المدينة',
            icon: Icons.place,
            validator: (value) => value!.isEmpty ? 'الرجاء إدخال المدينة' : null,
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _submitForm,
              child: Text('حفظ العنوان', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
            ),
          )],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.accent),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: validator,
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      widget.onAdd({
        'title': _titleController.text,
        'address': _addressController.text,
        'city': _cityController.text,
      });
      Navigator.pop(context);
    }
  }
}