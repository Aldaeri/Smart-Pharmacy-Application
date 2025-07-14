import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medicine_model.dart';
import '../constants/colors.dart';
import '../widgets/medicine_card.dart';

class AllMedicinesScreen extends StatefulWidget {
  final String searchQuery;
  final Set<String> initialFavorites;
  final Function(String) onFavoritePressed;

  const AllMedicinesScreen({
    super.key,
    this.searchQuery = '',
    required this.initialFavorites,
    required this.onFavoritePressed,
  });

  @override
  State<AllMedicinesScreen> createState() => _AllMedicinesScreenState();
}

class _AllMedicinesScreenState extends State<AllMedicinesScreen> {
  late Set<String> _favorites;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _favorites = widget.initialFavorites;
  }

  void _handleFavoritePressed(String medicineId) {
    setState(() {
      if (_favorites.contains(medicineId)) {
        _favorites.remove(medicineId);
        _showRemovedSnackbar(medicineId);
      } else {
        _favorites.add(medicineId);
        _showAddedSnackbar(medicineId);
      }
    });
    widget.onFavoritePressed(medicineId);
  }

  void _showAddedSnackbar(String medicineId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تمت إضافة الدواء إلى المفضلة'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'تراجع',
          textColor: Colors.white,
          onPressed: () {
            _handleFavoritePressed(medicineId);
          },
        ),
      ),
    );
  }

  void _showRemovedSnackbar(String medicineId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تمت إزالة الدواء من المفضلة'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'تراجع',
          textColor: Colors.white,
          onPressed: () {
            _handleFavoritePressed(medicineId);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جميع الأدوية'),
        titleSpacing: 80.0,
        leading: IconButton(
          icon: AnimatedIcon(
            icon: AnimatedIcons.menu_arrow,
            progress: const AlwaysStoppedAnimation(5),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: _buildMedicinesList(context),
      ),
    );
  }

  Widget _buildMedicinesList(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('medicines').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 50, color: Colors.red),
                const SizedBox(height: 10),
                Text('حدث خطأ: ${snapshot.error}'),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.medication, size: 50, color: AppColors.primary),
                const SizedBox(height: 10),
                Text(
                  'لا توجد أدوية متاحة',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: AppColors.textGray,
                  ),
                ),
              ],
            ),
          );
        }

        List<Medicine> medicines =
            snapshot.data!.docs
                .map((doc) => Medicine.fromFirestore(doc))
                .where(
                  (medicine) =>
                      widget.searchQuery.isEmpty ||
                      medicine.medicineName.toLowerCase().contains(
                        widget.searchQuery.toLowerCase(),
                      ) ||
                      medicine.scientificMaterial.toLowerCase().contains(
                        widget.searchQuery.toLowerCase(),
                      ),
                )
                .toList();

        if (medicines.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 50, color: AppColors.primary),
                const SizedBox(height: 10),
                Text(
                  'لا توجد نتائج للبحث',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: AppColors.textGray,
                  ),
                ),
              ],
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
            final childAspectRatio = constraints.maxWidth > 600 ? 0.8 : 0.7;

            return GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: screenWidth * 0.04,
                mainAxisSpacing: screenWidth * 0.04,
              ),
              itemCount: medicines.length,
              itemBuilder: (context, index) {
                final animation = AlwaysStoppedAnimation(1.0);
                return ScaleTransition(
                  scale: animation,
                  child: FadeTransition(
                    opacity: animation,
                    child: MedicineCard(
                      medicine: medicines[index],
                      isFavorite: _favorites.contains(medicines[index].id),
                      onFavoritePressed: () {
                        _handleFavoritePressed(medicines[index].id);
                      },
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}