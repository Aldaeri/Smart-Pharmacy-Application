import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/styles.dart';
import '../models/medicine_model.dart';
import '../widgets/bottom_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/medicine_card.dart';

import 'medicine_detail_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  List<Medicine> _favoriteMedicines = [];
  bool _isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    if (_user == null) return;

    try {
      QuerySnapshot favoritesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user.uid)
          .collection('favorites')
          .get();

      List<String> medicineIds = favoritesSnapshot.docs
          .map((doc) => doc['medicineId'] as String)
          .toList();

      if (medicineIds.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      QuerySnapshot medicinesSnapshot = await FirebaseFirestore.instance
          .collection('medicines')
          .where(FieldPath.documentId, whereIn: medicineIds)
          .get();

      List<Medicine> tempMedicines = medicinesSnapshot.docs
          .map((doc) => Medicine.fromFirestore(doc))
          .toList();

      setState(() {
        _favoriteMedicines = tempMedicines;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('حدث خطأ في جلب المفضلة: $e');
    }
  }

  Future<void> _removeFromFavorites(String medicineId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('favorites')
          .where('medicineId', isEqualTo: medicineId)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      setState(() {
        _favoriteMedicines.removeWhere((med) => med.id == medicineId);
      });

      _showSnackBar('تمت إزالة الدواء من المفضلة');
    } catch (e) {
      _showSnackBar('حدث خطأ أثناء الإزالة من المفضلة: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.1,
          left: 20,
          right: 20,
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0:
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
        Navigator.pushNamed(context, '/home');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('المفضلة', style: AppTextStyles.header),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteMedicines.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 60,
              color: AppColors.textGray,
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد عناصر في المفضلة',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'اضغط على أيقونة القلب لإضافة أدوية للمفضلة',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textGray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7, // يمكن تعديل هذه النسبة
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: _favoriteMedicines.length,
          itemBuilder: (context, index) =>
            // return MedicineCard(
            //   medicine: _favoriteMedicines[index],
            //   isFavorite: true,
            //   onFavoritePressed: () =>
            //       _removeFromFavorites(_favoriteMedicines[index].id),
            // );
            MedicineCard(
              medicine: _favoriteMedicines[index],
              isFavorite: true,
              inCart: false,
              onFavoritePressed: () => _removeFromFavorites(_favoriteMedicines[index].id),
              // onAddToCart: () => _addToCart(medicine),
              onAddToCart: () => _isLoading,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MedicineDetailsScreen(medicine: _favoriteMedicines[index]),
                  ),
                );
              },
            ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _currentIndex,
        onItemSelected: _onItemTapped,
      ),
      // floatingActionButton: Padding(
      //   padding: const EdgeInsets.only(bottom: 20),
      //   child: FloatingHomeButton(
      //     isSelected: _currentIndex == 4,
      //     onPressed: () => _onItemTapped(4),
      //     btnHomeColor: AppColors.btnDark,
      //     backgroundColor: AppColors.secondary,
      //   ),
      // ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

