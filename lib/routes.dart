import 'package:flutter/material.dart';
import 'package:smart_pharmacy_app/screens/profile/edit_profile_screen.dart';
import 'screens/my_orders_screen.dart';
import 'screens/no_internet_screen.dart';
import 'screens/sign_up.dart';
import 'screens/login_screen.dart';
import 'screens/multi_step_checkout_screen.dart';
import 'screens/order_confirmation_screen.dart';
import 'screens/account_created.dart';
import 'screens/favorite.dart';
import 'screens/forget_password.dart';
import 'screens/home.dart';
import 'screens/profile/profile.dart';
import 'screens/reminder.dart';
import 'screens/sign_in.dart';
import 'screens/splash_screen.dart';
import 'screens/verify_email.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/no_internet': (context) => const NoInternetScreen(),
  '/splash': (context) => const SplashScreen(),
  '/welcome': (context) => const LoginScreen(),
  '/login': (context) => const LoginScreen(),
  // '/signup': (context) => const SignUpScreen(),
  '/signup': (context) => const SignUpPage(),
  '/account_created': (context) => const AccountCreated(),
  // '/email_sent': (context) => const EmailSent(),
  '/home': (context) => const HomeScreen(),
  // '/favorite': (context) => const Favorite(),
  '/favorites': (context) => const FavoriteScreen(),
  '/profile': (context) => const ProfileScreen(),
  '/reminders': (context) => const Reminder(),
  '/signin': (context) => const SignIn(),
  '/forget_password': (context) => const ForgetPasswordScreen(),
  '/verify_email': (context) => const VerifyEmailScreen(),
  // '/cart': (context) => const CartScreen(),
  // '/cart': (context) => const CartScreen(),
  '/cart': (context) => const MyOrdersScreen(),
  '/my_orders': (context) => const MyOrdersScreen(),
  '/account': (context) => const EditProfileScreen(),
  '/checkout': (context) => const MultiStepCheckoutScreen(),
  // '/checkout': (context) => const CheckoutScreen(),
  '/order_confirmation': (context) => const OrderConfirmationScreen(),
};
