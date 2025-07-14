import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../models/medicine_model.dart';
import '../models/medicine_type.dart';
import '../providers/user_provider.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/medicine_card.dart';
import 'advanced_image_search.dart';
import 'all_products_screen.dart';
import 'category_medicines_screen.dart';
import 'image_analysis.dart';
import 'image_search_screen.dart';
import 'medicine_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  final Set<String> _favorites = {};
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _currentIndex = 4;
  final ScrollController _scrollController = ScrollController();
  late final List<Medicine> medicines; // قائمة الأدوية
  // final Set<String> _favorites; // قائمة المفضلة
  // late final Set<String> _cartItems; // قائمة السلة
  // late final Function(String) _toggleFavorite; // دالة تبديل المفضلة
  late final Function(Medicine) _addToCart;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _checkUserData();
    // medicines = [];
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkUserData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user == null) {
      final user = _auth.currentUser;
      if (user != null) {
        await userProvider.setUserFromFirestore(user.uid);
      }
    }
  }

  Future<void> _loadFavorites() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user?.favorites != null) {
      setState(() {
        _favorites.addAll(
          userProvider.user!.favorites.map(
            (fav) => fav['medicineId'].toString(),
          ),
        );
      });
      return;
    }

    final snapshot =
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .get();

    setState(() {
      _favorites.addAll(
        snapshot.docs.map((doc) => doc['medicineId'] as String),
      );
    });
  }

  Future<void> _toggleFavorite(String medicineId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    setState(() {
      if (_favorites.contains(medicineId)) {
        _favorites.remove(medicineId);
      } else {
        _favorites.add(medicineId);
      }
    });

    final favoritesRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .where('medicineId', isEqualTo: medicineId);

    final existingFavorites = await favoritesRef.get();

    if (existingFavorites.docs.isEmpty) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .add({
            'medicineId': medicineId,
            'addedAt': FieldValue.serverTimestamp(),
          });
    } else {
      for (final doc in existingFavorites.docs) {
        await doc.reference.delete();
      }
    }

    await userProvider.setUserFromFirestore(user.uid);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // شريط البحث والعنوان
          SliverAppBar(
            // expandedHeight: screenHeight * 0.16,
            expandedHeight: screenHeight * 0.15, // ارتفاع أقل للشريط
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _HeaderSection(
                userName: user?.name ?? 'ضيف',
                onSearch: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
              ),
            ),
          ),

          // قسم الفئات
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'الفئات الشهيرة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: MedicineType.values.length,
                      itemBuilder: (context, index) {
                        final type = MedicineType.values[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: InkWell(
                            onTap: () => _handleCategoryTap(context, type),
                            child: Column(
                              children: [
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    _getIconForMedicineType(type),
                                    size: 30,
                                    color: AppColors.primary,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  type.displayName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // قسم الأكثر مبيعاً
          SliverToBoxAdapter(
            child: _buildSectionHeader('الأكثر مبيعاً', 'عرض الكل'),
          ),
          _buildHorizontalProductsList(),

          // قسم العروض الخاصة
          SliverToBoxAdapter(
            child: _buildSectionHeader('صفقة اليوم', 'عرض الكل'),
          ),
          _buildHorizontalProductsList(),

          // قسم الفيتامينات والمكملات
          SliverToBoxAdapter(
            child: _buildSectionHeader(
              'الفيتامينات والمكملات الغذائية',
              'عرض الكل',
            ),
          ),
          _buildVerticalProductsGrid(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _currentIndex,
        onItemSelected: _onItemTapped,
      ),
    );
  }

  Widget _buildSectionHeader(String title, String actionText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => AllMedicinesScreen(
                        searchQuery: '',
                        initialFavorites: _favorites,
                        onFavoritePressed: _toggleFavorite,
                      ),
                ),
              );
            },
            child: Text(
              actionText,
              style: TextStyle(fontSize: 14, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalProductsList() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 245,
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('medicines').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            List<Medicine> allMedicines = snapshot.data!.docs
                .map((doc) => Medicine.fromFirestore(doc))
                .toList();

            // Filter only if searchQuery has value
            List<Medicine> filteredMedicines = _searchQuery.isEmpty
                ? allMedicines
                : allMedicines.where((medicine) {
              final words = _searchQuery
                  .toLowerCase()
                  .split(RegExp(r'\s+'))
                  .where((word) => word.isNotEmpty)
                  .toList();

              final name = medicine.medicineName.toLowerCase();
              final material = medicine.scientificMaterial.toLowerCase();

              return words.any((word) =>
              name.contains(word) || material.contains(word));
            }).toList();

            if (filteredMedicines.isEmpty) {
              return Center(child: Text('لا توجد نتائج للبحث'));
            }

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              itemCount: filteredMedicines.length,
              itemBuilder: (context, index) {
                final medicine = filteredMedicines[index];
                return Container(
                  width: 160,
                  margin: EdgeInsets.only(right: 10),
                  child: MedicineCard(
                    medicine: medicine,
                    isFavorite: _favorites.contains(medicine.id),
                    inCart: false,
                    onFavoritePressed: () => _toggleFavorite(medicine.id),
                    onAddToCart: () {},
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MedicineDetailsScreen(medicine: medicine),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildVerticalProductsGrid() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 5.0),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.705,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('medicines').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                List<Medicine> medicines =
                    snapshot.data!.docs
                        .map((doc) => Medicine.fromFirestore(doc))
                        .where(
                          (medicine) =>
                              _searchQuery.isEmpty ||
                              medicine.medicineName.toLowerCase().contains(
                                _searchQuery.toLowerCase(),
                              ) ||
                              medicine.scientificMaterial
                                  .toLowerCase()
                                  .contains(_searchQuery.toLowerCase()),
                        )
                        .toList();

                // final medicines = snapshot.data!.docs
                //     .map((doc) => Medicine.fromFirestore(doc))
                //     .toList();

                if (index >= medicines.length) return Container();
                // if (index >= medicines.length) {
                //   return Container(); // أو أي عنصر فارغ
                // }

                final medicine = medicines[index];
                return MedicineCard(
                  medicine: medicine,
                  isFavorite: _favorites.contains(medicine.id),
                  inCart: false,
                  // يمكنك تغيير هذا حسب حالة السلة لديك
                  onFavoritePressed: () => _toggleFavorite(medicine.id),
                  onAddToCart: () {
                    // أضف هنا دالة إضافة إلى السلة
                    // مثلاً: _addToCart(medicine);
                    _addToCart(medicine);
                  },
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                MedicineDetailsScreen(medicine: medicine),
                      ),
                    );
                  },
                );
              },
            );
          },
          // childCount: medicines?.length , // أو medicines.length إذا كنت تريد عرض كل
          childCount: 20,
        ),
      ),
    );
  }

  void _handleCategoryTap(BuildContext context, MedicineType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryMedicinesScreen(medicineType: type),
      ),
    );
  }

  IconData _getIconForMedicineType(MedicineType type) {
    switch (type) {
      case MedicineType.tablet:
        return Icons.medication;
      case MedicineType.capsule:
        return Icons.medication_liquid;
      case MedicineType.syrup:
        return Icons.liquor;
      case MedicineType.injection:
        return Icons.medical_services;
      case MedicineType.ointment:
        return Icons.healing;
      case MedicineType.drops:
        return Icons.water_drop;
      case MedicineType.inhaler:
        return Icons.air;
      case MedicineType.other:
        return Icons.medical_information;
    }
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/favorites');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/reminders');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/cart');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
      case 4:
      default:
        Navigator.pushReplacementNamed(context, '/home');
        break;
    }
  }
}

