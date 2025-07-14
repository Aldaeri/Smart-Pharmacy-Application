// TODO Implement this library.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/styles.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'add_address.dart';

class AddressListScreen extends StatefulWidget {
  // final Function(Map<String, dynamic>) onAdd;
  // const AddressListScreen({super.key, required this.onAdd});
  final String? userId;
  const AddressListScreen({super.key, this.userId});

  @override
  State<AddressListScreen> createState() => _AddressListState();
}

class _AddressListState extends State<AddressListScreen> {
  int _currentIndex = 3;
  String? address;
  bool isLoading = true;

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
        Navigator.pushReplacementNamed(context, '/cart');
        break;
      case 3:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAddress();
  }

  Future<void> fetchAddress() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? widget.userId;
      if (uid == null) return;

      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();

      if (data != null && data['address'] != null) {
        setState(() {
          address = data['address'];
          isLoading = false;
        });
      } else {
        setState(() {
          address = null;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching address: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _updateAddress(String newAddress) {
    setState(() {
      address = newAddress;
    });

    final uid = FirebaseAuth.instance.currentUser?.uid ?? widget.userId;
    if (uid != null) {
      FirebaseFirestore.instance.collection('users').doc(uid).update({
        'address': newAddress,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        title: Text('عنوان المستخدم', style: AppTextStyles.header),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : address == null || address!.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 60, color: AppColors.accent),
            const SizedBox(height: 20),
            Text(
              'لا يوجد عنوان مسجل حالياً',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDark),
            ),
          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: ListTile(
            leading: Icon(Icons.location_on, color: AppColors.primary),
            title: Text("عنوانك الحالي", style: AppTextStyles.bodyMedium),
            subtitle: Text(address!, style: AppTextStyles.bodySmall),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  address = null;
                });
                final uid = FirebaseAuth.instance.currentUser?.uid ?? widget.userId;
                if (uid != null) {
                  FirebaseFirestore.instance.collection('users').doc(uid).update({
                    'address': '',
                  });
                }
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.edit, color: Colors.white),
        onPressed: () async {
          final newAddress = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddAddress(
                onAdd: (data) {
                  _updateAddress(data['address'] ?? '');
                },
              ),
            ),
          );
        },
        // child: FloatingActionButton(
        //   onPressed: () {  },
        // ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _currentIndex,
        onItemSelected: _onItemTapped,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
      //   backgroundColor: AppColors.secondary,
      //   child: const Icon(Icons.home, color: Colors.black),
      //   elevation: 2,
      // ),
    );
  }
}