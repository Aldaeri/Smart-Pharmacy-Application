import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/medicine_card.dart';
import '../models/medicine_model.dart';
import '../models/medicine_type.dart';

class CategoryMedicinesScreen extends StatefulWidget {
  final MedicineType medicineType;

  const CategoryMedicinesScreen({super.key, required this.medicineType});

  @override
  State<CategoryMedicinesScreen> createState() =>
      _CategoryMedicinesScreenState();
}

class _CategoryMedicinesScreenState extends State<CategoryMedicinesScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medicineType.displayName),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ابحث في ${widget.medicineType.displayName}',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      body: _buildMedicinesList(),
    );
  }

  Widget _buildMedicinesList() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('medicines')
              .where(
                'medicineType',
                isEqualTo: widget.medicineType.toString().split('.').last,
              )
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('حدث خطأ: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'لا توجد أدوية في تصنيف ${widget.medicineType.displayName}',
            ),
          );
        }

        List<Medicine> medicines =
            snapshot.data!.docs
                .map((doc) => Medicine.fromFirestore(doc))
                .where(
                  (medicine) =>
                      medicine.medicineName.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ) ||
                      medicine.scientificMaterial.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ),
                )
                .toList();
        // FirebaseFirestore.instance
        //     .collection('medicines')
        //     .where('medicineType', isEqualTo: widget.medicineType.toString().split('.').last,)
        //     .where('searchKeywords', arrayContains: _searchQuery.toLowerCase())
        //     .snapshots();

        if (medicines.isEmpty) {
          return const Center(child: Text('لا توجد نتائج للبحث'));
        }

        final medicines2 =
            snapshot.data!.docs
                .map((doc) => Medicine.fromFirestore(doc))
                .toList();

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          itemCount: medicines.length,
          itemBuilder: (context, index) {
            return MedicineCard(medicine: medicines[index]);
          },
        );
      },
    );
  }
}