class _HeaderSection extends StatefulWidget {
  final String userName;
  final Function(String) onSearch;

  // final String userName;
  // final Function(String) onSearch;

  const _HeaderSection({required this.userName, required this.onSearch});

  @override
  State<_HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<_HeaderSection> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _favorites = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary, // تغيير لون الخلفية إلى الأبيض
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: 3,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // شعار التطبيق
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'SMART',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              SizedBox(width: 5),
              Text(
                'PHARMACY',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[200],
                ),
              ),
            ],
          ),
          // SizedBox(height: 2),

          // رسالة الترحيب البسيطة
          Text(
            'مرحباً بك في الصيدلية الذكية',
            style: TextStyle(fontSize: 16, color: Colors.grey[400]),
          ),
          SizedBox(height: 3),

          // شريط البحث المعدل
          _buildSearchBar(context),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[100], // لون خلفية فاتح
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey[300]!, width: 2),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.camera_alt, size: 25),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdvancedImageSearchScreen(
                    toggleFavorite: widget.onSearch,
                    favorites: _favorites,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.camera_alt, size: 20),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageAnalysisOnly(),
                ),
              );

              if (result != null && result is String && result.trim().isNotEmpty) {
                // Pass extracted text to search
                widget.onSearch(result);
              }
            },
          ),
          // IconButton(
          //   icon: Icon(Icons.camera_alt, size: 20),
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder:
          //             (context) => ImageSearchScreen(
          //               toggleFavorite: widget.onSearch,
          //               favorites: _favorites,
          //             ),
          //       ),
          //     );
          //   },
          // ),
          Expanded(
            child: TextField(
              textAlign: TextAlign.right,
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث عن الأدوية هنا...',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            widget.onSearch('');
                          },
                        )
                        : null,
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
              onChanged: (value) {
                widget.onSearch(value);
              },
            ),
          ),
        ],
      ),
      // child: TextField(
      //   textAlign: TextAlign.right,
      //   controller: _searchController,
      //   decoration: InputDecoration(
      //     hintText: 'ابحث عن الأدوية هنا...',
      //     hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
      //     border: InputBorder.none,
      //     prefixIcon: Icon(Icons.search, color: Colors.grey),
      //     suffixIcon:
      //         _searchController.text.isNotEmpty
      //             ? IconButton(
      //               icon: Icon(Icons.clear, size: 20),
      //               onPressed: () {
      //                 _searchController.clear();
      //                 widget.onSearch('');
      //               },
      //             )
      //             : null,
      //     contentPadding: EdgeInsets.symmetric(horizontal: 25),
      //   ),
      //   onChanged: (value) {
      //     widget.onSearch(value);
      //   },
      // ),
    );
  }

  // Widget _buildSearchBar(BuildContext context) {
  //   final screenWidth = MediaQuery.of(context).size.width;
  //
  //   return Container(
  //     height: 50,
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(25),
  //     ),
  //     child: TextField(
  //       textAlign: TextAlign.right,
  //       controller: _searchController,
  //       decoration: InputDecoration(
  //         hintText: 'البحث في الصيدلية',
  //         hintStyle: TextStyle(color: Colors.grey, fontSize: 14, height: 3.3),
  //         border: InputBorder.none,
  //         prefixIcon: Icon(Icons.search, color: Colors.grey),
  //         suffixIcon:
  //             _searchController.text.isNotEmpty
  //                 ? IconButton(
  //                   icon: Icon(Icons.clear, size: 20),
  //                   onPressed: () {
  //                     _searchController.clear();
  //                     widget.onSearch('');
  //                   },
  //                 )
  //                 : null,
  //         contentPadding: EdgeInsets.symmetric(horizontal: 20),
  //       ),
  //       onChanged: (value) {
  //         widget.onSearch(value);
  //       },
  //     ),
  //   );
  // }
}
