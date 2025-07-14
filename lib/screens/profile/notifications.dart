import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/styles.dart';
import '../../widgets/bottom_nav_bar.dart';

class NotificationsScreen extends StatefulWidget {
  final String? userId;
  const NotificationsScreen({super.key, this.userId});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _generalNotifications = true;
  List<Map<String, dynamic>> _notifications = [];
  int _currentIndex = 3;

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
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    if (!_generalNotifications) return;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .get();

      setState(() {
        _notifications = querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'title': data['title'] ?? '',
            'message': data['message'] ?? '',
            'createdAt': data['createdAt'],
            'notificationId': data['notificationId'],
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text('الإشعارات',
                  style: AppTextStyles.header.copyWith(color: Colors.white)),
            ),
            automaticallyImplyLeading: true, // Show back button automatically
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('إعدادات الإشعارات', style: AppTextStyles.subHeader),
                    const SizedBox(height: 16),
                    _buildNotificationSwitch(
                      'الإشعارات العامة',
                      'تلقي إشعارات عامة من التطبيق',
                      _generalNotifications,
                          (value) {
                        setState(() {
                          _generalNotifications = value;
                          if (value) {
                            _fetchNotifications();
                          } else {
                            _notifications.clear();
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 30),
                    Text('الإشعارات الحديثة', style: AppTextStyles.subHeader),
                    const SizedBox(height: 16),
                    if (_generalNotifications && _notifications.isNotEmpty)
                      ..._notifications.map((notification) => Column(
                        children: [
                          _buildNotificationItem(
                            notification['title'],
                            notification['message'],
                            _formatTimestamp(notification['createdAt']),
                            Icons.notifications,
                          ),
                          const Divider(),
                        ],
                      )),
                    if (_generalNotifications && _notifications.isEmpty)
                      Text('لا توجد إشعارات',
                          style: AppTextStyles.bodyMedium),
                    if (!_generalNotifications)
                      Text('تم تعطيل الإشعارات العامة',
                          style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _currentIndex,
        onItemSelected: _onItemTapped,
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
      //   backgroundColor: AppColors.secondary,
      //   elevation: 2,
      //   child: const Icon(Icons.home, color: Colors.black),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'وقت غير معروف';
    if (timestamp is Timestamp) {
      DateTime date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year}';
    } else if (timestamp is String) {
      return timestamp;
    }
    return 'وقت غير معروف';
  }

  Widget _buildNotificationSwitch(String title, String description, bool value,
      Function(bool) onChanged) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodyMedium),
              const SizedBox(height: 4),
              Text(description,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textDark)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildNotificationItem(
      String title, String message, String time, IconData icon) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: AppTextStyles.bodyMedium),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: AppTextStyles.bodySmall),
          const SizedBox(height: 4),
          Text(time,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textLight)),
        ],
      ),
      trailing:
      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        // Add your tap handling logic here
      },
    );
  }
}