// class FavoriteScreen4 extends StatefulWidget {
//   const FavoriteScreen4({super.key});
//
//   @override
//   State<FavoriteScreen4> createState() => _FavoriteScreen4State();
// }
//
// class _FavoriteScreen4State extends State<FavoriteScreen4> {
//   final User? _user = FirebaseAuth.instance.currentUser;
//   List<Medicine> _favoriteMedicines = [];
//   bool _isLoading = true;
//   int _currentIndex = 0; // تم التعديل ليتوافق مع الفهرس الجديد
//
//   @override
//   void initState() {
//     super.initState();
//     _loadFavorites();
//   }
//
//   Future<void> _loadFavorites() async {
//     if (_user == null) return;
//
//     try {
//       // جلب جميع الأدوية المفضلة
//       QuerySnapshot favoritesSnapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(_user!.uid)
//           .collection('favorites')
//           .get();
//
//       // استخراج معرفات الأدوية المفضلة
//       List<String> medicineIds = favoritesSnapshot.docs
//           .map((doc) => doc['medicineId'] as String)
//           .toList();
//
//       if (medicineIds.isEmpty) {
//         setState(() => _isLoading = false);
//         return;
//       }
//
//       // جلب بيانات الأدوية المفضلة
//       QuerySnapshot medicinesSnapshot = await FirebaseFirestore.instance
//           .collection('medicines')
//           .where(FieldPath.documentId, whereIn: medicineIds)
//           .get();
//
//       // تحويل إلى قائمة من نماذج Medicine
//       List<Medicine> tempMedicines = medicinesSnapshot.docs
//           .map((doc) => Medicine.fromFirestore(doc))
//           .toList();
//
//       setState(() {
//         _favoriteMedicines = tempMedicines;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() => _isLoading = false);
//       _showSnackBar('حدث خطأ في جلب المفضلة: $e');
//       // ScaffoldMessenger.of(context).showSnackBar(
//       //     SnackBar(content: Text('حدث خطأ في جلب المفضلة: $e'))
//       // );
//     }
//   }
//
//   Future<void> _removeFromFavorites(String medicineId) async {
//     try {
//       // البحث عن المستند المراد حذفه
//       QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(_user!.uid)
//           .collection('favorites')
//           .where('medicineId', isEqualTo: medicineId)
//           .get();
//
//       // حذف جميع المستندات المطابقة
//       for (var doc in querySnapshot.docs) {
//         await doc.reference.delete();
//       }
//
//       // تحديث القائمة محلياً
//       setState(() {
//         _favoriteMedicines.removeWhere((med) => med.id == medicineId);
//       });
//
//       // ScaffoldMessenger.of(context).showSnackBar(
//       //     const SnackBar(content: Text('تمت إزالة المنتج من المفضلة'))
//       // );
//       _showSnackBar('تمت إزالة المنتج من المفضلة');
//     } catch (e) {
//       // ScaffoldMessenger.of(context).showSnackBar(
//       //     SnackBar(content: Text('حدث خطأ أثناء الإزالة: $e'))
//       // );
//       _showSnackBar('حدث خطأ أثناء الإزالة: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('تمت إزالة المنتج من المفضلة'),
//           behavior: SnackBarBehavior.floating, // يجعل الـ SnackBar عائمًا
//           margin: EdgeInsets.only(
//             bottom: MediaQuery.of(context).size.height * 0.1, // يترك مساحة للزر العائم
//             left: 20,
//             right: 20,
//           ),
//         ),
//       );
//     }
//   }
//
//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         behavior: SnackBarBehavior.floating,
//         margin: EdgeInsets.only(
//           bottom: MediaQuery.of(context).size.height * 0.1,
//           left: 20,
//           right: 20,
//         ),
//       ),
//     );
//   }
//
//   void _onItemTapped(int index) {
//     if (index == _currentIndex) return;
//     setState(() {
//       _currentIndex = index;
//     });
//     switch (index) {
//       case 0:
//         // Navigator.pushReplacementNamed(context, '/favorites');
//         break;
//       case 1:
//         Navigator.pushReplacementNamed(context, '/reminders');
//         break;
//       case 2:
//         Navigator.pushReplacementNamed(context, '/cart');
//         break;
//       case 3:
//         Navigator.pushReplacementNamed(context, '/profile');
//         break;
//       case 4:
//         Navigator.pushNamed(context, '/home');
//         break;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: false, // هذا يمنع تحرك العناصر عند ظهور لوحة المفاتيح
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: Text('المفضلة', style: AppTextStyles.header),
//         centerTitle: true,
//         backgroundColor: AppColors.primary,
//         elevation: 0,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _favoriteMedicines.isEmpty
//           ? Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.favorite_border,
//               size: 60,
//               color: AppColors.textGray,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'لا توجد عناصر في المفضلة',
//               style: AppTextStyles.bodyLarge.copyWith(
//                 color: AppColors.textGray,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'اضغط على أيقونة القلب لإضافة أدوية للمفضلة',
//               style: AppTextStyles.bodyMedium.copyWith(
//                 color: AppColors.textGray,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       )
//           : Padding(
//         padding: const EdgeInsets.all(16),
//         child: GridView.builder(
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             childAspectRatio: 0.7,
//             crossAxisSpacing: 20,
//             mainAxisSpacing: 20,
//           ),
//           itemCount: _favoriteMedicines.length,
//           itemBuilder: (context, index) {
//             return MedicineCard(
//               medicine: _favoriteMedicines[index],
//               isFavorite: true,
//               onFavoritePressed: () =>
//                   _removeFromFavorites(_favoriteMedicines[index].id),
//             );
//           },
//         ),
//       ),
//       bottomNavigationBar: CustomBottomNavBar(
//         selectedIndex: _currentIndex,
//         onItemSelected: _onItemTapped,
//       ),
//       // floatingActionButton: FloatingHomeButton(
//       //   isSelected: _currentIndex == 4,
//       //   onPressed: () => _onItemTapped(4),
//       //   btnHomeColor: AppColors.btnDark,
//       //   backgroundColor: AppColors.secondary,
//       // ),
//       floatingActionButton: Padding(
//         padding: const EdgeInsets.only(bottom: 20),
//         child: FloatingHomeButton(
//           isSelected: _currentIndex == 4,
//           onPressed: () => _onItemTapped(4),
//           btnHomeColor: AppColors.btnDark,
//           backgroundColor: AppColors.secondary,
//         ),
//       ),
//
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//
//     );
//   }
// }
//
// class FavoriteScreen3 extends StatefulWidget {
//   const FavoriteScreen3({super.key});
//
//   @override
//   State<FavoriteScreen3> createState() => _FavoriteScreen3State();
// }
//
// class _FavoriteScreen3State extends State<FavoriteScreen3> {
//   final User? _user = FirebaseAuth.instance.currentUser;
//   List<Medicine> _favoriteMedicines = [];
//   bool _isLoading = true;
//   bool _isDeleting = false;
//   int _currentIndex = 1;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadFavorites();
//   }
//
//   Future<void> _loadFavorites() async {
//     if (_user == null) return;
//
//     setState(() => _isLoading = true);
//
//     try {
//       final favoritesSnapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(_user!.uid)
//           .collection('favorites')
//           .get();
//
//       if (favoritesSnapshot.docs.isEmpty) {
//         setState(() => _isLoading = false);
//         return;
//       }
//
//       // الحصول على معرفات الأدوية المفضلة
//       final medicineIds = favoritesSnapshot.docs
//           .map((doc) => doc['medicineId'] as String)
//           .toList();
//
//       // جلب بيانات الأدوية باستخدام whereIn
//       final medicinesSnapshot = await FirebaseFirestore.instance
//           .collection('medicines')
//           .where(FieldPath.documentId, whereIn: medicineIds)
//           .get();
//
//       final tempMedicines = medicinesSnapshot.docs
//           .map((doc) => Medicine.fromFirestore(doc))
//           .toList();
//
//       setState(() {
//         _favoriteMedicines = tempMedicines;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() => _isLoading = false);
//       _showErrorSnackBar('حدث خطأ في جلب المفضلة: $e');
//     }
//   }
//
//   Future<void> _removeFromFavorites(String medicineId) async {
//     if (_user == null || _isDeleting) return;
//
//     setState(() => _isDeleting = true);
//
//     try {
//       final querySnapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(_user!.uid)
//           .collection('favorites')
//           .where('medicineId', isEqualTo: medicineId)
//           .get();
//
//       final batch = FirebaseFirestore.instance.batch();
//       for (var doc in querySnapshot.docs) {
//         batch.delete(doc.reference);
//       }
//       await batch.commit();
//
//       setState(() {
//         _favoriteMedicines.removeWhere((med) => med.id == medicineId);
//         _isDeleting = false;
//       });
//
//       _showSuccessSnackBar('تمت إزالة المنتج من المفضلة');
//     } catch (e) {
//       setState(() => _isDeleting = false);
//       _showErrorSnackBar('حدث خطأ أثناء الإزالة: $e');
//     }
//   }
//
//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }
//
//   void _showSuccessSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.green,
//       ),
//     );
//   }
//
//   void _onItemTapped(int index) {
//     if (index == _currentIndex) return;
//
//     setState(() => _currentIndex = index);
//
//     switch (index) {
//       case 0:
//         break;
//       case 1:
//         Navigator.pushNamed(context, '/reminders');
//         break;
//       case 2:
//         Navigator.pushNamed(context, '/cart');
//         break;
//       case 3:
//         Navigator.pushNamed(context, '/profile');
//         break;
//       case 4: // الصفحة الرئيسية
//         Navigator.pushNamed(context, '/home');
//         break;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: Text('المفضلة', style: AppTextStyles.header),
//         centerTitle: true,
//         backgroundColor: AppColors.primary,
//         elevation: 0,
//         actions: [
//           if (_favoriteMedicines.isNotEmpty)
//             IconButton(
//               icon: const Icon(Icons.delete_sweep),
//               onPressed: _isLoading || _isDeleting
//                   ? null
//                   : () => _confirmClearAll(),
//               tooltip: 'حذف الكل',
//             ),
//         ],
//       ),
//       body: _buildBody(),
//       floatingActionButton: FloatingHomeButton(
//         isSelected: _currentIndex == 4,
//         onPressed: () => _onItemTapped(4),
//         btnHomeColor: AppColors.btnDark,
//         backgroundColor: AppColors.secondary,
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//       bottomNavigationBar: CustomBottomNavBar(
//         selectedIndex: _currentIndex,
//         onItemSelected: _onItemTapped,
//       ),
//     );
//   }
//
//   Widget _buildBody() {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     if (_favoriteMedicines.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.favorite_border,
//               size: 60,
//               color: AppColors.textGray.withValues(alpha: 0.5),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'لا توجد عناصر في المفضلة',
//               style: AppTextStyles.bodyLarge.copyWith(
//                 color: AppColors.textGray,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'اضغط على ♡ لإضافة أدوية للمفضلة',
//               style: AppTextStyles.bodySmall,
//             ),
//           ],
//         ),
//       );
//     }
//
//     return RefreshIndicator(
//       onRefresh: _loadFavorites,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: GridView.builder(
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             childAspectRatio: 0.75,
//             crossAxisSpacing: 16,
//             mainAxisSpacing: 16,
//           ),
//           itemCount: _favoriteMedicines.length,
//           itemBuilder: (context, index) {
//             return _buildMedicineCard(_favoriteMedicines[index]);
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMedicineCard(Medicine medicine) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Stack(
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // صورة الدواء
//               ClipRRect(
//                 borderRadius: const BorderRadius.vertical(
//                     top: Radius.circular(12)),
//                 // child: CachedNetworkImage(
//                 child: CachedNetworkImage(
//                   imageUrl: medicine.image ?? '', // استخدام القيمة الافتراضية إذا كانت null
//                   height: 120,
//                   fit: BoxFit.cover,
//                   placeholder: (context, url) => Container(
//                     color: Colors.grey[200],
//                     child: const Center(
//                       child: Icon(
//                         Icons.medication,
//                         size: 40,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ),
//                   errorWidget: (context, url, error) => Container(
//                     color: Colors.grey[200],
//                     child: const Center(
//                       child: Icon(
//                         Icons.medication,
//                         size: 40,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               // معلومات الدواء
//               Padding(
//                 padding: const EdgeInsets.all(8),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       medicine.medicineName, // استخدام القيمة الافتراضية إذا كانت null
//                       style: AppTextStyles.bodyMedium.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       '${medicine.price ?? 0} ر.ي', // استخدام القيمة الافتراضية إذا كانت null
//                       style: AppTextStyles.bodyMedium.copyWith(
//                         color: AppColors.primary,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       medicine.description ?? '', // استخدام القيمة الافتراضية إذا كانت null
//                       style: AppTextStyles.bodySmall,
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           // زر الإزالة من المفضلة
//           Positioned(
//             top: 4,
//             right: 4,
//             child: IconButton(
//               icon: _isDeleting
//                   ? const CircularProgressIndicator(
//                 strokeWidth: 2,
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
//               )
//                   : const Icon(Icons.favorite, color: Colors.red),
//               onPressed: () => _removeFromFavorites(medicine.id),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _confirmClearAll() async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('حذف الكل'),
//         content: const Text('هل أنت متأكد من حذف جميع العناصر من المفضلة؟'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('إلغاء'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('حذف', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//
//     if (confirmed == true) {
//       await _clearAllFavorites();
//     }
//   }
//
//   Future<void> _clearAllFavorites() async {
//     if (_user == null || _favoriteMedicines.isEmpty) return;
//
//     setState(() => _isDeleting = true);
//
//     try {
//       final batch = FirebaseFirestore.instance.batch();
//       final favoritesRef = FirebaseFirestore.instance
//           .collection('users')
//           .doc(_user!.uid)
//           .collection('favorites');
//
//       for (var medicine in _favoriteMedicines) {
//         final query = await favoritesRef
//             .where('medicineId', isEqualTo: medicine.id)
//             .get();
//         for (var doc in query.docs) {
//           batch.delete(doc.reference);
//         }
//       }
//
//       await batch.commit();
//
//       setState(() {
//         _favoriteMedicines.clear();
//         _isDeleting = false;
//       });
//
//       _showSuccessSnackBar('تم حذف جميع العناصر من المفضلة');
//     } catch (e) {
//       setState(() => _isDeleting = false);
//       _showErrorSnackBar('حدث خطأ أثناء حذف العناصر: $e');
//     }
//   }
// }
//
// class FavoriteScreen2 extends StatefulWidget {
//   const FavoriteScreen2({super.key,});
//
//   @override
//   State<FavoriteScreen2> createState() => _FavoriteScreen2State();
// }
//
// class _FavoriteScreen2State extends State<FavoriteScreen2> {
//   final User? _user = FirebaseAuth.instance.currentUser;
//   List<Medicine> _favoriteMedicines = [];
//   bool _isLoading = true;
//
//   int _currentIndex = 1;
//
//   void _onItemTapped(int index) {
//     if (index == _currentIndex) return;
//
//     setState(() {
//       _currentIndex = index;
//     });
//
//     switch (index) {
//       case 0:
//         Navigator.pushReplacementNamed(context, '/home');
//         break;
//       case 1:
//         Navigator.pushReplacementNamed(context, '/favorites');
//         break;
//       case 2:
//         Navigator.pushReplacementNamed(context, '/reminders');
//         break;
//       case 3:
//         Navigator.pushReplacementNamed(context, '/profile');
//         break;
//     }
//   }
//   @override
//   void initState() {
//     super.initState();
//     _loadFavorites();
//   }
//
//   Future<void> _loadFavorites() async {
//     if (_user == null) return;
//
//     try {
//       // جلب جميع الأدوية المفضلة
//       QuerySnapshot favoritesSnapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(_user!.uid)
//           .collection('favorites')
//           .get();
//
//       // استخراج معرفات الأدوية المفضلة
//       List<String> medicineIds = favoritesSnapshot.docs
//           .map((doc) => doc['medicineId'] as String)
//           .toList();
//
//       if (medicineIds.isEmpty) {
//         setState(() => _isLoading = false);
//         return;
//       }
//
//       // جلب بيانات الأدوية المفضلة
//       QuerySnapshot medicinesSnapshot = await FirebaseFirestore.instance
//           .collection('medicines')
//           .where(FieldPath.documentId, whereIn: medicineIds)
//           .get();
//
//       // تحويل إلى قائمة من نماذج Medicine
//       List<Medicine> tempMedicines = medicinesSnapshot.docs
//           .map((doc) => Medicine.fromFirestore(doc))
//           .toList();
//
//       setState(() {
//         _favoriteMedicines = tempMedicines;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() => _isLoading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('حدث خطأ في جلب المفضلة: $e'))
//       );
//     }
//   }
//
//   Future<void> _removeFromFavorites(String medicineId) async {
//     try {
//       // البحث عن المستند المراد حذفه
//       QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(_user!.uid)
//           .collection('favorites')
//           .where('medicineId', isEqualTo: medicineId)
//           .get();
//
//       // حذف جميع المستندات المطابقة (يجب أن يكون واحد فقط في الواقع)
//       for (var doc in querySnapshot.docs) {
//         await doc.reference.delete();
//       }
//
//       // تحديث القائمة محلياً
//       setState(() {
//         _favoriteMedicines.removeWhere((med) => med.id == medicineId);
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('تمت إزالة المنتج من المفضلة'))
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('حدث خطأ أثناء الإزالة: $e'))
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: Text('المفضلة', style: AppTextStyles.header),
//         centerTitle: true,
//         backgroundColor: AppColors.primary,
//         elevation: 0,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _favoriteMedicines.isEmpty
//           ? Center(
//         child: Text(
//           'لا توجد عناصر في المفضلة',
//           style: AppTextStyles.bodyLarge,
//         ),
//       )
//           : Padding(
//         padding: const EdgeInsets.all(16),
//         child: GridView.builder(
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             childAspectRatio: 0.7,
//             crossAxisSpacing: 20,
//             mainAxisSpacing: 20,
//           ),
//           itemCount: _favoriteMedicines.length,
//           itemBuilder: (context, index) {
//             return MedicineCard(
//               medicine: _favoriteMedicines[index],
//               isFavorite: true,
//               onFavoritePressed: () =>
//                   _removeFromFavorites(_favoriteMedicines[index].id),
//             );
//           },
//         ),
//       ),
//       bottomNavigationBar: CustomBottomNavBar(
//         selectedIndex: _currentIndex,
//         onItemSelected: _onItemTapped,
//       ),
//     );
//   }
// }