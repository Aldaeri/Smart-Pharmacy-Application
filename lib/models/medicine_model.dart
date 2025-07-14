import 'package:cloud_firestore/cloud_firestore.dart';
import 'medicine_type.dart';

class Medicine {
  final String id;
  final String medicineName;
  final String scientificMaterial;
  final String description;
  final Timestamp expiryDate;
  final Timestamp productionDate;
  final MedicineType medicineType;
  final double price;
  final int quantity;
  final String shelf;
  final String? image;
  final String? barcode;
  final String? imprint;
  final List<String>? keywords;

  Medicine({
    required this.id,
    required this.medicineName,
    required this.scientificMaterial,
    required this.description,
    required this.expiryDate,
    required this.productionDate,
    required this.medicineType,
    required this.price,
    required this.quantity,
    required this.shelf,
    this.image,
    this.barcode,
    this.imprint,
    this.keywords,
  });

  factory Medicine.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Medicine(
      id: doc.id,
      medicineName: data['medicineName'] ?? '',
      scientificMaterial: data['Scientific_material'] ?? data['scientificMaterial'] ?? '',
      description: data['description'] ?? '',
      expiryDate: data['expiryDate'] as Timestamp,
      productionDate: data['productionDate'] as Timestamp,
      medicineType: _parseMedicineType(data['medicineType']),
      price: (data['price'] as num).toDouble(),
      quantity: data['quantity'] as int,
      shelf: data['shelf'] ?? '',
      image: data['image'] ?? data['image'],
      barcode: data['barcode']?.toString(),
      imprint: data['imprint']?.toString(),
      keywords: List<String>.from(data['keywords'] ?? []),
    );
  }

  static MedicineType _parseMedicineType(dynamic type) {
    if (type == null) return MedicineType.other;
    final typeString = type.toString().toLowerCase();
    return MedicineType.values.firstWhere(
          (e) => e.toString().split('.').last == typeString,
      orElse: () => MedicineType.other,
    );
  }

  List<String> generateKeywords() {
    final keywords = <String>[
      medicineName.toLowerCase(),
      scientificMaterial.toLowerCase(),
      ...medicineName.toLowerCase().split(' '),
      ...scientificMaterial.toLowerCase().split(' '),
    ];

    if (imprint != null && imprint!.isNotEmpty) {
      keywords.add(imprint!.toLowerCase());
    }

    if (barcode != null && barcode!.isNotEmpty) {
      keywords.add(barcode!.toLowerCase());
    }

    if (description.isNotEmpty) {
      keywords.addAll(description.toLowerCase().split(' '));
    }

    return keywords
        .where((word) => word.length > 2)
        .toSet()
        .toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'medicineName': medicineName,
      'Scientific_material': scientificMaterial,
      'description': description,
      'expiryDate': expiryDate,
      'productionDate': productionDate,
      'medicineType': medicineType.toString().split('.').last,
      'price': price,
      'quantity': quantity,
      'shelf': shelf,
      'image': image,
      'barcode': barcode,
      'imprint': imprint,
      'keywords': generateKeywords(),
    };
  }
}

class Medicine3 {
  final String id;
  final String medicineName;
  final String scientificMaterial;
  final String description;
  final Timestamp expiryDate;
  final Timestamp productionDate;
  final MedicineType medicineType;
  final double price;
  final int quantity;
  final String shelf;
  final String? image;
  final List<String> keywords;
  final String? barcode;
  final String? shape;
  final String? color;
  final String? imprint;

  Medicine3({
    required this.id,
    required this.medicineName,
    required this.scientificMaterial,
    required this.description,
    required this.expiryDate,
    required this.productionDate,
    required this.medicineType,
    required this.price,
    required this.quantity,
    required this.shelf,
    this.image,
    this.keywords = const [],
    this.barcode,
    this.shape,
    this.color,
    this.imprint,
  });

