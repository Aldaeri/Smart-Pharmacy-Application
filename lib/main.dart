import 'dart:async';
import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_pharmacy_app/providers/cart_provider.dart';
import 'package:smart_pharmacy_app/routes.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'providers/user_provider.dart';
import 'screens/home.dart';
import 'screens/login_screen.dart';

// متغير عالمي لتتبع حالة تهيئة Firebase
bool _isFirebaseInitialized = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase
  await _initializeFirebase();

  // نسخ ملفات tessdata
  await _copyTessDataToAppDir();

  tz.initializeTimeZones();

  // تهيئة الإشعارات
  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'reminder_channel',
        channelName: 'تذكيرات الأدوية',
        channelDescription: 'تذكيرات تناول الأدوية يومياً',
        defaultColor: const Color(0xFF9050DD),
        importance: NotificationImportance.High,
        ledColor: Colors.white,
        playSound: true,
        enableVibration: true,
        locked: true,
      ),
    ],
  );

  // طلب إذن الإشعارات
  AwesomeNotifications().isNotificationAllowed().then((allowed) {
    if (!allowed) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });

  final prefs = await SharedPreferences.getInstance();

  // تهيئة الخدمة الخلفية بعد التأكد من تهيئة Firebase
  await initializeService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider(prefs)..loadUser()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: SmartPharmacyApp(),
    ),
  );
}

// دالة منفصلة لتهيئة Firebase مع التعامل مع الأخطاء
Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _isFirebaseInitialized = true;
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
    _isFirebaseInitialized = false;
  }
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'reminder_channel',
      initialNotificationContent: 'جاري مراقبة مواعيد الأدوية',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
  service.startService();
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // تأخير البدء لضمان تهيئة Firebase
  await Future.delayed(Duration(seconds: 3));

  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
  }

  // مهمة دورية للتحقق من التذكيرات كل دقيقة
  Timer.periodic(const Duration(minutes: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        await _checkAndSendReminders();
      }
    }
  });
}

Future<void> _checkAndSendReminders() async {
  try {
    // التأكد من تهيئة Firebase قبل الاستخدام
    if (!_isFirebaseInitialized) {
      await _initializeFirebase();
      if (!_isFirebaseInitialized) return;
    }

    final now = DateTime.now();
    final currentTime = '${now.hour}:${now.minute} ${now.hour >= 12 ? 'PM' : 'AM'}';

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('reminders')
        .where('reminderTime', isEqualTo: currentTime)
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: doc.id.hashCode,
          channelKey: 'reminder_channel',
          title: 'تذكير تناول الدواء',
          body: 'حان الوقت لتناول ${data['medicineName']}',
          payload: {'reminderId': doc.id},
          notificationLayout: NotificationLayout.Default,
          wakeUpScreen: true,
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'CONFIRM',
            label: 'تأكيد تناول الدواء',
          ),
          NotificationActionButton(
            key: 'SNOOZE',
            label: 'تأجيل لمدة 10 دقائق',
          ),
        ],
      );
    }
  } catch (e) {
    print('Error in _checkAndSendReminders: $e');
  }
}

Future<void> _copyTessDataToAppDir() async {
  final appDir = await getApplicationDocumentsDirectory();
  final tessDir = Directory('${appDir.path}/tessdata');

  if (!await tessDir.exists()) {
    await tessDir.create();
  }

  await Future.wait([
    rootBundle.load('assets/tessdata/ara.traineddata')
        .then((data) => File('${tessDir.path}/ara.traineddata').writeAsBytes(data.buffer.asUint8List())),
    rootBundle.load('assets/tessdata/eng.traineddata')
        .then((data) => File('${tessDir.path}/eng.traineddata').writeAsBytes(data.buffer.asUint8List())),
    rootBundle.load('assets/tessdata/tessdata_config.json')
        .then((data) => File('${tessDir.path}/tessdata_config.json').writeAsBytes(data.buffer.asUint8List())),
  ]);
}

class SmartPharmacyApp extends StatelessWidget {
  SmartPharmacyApp({super.key});

  final routeObserver = RouteObserver<PageRoute>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'الصيدلية الذكية',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/splash',
      routes: appRoutes,
      navigatorObservers: [routeObserver],
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          final userProvider = Provider.of<UserProvider>(
            context,
            listen: false,
          );

