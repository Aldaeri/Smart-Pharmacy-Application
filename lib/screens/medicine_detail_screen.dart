import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/medicine_model.dart';
import '../constants/styles.dart';
import '../constants/colors.dart';

class MedicineDetailsScreen extends StatelessWidget {
  final Medicine medicine;

  const MedicineDetailsScreen({super.key, required this.medicine});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(medicine.medicineName),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // مشاركة المنتج
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          // mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // صورة المنتج
            Hero(
              tag: 'medicine-${medicine.id}',
              child: Center(
                child: Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    image: medicine.image != null
                        ? DecorationImage(
                      image: CachedNetworkImageProvider(medicine.image!),
                      fit: BoxFit.cover,
                    )
                        : const DecorationImage(
                      image: AssetImage('assets/images/medicine_placeholder.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // معلومات المنتج الأساسية
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          medicine.medicineType.displayName,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        medicine.medicineName,
                        style: AppTextStyles.header.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'المادة الفعالة: ${medicine.scientificMaterial}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // السعر والكمية
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${medicine.price.toStringAsFixed(2)} ر.ي',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'الكمية: ${medicine.quantity}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // تبويبات الوصف والتعليقات
                  DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        const TabBar(
                          tabs: [
                            Tab(text: 'التعليقات'),
                            Tab(text: 'وصف الدواء'),
                          ],
                          labelColor: AppColors.primary,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: AppColors.primary,
                        ),
                        SizedBox(
                          height: 200,
                          child: TabBarView(
                            children: [
                              // التعليقات (يمكنك إضافتها لاحقاً)
                              const Center(
                                child: Text('لا توجد تعليقات بعد'),
                              ),
                              // وصف المنتج
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SingleChildScrollView(
                                  child: Text(
                                    medicine.description,
                                    style: const TextStyle(fontSize: 16),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // زر إضافة إلى السلة

            // Padding(
            //   padding: const EdgeInsets.all(16.0),
            //   child: SizedBox(
            //     width: double.infinity,
            //     child: ElevatedButton(
            //       style: ElevatedButton.styleFrom(
            //         backgroundColor: AppColors.primary,
            //         padding: const EdgeInsets.symmetric(vertical: 16),
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(8),
            //         ),
            //       ),
            //       onPressed: () {
            //         ScaffoldMessenger.of(context).showSnackBar(
            //           SnackBar(
            //             content: Text('تمت إضافة ${medicine.medicineName} إلى السلة'),
            //             duration: const Duration(seconds: 2),
            //           ),
            //         );
            //       },
            //       child: const Text(
            //         'أضف إلى السلة',
            //         style: TextStyle(
            //           fontSize: 18,
            //           color: Colors.white,
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),

            // منتجات ذات صلة (يمكنك إضافتها لاحقاً)

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => _showAddToCartDialog(context),
                  child: const Text(
                    'أضف إلى السلة',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'منتجات ذات صلة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 3, // يمكنك تغيير هذا الرقم
                      itemBuilder: (context, index) {
                        return Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text('منتج مشابه'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
  // إضافة هذه الدالة داخل class MedicineDetailsScreen
  void _showAddToCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('إضافة ${medicine.medicineName}'),
          content: Text('ما الإجراء الذي تريد تنفيذه؟'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _addToCart(context);
              },
              child: Text('إضافة إلى السلة فقط'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: () {
                Navigator.pop(context);
                _buyNow(context);
              },
              child: Text(
                'شراء الآن',
                style: TextStyle(
                  color: Colors.white
                  )
              ),
            ),
          ],
        );
      },
    );
  }

  void _addToCart(BuildContext context) {
    // هنا كود إضافة المنتج إلى السلة
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تمت إضافة ${medicine.medicineName} إلى السلة'),
        duration: const Duration(seconds: 2),
      ),
    );

    // يمكنك هنا استدعاء دالة لإضافة المنتج إلى سلة التسوق في Firestore
    // مثلاً: CartService.addToCart(medicine);
  }

  void _buyNow(BuildContext context) {
    // هنا كود الانتقال إلى صفحة الدفع
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('جاري تحويلك إلى صفحة الدفع لشراء ${medicine.medicineName}'),
        duration: const Duration(seconds: 1),
      ),
    );

    // الانتقال إلى صفحة الدفع
    Navigator.pushReplacementNamed(context, '/checkout',
    arguments: {
        'items': [medicine],
        'total': medicine.price,
      },
    );
  }
}

// class MedicineDetailsScreen extends StatelessWidget {
//   final Medicine medicine;
//
//   const MedicineDetailsScreen({super.key, required this.medicine});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(medicine.medicineName),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.share),
//             onPressed: () {
//               // مشاركة الدواء
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // صورة المنتج
//             Hero(
//               tag: 'medicine-${medicine.id}',
//               child: Center(
//                 child: Container(
//                   width: double.infinity,
//                   height: 250,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[200],
//                     image:
//                         medicine.image != null
//                             ? DecorationImage(
//                               image: CachedNetworkImageProvider(
//                                 medicine.image!,
//                               ),
//                               fit: BoxFit.cover,
//                             )
//                             : null,
//                   ),
//                   child:
//                       medicine.image == null
//                           ? const Center(
//                             child: Icon(Icons.medical_services, size: 100),
//                           )
//                           : null,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//
//             // معلومات الأساسية
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         medicine.medicineName,
//                         style: AppTextStyles.header.copyWith(
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black,
//                         ),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 8,
//                           vertical: 4,
//                         ),
//                         decoration: BoxDecoration(
//                           color: AppColors.primary.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: Text(
//                           medicine.medicineType.displayName,
//                           style: TextStyle(
//                             color: AppColors.primary,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//
//                   Text(
//                     'المادة العلمية: ${medicine.scientificMaterial}',
//                     style: AppTextStyles.productSubtitle.copyWith(
//                       color: Colors.grey[700],
//                       fontSize: 14,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     // crossAxisAlignment: CrossAxisAlignment.end,
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         '${medicine.price.toStringAsFixed(2)} ر.ي',
//                         style: AppTextStyles.productPrice.copyWith(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Text(
//                         'الكمية: ${medicine.quantity}',
//                         style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//                       ),
//                       // Container(
//                       //   padding: const EdgeInsets.symmetric(
//                       //     horizontal: 10,
//                       //     vertical: 5,
//                       //   ),
//                       //   decoration: BoxDecoration(
//                       //     color: AppColors.primary.withValues(alpha: 0.1),
//                       //     borderRadius: BorderRadius.circular(20),
//                       //   ),
//                       //   child: Text(
//                       //     medicine.medicineType.displayName,
//                       //     style: TextStyle(
//                       //       color: AppColors.primary,
//                       //       fontWeight: FontWeight.bold,
//                       //     ),
//                       //   ),
//                       // ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),
//
//             // تبويبات الوصف والتعليقات
//             DefaultTabController(
//               length: 2,
//               child: Column(
//                 // mainAxisAlignment: MainAxisAlignment.center,
//                 // crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   const TabBar(
//                     // tabAlignment: TabAlignment.center,
//                     labelColor: AppColors.primary,
//                     unselectedLabelColor: Colors.grey,
//                     tabs: [Tab(text: 'التعليقات'), Tab(text: 'وصف المنتج')],
//                   ),
//                   SizedBox(
//                     height: 200,
//                     child: TabBarView(
//                       children: [
//                         // التعليقات
//                         const Center(child: Text('لا توجد تعليقات بعد')),
//                         // وصف المنتج
//                         Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: SingleChildScrollView(
//                             child: Text(
//                               medicine.description,
//                               style: const TextStyle(fontSize: 16),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // زر إضافة إلى السلة
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primary,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   onPressed: () {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text(
//                           'تمت إضافة ${medicine.medicineName} إلى العربة',
//                         ),
//                       ),
//                     );
//                   },
//                   child: const Text(
//                     'أضف إلى السلة',
//                     style: TextStyle(fontSize: 18, color: Colors.white),
//                   ),
//                 ),
//               ),
//             ),
//
//             // منتجات ذات صلة
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16.0),
//               child: Text(
//                 'منتجات ذات صلة',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//             ),
//             const SizedBox(height: 16),
//             SizedBox(
//               height: 200,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: 3,
//                 itemBuilder: (context, index) {
//                   return Container(
//                     width: 150,
//                     margin: const EdgeInsets.only(left: 16),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey[300]!),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Column(
//                       children: [
//                         Expanded(
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.grey[200],
//                               borderRadius: const BorderRadius.vertical(
//                                 top: Radius.circular(8),
//                               ),
//                             ),
//                             child: const Icon(Icons.medical_services, size: 50),
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(
//                             'منتج مشابه ${index + 1}',
//                             style: const TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                         Text(
//                           '${100 * (index + 1)} ر.ي',
//                           style: const TextStyle(color: AppColors.primary),
//                         ),
//                         const SizedBox(height: 8),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoCard(String title, String value) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 10),
//       elevation: 1,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.primary,
//               ),
//             ),
//             const SizedBox(height: 5),
//             Text(value, style: const TextStyle(fontSize: 16)),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class MedicineDetailsScreen extends StatelessWidget {
//   final Medicine medicine;
//
//   const MedicineDetailsScreen({super.key, required this.medicine});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(medicine.medicineName),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.share),
//             onPressed: () {
//               // مشاركة الدواء
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Hero(
//               tag: 'medicine-${medicine.id}',
//               child: Center(
//                 child: Container(
//                   width: 200,
//                   height: 200,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                     image: DecorationImage(
//                       image: medicine.image != null
//                           ? CachedNetworkImageProvider(medicine.image!)
//                           : const AssetImage('assets/images/medicine_placeholder.png')
//                       as ImageProvider,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//
//             // معلومات أساسية
//             Text(
//               medicine.medicineName,
//               style: AppTextStyles.header.copyWith(color: Colors.black),
//             ),
//             const SizedBox(height: 10),
//
//             Text(
//               'المادة العلمية: ${medicine.scientificMaterial}',
//               style: AppTextStyles.productSubtitle.copyWith(color: Colors.grey[700]),
//             ),
//             const SizedBox(height: 10),
//
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   '${medicine.price.toStringAsFixed(2)} ر.ي',
//                   style: AppTextStyles.productPrice.copyWith(fontSize: 20),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: AppColors.primary.withValues(alpha: 0.2),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     medicine.medicineType.displayName,
//                     style: const TextStyle(color: AppColors.primary),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//
//             // معلومات تفصيلية
//             _buildInfoCard('الوصف', medicine.description),
//             _buildInfoCard('تاريخ الانتهاء', DateFormat('yyyy-MM-dd').format(medicine.expiryDate.toDate())),
//             _buildInfoCard('تاريخ الإنتاج', DateFormat('yyyy-MM-dd').format(medicine.productionDate.toDate())),
//             _buildInfoCard('الكمية المتاحة', medicine.quantity.toString()),
//             _buildInfoCard('الرف', medicine.shelf),
//
//             // زر الشراء
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 20),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primary,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   onPressed: () {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('تمت إضافة ${medicine.medicineName} إلى العربة')),
//                     );
//                   },
//                   child: const Text(
//                     'أضف إلى العربة',
//                     style: TextStyle(fontSize: 18, color: Colors.white),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoCard(String title, String value) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 10),
//       elevation: 1,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.primary,
//               ),
//             ),
//             const SizedBox(height: 5),
//             Text(
//               value,
//               style: const TextStyle(fontSize: 16),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:smart_pharmacy_app/constants/colors.dart';
// import 'package:smart_pharmacy_app/constants/styles.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class MedicineDetailsScreen2 extends StatelessWidget {
//   final Map<String, dynamic> medicine;
//
//   // final String name;
//   // final String description;
//   // final double price;
//
//   const MedicineDetailsScreen2({super.key, required this.medicine});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(medicine['medicineName'] ?? 'تفاصيل الدواء'),
//         actions: [IconButton(icon: const Icon(Icons.share), onPressed: () {})],
//         // backgroundColor: const Color(0xFF1E88E5),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             Hero(
//               tag: 'medicine-${medicine['medicineId']}',
//               child: Center(
//                 child: Container(
//                   width: 200,
//                   height: 200,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                     image: DecorationImage(
//                       image: CachedNetworkImageProvider(
//                         medicine['image'] ?? 'assets/images/spa.png',
//                       ),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//
//             Text(
//               medicine['medicineName'] ?? 'بدون اسم',
//               style: AppTextStyles.header.copyWith(color: Colors.black),
//             ),
//             const SizedBox(height: 10),
//
//             Text(
//               'المادة العلمية: ${medicine['Scientific_material'] ?? 'غير معروف'}',
//               style: AppTextStyles.productSubtitle.copyWith(
//                 color: Colors.grey[700],
//               ),
//             ),
//             const SizedBox(height: 10),
//
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: AppColors.primary.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     'متوفر: ${medicine['quantity']?.toString() ?? '0'}',
//                     style: const TextStyle(color: AppColors.primary),
//                   ),
//                 ),
//                 Text(
//                   '${medicine['price']?.toString() ?? '00.0'} ري',
//                   style: AppTextStyles.productPrice.copyWith(fontSize: 20),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: AppColors.primary.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     medicine.medicineType.displayName,
//                     style: const TextStyle(color: AppColors.primary),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//
//             _buildInfoCard('الوصف ', medicine['description'] ?? 'لا يوجد وصف'),
//             _buildInfoCard(
//               'تاريخ الانتهاء ',
//               medicine['expiryDate'] ?? 'غير معروف',
//             ),
//             _buildInfoCard(
//               'تاريخ الإنتاج ',
//               medicine['productionDate'] ?? 'غير معروف',
//             ),
//             _buildInfoCard('النوع ', medicine['medicineType'] ?? 'غير معروف'),
//             _buildInfoCard('الرف ', medicine['shelf'] ?? 'غير معروف'),
//
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 20),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primary,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   onPressed: () {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text(
//                           'تمت إضافة  ${medicine['medicineName']} إلى العربة',
//                         ),
//                       ),
//                     );
//                   },
//                   child: const Text(
//                     'أضف إلى العربة',
//                     style: TextStyle(fontSize: 18, color: Colors.white),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   String formatValue(dynamic value) {
//     if (value == null) return 'غير معروف';
//
//     return switch (value) {
//       Timestamp() => DateFormat('yyyy-MM-dd').format(value.toDate()),
//       DateTime() => DateFormat('yyyy-MM-dd').format(value),
//       num() => value.toStringAsFixed(2),
//       String() => value,
//       _ => value.toString(),
//     };
//   }
//
//   Widget _buildInfoCard(String title, dynamic value) {
//     final displayValue = formatValue(value);
//     assert(displayValue.isNotEmpty, 'Display value should not be empty');
//     // final String displayValue;
//
//     // if (value == null) {
//     //   displayValue = 'غير معروف';
//     // } else if (value is Timestamp) {
//     //   displayValue = DateFormat('yyyy-MM-dd').format(value.toDate());
//     // } else if (value is DateTime) {
//     //   displayValue = DateFormat('yyyy-MM-dd').format(value);
//     // } else if (value is num) {
//     //   displayValue = value.toStringAsFixed(2);
//     // } else if (value is String) {
//     //   displayValue = value;
//     // } else {
//     //   displayValue = value.toString();
//     // }
//     return Card(
//       margin: const EdgeInsets.only(bottom: 10),
//       elevation: 1,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.primary,
//               ),
//             ),
//             const SizedBox(height: 5),
//             Text(displayValue, style: const TextStyle(fontSize: 16)),
//           ],
//         ),
//       ),
//     );
//   }
// }