  // factory Medicine.fromFirestore(DocumentSnapshot doc) {
  //   try {
  //     final data = doc.data() as Map<String, dynamic>;
  //     return Medicine(
  //       id: doc.id,
  //       medicineName: data['medicineName'] ?? '',
  //       scientificMaterial: data['Scientific_material'] ?? '',
  //       description: data['description'] ?? '',
  //       expiryDate: data['expiryDate'] as Timestamp,
  //       productionDate: data['productionDate'] as Timestamp,
  //       medicineType: _parseMedicineType(data['medicineType']),
  //       price: (data['price'] as num).toDouble(),
  //       quantity: data['quantity'] as int,
  //       shelf: data['shelf'] ?? '',
  //       image: data['image'],
  //       keywords: List<String>.from(data['keywords'] ?? []),
  //       barcode: data['barcode'],
  //       shape: data['shape'],
  //       color: data['color'],
  //       imprint: data['imprint'],
  //     );
  //   } catch (e) {
  //     print('Error parsing medicine: $e');
  //     return Medicine(
  //       id: '',
  //       medicineName: '',
  //       scientificMaterial: '',
  //       description: '',
  //       expiryDate: Timestamp.now(),
  //       productionDate: Timestamp.now(),
  //       medicineType: MedicineType.other,
  //       price: 0,
  //       quantity: 0,
  //       shelf: '',
  //     );
  //   }
  // }

  factory Medicine3.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Medicine3(
      id: doc.id,
      medicineName: data['medicineName'] ?? '',
      scientificMaterial: data['Scientific_material'] ?? data['ScientificName'] ?? '',
      description: data['description'] ?? '',
      expiryDate: data['expiryDate'] as Timestamp,
      productionDate: data['productionDate'] as Timestamp,
      medicineType: _parseMedicineType(data['medicineType']),
      price: (data['price'] as num).toDouble(),
      quantity: data['quantity'] as int,
      shelf: data['shelf'] ?? '',
      image: data['image'] ?? '',
      keywords: List<String>.from(data['keywords'] ?? []),
      barcode: data['barcode']?.toString(),
      imprint: data['imprint']?.toString(),
    );
  }

  static MedicineType _parseMedicineType(dynamic type) {
    if (type == null) return MedicineType.other;

    final typeString = type.toString().toLowerCase();
    return MedicineType.values.firstWhere(
          (e) => e.toString().split('.').last == typeString,
      orElse: () => MedicineType.other,
    );
  }

  List<String> generateKeywords() {
    final keywords = <String>[
      medicineName.toLowerCase(),
      scientificMaterial.toLowerCase(),
      ...medicineName.toLowerCase().split(' '),
      ...scientificMaterial.toLowerCase().split(' '),
    ];

    if (imprint != null && imprint!.isNotEmpty) {
      keywords.add(imprint!.toLowerCase());
    }

    if (barcode != null && barcode!.isNotEmpty) {
      keywords.add(barcode!.toLowerCase());
    }

    // إزالة التكرارات والقيم الفارغة
    return keywords
        .where((word) => word.isNotEmpty && word.length > 2)
        .toSet()
        .toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'medicineName': medicineName,
      'Scientific_material': scientificMaterial,
      'description': description,
      'expiryDate': expiryDate,
      'productionDate': productionDate,
      'medicineType': medicineType.toString().split('.').last,
      'price': price,
      'quantity': quantity,
      'shelf': shelf,
      'image': image,
      'keywords': generateKeywords(),
      'barcode': barcode,
      'shape': shape,
      'color': color,
      'imprint': imprint,
    };
  }

  // دالة مساعدة لإنشاء كلمات مفتاحية تلقائية
  // List<String> generateKeywords() {
  //     // final baseKeywords = [
  //     //   medicineName.toLowerCase(),
  //     //   scientificMaterial.toLowerCase(),
  //     //   ...medicineName.toLowerCase().split(' '),
  //     //   ...scientificMaterial.toLowerCase().split(' '),
  //     // ];
  //     //
  //     // // إضافة كلمات من الوصف
  //     // final descKeywords = description?.toLowerCase().split(' ') ?? [];
  //     //
  //     // // تصفية الكلمات المهمة فقط
  //     // final filtered = [...baseKeywords, ...descKeywords]
  //     //     .where((word) => word.length > 2)
  //     //     .toSet()
  //     //     .toList();
  //
  //   // return filtered;
  //   // final keywords = <String>[
  //   //   medicineName.toLowerCase(),
  //   //   scientificMaterial.toLowerCase(),
  //   //   ...medicineName.toLowerCase().split(' '),
  //   //   ...scientificMaterial.toLowerCase().split(' '),
  //   // ];
  //
  //   // if (imprint != null && imprint!.isNotEmpty) {
  //   //   keywords.add(imprint!.toLowerCase());
  //   // }
  //   //
  //   // if (barcode != null && barcode!.isNotEmpty) {
  //   //   keywords.add(barcode!.toLowerCase());
  //   // }
  //   //
  //   // // إزالة التكرارات
  //   // return keywords.toSet().toList();
  //     final keywords = <String>[
  //       medicineName.toLowerCase(),
  //       scientificMaterial.toLowerCase(),
  //       ...medicineName.toLowerCase().split(' '),
  //       ...scientificMaterial.toLowerCase().split(' '),
  //     ];
  //
  //     // إضافة كلمات من الوصف
  //     final descKeywords = description?.toLowerCase().split(' ') ?? [];
  //
  //     // تصفية الكلمات المهمة فقط
  //     final filtered = [...keywords, ...descKeywords]
  //         .where((word) => word.length > 2)
  //         .toSet()
  //         .toList();
  //
  //     if (imprint != null && imprint!.isNotEmpty) {
  //       keywords.add(imprint!.toLowerCase());
  //     }
  //
  //     if (barcode != null && barcode!.isNotEmpty) {
  //       keywords.add(barcode!.toLowerCase());
  //     }
  //
  //     // إزالة التكرارات والقيم الفارغة
  //     return keywords
  //         .where((word) => word.length > 2)
  //         .toSet()
  //         .toList();
  // }
}

