// models/user_model.dart
class UserModel {
  final int userId;
  final String name;
  final String email;
  final String address;
  final String password;
  final String userType;
  final int phone;
  final List<Map<String, dynamic>> favorites;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.address,
    required this.password,
    required this.userType,
    required this.phone,
    required this.favorites,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: int.tryParse(map['userId']?.toString() ?? '0') ?? 0,
      name: map['name']?.toString() ?? 'بدون اسم',
      email: map['Email']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      password: map['password']?.toString() ?? '',
      userType: map['userType']?.toString() ?? 'user',
      phone: int.tryParse(map['phone']?.toString() ?? '0') ?? 0,
      favorites: List<Map<String, dynamic>>.from(map['favorites'] ?? []),
    );
  }

  // factory UserModel.fromMap(Map<String, dynamic> map) {
  //   return UserModel(
  //     userId: map['userId'] as int,
  //     name: map['name'],
  //     email: map['Email'],
  //     address: map['address'],
  //     password: map['password'] ?? '',
  //     userType: map['userType'],
  //     phone: map['phone'] as int,
  //     favorites: List<Map<String, dynamic>>.from(map['favorites'] ?? []),
  //   );
  // }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'Email': email,
      'address': address,
      'password': password,
      'userType': userType,
      'phone': phone,
      'favorites': favorites,
    };
  }

  // أضف هذه الدالة لإنشاء نسخة معدلة من النموذج
  UserModel copyWith({
    required final int userId,
    required final String name,
    required final String email,
    required final String address,
    required final String password,
    required final String userType,
    required final int phone,
    required final List<Map<String, dynamic>> favorites,
  }
  ) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      password: password ?? this.password,
      userType: userType ?? this.userType,
      favorites: favorites ?? this.favorites,
    );
  }
}