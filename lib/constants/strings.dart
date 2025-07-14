import 'package:flutter/material.dart';

@immutable
class AppTextTheme extends ThemeExtension<AppTextTheme> {
  final TextStyle? arialBold25px;
  final TextStyle? arialRegular14px;

  const AppTextTheme({
    this.arialBold25px,
    this.arialRegular14px,
  });

  const AppTextTheme.fallback()
      : this(
    arialBold25px: const TextStyle(
      fontSize: 25,
      fontWeight: FontWeight.w400,
      fontFamily: "Inter",
      fontStyle: FontStyle.normal,
      decoration: TextDecoration.none,
    ),
    arialRegular14px: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      fontFamily: "Inter",
      fontStyle: FontStyle.normal,
      decoration: TextDecoration.none,
    ),
  );

  @override
  AppTextTheme copyWith({
    TextStyle? arialBold25px,
    TextStyle? arialRegular14px,
  }) {
    return AppTextTheme(
      arialBold25px: arialBold25px ?? this.arialBold25px,
      arialRegular14px: arialRegular14px ?? this.arialRegular14px,
    );
  }

  @override
  AppTextTheme lerp(AppTextTheme? other, double t) {
    if (other is! AppTextTheme) return this;
    return AppTextTheme(
      arialBold25px: TextStyle.lerp(arialBold25px, other.arialBold25px, t),
      arialRegular14px: TextStyle.lerp(arialRegular14px, other.arialRegular14px, t),
    );
  }
}

class AppStrings {
  static const String welcome = 'أهلاً وسهلاً!';
  static const String userName = 'أسامة محمد';
  static const String searchHint = 'البحث في الصيدلية';
// ... إلخ
}