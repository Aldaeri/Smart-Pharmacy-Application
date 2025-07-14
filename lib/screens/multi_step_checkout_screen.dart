import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class MultiStepCheckoutScreen extends StatefulWidget {
  const MultiStepCheckoutScreen({super.key});

  @override
  State<MultiStepCheckoutScreen> createState() =>
      _MultiStepCheckoutScreenState();
}

class _MultiStepCheckoutScreenState extends State<MultiStepCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isLoading = false;
  bool _locationLoading = false;
  bool _useSavedLocation = true;
  bool _validatingData = false;

  // بيانات الطلب
  String _address = '';
  String _phone = '';
  String _notes = '';
  String _paymentMethod = 'cash';
  Position? _currentPosition;
  String _currentAddress = 'جاري تحديد الموقع...';
  List<dynamic> _orderItems = [];
  double _total = 0.0;
  double _deliveryCost = 0.0;
  String? _selectedStoreId;
  Map<String, dynamic>? _selectedStore;
  List<Map<String, dynamic>> _stores = [];
  int _quantity = 1;

  // متحكمات النصوص للتحقق من البيانات
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(
    text: '1',
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          _orderItems = args['items'] ?? [];
          _total = args['total'] ?? 0.0;
          if (args.containsKey('quantity')) {
            _quantity = args['quantity'] ?? 1;
            _quantityController.text = _quantity.toString();
          }
        });
      }
      _loadStores();
      _getUserSavedLocation();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  // تحميل قائمة المخازن من Firestore
  Future<void> _loadStores() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('stores').get();
      setState(() {
        _stores =
            snapshot.docs.map((doc) {
              return {
                'storeId': doc.id,
                ...doc.data(),
                'location': doc['location'] as GeoPoint,
              };
            }).toList();
      });
      print('المخازن: ${_stores.length}');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في تحميل االمخازن: $e')));
    }
  }

  // الحصول على الموقع المحفوظ للمستخدم
  Future<void> _getUserSavedLocation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      if (userDoc.exists && userDoc.data()?['address'] != null) {
        setState(() {
          _address = userDoc.data()?['address'];
          _addressController.text = _address;
          _phone = userDoc.data()?['phone'] ?? '';
          _phoneController.text = _phone;
        });
      }
      print('الموقع الحالي: $_currentPosition');
    } catch (e) {
      print('Error getting user location: $e');
    }
  }

  // تحديد أقرب صيدلية بناء على موقع المستخدم
  Future<void> _findNearestStore() async {
    if (_currentPosition == null || _stores.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('لا توجد صيدليات متاحة')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // حساب المسافة لكل صيدلية
      for (var store in _stores) {
        final distance = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          store['location'].latitude,
          store['location'].longitude,
        );
        store['distance'] = distance;
      }

      // ترتيب المخازن حسب الأقرب
      _stores.sort((a, b) => a['distance'].compareTo(b['distance']));

      // اختيار أقرب صيدلية
      Map<String, dynamic> nearestStore = _stores.first;

      // حساب تكلفة التوصيل بناء على المسافة (5 ريال لكل كيلومتر)
      final deliveryCost = (nearestStore['distance'] / 1000) * 5;

      // setState(() {
      //   _selectedStore = nearestStore;
      //   _selectedStoreId = nearestStore['storeId'];
      //   _deliveryCost = deliveryCost.clamp(5, 25).toDouble(); // بين 5 و 25 ريال كحد أعلى
      // });

      setState(() {
        _selectedStore = nearestStore;
        _selectedStoreId =
            nearestStore['storeId']; // تأكد من وجود هذا السطر
        _deliveryCost = deliveryCost.clamp(5, 25).toDouble();
      });
      print('المخزن المحددة: $_selectedStoreId');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في إيجاد المخزن: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // الحصول على الموقع الحالي
  Future<void> _getCurrentLocation() async {
    setState(() => _locationLoading = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('خدمة الموقع معطلة. يرجى تفعيلها');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('تم رفض أذونات الموقع');
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks[0];

      setState(() {
        _currentPosition = position;
        _currentAddress =
            '${place.street}, ${place.locality}, ${place.country}';
        if (!_useSavedLocation) {
          _address = _currentAddress;
          _addressController.text = _address;
        }
      });

      // بعد تحديد الموقع، نبحث عن أقرب صيدلية
      await _findNearestStore();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في تحديد الموقع: $e')));
    } finally {
      setState(() => _locationLoading = false);
    }
  }

  // التحقق من صحة البيانات المدخلة
  bool _validateInputs() {
    setState(() => _validatingData = true);

    if (_address.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('الرجاء إدخال العنوان')));
      setState(() => _validatingData = false);
      return false;
    }

    if (_phone.isEmpty || !RegExp(r'^[0-9]{9}$').hasMatch(_phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال رقم هاتف صحيح (9 أرقام)')),
      );
      setState(() => _validatingData = false);
      return false;
    }

    if (_selectedStoreId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد صيدلية متاحة لتوصيل الطلب')),
      );
      setState(() => _validatingData = false);
      return false;
    }

    setState(() => _validatingData = false);
    return true;
  }

  bool _validateStepOne() {
    if (_address.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('الرجاء إدخال العنوان')));
      return false;
    }

    if (_selectedStoreId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء تحديد الموقع لاختيار المخزن')),
      );
      return false;
    }

    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null || quantity < 1) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('الرجاء إدخال كمية صحيحة')));
      return false;
    }

    return true;
  }

  // تنفيذ الطلب
  Future<void> _placeOrder() async {
    if (!_validateInputs()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('يجب تسجيل الدخول أولاً');

      // التحقق من توفر الكمية في المخزون
      for (var item in _orderItems) {
        final medRef = FirebaseFirestore.instance
            .collection('medicines')
            .doc(item.id);

        final medDoc = await medRef.get();
        if (!medDoc.exists || (medDoc['quantity'] as int) < _quantity) {
          throw Exception('الكمية المطلوبة من ${item.medicineName} غير متوفرة');
        }
      }

      final orderId = FirebaseFirestore.instance.collection('orders').doc().id;
      final now = DateTime.now();

      final orderData = {
        'date': now,
        'deliveryCost': _deliveryCost,
        'location': _address,
        'coordinates':
            _currentPosition != null
                ? GeoPoint(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                )
                : null,
        'orderId': orderId,
        'orderItems':
            _orderItems
                .map(
                  (item) => {
                    'medicineId': item.id,
                    'name': item.medicineName,
                    'price': item.price,
                    'quantity': _quantity,
                  },
                )
                .toList(),
        'paymentStatus': 'pending',
        'status': 'processing',
        'total': (_total * _quantity) + _deliveryCost,
        'userId': user.uid,
        'phone': _phone,
        'notes': _notes,
        'paymentMethod': _paymentMethod,
        'storeId': _selectedStoreId,
        'storeName': _selectedStore?['storeName'] ?? '',
        'deliveryId': '',

      };

      // بدء معاملة Firestore
      final batch = FirebaseFirestore.instance.batch();

      // إضافة الطلب
      final orderRef = FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId);
      batch.set(orderRef, orderData);

      // تحديث كميات الأدوية
      for (var item in _orderItems) {
        final medRef = FirebaseFirestore.instance
            .collection('medicines')
            .doc(item.id);

        batch.update(medRef, {
          'quantity': FieldValue.increment(-_quantity),
          'lastUpdated': now,
        });
      }

      // تنفيذ المعاملة
      await batch.commit();

      // إرسال إشعار للمندوب
      await _sendDeliveryNotification(orderId);

      // حفظ بيانات المستخدم إذا كانت جديدة
      if (_useSavedLocation) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'address': _address,
          'phone': _phone,
          'lastUpdated': now,
        }, SetOptions(merge: true));
      }

      Navigator.pushReplacementNamed(
        context,
        '/order_confirmation',
        arguments: {'orderId': orderId},
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // إرسال إشعار للمندوب
  Future<void> _sendDeliveryNotification(String orderId) async {
    try {
      // البحث عن مندوب قريب من المخزن
      final storeLocation = _selectedStore?['location'] as GeoPoint?;
      if (storeLocation == null) return;

      final deliverySnapshot =
          await FirebaseFirestore.instance
              .collection('delivery')
              .where('status', isEqualTo: 'available')
              .get();

      if (deliverySnapshot.docs.isEmpty) return;

      // حساب المسافة لكل مندوب واختيار الأقرب
      List<QueryDocumentSnapshot> availableDelivery = [];
      for (var doc in deliverySnapshot.docs) {
        final deliveryData = doc.data();
        if (deliveryData['location'] != null) {
          final deliveryLocation = deliveryData['location'] as GeoPoint;
          final distance = Geolocator.distanceBetween(
            storeLocation.latitude,
            storeLocation.longitude,
            deliveryLocation.latitude,
            deliveryLocation.longitude,
          );

          if (distance < 5000) {
            // ضمن 5 كم
            availableDelivery.add(doc);
          }
        }
      }

      if (availableDelivery.isEmpty) return;

      // إرسال الإشعار لأول مندوب متاح
      final deliveryId = availableDelivery.first.id;
      await FirebaseFirestore.instance.collection('notifications').add({
        'deliveryId': deliveryId,
        'orderId': orderId,
        'storeId': _selectedStoreId,
        'storeName': _selectedStore?['storeName'] ?? '',
        'timestamp': DateTime.now(),
        'status': 'pending',
        'message': 'طلب جديد يحتاج للتوصيل',
      });
    } catch (e) {
      print('Error sending delivery notification: $e');
    }
  }

  List<Step> _buildSteps() {
    return [
      // الخطوة 1: تحديد الموقع
      Step(
        title: const Text('تحديد الموقع'),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
        content: Column(
          children: [
            // اختيار استخدام الموقع المحفوظ أو جديد
            Row(
              children: [
                const Text('استخدام الموقع المحفوظ:'),
                Switch(
                  value: _useSavedLocation,
                  onChanged: (value) {
                    setState(() {
                      _useSavedLocation = value;
                      if (!value) {
                        _getCurrentLocation();
                      } else {
                        _getUserSavedLocation();
                      }
                    });
                  },
                ),
              ],
            ),

            _locationLoading
                ? const CircularProgressIndicator()
                : Text(
                  _useSavedLocation ? _address : _currentAddress,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
            const SizedBox(height: 16),

            if (!_useSavedLocation) ...[
              ElevatedButton(
                onPressed: _getCurrentLocation,
                child: const Text('تحديث الموقع الحالي'),
              ),
              const SizedBox(height: 16),
            ],

            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'أدخل العنوان بالتفصيل',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _address = value,
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال العنوان';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // عرض معلومات المخزن المختارة
            if (_selectedStore != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المخزن: ${_selectedStore!['storeName']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'المسافة: ${(_selectedStore!['distance'] / 1000).toStringAsFixed(1)} كم',
                      ),
                      Text(
                        'تكلفة التوصيل: ${_deliveryCost.toStringAsFixed(2)} ر.ي',
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // حقل كمية الطلب
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'الكمية',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    int.tryParse(value) == null ||
                    int.parse(value) < 1) {
                  return 'الرجاء إدخال كمية صحيحة';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  _quantity = int.tryParse(value) ?? 1;
                });
              },
            ),
          ],
        ),
      ),

      // الخطوة 2: معلومات الاتصال
      Step(
        title: const Text('معلومات الاتصال'),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
        content: Column(
          children: [
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'رقم الهاتف',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال رقم الهاتف';
                }
                if (!RegExp(r'^[0-9]{9}$').hasMatch(value)) {
                  return 'يجب أن يتكون رقم الهاتف من 9 أرقام';
                }
                return null;
              },
              onChanged: (value) => _phone = value,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'ملاحظات إضافية (اختياري)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _notes = value,
              maxLines: 3,
            ),
          ],
        ),
      ),

      // الخطوة 3: طريقة الدفع
      Step(
        title: const Text('طريقة الدفع'),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
        content: Column(
          children: [
            RadioListTile<String>(
              title: const Text('الدفع عند الاستلام'),
              value: 'cash',
              groupValue: _paymentMethod,
              onChanged: (value) {
                setState(() => _paymentMethod = value!);
              },
            ),
            RadioListTile<String>(
              title: const Text('بطاقة ائتمانية'),
              value: 'credit_card',
              groupValue: _paymentMethod,
              onChanged: (value) {
                setState(() => _paymentMethod = value!);
              },
            ),
          ],
        ),
      ),

      // الخطوة 4: تأكيد الطلب
      Step(
        title: const Text('تأكيد الطلب'),
        isActive: _currentStep >= 3,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ملخص الطلب',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    for (var item in _orderItems)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${item.medicineName} (×$_quantity)'),
                            Text(
                              '${(item.price * _quantity).toStringAsFixed(2)} ر.ي',
                            ),
                          ],
                        ),
                      ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('المخزن:'),
                        Flexible(
                          child: Text(
                            _selectedStore?['storeName'] ?? 'غير محدد',
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('العنوان:'),
                        Flexible(child: Text(_address)),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('طريقة الدفع:'),
                        Text(
                          _paymentMethod == 'cash'
                              ? 'الدفع عند الاستلام'
                              : 'بطاقة ائتمانية',
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('تكلفة التوصيل:'),
                        Text('${_deliveryCost.toStringAsFixed(2)} ر.ي'),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('الإجمالي:'),
                        Text(
                          '${(_total * _quantity + _deliveryCost).toStringAsFixed(2)} ر.ي',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _isLoading || _validatingData
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _placeOrder,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('تأكيد الطلب'),
                  ),
                ),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إتمام الطلب'), centerTitle: true),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep == 0) {
              if (!_validateStepOne()) {
                return;
              }
            } else if (_currentStep == 1) {
              if (!_formKey.currentState!.validate()) {
                return;
              }
            }

            if (_currentStep < _buildSteps().length - 1) {
              setState(() => _currentStep += 1);
            }
          },
          // onStepContinue: () {
          //   if (_currentStep == 0 && !_formKey.currentState!.validate()) {
          //     return;
          //   }
          //   if (_currentStep == 1 && !_formKey.currentState!.validate()) {
          //     return;
          //   }
          //   if (_currentStep < _buildSteps().length - 1) {
          //     setState(() => _currentStep += 1);
          //   }
          // },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep -= 1);
            }
          },
          steps: _buildSteps(),
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: [
                  if (_currentStep != 0)
                    ElevatedButton(
                      onPressed: details.onStepCancel,
                      child: const Text('السابق'),
                    ),
                  const SizedBox(width: 8),
                  if (_currentStep != _buildSteps().length - 1)
                    ElevatedButton(
                      onPressed: details.onStepContinue,
                      child: const Text('التالي'),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}