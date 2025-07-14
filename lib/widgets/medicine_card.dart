import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/medicine_model.dart';
import '../constants/colors.dart';

class MedicineCard extends StatelessWidget {
  final Medicine medicine;
  final bool isFavorite;
  final bool inCart;
  final VoidCallback? onFavoritePressed;
  final VoidCallback? onAddToCart;
  final VoidCallback? onTap;

  const MedicineCard({
    super.key,
    required this.medicine,
    this.isFavorite = false,
    this.inCart = false,
    this.onFavoritePressed,
    this.onAddToCart,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // تم إزالة BoxConstraints للسماح بالحجم الديناميكي
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          // مهم لجعل العمود يأخذ أقل مساحة ممكنة
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // صورة المنتج مع زر المفضلة
            Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  height: 120, // يمكن الإبقاء على ارتفاع ثابت للصورة
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    color: Colors.grey[100],
                  ),
                  child: Center(
                    child:
                        medicine.image!.isNotEmpty
                            ? CachedNetworkImage(
                              imageUrl: medicine.image!,
                              fit: BoxFit.contain,
                              placeholder:
                                  (context, url) => CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                              errorWidget:
                                  (context, url, error) => Icon(
                                    Icons.medical_services,
                                    size: 40,
                                    color: AppColors.primary,
                                  ),
                            )
                            : Icon(
                              Icons.medical_services,
                              size: 40,
                              color: AppColors.primary,
                            ),
                  ),
                ),
                if (onFavoritePressed != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white.withOpacity(0.8),
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: isFavorite ? Colors.red : Colors.grey[600],
                        ),
                        onPressed: onFavoritePressed,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
              ],
            ),

            // معلومات المنتج
            // Flexible لا تزال مفيدة هنا لتوزيع المساحة داخل العمود
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                // زيادة الـ padding العمودي قليلاً
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  // مهم لجعل هذا العمود الداخلي صغيرًا أيضًا
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // اسم الدواء ونوعه
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // اسم الدواء
                        // Expanded مهمة لتأخذ المساحة المتبقية وتسمح بالالتفاف إذا لزم الأمر
                        Expanded(
                          flex: 2,
                          child: Text(
                            medicine.medicineName,
                            // textAlign: TextAlign.end,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            // يمكن زيادة maxLines إذا أردت السماح بأسطر أكثر للأسماء الطويلة
                            maxLines: 3,
                            // تم التعديل إلى 3 أسطر كحد أقصى
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        const SizedBox(width: 4),

                        // نوع الدواء
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              medicine.medicineType.displayName,
                              style: const TextStyle(
                                fontSize: 8,
                                color: AppColors.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        // اسم الدواء
                        // Expanded مهمة لتأخذ المساحة المتبقية وتسمح بالالتفاف إذا لزم الأمر
                        // Expanded(
                        //   flex: 2,
                        //   child: Text(
                        //     medicine.medicineName,
                        //     textAlign: TextAlign.end,
                        //     style: const TextStyle(
                        //       fontSize: 12,
                        //       fontWeight: FontWeight.bold,
                        //     ),
                        //     // يمكن زيادة maxLines إذا أردت السماح بأسطر أكثر للأسماء الطويلة
                        //     maxLines: 3, // تم التعديل إلى 3 أسطر كحد أقصى
                        //     overflow: TextOverflow.ellipsis,
                        //   ),
                        // ),
                      ],
                    ),

                    // const SizedBox(height: 2), // زيادة المسافة قليلاً
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        // decoration: BoxDecoration(
                        //   color: AppColors.primary.withOpacity(0.1),
                        //   borderRadius: BorderRadius.circular(4),
                        // ),
                        child: Text(
                          medicine.scientificMaterial,
                          // textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1, // حد أقصى سطرين للاسم العلمي
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ),
                    // الاسم العلمي
                    // Text(
                    //   medicine.scientificMaterial,
                    //   textAlign: TextAlign.end,
                    //   style: TextStyle(
                    //     fontSize: 9,
                    //     color: Colors.grey[600],
                    //   ),
                    //   maxLines: 1, // حد أقصى سطرين للاسم العلمي
                    //   overflow: TextOverflow.fade,
                    // ),

                    // تم إزالة Spacer، سيتم دفع المحتوى التالي للأسفل تلقائيًا
                    const SizedBox(height: 4),
                    // إضافة مسافة ثابتة قبل السعر والزر

                    // السعر وزر الإضافة إلى السلة
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      // محاذاة العناصر في المنتصف عموديًا
                      children: [
                        // زر الإضافة إلى السلة (أيقونة)
                        if (onAddToCart != null)
                          IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color:
                                    inCart
                                        ? Colors.grey[300]
                                        : AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                inCart ? Icons.check : Icons.add,
                                size: 20,
                                color: inCart ? Colors.grey[600] : Colors.white,
                              ),
                            ),
                            onPressed: onAddToCart,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 35,
                              minHeight: 35,
                            ),
                          ),

                        // السعر
                        // Flexible هنا تسمح للسعر بأخذ المساحة المتاحة والتكيف
                        Flexible(
                          child: Text(
                            '${medicine.price.toStringAsFixed(2)} ر.ي',
                            // textAlign: TextAlign.end, // محاذاة لليمين
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2, // حد أقصى سطرين للسعر (احتياطي)
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class MedicineCard2 extends StatelessWidget {
//   final Medicine medicine;
//   final bool isFavorite;
//   final bool inCart;
//   final VoidCallback? onFavoritePressed;
//   final VoidCallback? onAddToCart;
//   final VoidCallback? onTap;
//
//   const MedicineCard2({
//     super.key,
//     required this.medicine,
//     this.isFavorite = false,
//     this.inCart = false,
//     this.onFavoritePressed,
//     this.onAddToCart,
//     this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(4),
//       constraints: const BoxConstraints(
//         minHeight: 220, // تحديد ارتفاع أدنى
//         maxHeight: 260, // تحديد ارتفاع أقصى
//         minWidth: 180,
//         maxWidth: 200,
//       ),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 1,
//             blurRadius: 5,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(8),
//         child: Column(
//           mainAxisSize: MainAxisSize.min, // مهم لتجنب الـ overflow
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // صورة المنتج مع زر المفضلة
//             Stack(
//               alignment: Alignment.topRight,
//               children: [
//                 Container(
//                   height: 120,
//                   decoration: BoxDecoration(
//                     borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
//                     color: Colors.grey[100],
//                   ),
//                   child: Center(
//                     child: medicine.image!.isNotEmpty
//                         ? CachedNetworkImage(
//                       imageUrl: medicine.image!,
//                       fit: BoxFit.contain,
//                       placeholder: (context, url) => CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: AppColors.primary,
//                       ),
//                       errorWidget: (context, url, error) => Icon(
//                         Icons.medical_services,
//                         size: 40,
//                         color: AppColors.primary,
//                       ),
//                     )
//                         : Icon(
//                       Icons.medical_services,
//                       size: 40,
//                       color: AppColors.primary,
//                     ),
//                   ),
//                 ),
//                 if (onFavoritePressed != null)
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: CircleAvatar(
//                       radius: 16,
//                       backgroundColor: Colors.white.withOpacity(0.8),
//                       child: IconButton(
//                         icon: Icon(
//                           isFavorite ? Icons.favorite : Icons.favorite_border,
//                           size: 18,
//                           color: isFavorite ? Colors.red : Colors.grey[600],
//                         ),
//                         onPressed: onFavoritePressed,
//                         padding: EdgeInsets.zero,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//
//             // معلومات المنتج
//             Flexible( // إضافة Flexible هنا لمنع الـ overflow
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     // اسم الدواء ونوعه
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // نوع الدواء
//                         Flexible(
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
//                             decoration: BoxDecoration(
//                               color: AppColors.primary.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                             child: Text(
//                               medicine.medicineType.displayName,
//                               style: const TextStyle(
//                                 fontSize: 10,
//                                 color: AppColors.primary,
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ),
//
//                         const SizedBox(width: 8),
//
//                         // اسم الدواء
//                         Expanded(
//                           flex: 2,
//                           child: Text(
//                             medicine.medicineName,
//                             textAlign: TextAlign.end,
//                             style: const TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                             ),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     const SizedBox(height: 3),
//
//                     // الاسم العلمي
//                     Text(
//                       medicine.scientificMaterial,
//                       textAlign: TextAlign.end,
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey[600],
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//
//                     const Spacer(), // يستخدم المساحة الفارغة
//
//                     // السعر وزر الإضافة إلى السلة
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         // زر الإضافة إلى السلة (أيقونة)
//                         if (onAddToCart != null)
//                           IconButton(
//                             icon: Container(
//                               // alignment: Alignment.bottomLeft,
//                               padding: const EdgeInsets.all(4),
//                               decoration: BoxDecoration(
//                                 color: inCart ? Colors.grey[300] : AppColors.primary,
//                                 shape: BoxShape.circle,
//                               ),
//                               child: Icon(
//                                 inCart ? Icons.check : Icons.add,
//                                 size: 20,
//                                 color: inCart ? Colors.grey[600] : Colors.white,
//                               ),
//                             ),
//                             onPressed: onAddToCart,
//                             padding: EdgeInsets.zero,
//                             constraints: const BoxConstraints(
//                               minWidth: 36,
//                               minHeight: 36,
//                             ),
//                           ),
//
//                         // السعر
//                         Flexible(
//                           child: Text(
//                             '${medicine.price.toStringAsFixed(2)} ر.ي',
//                             style: const TextStyle(
//                               fontSize: 10,
//                               fontWeight: FontWeight.bold,
//                               color: AppColors.primary,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                             maxLines: 2,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class MedicineCard8 extends StatelessWidget {
//   final Medicine medicine;
//   final bool isFavorite;
//   final bool inCart;
//   final VoidCallback? onFavoritePressed;
//   final VoidCallback? onAddToCart;
//   final VoidCallback? onTap;
//
//   const MedicineCard8({
//     super.key,
//     required this.medicine,
//     this.isFavorite = false,
//     this.inCart = false,
//     this.onFavoritePressed,
//     this.onAddToCart,
//     this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final cardWidth = constraints.maxWidth;
//         return Container(
//           margin: const EdgeInsets.all(4), // هام: إضافة margin
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(8),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.1),
//                 spreadRadius: 1,
//                 blurRadius: 5,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: InkWell(
//             onTap: onTap,
//             borderRadius: BorderRadius.circular(8),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // صورة المنتج مع زر المفضلة
//                 Stack(
//                   alignment: Alignment.topRight,
//                   children: [
//                     Container(
//                       height: cardWidth * 0.68, // نسبة ارتفاع الصورة لعرض البطاقة
//                       decoration: BoxDecoration(
//                         borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
//                         color: Colors.grey[100],
//                       ),
//                       child: Center(
//                         child: medicine.image!.isNotEmpty
//                             ? CachedNetworkImage(
//                           imageUrl: medicine.image!,
//                           fit: BoxFit.contain,
//                           placeholder: (context, url) => CircularProgressIndicator(
//                             strokeWidth: 2,
//                             color: AppColors.primary,
//                           ),
//                           errorWidget: (context, url, error) => Icon(
//                             Icons.medical_services,
//                             size: 40,
//                             color: AppColors.primary,
//                           ),
//                         )
//                             : Icon(
//                           Icons.medical_services,
//                           size: 40,
//                           color: AppColors.primary,
//                         ),
//                       ),
//                     ),
//                     if (onFavoritePressed != null)
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: CircleAvatar(
//                           radius: 16,
//                           backgroundColor: Colors.white.withOpacity(0.8),
//                           child: IconButton(
//                             icon: Icon(
//                               isFavorite ? Icons.favorite : Icons.favorite_border,
//                               size: 18,
//                               color: isFavorite ? Colors.red : Colors.grey[600],
//                             ),
//                             onPressed: onFavoritePressed,
//                             padding: EdgeInsets.zero,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//
//                 // معلومات المنتج
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       // اسم الدواء ونوعه
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // نوع الدواء
//                           Flexible(
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
//                               decoration: BoxDecoration(
//                                 color: AppColors.primary.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                               child: Text(
//                                 medicine.medicineType.displayName,
//                                 style: const TextStyle(
//                                   fontSize: 10,
//                                   color: AppColors.primary,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ),
//
//                           const SizedBox(width: 8),
//
//                           // اسم الدواء
//                           Expanded(
//                             flex: 2, // يعطي مساحة أكبر لاسم الدواء
//                             child: Text(
//                               medicine.medicineName,
//                               textAlign: TextAlign.end,
//                               style: const TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ],
//                       ),
//
//                       const SizedBox(height: 6),
//
//                       // الاسم العلمي
//                       Text(
//                         medicine.scientificMaterial,
//                         textAlign: TextAlign.end,
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey[600],
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//
//                       const SizedBox(height: 12),
//
//                       // السعر وزر الإضافة إلى السلة
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           // زر الإضافة إلى السلة
//                           if (onAddToCart != null)
//                             IconButton(
//                               icon: Container(
//                                 padding: const EdgeInsets.all(4),
//                                 decoration: BoxDecoration(
//                                   color: inCart ? Colors.grey[300] : AppColors.primary,
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: Icon(
//                                   inCart ? Icons.check : Icons.add,
//                                   size: 15,
//                                   color: inCart ? Colors.grey[600] : Colors.white,
//                                 ),
//                               ),
//                               onPressed: onAddToCart,
//                               padding: EdgeInsets.zero,
//                               constraints: const BoxConstraints(
//                                 minWidth: 20, // تحديد حجم ثابت للأيقونة
//                                 minHeight: 20,
//                               ),
//                             ),
//                           // if (onAddToCart != null)
//                           //   Flexible(
//                           //     child: InkWell(
//                           //       onTap: onAddToCart,
//                           //       borderRadius: BorderRadius.circular(4),
//                           //       child: Container(
//                           //         // constraints: BoxConstraints(minWidth: 10), // عرض أدنى للزر
//                           //         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
//                           //         decoration: BoxDecoration(
//                           //           color: inCart ? Colors.grey[300] : AppColors.primary,
//                           //           borderRadius: BorderRadius.circular(4),
//                           //         ),
//                           //         child: Center(
//                           //           child: Text(
//                           //             inCart ? '+' : '-',
//                           //             style: TextStyle(
//                           //               fontSize: 14,
//                           //               fontWeight: FontWeight.bold,
//                           //               color: inCart ? Colors.grey[600] : Colors.white,
//                           //             ),
//                           //           ),
//                           //         ),
//                           //       ),
//                           //     ),
//                           //   ),
//
//                           // السعر
//                           Flexible(
//                             child: Text(
//                               '${medicine.price.toStringAsFixed(2)} ر.ي',
//                               style: const TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                                 color: AppColors.primary,
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                           // Flexible(
//                           //   child: Padding(
//                           //     padding: const EdgeInsets.only(left: 8),
//                           //     child: Text(
//                           //       '${medicine.price.toStringAsFixed(2)} ر.ي',
//                           //       style: const TextStyle(
//                           //         fontSize: 14,
//                           //         fontWeight: FontWeight.bold,
//                           //         color: AppColors.primary,
//                           //       ),
//                           //       overflow: TextOverflow.ellipsis,
//                           //     ),
//                           //   ),
//                           // ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
//
// class MedicineCard7 extends StatelessWidget {
//   final Medicine medicine;
//   final bool isFavorite;
//   final bool inCart;
//   final VoidCallback? onFavoritePressed;
//   final VoidCallback? onAddToCart;
//   final VoidCallback? onTap;
//
//   const MedicineCard7({
//     super.key,
//     required this.medicine,
//     this.isFavorite = false,
//     this.inCart = false,
//     this.onFavoritePressed,
//     this.onAddToCart,
//     this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(8),
//       child: Container(
//         constraints: BoxConstraints(
//           minHeight: 220, // تحديد ارتفاع أدنى
//           maxHeight: 260, // تحديد ارتفاع أقصى
//         ),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(8),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.1),
//               spreadRadius: 1,
//               blurRadius: 5,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min, // مهم لتجنب الـ overflow
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // صورة المنتج مع زر المفضلة
//             Stack(
//               alignment: Alignment.topRight,
//               children: [
//                 Container(
//                   height: 120,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
//                     color: Colors.grey[100],
//                   ),
//                   child: Center(
//                     child: medicine.image!.isNotEmpty
//                         ? CachedNetworkImage(
//                       imageUrl: medicine.image!,
//                       fit: BoxFit.contain,
//                       placeholder: (context, url) => CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: AppColors.primary,
//                       ),
//                       errorWidget: (context, url, error) => Icon(
//                         Icons.medical_services,
//                         size: 40,
//                         color: AppColors.primary,
//                       ),
//                     )
//                         : Icon(
//                       Icons.medical_services,
//                       size: 40,
//                       color: AppColors.primary,
//                     ),
//                   ),
//                 ),
//                 if (onFavoritePressed != null)
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: CircleAvatar(
//                       radius: 16,
//                       backgroundColor: Colors.white.withOpacity(0.8),
//                       child: IconButton(
//                         icon: Icon(
//                           isFavorite ? Icons.favorite : Icons.favorite_border,
//                           size: 18,
//                           color: isFavorite ? Colors.red : Colors.grey[600],
//                         ),
//                         onPressed: onFavoritePressed,
//                         padding: EdgeInsets.zero,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//
//             // معلومات المنتج
//             Flexible( // إضافة Flexible هنا
//               child: Padding(
//                 padding: const EdgeInsets.all(12),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min, // مهم لتجنب الـ overflow
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     // اسم الدواء ونوعه
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // نوع الدواء
//                         Container(
//                           constraints: BoxConstraints(maxWidth: 80), // تحديد عرض أقصى
//                           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
//                           decoration: BoxDecoration(
//                             color: AppColors.primary.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: Text(
//                             medicine.medicineType.displayName,
//                             style: const TextStyle(
//                               fontSize: 10,
//                               color: AppColors.primary,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//
//                         // اسم الدواء
//                         Expanded(
//                           child: Text(
//                             medicine.medicineName,
//                             textAlign: TextAlign.end,
//                             style: const TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                             ),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     const SizedBox(height: 6),
//
//                     // الاسم العلمي
//                     Text(
//                       medicine.scientificMaterial,
//                       textAlign: TextAlign.end,
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey[600],
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//
//                     const Spacer(), // يستخدم المساحة الفارغة
//
//                     // السعر وزر الإضافة إلى السلة
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         // زر الإضافة إلى السلة
//                         if (onAddToCart != null)
//                           InkWell(
//                             onTap: onAddToCart,
//                             borderRadius: BorderRadius.circular(4),
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                               decoration: BoxDecoration(
//                                 color: inCart ? Colors.grey[300] : AppColors.primary,
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                               child: Text(
//                                 inCart ? 'مضاف' : '+',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.bold,
//                                   color: inCart ? Colors.grey[600] : Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ),
//
//                         // السعر
//                         Text(
//                           '${medicine.price.toStringAsFixed(2)} ر.ي',
//                           style: const TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.bold,
//                             color: AppColors.primary,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class MedicineCard6 extends StatelessWidget {
//   final Medicine medicine;
//   final bool isFavorite;
//   final bool inCart;
//   final VoidCallback? onFavoritePressed;
//   final VoidCallback? onAddToCart;
//   final VoidCallback? onTap;
//
//   const MedicineCard6({
//     super.key,
//     required this.medicine,
//     this.isFavorite = false,
//     this.inCart = false,
//     this.onFavoritePressed,
//     this.onAddToCart,
//     this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(8),
//       child: Container(
//         constraints: BoxConstraints(
//           minHeight: 220, // تحديد ارتفاع أدنى
//           maxHeight: 260, // تحديد ارتفاع أقصى
//         ),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(8),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.1),
//               spreadRadius: 1,
//               blurRadius: 5,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min, // مهم لتجنب الـ overflow
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // صورة المنتج مع زر المفضلة
//             Stack(
//               alignment: Alignment.topRight,
//               children: [
//                 Container(
//                   height: 120,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
//                     color: Colors.grey[100],
//                   ),
//                   child: Center(
//                     child: medicine.image!.isNotEmpty
//                         ? CachedNetworkImage(
//                       imageUrl: medicine.image!,
//                       fit: BoxFit.contain,
//                       placeholder: (context, url) => CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: AppColors.primary,
//                       ),
//                       errorWidget: (context, url, error) => Icon(
//                         Icons.medical_services,
//                         size: 40,
//                         color: AppColors.primary,
//                       ),
//                     )
//                         : Icon(
//                       Icons.medical_services,
//                       size: 40,
//                       color: AppColors.primary,
//                     ),
//                   ),
//                 ),
//                 if (onFavoritePressed != null)
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: CircleAvatar(
//                       radius: 16,
//                       backgroundColor: Colors.white.withOpacity(0.8),
//                       child: IconButton(
//                         icon: Icon(
//                           isFavorite ? Icons.favorite : Icons.favorite_border,
//                           size: 18,
//                           color: isFavorite ? Colors.red : Colors.grey[600],
//                         ),
//                         onPressed: onFavoritePressed,
//                         padding: EdgeInsets.zero,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//
//             // معلومات المنتج
//             Padding(
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.end, // محاذاة النصوص لليمين
//                 children: [
//                   // اسم الدواء ونوعه في نفس السطر
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // نوع الدواء (في اليسار)
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: AppColors.primary.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: Text(
//                           medicine.medicineType.displayName,
//                           style: const TextStyle(
//                             fontSize: 10,
//                             color: AppColors.primary,
//                           ),
//                         ),
//                       ),
//
//                       // اسم الدواء (في اليمين)
//                       Expanded(
//                         child: Text(
//                           medicine.medicineName,
//                           textAlign: TextAlign.end,
//                           style: const TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.bold,
//                             height: 1.2,
//                           ),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//
//                   const SizedBox(height: 8),
//
//                   // الاسم العلمي للدواء (محاذاة لليمين)
//                   Text(
//                     medicine.scientificMaterial,
//                     textAlign: TextAlign.end,
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey[600],
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//
//                   const SizedBox(height: 12),
//
//                   // السعر وزر الإضافة إلى السلة
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       // زر الإضافة إلى السلة (في اليسار)
//                       if (onAddToCart != null)
//                         InkWell(
//                           onTap: onAddToCart,
//                           borderRadius: BorderRadius.circular(4),
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                             decoration: BoxDecoration(
//                               color: inCart ? Colors.grey[300] : AppColors.primary,
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                             child: Text(
//                               inCart ? 'مضاف' : '+',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                                 color: inCart ? Colors.grey[600] : Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//
//                       // السعر (في اليمين)
//                       Text(
//                         '${medicine.price.toStringAsFixed(2)} ر.ي',
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                           color: AppColors.primary,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class MedicineCard5 extends StatelessWidget {
//   final Medicine medicine;
//   final bool isFavorite;
//   final bool inCart;
//   final VoidCallback? onFavoritePressed;
//   final VoidCallback? onAddToCart;
//   final VoidCallback? onTap;
//   final bool showType;
//
//   const MedicineCard5({
//     super.key,
//     required this.medicine,
//     this.isFavorite = false,
//     this.inCart = false,
//     this.onFavoritePressed,
//     this.onAddToCart,
//     this.onTap,
//     this.showType = true,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(10),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(10),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.1),
//               spreadRadius: 1,
//               blurRadius: 5,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // صورة المنتج
//             Stack(
//               children: [
//                 Container(
//                   height: 120,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
//                     color: Colors.grey[100],
//                   ),
//                   child: Center(
//                     child: medicine.image!.isNotEmpty
//                         ? CachedNetworkImage(
//                       imageUrl: medicine.image!,
//                       fit: BoxFit.contain,
//                       placeholder: (context, url) => CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: AppColors.primary,
//                       ),
//                       errorWidget: (context, url, error) => Icon(
//                         Icons.medical_services,
//                         size: 40,
//                         color: AppColors.primary,
//                       ),
//                     )
//                         : Icon(
//                       Icons.medical_services,
//                       size: 40,
//                       color: AppColors.primary,
//                     ),
//                   ),
//                 ),
//
//                 // زر المفضلة
//                 if (onFavoritePressed != null)
//                   Positioned(
//                     top: 8,
//                     right: 8,
//                     child: IconButton(
//                       icon: Container(
//                         padding: EdgeInsets.all(4),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.8),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Icon(
//                           isFavorite ? Icons.favorite : Icons.favorite_border,
//                           color: isFavorite ? Colors.red : Colors.grey[600],
//                           size: 20,
//                         ),
//                       ),
//                       onPressed: onFavoritePressed,
//                     ),
//                   ),
//               ],
//             ),
//
//             // معلومات المنتج
//             Padding(
//               padding: EdgeInsets.all(12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // // اسم العلامة التجارية
//                   // Text(
//                   //   medicine.brand ?? 'CeraVe', // يمكن استبدالها بقيمة من النموذج
//                   //   style: TextStyle(
//                   //     fontSize: 12,
//                   //     color: Colors.grey[600],
//                   //   ),
//                   // ),
//
//                   // SizedBox(height: 4),
//
//                   // اسم المنتج
//                   Text(
//                     medicine.medicineName,
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                       height: 1.2,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//
//                   SizedBox(height: 4),
//                   // المادة العلمية
//                   Text(
//                     medicine.scientificMaterial,
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey[600],
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//
//                   // معلومات إضافية (مكان التوصيل)
//                   // Text(
//                   //   'Pickup in ${medicine.location ?? 'Belgium'}', // يمكن تعديلها حسب البيانات المتاحة
//                   //   style: TextStyle(
//                   //     fontSize: 10,
//                   //     color: Colors.grey[500],
//                   //   ),
//                   // ),
//                   //
//                   // SizedBox(height: 12),
//
//                   // السعر وزر الإضافة إلى السلة
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       // السعر
//                       Text(
//                         '${medicine.price.toStringAsFixed(2)} ر.ي',
//                         // '${medicine.price.toStringAsFixed(2)} ريال',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                           color: AppColors.primary,
//                         ),
//                       ),
//
//                       // نوع المنتج (اختياري)
//                       if (showType)
//                         Container(
//                           padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                           decoration: BoxDecoration(
//                             color: AppColors.primary.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Text(
//                             medicine.medicineType.displayName,
//                             style: TextStyle(
//                               fontSize: 10,
//                               color: AppColors.primary,
//                             ),
//                           ),
//                         ),
//
//                       // زر الإضافة إلى السلة
//                       if (onAddToCart != null)
//                         InkWell(
//                           onTap: onAddToCart,
//                           borderRadius: BorderRadius.circular(6),
//                           child: Container(
//                             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                             decoration: BoxDecoration(
//                               color: inCart ? Colors.blue : AppColors.primary,
//                               borderRadius: BorderRadius.circular(6),
//                             ),
//                             child: Text(
//                               inCart ? 'مضاف' : '+',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                                 color: inCart ? Colors.red : Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class MedicineCard4 extends StatelessWidget {
//   final Medicine medicine;
//   final bool isFavorite;
//   final VoidCallback? onFavoritePressed;
//   final VoidCallback? onTap;
//   final bool showType;
//
//   const MedicineCard4({
//     super.key,
//     required this.medicine,
//     this.isFavorite = false,
//     this.onFavoritePressed,
//     this.onTap,
//     this.showType = true,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap ?? () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => MedicineDetailsScreen(medicine: medicine),
//           ),
//         );
//       },
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.1),
//               spreadRadius: 1,
//               blurRadius: 5,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // صورة المنتج
//             Stack(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
//                   child: Container(
//                     height: 120,
//                     width: double.infinity,
//                     color: Colors.grey[100],
//                     child: medicine.image!.isNotEmpty
//                         ? CachedNetworkImage(
//                       imageUrl: medicine.image!,
//                       fit: BoxFit.contain,
//                       placeholder: (context, url) => Center(
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           color: AppColors.primary,
//                         ),
//                       ),
//                       errorWidget: (context, url, error) => Center(
//                         child: Icon(
//                           _getIconForMedicineType(medicine.medicineType),
//                           size: 40,
//                           color: AppColors.primary,
//                         ),
//                       ),
//                     )
//                         : Center(
//                       child: Icon(
//                         _getIconForMedicineType(medicine.medicineType),
//                         size: 40,
//                         color: AppColors.primary,
//                       ),
//                     ),
//                   ),
//                 ),
//                 if (onFavoritePressed != null)
//                   Positioned(
//                     top: 8,
//                     right: 8,
//                     child: IconButton(
//                       icon: Container(
//                         padding: EdgeInsets.all(4),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.8),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Icon(
//                           isFavorite ? Icons.favorite : Icons.favorite_border,
//                           color: isFavorite ? Colors.red : Colors.grey[600],
//                           size: 20,
//                         ),
//                       ),
//                       onPressed: onFavoritePressed,
//                     ),
//                   ),
//               ],
//             ),
//
//             // معلومات المنتج
//             Padding(
//               padding: EdgeInsets.all(10),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // اسم المنتج
//                   Text(
//                     medicine.medicineName,
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                       height: 1.2,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//
//                   SizedBox(height: 4),
//
//                   // المادة العلمية
//                   Text(
//                     medicine.scientificMaterial,
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey[600],
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//
//                   SizedBox(height: 8),
//
//                   // السعر ونوع المنتج
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       // السعر
//                       Text(
//                         '${medicine.price.toStringAsFixed(2)} ريال',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                           color: AppColors.primary,
//                         ),
//                       ),
//
//                       // نوع المنتج (اختياري)
//                       if (showType)
//                         Container(
//                           padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                           decoration: BoxDecoration(
//                             color: AppColors.primary.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Text(
//                             medicine.medicineType.displayName,
//                             style: TextStyle(
//                               fontSize: 10,
//                               color: AppColors.primary,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   IconData _getIconForMedicineType(MedicineType type) {
//     switch (type) {
//       case MedicineType.tablet:
//         return Icons.medication;
//       case MedicineType.capsule:
//         return Icons.medication_liquid;
//       case MedicineType.syrup:
//         return Icons.liquor;
//       case MedicineType.injection:
//         return Icons.medical_services;
//       case MedicineType.ointment:
//         return Icons.healing;
//       case MedicineType.drops:
//         return Icons.water_drop;
//       case MedicineType.inhaler:
//         return Icons.air;
//       case MedicineType.other:
//         return Icons.medical_information;
//     }
//   }
// }
//
// class MedicineCard3 extends StatelessWidget {
//   final Medicine medicine;
//   final bool isFavorite;
//   final VoidCallback? onFavoritePressed;
//   final VoidCallback? onTap;
//
//   const MedicineCard3({
//     super.key,
//     required this.medicine,
//     this.isFavorite = false,
//     this.onFavoritePressed,
//     this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final isLargeScreen = screenWidth > 600;
//
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final cardWidth = constraints.maxWidth;
//         final cardHeight = cardWidth * 1.2; // نسبة ارتفاع إلى العرض
//
//         return InkWell(
//           onTap: onTap ?? () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => MedicineDetailsScreen(medicine: medicine),
//               ),
//             );
//           },
//           borderRadius: BorderRadius.circular(cardWidth * 0.04),
//           child: Card(
//             elevation: 2,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(cardWidth * 0.04),
//             ),
//             child: Stack(
//               children: [
//                 Padding(
//                   padding: EdgeInsets.all(cardWidth * 0.04),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       // صورة الدواء
//                       Center(
//                         child: Container(
//                           height: cardHeight * 0.7,
//                           constraints: BoxConstraints(
//                             maxHeight: screenHeight * 0.2,
//                           ),
//                           child: CachedNetworkImage(
//                             imageUrl: medicine.image ?? '',
//                             fit: BoxFit.contain,
//                             placeholder: (context, url) => Center(
//                               child: CircularProgressIndicator(
//                                 strokeWidth: cardWidth * 0.01,
//                               ),
//                             ),
//                             errorWidget: (context, url, error) => Icon(
//                               _getIconForMedicineType(medicine.medicineType),
//                               size: cardWidth * 0.2,
//                               color: AppColors.primary,
//                             ),
//                           ),
//                         ),
//                       ),
//
//                       // مسافة بين الصورة والنص
//                       SizedBox(height: cardHeight * 0.02),
//
//                       // اسم الدواء
//                       Text(
//                         medicine.medicineName,
//                         style: AppTextStyles.productTitle.copyWith(
//                           fontSize: cardWidth * 0.120,
//                           height: 1.2,
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//
//                       // المادة العلمية
//                       Text(
//                         medicine.scientificMaterial,
//                         style: AppTextStyles.productSubtitle.copyWith(
//                           fontSize: cardWidth * 0.095,
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//
//                       // مساحة فارغة لدفع السعر للأسفل
//                       const Spacer(),
//
//                       // السعر ونوع الدواء
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           // السعر
//                           Flexible(
//                             child: Text(
//                               '${medicine.price.toStringAsFixed(2)} ر.ي',
//                               style: AppTextStyles.productPrice.copyWith(
//                                 fontSize: cardWidth * 0.08,
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//
//                           // نوع الدواء
//                           Flexible(
//                             child: Container(
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: cardWidth * 0.02,
//                                 vertical: cardWidth * 0.01,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: AppColors.primary.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(cardWidth * 0.02),
//                               ),
//                               child: Text(
//                                 medicine.medicineType.displayName,
//                                 style: TextStyle(
//                                   fontSize: cardWidth * 0.08,
//                                   color: AppColors.primary,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // زر الإعجاب
//                 if (onFavoritePressed != null)
//                   Positioned(
//                     top: cardHeight * 0.00,
//                     right: cardWidth * 0.01,
//                     child: IconButton(
//                       icon: Icon(
//                         isFavorite ? Icons.favorite : Icons.favorite_border,
//                         color: isFavorite ? Colors.red : Colors.grey,
//                         size: cardWidth * 0.15,
//                       ),
//                       onPressed: onFavoritePressed,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   IconData _getIconForMedicineType(MedicineType type) {
//     switch (type) {
//       case MedicineType.tablet:
//         return Icons.medication;
//       case MedicineType.capsule:
//         return Icons.medication_liquid;
//       case MedicineType.syrup:
//         return Icons.liquor;
//       case MedicineType.injection:
//         return Icons.medical_services;
//       case MedicineType.ointment:
//         return Icons.healing;
//       case MedicineType.drops:
//         return Icons.water_drop;
//       case MedicineType.inhaler:
//         return Icons.air;
//       case MedicineType.other:
//         return Icons.medical_information;
//     }
//   }
// }
//
// class MedicineCard2 extends StatelessWidget {
//   final Medicine medicine;
//   final bool isFavorite;
//   final VoidCallback? onFavoritePressed;
//   final VoidCallback? onTap;
//
//   const MedicineCard2({
//     super.key,
//     required this.medicine,
//     this.isFavorite = false,
//     this.onFavoritePressed,
//     this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap ?? () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => MedicineDetailsScreen(medicine: medicine),
//           ),
//         );
//       },
//       child: Card(
//         elevation: 2,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Stack(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Center(
//                     child: CachedNetworkImage(
//                       imageUrl: medicine.image ?? '',
//                       height: 100,
//                       placeholder: (context, url) =>
//                       const CircularProgressIndicator(),
//                       errorWidget: (context, url, error) => Icon(
//                         _getIconForMedicineType(medicine.medicineType),
//                         size: 60,
//                         color: AppColors.primary,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     medicine.medicineName,
//                     style: AppTextStyles.productTitle,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   Text(
//                     medicine.scientificMaterial,
//                     style: AppTextStyles.productSubtitle,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const Spacer(),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         '${medicine.price.toStringAsFixed(2)} ر.ي',
//                         style: AppTextStyles.productPrice,
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 8,
//                           vertical: 4,
//                         ),
//                         decoration: BoxDecoration(
//                           color: AppColors.primary.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Text(
//                           medicine.medicineType.displayName,
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: AppColors.primary,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             if (onFavoritePressed != null)
//               Positioned(
//                 top: 8,
//                 right: 8,
//                 child: IconButton(
//                   icon: Icon(
//                     isFavorite ? Icons.favorite : Icons.favorite_border,
//                     color: isFavorite ? Colors.red : Colors.grey,
//                     size: 24,
//                   ),
//                   onPressed: onFavoritePressed,
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   IconData _getIconForMedicineType(MedicineType type) {
//     switch (type) {
//       case MedicineType.tablet:
//         return Icons.medication;
//       case MedicineType.capsule:
//         return Icons.medication_liquid;
//       case MedicineType.syrup:
//         return Icons.liquor;
//       case MedicineType.injection:
//         return Icons.medical_services;
//       case MedicineType.ointment:
//         return Icons.healing;
//       case MedicineType.drops:
//         return Icons.water_drop;
//       case MedicineType.inhaler:
//         return Icons.air;
//       case MedicineType.other:
//         return Icons.medical_information;
//     }
//   }
// }