class Medicine2 {
  final String id;
  final String medicineName;
  final String scientificMaterial;
  final String description;
  final Timestamp expiryDate;
  final Timestamp productionDate;
  final MedicineType medicineType;
  final double price;
  final int quantity;
  final String shelf;
  final String? image;

  Medicine2({
    required this.id,
    required this.medicineName,
    required this.scientificMaterial,
    required this.description,
    required this.expiryDate,
    required this.productionDate,
    required this.medicineType,
    required this.price,
    required this.quantity,
    required this.shelf,
    this.image,
  });

  factory Medicine2.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>;
      return Medicine2(
        id: doc.id,
        medicineName: data['medicineName'] ?? '',
        scientificMaterial: data['Scientific_material'] ?? '',
        description: data['description'] ?? '',
        expiryDate: data['expiryDate'] as Timestamp,
        productionDate: data['productionDate'] as Timestamp,
        medicineType: _parseMedicineType(data['medicineType']),
        price: (data['price'] as num).toDouble(),
        quantity: data['quantity'] as int,
        shelf: data['shelf'] ?? '',
        image: data['image'],
      );
    } catch (e) {
      print('Error parsing medicine: $e');
      return Medicine2(
        id: '',
        medicineName: '',
        scientificMaterial: '',
        description: '',
        expiryDate: Timestamp.now(),
        productionDate: Timestamp.now(),
        medicineType: MedicineType.other,
        price: 0,
        quantity: 0,
        shelf: '',
      );
    }
  }

  static MedicineType _parseMedicineType(dynamic type) {
    if (type == null) return MedicineType.other;

    final typeString = type.toString().toLowerCase();
    return MedicineType.values.firstWhere(
          (e) => e.toString().split('.').last == typeString,
      orElse: () => MedicineType.other,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'medicineName': medicineName,
      'Scientific_material': scientificMaterial,
      'description': description,
      'expiryDate': expiryDate,
      'productionDate': productionDate,
      'medicineType': medicineType.toString().split('.').last,
      'price': price,
      'quantity': quantity,
      'shelf': shelf,
      'image': image,
    };
  }
}