          if (snapshot.connectionState == ConnectionState.active) {
            final user = snapshot.data;
            if (user == null) {
              return const LoginScreen();
            } else {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (userProvider.user == null) {
                  userProvider.setUserFromFirestore(user.uid);
                }
              });
              return const HomeScreen();
            }
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Step 1: Initialize Firebase
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform, // إذا كنت تستخدم flutterfire CLI
//   );
//
//   // Step 2: Copy tessdata files
//   await _copyTessDataToAppDir();
//
//   tz.initializeTimeZones();
//
//   // تهيئة الخدمة الخلفية
//   await initializeService();
//
//   // تهيئة الإشعارات
//   await AwesomeNotifications().initialize(
//     null,
//     [
//       NotificationChannel(
//         channelKey: 'reminder_channel',
//         channelName: 'تذكيرات الأدوية',
//         // channelName: null,
//         channelDescription: 'تذكيرات تناول الأدوية يومياً',
//         defaultColor: const Color(0xFF9050DD),
//         importance: NotificationImportance.High,
//         ledColor: Colors.white,
//         playSound: true,
//         enableVibration: true,
//         locked: true,
//       ),
//     ],
//   );
//
//   // طلب إذن الإشعارات إذا لم يكن مسموحًا
//   AwesomeNotifications().isNotificationAllowed().then((allowed) {
//     if (!allowed) {
//       AwesomeNotifications().requestPermissionToSendNotifications();
//     }
//   });
//
//   final prefs = await SharedPreferences.getInstance();
//
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => UserProvider(prefs)..loadUser()),
//         ChangeNotifierProvider(create: (_) => CartProvider()),
//       ],
//       child: SmartPharmacyApp(),
//     ),
//   );
//
// }
//
// Future<void> initializeService() async {
//   final service = FlutterBackgroundService();
//   await service.configure(
//     androidConfiguration: AndroidConfiguration(
//       onStart: onStart,
//       autoStart: true,
//       isForegroundMode: true,
//       notificationChannelId: 'reminder_channel',
//       // initialNotificationTitle: 'خدمة تذكير الأدوية',
//       initialNotificationContent: 'جاري مراقبة مواعيد الأدوية',
//       foregroundServiceNotificationId: 888,
//     ),
//     iosConfiguration: IosConfiguration(
//       autoStart: true,
//       onForeground: onStart,
//       onBackground: onIosBackground,
//     ),
//   );
//   service.startService();
// }
//
// @pragma('vm:entry-point')
// Future<bool> onIosBackground(ServiceInstance service) async {
//   return true;
// }
//
// @pragma('vm:entry-point')
// void onStart(ServiceInstance service) async {
//   // للمنصة Android فقط
//   if (service is AndroidServiceInstance) {
//     service.setAsForegroundService();
//   }
//
//   // مهمة دورية للتحقق من التذكيرات كل دقيقة
//   Timer.periodic(const Duration(minutes: 1), (timer) async {
//     if (service is AndroidServiceInstance) {
//       if (await service.isForegroundService()) {
//         await _checkAndSendReminders();
//       }
//     }
//   });
// }
//
// Future<void> _checkAndSendReminders() async {
//   final now = DateTime.now();
//   final currentTime = '${now.hour}:${now.minute} ${now.hour >= 12 ? 'PM' : 'AM'}';
//
//   final user = FirebaseAuth.instance.currentUser;
//   if (user == null) return;
//
//   final snapshot = await FirebaseFirestore.instance
//       .collection('users')
//       .doc(user.uid)
//       .collection('reminders')
//       .where('reminderTime', isEqualTo: currentTime)
//       .get();
//
//   for (var doc in snapshot.docs) {
//     final data = doc.data();
//     await AwesomeNotifications().createNotification(
//       content: NotificationContent(
//         id: doc.id.hashCode,
//         channelKey: 'reminder_channel',
//         title: 'تذكير تناول الدواء',
//         body: 'حان الوقت لتناول ${data['medicineName']}',
//         payload: {'reminderId': doc.id},
//         notificationLayout: NotificationLayout.Default,
//         // locked: true,
//         // تم إزالة autoCancel غير المعرّفة
//         wakeUpScreen: true,
//       ),
//       actionButtons: [
//         NotificationActionButton(
//           key: 'CONFIRM',
//           label: 'تأكيد تناول الدواء',
//         ),
//         NotificationActionButton(
//           key: 'SNOOZE',
//           label: 'تأجيل لمدة 10 دقائق',
//         ),
//       ],
//     );
//     // AwesomeNotifications().setListeners(
//     //   onActionReceivedMethod: (ReceivedAction receivedAction) async {
//     //     if (receivedAction.buttonKeyPressed == 'CONFIRM') {
//     //       // تم تأكيد تناول الدواء
//     //     } else {
//     //       // إعادة جدولة الإشعار بعد 10 دقائق
//     //       await _rescheduleReminder(receivedAction.payload?['reminderId']);
//     //     }
//     //   },
//     // );
//   }
// }
// // Future<void> _checkAndSendReminders() async {
// //   final now = DateTime.now();
// //   final currentTime = '${now.hour}:${now.minute} ${now.hour >= 12 ? 'PM' : 'AM'}';
// //
// //   final user = FirebaseAuth.instance.currentUser;
// //   if (user == null) return;
// //
// //   final snapshot = await FirebaseFirestore.instance
// //       .collection('users').doc(user.uid)
// //       .collection('reminders').where('reminderTime', isEqualTo: currentTime).get();
// //
// //   for (var doc in snapshot.docs) {
// //     final data = doc.data();
// //     await AwesomeNotifications().createNotification(
// //       content: NotificationContent(
// //         id: doc.id.hashCode,
// //         channelKey: 'reminder_channel',
// //         title: 'تذكير تناول الدواء',
// //         body: 'حان الوقت لتناول ${data['medicineName']}',
// //         payload: {'reminderId': doc.id},
// //         notificationLayout: NotificationLayout.Default,
// //         autoCancel: false,
// //         wakeUpScreen: true,
// //       ),
// //     );
// //   }
// // }
//
// // // أضف هذه الدالة الجديدة
// // Future<void> initializeService() async {
// //   final service = FlutterBackgroundService();
// //   await service.configure(
// //     androidConfiguration: AndroidConfiguration(
// //       onStart: onStart,
// //       autoStart: true,
// //       isForegroundMode: true,
// //       notificationChannelId: 'reminder_channel',
// //       initialNotificationTitle: 'الخدمة الخلفية تعمل',
// //       initialNotificationContent: 'جاري مراقبة التذكيرات',
// //     ),
// //     iosConfiguration: IosConfiguration(),
// //   );
// //   service.startService();
// // }
// //
// // // دالة معالجة المهام الخلفية
// // @pragma('vm:entry-point')
// // void onStart(ServiceInstance service) async {
// //   // يمكنك وضع كود المهام الخلفية هنا
// //   if (service is AndroidServiceInstance) {
// //     service.setForegroundNotificationInfo(
// //       title: "خدمة التذكيرات نشطة",
// //       content: "جاري مراقبة مواعيد الأدوية",
// //     );
// //   }
// //
// //   // مثال على مهمة دورية
// //   Timer.periodic(Duration(minutes: 15), (timer) async {
// //     if (service is AndroidServiceInstance) {
// //       service.setForegroundNotificationInfo(
// //         title: "آخر تحديث: ${DateTime.now()}",
// //         content: "جاري التحقق من التذكيرات",
// //       );
// //     }
// //
// //     // أضف منطق التحقق من التذكيرات هنا
// //     // await checkMedicationReminders();
// //   });
// // }
// Future<void> _copyTessDataToAppDir() async {
//   final appDir = await getApplicationDocumentsDirectory();
//   final tessDir = Directory('${appDir.path}/tessdata');
//
//   if (!await tessDir.exists()) {
//     await tessDir.create();
//   }
//
//   await Future.wait([
//     rootBundle.load('assets/tessdata/ara.traineddata')
//         .then((data) => File('${tessDir.path}/ara.traineddata').writeAsBytes(data.buffer.asUint8List())),
//     rootBundle.load('assets/tessdata/eng.traineddata')
//         .then((data) => File('${tessDir.path}/eng.traineddata').writeAsBytes(data.buffer.asUint8List())),
//     rootBundle.load('assets/tessdata/tessdata_config.json')
//         .then((data) => File('${tessDir.path}/tessdata_config.json').writeAsBytes(data.buffer.asUint8List())),
//   ]);
// }
// class SmartPharmacyApp extends StatelessWidget {
//   SmartPharmacyApp({super.key});
//
//   final routeObserver = RouteObserver<PageRoute>();
//
//   @override
//   Widget build(BuildContext context) {
//     // Connectivity().onConnectivityChanged.listen((result) {
//     //   if (result == ConnectivityResult.none) {
//     //     Navigator.pushNamedAndRemoveUntil(
//     //       context,
//     //       '/no_internet',
//     //           (route) => false,
//     //     );
//     //   }
//     // });
//     return MaterialApp(
//       title: 'الصيدلية الذكية',
//       debugShowCheckedModeBanner: false,
//       themeMode: ThemeMode.system,
//       theme: ThemeData(
//         primarySwatch: Colors.teal,
//         // fontFamily: 'Inter',
//         scaffoldBackgroundColor: Colors.white,
//       ),
//       initialRoute: '/splash',
//       routes: appRoutes,
//       navigatorObservers: [routeObserver],
//
//       home: StreamBuilder<User?>(
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (context, snapshot) {
//           final userProvider = Provider.of<UserProvider>(
//             context,
//             listen: false,
//           );
//
//           if (snapshot.connectionState == ConnectionState.active) {
//             final user = snapshot.data;
//             if (user == null) {
//               return const LoginScreen();
//             } else {
//               // تحميل بيانات المستخدم إذا لم تكن محملة
//               WidgetsBinding.instance.addPostFrameCallback((_) {
//                 if (userProvider.user == null) {
//                   userProvider.setUserFromFirestore(user.uid);
//                 }
//               });
//               return const HomeScreen();
//             }
//           }
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         },
//       ),
//     );
//   }
// }
