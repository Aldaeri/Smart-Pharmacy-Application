import 'package:flutter/material.dart';
// import 'package:connectivity/connectivity.dart';

import 'package:connectivity_plus/connectivity_plus.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/no_internet.png', width: 150, height: 150),
              const SizedBox(height: 30),
              const Text(
                'لا يوجد اتصال بالإنترنت',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'الرجاء التحقق من اتصال الإنترنت الخاص بك والمحاولة مرة أخرى',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  var result = await Connectivity().checkConnectivity();
                  if (result != ConnectivityResult.none) {
                    Navigator.pushReplacementNamed(context, '/splash');
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'إعادة المحاولة',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  // يمكنك إضافة أي إجراء عند الضغط على إلغاء
                },
                child: const Text(
                  'إلغاء',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoInternetScreen2 extends StatelessWidget {
  const NoInternetScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'الرجاء التحقق من اتصال الإنترنت الخاص بك',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'تأكد من اتصالك بالإنترنت أو حاول في وقت لاحق',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                var connectivityResult = await Connectivity().checkConnectivity();
                if (connectivityResult != ConnectivityResult.none) {
                  Navigator.pushReplacementNamed(context, '/splash');
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: Text('فحص الاتصال'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء'),
            ),
          ],
        ),
      ),
    );
  }
}