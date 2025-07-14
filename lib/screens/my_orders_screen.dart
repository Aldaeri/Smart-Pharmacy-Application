import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../constants/styles.dart';
import '../widgets/bottom_nav_bar.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  List<Map<String, dynamic>> _orders = [];
  int _currentIndex = 2;
  var index = 0;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .orderBy('date', descending: true)
          .get();

      setState(() {
        _orders = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            ...data,
            'formattedDate': DateFormat('yyyy/MM/dd - HH:mm').format(
                (data['date'] as Timestamp).toDate()),
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ في تحميل الطلبات: $e')),
      );
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
        // Navigator.pushReplacementNamed(context, '/cart');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
      case 4:
        Navigator.pushNamed(context, '/home');
        break;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'processing':
        return Colors.orange;
      case 'on_way':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'تم التسليم';
      case 'cancelled':
        return 'ملغى';
      case 'processing':
        return 'قيد المعالجة';
      case 'on_way':
        return 'في الطريق';
      default:
        return status;
    }
  }

  Widget _buildOrderItem(Map<String, dynamic> order) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Text('طلب رقم: ${index + 1}'),
            Chip(
              label: Text(
                _getStatusText(order['status']),
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: _getStatusColor(order['status']),
            ),
            // Text('طلب رقم: ${1 + index++}'),
            Text('طلب رقم: ${order['name']}'),
            // Text('طلب رقم: ${++index}'),
            // Text('طلب رقم: ${1 + index++}'),
            // Text('طلب رقم: ${index++ + 1}'),
            // Text('طلب رقم: ${item['name']}'),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.end, // تغيير إلى end
          children: [
            Text(order['formattedDate']),
            Text('الإجمالي: ${order['total'].toStringAsFixed(2)} ر.ي'),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end, // تغيير إلى end
              children: [
                if (order['pharmacyName'] != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end, // تغيير إلى end
                      children: [
                        Text('الصيدلية: ${order['pharmacyName']}'),
                        const SizedBox(width: 8),
                        const Icon(Icons.local_pharmacy, size: 20),
                      ],
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end, // تغيير إلى end
                    children: [
                      Text('طريقة الدفع: ${order['paymentMethod'] == 'cash'
                          ? 'الدفع عند الاستلام'
                          : 'بطاقة ائتمانية'}'),
                      const SizedBox(width: 8),
                      const Icon(Icons.payment, size: 20),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end, // تغيير إلى end
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'العنوان: ${order['location']}',
                          textAlign: TextAlign.end, // تغيير إلى end
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.location_on, size: 20),
                    ],
                  ),
                ),

                if (order['notes'] != null && order['notes'].isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end, // تغيير إلى end
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            'ملاحظات: ${order['notes']}',
                            textAlign: TextAlign.end, // تغيير إلى end
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.note, size: 20),
                      ],
                    ),
                  ),

                const Divider(),
                const Text(
                  'الأدوية المطلوبة:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.end, // تغيير إلى end
                ),
                const SizedBox(height: 8),
                ...(order['orderItems'] as List).map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end, // تغيير إلى end
                      children: [
                        // Text('ر.ي'),
                        // Text(' ${item['price'].toStringAsFixed(2)}'),
                        Text(
                            '${item['name']} (×${item['quantity']}) : ${item['price']
                                .toStringAsFixed(2)} ر.ي'),
                        // const SizedBox(width: 16),
                        // Text('${item['name']} (×${item['quantity']})'),
                      ],
                    ),
                  );
                }),

                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end, // تغيير إلى end
                  children: [
                    // Text('ر.ي'),
                    Text('تكلفة التوصيل : ${order['deliveryCost']
                        .toStringAsFixed(2)} ر.ي'),
                    // const SizedBox(width: 8),
                    // const Text(': تكلفة التوصيل'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  // crossAxisAlignment: CrossAxisAlignment.center,// تغيير إلى end
                  children: [
                    // Text('ر.ي',style: const TextStyle(fontWeight: FontWeight.bold),),
                    Text(
                      'الإجمالي : ${order['total'].toStringAsFixed(2)} ر.ي',
                      // textAlign: TextAlign.left,
                      // semanticsLabel: 'رررر',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    // Text('ر.ي',textAlign: TextAlign.left,),
                    // const SizedBox(width: 8),
                    // const Text(
                    //   'الإجمالي:',
                    //   style: TextStyle(fontWeight: FontWeight.bold),
                    // ),
                  ],
                ),

                if (order['status'] == 'processing')
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end, // تغيير إلى end
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                _cancelOrder(order['id'], order['status']),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                            child: const Text('إلغاء الطلب'),
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
    );
  }

  Future<void> _cancelOrder(String orderId, String currentStatus) async {
    if (currentStatus != 'processing') {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                currentStatus == 'on_way'
                    ? 'لا يمكن إلغاء الطلب وهو في الطريق للتوصيل'
                    : 'لا يمكن إلغاء الطلب في حالته الحالية'
            ),
            backgroundColor: Colors.orange,
          )
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('تأكيد الإلغاء'),
            content: const Text('هل أنت متأكد أنك تريد إلغاء هذا الطلب؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('تراجع'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                    'تأكيد الإلغاء', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إلغاء الطلب بنجاح')),
      );

      _loadOrders();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء إلغاء الطلب: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مشترياتي',style: AppTextStyles.header),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
          ? const Center(
        child: Text(
          'لا توجد طلبات سابقة',
          style: TextStyle(fontSize: 18),
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadOrders,
        child: ListView.builder(
          itemCount: _orders.length,
          itemBuilder: (context, index) => _buildOrderItem(_orders[index]),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _currentIndex,
        onItemSelected: _onItemTapped,
      ),
      // floatingActionButton: FloatingHomeButton(
      //   isSelected: _currentIndex == 4,
      //   onPressed: () => _onItemTapped(4),
      //   btnHomeColor: AppColors.btnDark,
      //   backgroundColor: AppColors.secondary,
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

// class MyOrdersScreen2 extends StatefulWidget {
//   const MyOrdersScreen2({super.key});
//
//   @override
//   State<MyOrdersScreen2> createState() => _MyOrdersScreen2State();
// }

// class _MyOrdersScreen2State extends State<MyOrdersScreen2> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   bool _isLoading = true;
//   List<Map<String, dynamic>> _orders = [];
//
//   int _currentIndex = 2;
//
//   var index = 1;
//
//   void _onItemTapped(int index) {
//     if (index == _currentIndex) return;
//
//     setState(() {
//       _currentIndex = index;
//     });
//
//     switch (index) {
//       case 0: // المفضلة
//         Navigator.pushReplacementNamed(context, '/favorites');
//         break;
//       case 1: // التذكيرات
//         Navigator.pushReplacementNamed(context, '/reminders');
//         break;
//       case 2: // الحساب (نحن هنا بالفعل)
//       // Navigator.pushReplacementNamed(context, '/cart');
//         break;
//       case 3:
//         Navigator.pushReplacementNamed(context, '/profile');
//         break;
//       case 4:
//         Navigator.pushReplacementNamed(context, '/home');
//         break;
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _loadOrders();
//   }
//
//   Future<void> _loadOrders() async {
//     final user = _auth.currentUser;
//     if (user == null) {
//       setState(() => _isLoading = false);
//       return;
//     }
//
//     try {
//       final snapshot = await _firestore
//           .collection('orders')
//           .where('userId', isEqualTo: user.uid)
//           .orderBy('date', descending: true)
//           .get();
//
//       setState(() {
//         _orders = snapshot.docs.map((doc) {
//           final data = doc.data();
//           return {
//             'id': doc.id,
//             ...data,
//             'formattedDate': DateFormat('yyyy/MM/dd - HH:mm').format(
//                 (data['date'] as Timestamp).toDate()),
//           };
//         }).toList();
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() => _isLoading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('حدث خطأ في تحميل الطلبات: $e')),
//       );
//     }
//   }
//
//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'completed':
//         return Colors.green;
//       case 'cancelled':
//         return Colors.red;
//       case 'processing':
//         return Colors.orange;
//       case 'on_way':
//         return Colors.blue;
//       default:
//         return Colors.grey;
//     }
//   }
//
//   String _getStatusText(String status) {
//     switch (status) {
//       case 'completed':
//         return 'تم التسليم';
//       case 'cancelled':
//         return 'ملغى';
//       case 'processing':
//         return 'قيد المعالجة';
//       case 'on_way':
//         return 'في الطريق';
//       default:
//         return status;
//     }
//   }
//
//   Widget _buildOrderItem(Map<String, dynamic> order) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       elevation: 3,
//       child: ExpansionTile(
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             // Text('طلب #${order['orderId'].toString().substring(0, 8)}'),
//             Text('طلب رقم: ${index + 1}'),
//             // Text('طلب #${}'),
//             Chip(
//               label: Text(
//                 _getStatusText(order['status']),
//                 style: const TextStyle(color: Colors.white),
//               ),
//               backgroundColor: _getStatusColor(order['status']),
//             ),
//           ],
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(order['formattedDate']),
//             Text('الإجمالي: ${order['total'].toStringAsFixed(2)} ر.ي'),
//           ],
//         ),
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // معلومات الصيدلية
//                 if (order['pharmacyName'] != null)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8.0),
//                     child: Row(
//                       children: [
//                         const Icon(Icons.local_pharmacy, size: 20),
//                         const SizedBox(width: 8),
//                         Text('الصيدلية: ${order['pharmacyName']}'),
//                       ],
//                     ),
//                   ),
//
//                 // طريقة الدفع
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 8.0),
//                   child: Row(
//                     children: [
//                       const Icon(Icons.payment, size: 20),
//                       const SizedBox(width: 8),
//                       Text('طريقة الدفع: ${order['paymentMethod'] == 'cash'
//                           ? 'الدفع عند الاستلام'
//                           : 'بطاقة ائتمانية'}'),
//                     ],
//                   ),
//                 ),
//
//                 // العنوان
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 8.0),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Icon(Icons.location_on, size: 20),
//                       const SizedBox(width: 8),
//                       Expanded(child: Text('العنوان: ${order['location']}')),
//                     ],
//                   ),
//                 ),
//
//                 // الملاحظات
//                 if (order['notes'] != null && order['notes'].isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8.0),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Icon(Icons.note, size: 20),
//                         const SizedBox(width: 8),
//                         Expanded(child: Text('ملاحظات: ${order['notes']}')),
//                       ],
//                     ),
//                   ),
//
//                 // تفاصيل الأدوية
//                 const Divider(),
//                 const Text(
//                   'الأدوية المطلوبة:',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8),
//                 ...(order['orderItems'] as List).map((item) {
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 4.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text('${item['name']} (×${item['quantity']})'),
//                         Text('${item['price'].toStringAsFixed(2)} ر.ي'),
//                       ],
//                     ),
//                   );
//                 }).toList(),
//
//                 // التكلفة الإجمالية
//                 const Divider(),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text('تكلفة التوصيل:'),
//                     Text('${order['deliveryCost'].toStringAsFixed(2)} ر.ي'),
//                   ],
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       'الإجمالي:',
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     Text(
//                       '${order['total'].toStringAsFixed(2)} ر.ي',
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                   ],
//                 ),
//
//                 // أزرار الإجراءات
//                 if (order['status'] == 'processing')
//                   Padding(
//                     padding: const EdgeInsets.only(top: 16.0),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: OutlinedButton(
//                             onPressed: () =>
//                                 _cancelOrder(order['id'], order['status']),
//                             style: OutlinedButton.styleFrom(
//                               foregroundColor: Colors.red,
//                               side: const BorderSide(color: Colors.red),
//                             ),
//                             child: const Text('إلغاء الطلب'),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _cancelOrder(String orderId, String currentStatus) async {
//     // التحقق من حالة الطلب
//     if (currentStatus != 'processing') {
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//                 currentStatus == 'on_way'
//                     ? 'لا يمكن إلغاء الطلب وهو في الطريق للتوصيل'
//                     : 'لا يمكن إلغاء الطلب في حالته الحالية'
//             ),
//             backgroundColor: Colors.orange,
//           )
//       );
//       return;
//     }
//
//     // final confirmed = await showDialog<bool>(
//     //   context: context,
//     //   builder: (context) => AlertDialog(
//     //     title: const Text('تأكيد الإلغاء'),
//     //     content: const Text('هل أنت متأكد أنك تريد إلغاء هذا الطلب؟'),
//     //     actions: [
//     //       TextButton(
//     //         onPressed: () => Navigator.pop(context, false),
//     //         child: const Text('تراجع'),
//     //       ),
//     //       TextButton(
//     //         onPressed: () => Navigator.pop(context, true),
//     //         child: const Text('تأكيد الإلغاء', style: TextStyle(color: Colors.red)),
//     //       ),
//     //     ],
//     //   ),
//     // );
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) =>
//           AlertDialog(
//             title: const Text('تأكيد الإلغاء'),
//             content: const Text('هل أنت متأكد أنك تريد إلغاء هذا الطلب؟'),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context, false),
//                 child: const Text('تراجع'),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.pop(context, true),
//                 child: const Text(
//                     'تأكيد الإلغاء', style: TextStyle(color: Colors.red)),
//               ),
//             ],
//           ),
//     );
//
//     if (confirmed != true) return;
//
//     try {
//       await _firestore.collection('orders').doc(orderId).update({
//         'status': 'cancelled',
//         'cancelledAt': FieldValue.serverTimestamp(),
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('تم إلغاء الطلب بنجاح')),
//       );
//
//       _loadOrders(); // تحديث القائمة
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('حدث خطأ أثناء إلغاء الطلب: $e')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('طلباتي'),
//         centerTitle: true,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _orders.isEmpty
//           ? const Center(
//         child: Text(
//           'لا توجد طلبات سابقة',
//           style: TextStyle(fontSize: 18),
//         ),
//       )
//           : RefreshIndicator(
//         onRefresh: _loadOrders,
//         child: ListView.builder(
//           itemCount: _orders.length,
//           itemBuilder: (context, index) => _buildOrderItem(_orders[index]),
//         ),
//       ),
//       bottomNavigationBar: CustomBottomNavBar(
//         selectedIndex: _currentIndex,
//         onItemSelected: _onItemTapped,
//       ),
//       // floatingActionButton: FloatingActionButton(
//       //   onPressed: () {
//       //     Navigator.pushReplacementNamed(context, '/home');
//       //   },
//       //   backgroundColor: AppColors.secondary,
//       //   child: const Icon(Icons.home, color: Colors.black),
//       // ),
//       floatingActionButton: FloatingHomeButton(
//         isSelected: _currentIndex == 4,
//         onPressed: () => _onItemTapped(4),
//         btnHomeColor: AppColors.btnDark,
//         backgroundColor: AppColors.secondary,
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//     );
//   }
// }
