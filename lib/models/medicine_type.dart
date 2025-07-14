enum MedicineType {
  tablet,
  capsule,
  syrup,
  injection,
  ointment,
  drops,
  inhaler,
  other;

  String get displayName {
    switch (this) {
      case MedicineType.tablet:
        return 'أقراص';
      case MedicineType.capsule:
        return 'كبسولات';
      case MedicineType.syrup:
        return 'شراب';
      case MedicineType.injection:
        return 'حقن';
      case MedicineType.ointment:
        return 'مرهم';
      case MedicineType.drops:
        return 'قطرات';
      case MedicineType.inhaler:
        return 'بخاخ';
      case MedicineType.other:
        return 'أخرى';
    }
  }
}