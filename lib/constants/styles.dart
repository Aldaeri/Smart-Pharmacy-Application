import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {

  static const TextStyle header = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle subHeader = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: Colors.white,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const TextStyle seeAll = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  static const TextStyle productTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const TextStyle productSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.grey,
  );

  static const TextStyle productPrice = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  // نصوص أخرى
  static const TextStyle buttonText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle hintText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textGray,
  );


  // static const header = TextStyle(
  //   fontSize: 25,
  //   fontWeight: FontWeight.w400,
  //   color: AppColors.textLight,
  // );

  // static const subHeader = TextStyle(
  //   fontSize: 20,
  //   fontWeight: FontWeight.w400,
  //   color: AppColors.textLight,
  // );

  // static const sectionTitle = TextStyle(
  //   fontSize: 20,
  //   fontWeight: FontWeight.w400,
  //   color: AppColors.textDark,
  // );

  static const bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
  );

  static const bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
  );

  static const bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textGray,
  );

  static const button = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
  );

  // static const seeAll = TextStyle(
  //   fontSize: 14,
  //   fontWeight: FontWeight.w400,
  //   color: AppColors.primary,
  // );

  static const price = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
  );

  // static const productTitle = TextStyle(
  //   fontSize: 15,
  //   fontWeight: FontWeight.w400,
  //   color: AppColors.textDark,
  // );
}
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
