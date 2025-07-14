import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/colors.dart';
import '../constants/styles.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/custom_button.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class Reminder extends StatefulWidget {
  const Reminder({super.key});

  @override
  State<Reminder> createState() => _ReminderState();
}

class _ReminderState extends State<Reminder> {
  int _currentIndex = 1;
  DateTime _selectedDate = DateTime.now();
  String? _selectedMedicineType;
  List<String> _dosageOptions = [];
  final _dosageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _rescheduleAllReminders(FirebaseAuth.instance.currentUser?.uid ?? '');
    _startBackgroundService();
  }

  Future<void> _startBackgroundService() async {
    final service = FlutterBackgroundService();
    await service.startService();
  }

  Future<void> _initializeNotifications() async {
    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {}

  @pragma('vm:entry-point')
  static Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {}

  @pragma('vm:entry-point')
  static Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {}

  @pragma('vm:entry-point')
  static Future<void> onDismissActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {}

  Future<void> _rescheduleAllReminders(String userId) async {
    if (userId.isEmpty) return;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('reminders')
            .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final String? name = data['medicineName'];
      final String? time = data['reminderTime'];

      if (name != null && time != null) {
        _scheduleNotification(doc.id, name, time);
      }
    }
  }

  Future<void> _scheduleNotification(
    String docId,
    String name,
    String reminderTime,
  ) async {
    final timeParts = reminderTime.split(" ");
    if (timeParts.length < 2) return;

    final hourMin = timeParts[0].split(":");
    int hour = int.parse(hourMin[0]);
    int minute = int.parse(hourMin[1]);

    if (timeParts[1].toLowerCase() == "pm" && hour != 12) hour += 12;
    if (timeParts[1].toLowerCase() == "am" && hour == 12) hour = 0;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: docId.hashCode,
        channelKey: 'reminder_channel',
        title: 'تذكير تناول الدواء',
        body: 'حان الوقت لتناول $name',
        payload: {'reminderId': docId},
      ),
      schedule: NotificationCalendar(
        hour: hour,
        minute: minute,
        second: 0,
        millisecond: 0,
        repeats: true,
      ),
    );
  }

  void _updateDosage(String? medicineType) {
    setState(() {
      _selectedMedicineType = medicineType;

      if (medicineType == 'pills') {
        _dosageOptions = ['حبة واحدة', 'حبتين', 'ثلاث حبات', 'أربع حبات'];
      } else if (medicineType == 'syrup') {
        _dosageOptions = ['ملعقة صغيرة', 'ملعقتين صغيرتين', 'ملعقة كبيرة'];
      } else {
        _dosageOptions = [];
      }

      _dosageController.text = '';
    });
  }

  Widget _buildCalendarHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(6, (index) {
          final date = _selectedDate.add(
            Duration(days: index - _selectedDate.weekday + 1),
          );
          final isSelected = date.day == _selectedDate.day;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = date;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getDayName(date.weekday),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      date.day.toString(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'MON';
      case 2:
        return 'TUE';
      case 3:
        return 'WED';
      case 4:
        return 'THU';
      case 5:
        return 'FRI';
      case 6:
        return 'SAT';
      case 7:
        return 'SUN';
      default:
        return '';
    }
  }

  Widget _buildMedicineItem(Map<String, dynamic> reminder, String docId) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed:
                    () => _showEditReminderDialog(context, reminder, docId),
              ),
              Text(
                reminder['medicineName'] ?? 'دواء',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'مرات الاستخدام: ${reminder['dosage'] ?? '1'}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'موعد التذكير: ${reminder['reminderTime']}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddReminderDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final medicineNameController = TextEditingController();
    final reminderTimeController = TextEditingController();
    final dosageController = TextEditingController();
    String? selectedMedicineType;
    List<String> dosageOptions = [];

    void updateDosageOptions(String? type) {
      selectedMedicineType = type;
      if (type == 'pills') {
        dosageOptions = ['حبة واحدة', 'حبتين', 'ثلاث حبات', 'أربع حبات'];
      } else if (type == 'syrup') {
        dosageOptions = ['ملعقة صغيرة', 'ملعقتين صغيرتين', 'ملعقة كبيرة'];
      } else {
        dosageOptions = [];
      }
      dosageController.text = '';
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لم يتم العثور على المستخدم')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              scrollable: true,
              title: const Text('إضافة تذكير جديد', textAlign: TextAlign.right),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      textAlign: TextAlign.right,
                      controller: medicineNameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم الدواء',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'اسم الدواء مطلوب';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      hint: const Text(
                        'اختر نوع الدواء',
                        textAlign: TextAlign.right,
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: 'pills',
                          child: Text('حبوب'),
                        ),
                        const DropdownMenuItem(
                          value: 'syrup',
                          child: Text('شراب'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          updateDosageOptions(value);
                        });
                      },
                      validator: (value) {
                        if (selectedMedicineType == null) {
                          return 'نوع الدواء مطلوب';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'نوع الدواء',
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: reminderTimeController,
                      decoration: const InputDecoration(
                        labelText: 'موعد التذكير',
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      onTap: () async {
                        FocusScope.of(context).requestFocus(FocusNode());
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            reminderTimeController.text = pickedTime.format(
                              context,
                            );
                          });
                        }
                      },
                      readOnly: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'موعد التذكير مطلوب';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    if (selectedMedicineType != null &&
                        dosageOptions.isNotEmpty)
                      DropdownButtonFormField<String>(
                        hint: const Text('اختر الجرعة'),
                        items:
                            dosageOptions.map((value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        onChanged: (value) {
                          dosageController.text = value!;
                        },
                        validator: (value) {
                          if (dosageController.text.isEmpty) {
                            return 'الجرعة مطلوبة';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(labelText: 'الجرعة'),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final reminderData = {
                        'medicineName': medicineNameController.text.trim(),
                        'medicineType': selectedMedicineType,
                        'reminderTime': reminderTimeController.text.trim(),
                        'dosage': dosageController.text.trim(),
                        'createdAt': FieldValue.serverTimestamp(),
                      };

                      try {
                        final DocumentReference docRef = await FirebaseFirestore
                            .instance
                            .collection('users')
                            .doc(currentUser.uid)
                            .collection('reminders')
                            .add(reminderData);

                        _scheduleNotification(
                          docRef.id,
                          medicineNameController.text,
                          reminderTimeController.text,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم إضافة التذكير بنجاح'),
                          ),
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('فشل في إضافة التذكير: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditReminderDialog(
    BuildContext context,
    Map<String, dynamic> reminder,
    String docId,
  ) {
    final formKey = GlobalKey<FormState>();
    final medicineNameController = TextEditingController(
      text: reminder['medicineName'],
    );
    final reminderTimeController = TextEditingController(
      text: reminder['reminderTime'],
    );
    final dosageController = TextEditingController(
      text: reminder['dosage'] ?? '',
    );
    _selectedMedicineType = reminder['medicineType'];
    if (_selectedMedicineType == 'pills') {
      _dosageOptions = ['حبة واحدة', 'حبتين', 'ثلاث حبات', 'أربع حبات'];
    } else {
      _dosageOptions = ['ملعقة صغيرة', 'ملعقتين صغيرتين', 'ملعقة كبيرة'];
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('لم يتم العثور على المستخدم')));
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, dialogSetState) {
              return AlertDialog(
                title: Text('تعديل التذكير', style: AppTextStyles.header),
                content: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: medicineNameController,
                        decoration: InputDecoration(labelText: 'اسم الدواء'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'اسم الدواء مطلوب';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      DropdownButtonFormField<String>(
                        value: _selectedMedicineType,
                        hint: Text('اختر نوع الدواء'),
                        items: [
                          DropdownMenuItem(value: 'pills', child: Text('حبوب')),
                          DropdownMenuItem(value: 'syrup', child: Text('شراب')),
                        ],
                        onChanged: (value) {
                          dialogSetState(() {
                            _updateDosage(value);
                          });
                        },
                        validator: (value) {
                          if (_selectedMedicineType == null) {
                            return 'اختر نوع الدواء';
                          }
                          return null;
                        },
                        decoration: InputDecoration(labelText: 'نوع الدواء'),
                      ),

                      SizedBox(height: 20),

                      TextFormField(
                        controller: reminderTimeController,
                        decoration: InputDecoration(
                          labelText: 'موعد التذكير',
                          suffixIcon: Icon(Icons.access_time),
                        ),
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (pickedTime != null) {
                            setState(() {
                              reminderTimeController.text = pickedTime.format(
                                context,
                              );
                            });
                          }
                        },
                        readOnly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'موعد التذكير مطلوب';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 20),

                      if (_selectedMedicineType != null &&
                          _dosageOptions.isNotEmpty)
                        DropdownButtonFormField<String>(
                          hint: Text('اختر الجرعة'),
                          value:
                              dosageController.text.isNotEmpty
                                  ? dosageController.text
                                  : null,
                          items:
                              _dosageOptions.map((value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                          onChanged: (value) {
                            dialogSetState(() {
                              dosageController.text = value!;
                            });
                          },
                          validator: (value) {
                            if (dosageController.text.isEmpty) {
                              return 'الجرعة مطلوبة';
                            }
                            return null;
                          },
                          decoration: InputDecoration(labelText: 'الجرعة'),
                        ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('إلغاء'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final updatedData = {
                          'medicineName': medicineNameController.text.trim(),
                          'medicineType': _selectedMedicineType,
                          'reminderTime': reminderTimeController.text.trim(),
                          'dosage': dosageController.text.trim(),
                        };

                        try {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(currentUser.uid)
                              .collection('reminders')
                              .doc(docId)
                              .update(updatedData);

                          await AwesomeNotifications().cancel(docId.hashCode);
                          _scheduleNotification(
                            docId,
                            medicineNameController.text,
                            reminderTimeController.text,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('تم تعديل التذكير بنجاح')),
                          );
                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('فشل في تعديل التذكير: $e')),
                          );
                        }
                      }
                    },
                    child: Text('تحديث'),
                  ),
                ],
              );
            },
          ),
    );
  }

  Future<bool?> showDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("حذف التذكير"),
            content: Text("هل أنت متأكد من رغبتك في حذف هذا التذكير؟"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("إلغاء"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text("حذف", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('لم يتم العثور على المستخدم'));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('منبه الدواء', style: AppTextStyles.header),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildCalendarHeader(),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('جرعات اليوم', style: TextStyle(fontSize: 16), textAlign: TextAlign.center,),
                // Text('جريعات الدواء', style: TextStyle(fontSize: 16)),
                // Text('الادوية المؤمنه', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUser.uid)
                      .collection('reminders')
                      .orderBy('reminderTime')
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('لا توجد تذكيرات بعد'));
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final reminder = docs[index].data() as Map<String, dynamic>;
                    final docId = docs[index].id;
                    return Dismissible(
                      key: Key(docId),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDeleteDialog(context);
                      },
                      onDismissed: (direction) async {
                        try {
                          // bool? confirm = await showDeleteDialog(context);
                          // if (confirm == true) {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(currentUser.uid)
                              .collection('reminders')
                              .doc(docId)
                              .delete();

                          await AwesomeNotifications().cancel(docId.hashCode);
                          // }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم حذف التذكير بنجاح'),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('قشل في حذف التذكير: $e')),
                          );
                          setState(() {});
                        }
                      },
                      child: _buildMedicineItem(reminder, docId),
                    );
                    // return _buildMedicineItem(reminder, docId);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddReminderDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _currentIndex,
        onItemSelected: _onItemTapped,
      ),
    );
  }

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
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/cart');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
      case 4:
        Navigator.pushNamed(context, '/home');
        break;
    }
  }
}

class Reminder2 extends StatefulWidget {
  const Reminder2({super.key});

  @override
  State<Reminder2> createState() => _Reminder2State();
}

class _Reminder2State extends State<Reminder2> {
  int _currentIndex = 1;
  String? _selectedMedicineType;
  List<String> _dosageOptions = [];
  final _dosageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _rescheduleAllReminders(FirebaseAuth.instance.currentUser?.uid ?? '');
    _startBackgroundService();
  }

  Future<void> _startBackgroundService() async {
    final service = FlutterBackgroundService();
    await service.startService();
  }

  Future<void> _initializeNotifications() async {
    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    // Handle notification actions
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {}

  @pragma('vm:entry-point')
  static Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {}

  @pragma('vm:entry-point')
  static Future<void> onDismissActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {}

  Future<void> _rescheduleAllReminders(String userId) async {
    if (userId.isEmpty) return;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('reminders')
            .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final String? name = data['medicineName'];
      final String? time = data['reminderTime'];

      if (name != null && time != null) {
        _scheduleNotification(doc.id, name, time);
      }
    }
  }

  Future<void> _scheduleNotification(
    String docId,
    String name,
    String reminderTime,
  ) async {
    final timeParts = reminderTime.split(" ");
    if (timeParts.length < 2) return;

    final hourMin = timeParts[0].split(":");
    int hour = int.parse(hourMin[0]);
    int minute = int.parse(hourMin[1]);

    if (timeParts[1].toLowerCase() == "pm" && hour != 12) hour += 12;
    if (timeParts[1].toLowerCase() == "am" && hour == 12) hour = 0;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: docId.hashCode,
        channelKey: 'reminder_channel',
        title: 'تذكير تناول الدواء',
        body: 'حان الوقت لتناول $name',
        payload: {'reminderId': docId},
      ),
      schedule: NotificationCalendar(
        hour: hour,
        minute: minute,
        second: 0,
        millisecond: 0,
        repeats: true,
      ),
    );
  }

  void _updateDosage(String? medicineType) {
    setState(() {
      _selectedMedicineType = medicineType;

      if (medicineType == 'pills') {
        _dosageOptions = ['حبة واحدة', 'حبتين', 'ثلاث حبات', 'أربع حبات'];
      } else if (medicineType == 'syrup') {
        _dosageOptions = ['ملعقة صغيرة', 'ملعقتين صغيرتين', 'ملعقة كبيرة'];
      } else {
        _dosageOptions = [];
      }

      _dosageController.text = '';
    });
  }

  Future<bool?> showDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("حذف التذكير"),
            content: Text("هل أنت متأكد من رغبتك في حذف هذا التذكير؟"),
            actions: [
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: Text("إلغاء"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text("حذف", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _showAddReminderDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final medicineNameController = TextEditingController();
    final reminderTimeController = TextEditingController();
    final dosageController = TextEditingController();
    String? selectedMedicineType0;
    List<String> dosageOptions0 = [];
    // final _formKey = GlobalKey<FormState>();
    // final _medicineNameController = TextEditingController();
    // final _reminderTimeController = TextEditingController();
    // final _dosageController = TextEditingController();

    // نقل المتغيرات هنا لتصبح جزءًا من حالة الحوار
    String? selectedMedicineType;
    List<String> dosageOptions = [];

    void updateDosageOptions(String? type) {
      selectedMedicineType = type;
      if (type == 'pills') {
        dosageOptions = ['حبة واحدة', 'حبتين', 'ثلاث حبات', 'أربع حبات'];
      } else if (type == 'syrup') {
        dosageOptions = ['ملعقة صغيرة', 'ملعقتين صغيرتين', 'ملعقة كبيرة'];
      } else {
        dosageOptions = [];
      }
      dosageController.text = '';
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('لم يتم العثور على المستخدم')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              // backgroundColor: Colors.blueGrey,
              title: Text(
                'إضافة تذكير جديد',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.right,
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      textAlign: TextAlign.right,
                      controller: medicineNameController,
                      decoration: InputDecoration(labelText: 'اسم الدواء'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'اسم الدواء مطلوب';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    DropdownButtonFormField<String>(
                      // alignment: Alignment.centerRight,
                      hint: Text('اختر نوع الدواء', textAlign: TextAlign.right),
                      items: [
                        DropdownMenuItem(value: 'pills', child: Text('حبوب')),
                        DropdownMenuItem(value: 'syrup', child: Text('شراب')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          updateDosageOptions(value);
                        });
                      },
                      validator: (value) {
                        if (selectedMedicineType == null) {
                          return 'نوع الدواء مطلوب';
                        }
                        return null;
                      },
                      decoration: InputDecoration(labelText: 'نوع الدواء'),
                    ),

                    SizedBox(height: 20),

                    TextFormField(
                      controller: reminderTimeController,
                      decoration: InputDecoration(
                        labelText: 'موعد التذكير',
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      onTap: () async {
                        FocusScope.of(context).requestFocus(FocusNode());
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            reminderTimeController.text = pickedTime.format(
                              context,
                            );
                          });
                        }
                      },
                      readOnly: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'موعد التذكير مطلوب';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 20),

                    if (selectedMedicineType != null &&
                        dosageOptions.isNotEmpty)
                      DropdownButtonFormField<String>(
                        hint: Text('اختر الجرعة'),
                        // value: dosageController.text.isNotEmpty ? _dosageController.text : null,
                        items:
                            dosageOptions.map((value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        onChanged: (value) {
                          // dialogSetState(() {
                          dosageController.text = value!;
                          // }
                          // )
                        },
                        validator: (value) {
                          if (dosageController.text.isEmpty) {
                            return 'الجرعة مطلوبة';
                          }
                          return null;
                        },
                        decoration: InputDecoration(labelText: 'الجرعة'),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final reminderData = {
                        'medicineName': medicineNameController.text.trim(),
                        'medicineType': selectedMedicineType0,
                        'reminderTime': reminderTimeController.text.trim(),
                        'dosage': dosageController.text.trim(),
                        'createdAt': FieldValue.serverTimestamp(),
                      };

                      try {
                        final DocumentReference docRef = await FirebaseFirestore
                            .instance
                            .collection('users')
                            .doc(currentUser.uid)
                            .collection('reminders')
                            .add(reminderData);

                        _scheduleNotification(
                          docRef.id,
                          medicineNameController.text,
                          reminderTimeController.text,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('تم إضافة التذكير بنجاح')),
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('فشل في إضافة التذكير: $e')),
                        );
                      }
                    }
                  },
                  child: Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditReminderDialog(
    BuildContext context,
    Map<String, dynamic> reminder,
    String docId,
  ) {
    final formKey = GlobalKey<FormState>();
    final medicineNameController = TextEditingController(
      text: reminder['medicineName'],
    );
    final reminderTimeController = TextEditingController(
      text: reminder['reminderTime'],
    );
    final dosageController = TextEditingController(
      text: reminder['dosage'] ?? '',
    );
    _selectedMedicineType = reminder['medicineType'];
    if (_selectedMedicineType == 'pills') {
      _dosageOptions = ['حبة واحدة', 'حبتين', 'ثلاث حبات', 'أربع حبات'];
    } else {
      _dosageOptions = ['ملعقة صغيرة', 'ملعقتين صغيرتين', 'ملعقة كبيرة'];
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('لم يتم العثور على المستخدم')));
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, dialogSetState) {
              return AlertDialog(
                title: Text('تعديل التذكير', style: AppTextStyles.header),
                content: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: medicineNameController,
                        decoration: InputDecoration(labelText: 'اسم الدواء'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'اسم الدواء مطلوب';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      DropdownButtonFormField<String>(
                        value: _selectedMedicineType,
                        hint: Text('اختر نوع الدواء'),
                        items: [
                          DropdownMenuItem(value: 'pills', child: Text('حبوب')),
                          DropdownMenuItem(value: 'syrup', child: Text('شراب')),
                        ],
                        onChanged: (value) {
                          dialogSetState(() {
                            _updateDosage(value);
                          });
                        },
                        validator: (value) {
                          if (_selectedMedicineType == null) {
                            return 'اختر نوع الدواء';
                          }
                          return null;
                        },
                        decoration: InputDecoration(labelText: 'نوع الدواء'),
                      ),

                      SizedBox(height: 20),

                      TextFormField(
                        controller: reminderTimeController,
                        decoration: InputDecoration(
                          labelText: 'موعد التذكير',
                          suffixIcon: Icon(Icons.access_time),
                        ),
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (pickedTime != null) {
                            setState(() {
                              reminderTimeController.text = pickedTime.format(
                                context,
                              );
                            });
                          }
                        },
                        readOnly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'موعد التذكير مطلوب';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 20),

                      if (_selectedMedicineType != null &&
                          _dosageOptions.isNotEmpty)
                        DropdownButtonFormField<String>(
                          hint: Text('اختر الجرعة'),
                          value:
                              dosageController.text.isNotEmpty
                                  ? dosageController.text
                                  : null,
                          items:
                              _dosageOptions.map((value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                          onChanged: (value) {
                            dialogSetState(() {
                              dosageController.text = value!;
                            });
                          },
                          validator: (value) {
                            if (dosageController.text.isEmpty) {
                              return 'الجرعة مطلوبة';
                            }
                            return null;
                          },
                          decoration: InputDecoration(labelText: 'الجرعة'),
                        ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('إلغاء'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final updatedData = {
                          'medicineName': medicineNameController.text.trim(),
                          'medicineType': _selectedMedicineType,
                          'reminderTime': reminderTimeController.text.trim(),
                          'dosage': dosageController.text.trim(),
                        };

                        try {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(currentUser.uid)
                              .collection('reminders')
                              .doc(docId)
                              .update(updatedData);

                          await AwesomeNotifications().cancel(docId.hashCode);
                          _scheduleNotification(
                            docId,
                            medicineNameController.text,
                            reminderTimeController.text,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('تم تعديل التذكير بنجاح')),
                          );
                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('فشل في تعديل التذكير: $e')),
                          );
                        }
                      }
                    },
                    child: Text('تحديث'),
                  ),
                ],
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Center(child: Text('لم يتم العثور على المستخدم'));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('منبه الدواء', style: AppTextStyles.productPrice),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeOption('اليوم', isSelected: false),
                _buildTimeOption('الأسبوع', isSelected: true),
                _buildTimeOption('الشهر', isSelected: false),
              ],
            ),
            const SizedBox(height: 30),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser.uid)
                        .collection('reminders')
                        .orderBy('reminderTime')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('لا توجد تذكيرات بعد'));
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final reminder =
                          docs[index].data() as Map<String, dynamic>;
                      final docId = docs[index].id;

                      return Dismissible(
                        key: Key(docId),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red.withOpacity(0.2),
                          child: const Icon(Icons.delete, color: Colors.red),
                        ),
                        onDismissed: (direction) async {
                          bool? confirm = await showDeleteDialog(context);
                          if (confirm == true) {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(currentUser.uid)
                                .collection('reminders')
                                .doc(docId)
                                .delete();

                            await AwesomeNotifications().cancel(docId.hashCode);
                          }
                        },
                        child: InkWell(
                          onTap:
                              () => _showEditReminderDialog(
                                context,
                                reminder,
                                docId,
                              ),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(23),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed:
                                          () => _showEditReminderDialog(
                                            context,
                                            reminder,
                                            docId,
                                          ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          reminder['medicineName'] ?? 'دواء',
                                          style: AppTextStyles.sectionTitle,
                                        ),
                                        Text(
                                          'نوع الدواء: ${reminder['medicineType'] == 'pills' ? 'حبوب' : 'شراب'}',
                                          style: AppTextStyles.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'موعد التذكير: ${reminder['reminderTime']}',
                                  style: AppTextStyles.bodyMedium,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'الجرعة: ${reminder['dosage']}',
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            CustomButton(
              text: 'إضافة تذكير جديد',
              onPressed: () => _showAddReminderDialog(context),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _currentIndex,
        onItemSelected: _onItemTapped,
      ),
      // floatingActionButton: FloatingHomeButton(
      //   isSelected: _currentIndex == 4,
      //   onPressed: () => _onItemTapped(4),
      //   btnHomeColor: AppColors.btnDark,
      //   backgroundColor: AppColors.secondary,
      //
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

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
        // Navigator.pushReplacementNamed(context, '/reminders');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/cart');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
      case 4:
        Navigator.pushNamed(context, '/home');
        break;
    }
  }

  Widget _buildTimeOption(String text, {bool isSelected = false}) {
    return Container(
      width: 80,
      height: 66,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.secondary,
        borderRadius: BorderRadius.circular(19),
      ),
      child: Center(
        child: Text(
          text,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

// class Reminder extends StatefulWidget {
//   const Reminder({super.key});
//
//   @override
//   State<Reminder> createState() => _ReminderState();
// }
//
// class _ReminderState extends State<Reminder> {
//   int _currentIndex = 1;
//   String? _selectedMedicineType;
//   List<String> _dosageOptions = [];
//   final _dosageController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeNotifications();
//     _rescheduleAllReminders(FirebaseAuth.instance.currentUser?.uid ?? '');
//   }
//
//   Future<void> _initializeNotifications() async {
//     await AwesomeNotifications().initialize(
//       null,
//       [
//         NotificationChannel(
//           channelKey: 'reminder_channel',
//           channelName: 'تذكير تناول الدواء',
//           channelDescription: 'قناة التذكير بتناول الأدوية',
//           importance: NotificationImportance.High,
//           defaultColor: AppColors.primary,
//           ledColor: Colors.white,
//           playSound: true,
//           enableVibration: true,
//         )
//       ],
//     );
//   }
//
//   Future<void> _rescheduleAllReminders(String userId) async {
//     if (userId.isEmpty) return;
//
//     final snapshot = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(userId)
//         .collection('reminders')
//         .get();
//
//     for (var doc in snapshot.docs) {
//       final data = doc.data();
//       final String? name = data['medicineName'];
//       final String? time = data['reminderTime'];
//
//       if (name != null && time != null) {
//         _scheduleNotification(doc.id, name, time);
//       }
//     }
//   }
//
//   Future<void> _scheduleNotification(String docId, String name, String reminderTime) async {
//     final timeParts = reminderTime.split(" ");
//     if (timeParts.length < 2) return;
//
//     final hourMin = timeParts[0].split(":");
//     int hour = int.parse(hourMin[0]);
//     int minute = int.parse(hourMin[1]);
//
//     if (timeParts[1].toLowerCase() == "pm" && hour != 12) hour += 12;
//     if (timeParts[1].toLowerCase() == "am" && hour == 12) hour = 0;
//
//     await AwesomeNotifications().createNotification(
//       content: NotificationContent(
//         id: docId.hashCode,
//         channelKey: 'reminder_channel',
//         title: 'تذكير تناول الدواء',
//         body: 'حان الوقت لتناول $name',
//       ),
//       schedule: NotificationCalendar(
//         hour: hour,
//         minute: minute,
//         second: 0,
//         millisecond: 0,
//         repeats: true,
//       ),
//     );
//   }
//
//   void _updateDosage(String? medicineType) {
//     setState(() {
//       _selectedMedicineType = medicineType;
//
//       if (medicineType == 'pills') {
//         _dosageOptions = ['حبة واحدة', 'حبتين', 'ثلاث حبات', 'أربع حبات'];
//       } else if (medicineType == 'syrup') {
//         _dosageOptions = ['ملعقة صغيرة', 'ملعقتين صغيرتين', 'ملعقة كبيرة'];
//       } else {
//         _dosageOptions = [];
//       }
//
//       _dosageController.text = '';
//     });
//   }
//
//   Future<bool?> showDeleteDialog(BuildContext context) {
//     return showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text("حذف التذكير"),
//         content: Text("هل أنت متأكد من رغبتك في حذف هذا التذكير؟"),
//         actions: [
//           TextButton(onPressed: Navigator.of(context).pop, child: Text("إلغاء")),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             child: Text("حذف", style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showAddReminderDialog(BuildContext context) {
//     final _formKey = GlobalKey<FormState>();
//     final _medicineNameController = TextEditingController();
//     final _reminderTimeController = TextEditingController();
//     final _dosageController = TextEditingController();
//     String? _selectedMedicineType;
//     List<String> _dosageOptions = [];
//
//     void _updateDosage(String? medicineType) {
//       setState(() {
//         _selectedMedicineType = medicineType;
//
//         if (medicineType == 'pills') {
//           _dosageOptions = ['حبة واحدة', 'حبتين', 'ثلاث حبات', 'أربع حبات'];
//         } else if (medicineType == 'syrup') {
//           _dosageOptions = ['ملعقة صغيرة', 'ملعقتين صغيرتين', 'ملعقة كبيرة'];
//         } else {
//           _dosageOptions = [];
//         }
//
//         _dosageController.text = '';
//       });
//     }
//
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('لم يتم العثور على المستخدم')),
//       );
//       return;
//     }
//
//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, dialogSetState) {
//           return AlertDialog(
//             title: Text('إضافة تذكير جديد', style: AppTextStyles.header),
//             content: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextFormField(
//                     controller: _medicineNameController,
//                     decoration: InputDecoration(labelText: 'اسم الدواء'),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'اسم الدواء مطلوب';
//                       }
//                       return null;
//                     },
//                   ),
//                   SizedBox(height: 20),
//
//                   DropdownButtonFormField<String>(
//                     hint: Text('اختر نوع الدواء'),
//                     items: [
//                       DropdownMenuItem(value: 'pills', child: Text('حبوب')),
//                       DropdownMenuItem(value: 'syrup', child: Text('شراب')),
//                     ],
//                     onChanged: (value) {
//                       dialogSetState(() {
//                         _updateDosage(value);
//                       });
//                     },
//                     validator: (value) {
//                       if (_selectedMedicineType == null) {
//                         return 'نوع الدواء مطلوب';
//                       }
//                       return null;
//                     },
//                     decoration: InputDecoration(labelText: 'نوع الدواء'),
//                   ),
//
//                   SizedBox(height: 20),
//
//                   TextFormField(
//                     controller: _reminderTimeController,
//                     decoration: InputDecoration(
//                       labelText: 'موعد التذكير',
//                       suffixIcon: Icon(Icons.access_time),
//                     ),
//                     onTap: () async {
//                       FocusScope.of(context).requestFocus(FocusNode());
//                       final TimeOfDay? pickedTime = await showTimePicker(
//                         context: context,
//                         initialTime: TimeOfDay.now(),
//                       );
//                       if (pickedTime != null) {
//                         setState(() {
//                           _reminderTimeController.text = pickedTime.format(context);
//                         });
//                       }
//                     },
//                     readOnly: true,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'موعد التذكير مطلوب';
//                       }
//                       return null;
//                     },
//                   ),
//
//                   SizedBox(height: 20),
//
//                   if (_selectedMedicineType != null && _dosageOptions.isNotEmpty)
//                     DropdownButtonFormField<String>(
//                       hint: Text('اختر الجرعة'),
//                       value: _dosageController.text.isNotEmpty ? _dosageController.text : null,
//                       items: _dosageOptions.map((value) {
//                         return DropdownMenuItem<String>(
//                           value: value,
//                           child: Text(value),
//                         );
//                       }).toList(),
//                       onChanged: (value) {
//                         dialogSetState(() {
//                           _dosageController.text = value!;
//                         });
//                       },
//                       validator: (value) {
//                         if (_dosageController.text.isEmpty) {
//                           return 'الجرعة مطلوبة';
//                         }
//                         return null;
//                       },
//                       decoration: InputDecoration(labelText: 'الجرعة'),
//                     ),
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: Text('إلغاء'),
//               ),
//               ElevatedButton(
//                 onPressed: () async {
//                   if (_formKey.currentState!.validate()) {
//                     final reminderData = {
//                       'medicineName': _medicineNameController.text.trim(),
//                       'medicineType': _selectedMedicineType,
//                       'reminderTime': _reminderTimeController.text.trim(),
//                       'dosage': _dosageController.text.trim(),
//                       'createdAt': FieldValue.serverTimestamp(),
//                     };
//
//                     try {
//                       final DocumentReference docRef = await FirebaseFirestore
//                           .instance
//                           .collection('users')
//                           .doc(currentUser.uid)
//                           .collection('reminders')
//                           .add(reminderData);
//
//                       _scheduleNotification(
//                         docRef.id,
//                         _medicineNameController.text,
//                         _reminderTimeController.text,
//                       );
//
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('تم إضافة التذكير بنجاح')),
//                       );
//                       Navigator.pop(context);
//                     } catch (e) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('فشل في إضافة التذكير: $e')),
//                       );
//                     }
//                   }
//                 },
//                 child: Text('حفظ'),
//               )
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   void _showEditReminderDialog(BuildContext context, Map<String, dynamic> reminder, String docId) {
//     final _formKey = GlobalKey<FormState>();
//     final _medicineNameController = TextEditingController(text: reminder['medicineName']);
//     final _reminderTimeController = TextEditingController(text: reminder['reminderTime']);
//     final _dosageController = TextEditingController(text: reminder['dosage'] ?? '');
//     _selectedMedicineType = reminder['medicineType'];
//     if (_selectedMedicineType == 'pills') {
//       _dosageOptions = ['حبة واحدة', 'حبتين', 'ثلاث حبات', 'أربع حبات'];
//     } else {
//       _dosageOptions = ['ملعقة صغيرة', 'ملعقتين صغيرتين', 'ملعقة كبيرة'];
//     }
//
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('لم يتم العثور على المستخدم')),
//       );
//       return;
//     }
//
//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, dialogSetState) {
//           return AlertDialog(
//             title: Text('تعديل التذكير', style: AppTextStyles.header),
//             content: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextFormField(
//                     controller: _medicineNameController,
//                     decoration: InputDecoration(labelText: 'اسم الدواء'),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'اسم الدواء مطلوب';
//                       }
//                       return null;
//                     },
//                   ),
//                   SizedBox(height: 20),
//
//                   DropdownButtonFormField<String>(
//                     value: _selectedMedicineType,
//                     hint: Text('اختر نوع الدواء'),
//                     items: [
//                       DropdownMenuItem(value: 'pills', child: Text('حبوب')),
//                       DropdownMenuItem(value: 'syrup', child: Text('شراب')),
//                     ],
//                     onChanged: (value) {
//                       dialogSetState(() {
//                         _updateDosage(value);
//                       });
//                     },
//                     validator: (value) {
//                       if (_selectedMedicineType == null) {
//                         return 'اختر نوع الدواء';
//                       }
//                       return null;
//                     },
//                     decoration: InputDecoration(labelText: 'نوع الدواء'),
//                   ),
//
//                   SizedBox(height: 20),
//
//                   TextFormField(
//                     controller: _reminderTimeController,
//                     decoration: InputDecoration(
//                       labelText: 'موعد التذكير',
//                       suffixIcon: Icon(Icons.access_time),
//                     ),
//                     onTap: () async {
//                       FocusScope.of(context).requestFocus(FocusNode());
//                       final TimeOfDay? pickedTime = await showTimePicker(
//                         context: context,
//                         initialTime: TimeOfDay.now(),
//                       );
//                       if (pickedTime != null) {
//                         setState(() {
//                           _reminderTimeController.text = pickedTime.format(context);
//                         });
//                       }
//                     },
//                     readOnly: true,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'موعد التذكير مطلوب';
//                       }
//                       return null;
//                     },
//                   ),
//
//                   SizedBox(height: 20),
//
//                   if (_selectedMedicineType != null && _dosageOptions.isNotEmpty)
//                     DropdownButtonFormField<String>(
//                       hint: Text('اختر الجرعة'),
//                       value: _dosageController.text.isNotEmpty ? _dosageController.text : null,
//                       items: _dosageOptions.map((value) {
//                         return DropdownMenuItem<String>(
//                           value: value,
//                           child: Text(value),
//                         );
//                       }).toList(),
//                       onChanged: (value) {
//                         dialogSetState(() {
//                           _dosageController.text = value!;
//                         });
//                       },
//                       validator: (value) {
//                         if (_dosageController.text.isEmpty) {
//                           return 'الجرعة مطلوبة';
//                         }
//                         return null;
//                       },
//                       decoration: InputDecoration(labelText: 'الجرعة'),
//                     ),
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: Text('إلغاء'),
//               ),
//               ElevatedButton(
//                 onPressed: () async {
//                   if (_formKey.currentState!.validate()) {
//                     final updatedData = {
//                       'medicineName': _medicineNameController.text.trim(),
//                       'medicineType': _selectedMedicineType,
//                       'reminderTime': _reminderTimeController.text.trim(),
//                       'dosage': _dosageController.text.trim(),
//                     };
//
//                     try {
//                       await FirebaseFirestore.instance
//                           .collection('users')
//                           .doc(currentUser.uid)
//                           .collection('reminders')
//                           .doc(docId)
//                           .update(updatedData);
//
//                       await AwesomeNotifications().cancel(docId.hashCode);
//                       _scheduleNotification(
//                         docId,
//                         _medicineNameController.text,
//                         _reminderTimeController.text,
//                       );
//
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('تم تعديل التذكير بنجاح')),
//                       );
//                       Navigator.pop(context);
//                     } catch (e) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('فشل في تعديل التذكير: $e')),
//                       );
//                     }
//                   }
//                 },
//                 child: Text('تحديث'),
//               )
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) {
//       return Center(child: Text('لم يتم العثور على المستخدم'));
//     }
//
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: Text('منبه الدواء', style: AppTextStyles.header),
//         centerTitle: true,
//         backgroundColor: AppColors.background,
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _buildTimeOption('اليوم', isSelected: false),
//                 _buildTimeOption('الأسبوع', isSelected: true),
//                 _buildTimeOption('الشهر', isSelected: false),
//               ],
//             ),
//             const SizedBox(height: 30),
//
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection('users')
//                     .doc(currentUser.uid)
//                     .collection('reminders')
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                     return const Center(child: Text('لا توجد تذكيرات بعد'));
//                   }
//
//                   final docs = snapshot.data!.docs;
//
//                   return ListView.builder(
//                     itemCount: docs.length,
//                     itemBuilder: (context, index) {
//                       final reminder = docs[index].data() as Map<String, dynamic>;
//                       final docId = docs[index].id;
//
//                       return Dismissible(
//                         key: Key(docId),
//                         direction: DismissDirection.endToStart,
//                         background: Container(
//                           alignment: Alignment.centerRight,
//                           padding: const EdgeInsets.only(right: 20),
//                           color: Colors.red.withOpacity(0.2),
//                           child: const Icon(Icons.delete, color: Colors.red),
//                         ),
//                         onDismissed: (direction) async {
//                           bool? confirm = await showDeleteDialog(context);
//                           if (confirm == true) {
//                             await FirebaseFirestore.instance
//                                 .collection('users')
//                                 .doc(currentUser.uid)
//                                 .collection('reminders')
//                                 .doc(docId)
//                                 .delete();
//
//                             await AwesomeNotifications().cancel(docId.hashCode);
//                           }
//                         },
//                         child: InkWell(
//                           onTap: () => _showEditReminderDialog(context, reminder, docId),
//                           child: Container(
//                             margin: const EdgeInsets.symmetric(vertical: 8),
//                             padding: const EdgeInsets.all(20),
//                             decoration: BoxDecoration(
//                               color: AppColors.secondary,
//                               borderRadius: BorderRadius.circular(23),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     IconButton(
//                                       icon: Icon(Icons.edit, color: Colors.blue),
//                                       onPressed: () => _showEditReminderDialog(context, reminder, docId),
//                                     ),
//                                     Column(
//                                       crossAxisAlignment: CrossAxisAlignment.end,
//                                       children: [
//                                         Text(
//                                           reminder['medicineName'] ?? 'دواء',
//                                           style: AppTextStyles.sectionTitle,
//                                         ),
//                                         Text(
//                                           'نوع الدواء: ${reminder['medicineType'] == 'pills' ? 'حبوب' : 'شراب'}',
//                                           style: AppTextStyles.bodySmall,
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(height: 10),
//                                 Text(
//                                   'موعد التذكير: ${reminder['reminderTime']}',
//                                   style: AppTextStyles.bodyMedium,
//                                 ),
//                                 SizedBox(height: 5),
//                                 Text(
//                                   'الجرعة: ${reminder['dosage']}',
//                                   style: AppTextStyles.bodyMedium,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//
//             CustomButton(
//               text: 'إضافة تذكير جديد',
//               onPressed: () => _showAddReminderDialog(context),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: CustomBottomNavBar(
//         selectedIndex: _currentIndex,
//         onItemSelected: _onItemTapped,
//       ),
//       floatingActionButton: FloatingHomeButton(
//         isSelected: _currentIndex == 4,
//         onPressed: () => _onItemTapped(4),
//         btnHomeColor: AppColors.secondary,
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//     );
//   }
//
//   void _onItemTapped(int index) {
//     if (index == _currentIndex) return;
//     setState(() {
//       _currentIndex = index;
//     });
//     switch (index) {
//       case 0:
//         Navigator.pushReplacementNamed(context, '/favorites');
//         break;
//       case 1:
//         break;
//       case 2:
//         Navigator.pushReplacementNamed(context, '/cart');
//         break;
//       case 3:
//         Navigator.pushReplacementNamed(context, '/profile');
//         break;
//       case 4:
//         Navigator.pushNamed(context, '/home');
//         break;
//     }
//   }
//
//   Widget _buildTimeOption(String text, {bool isSelected = false}) {
//     return Container(
//       width: 80,
//       height: 66,
//       decoration: BoxDecoration(
//         color: isSelected ? AppColors.primary : AppColors.secondary,
//         borderRadius: BorderRadius.circular(19),
//       ),
//       child: Center(
//         child: Text(
//           text,
//           style: AppTextStyles.bodyMedium.copyWith(
//             color: isSelected ? Colors.white : Colors.black,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class Reminder3 extends StatefulWidget {
//   const Reminder3({super.key});
//
//   @override
//   State<Reminder3> createState() => _Reminder3State();
// }

// class _Reminder3State extends State<Reminder3> {
//   int _currentIndex = 1;
//   late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
//
//   // 💊 Medicine Type & Dosage Logic
//   String? _selectedMedicineType;
//   List<String> _dosageOptions = [];
//   final _dosageController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Initialize timezone database
//     tz.initializeTimeZones();
//
//     // Initialize notifications plugin
//     flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//
//     const AndroidInitializationSettings initializationSettingsAndroid =
//     AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     final InitializationSettings initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: null,
//     );
//
//     flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {},
//     );
//
//     _createNotificationChannel(); // إنشاء قناة الإشعارات
//
//     // 🔄 Reschedule existing reminders on app launch
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser != null) {
//       _rescheduleAllReminders(currentUser.uid);
//     }
//   }
//
//   Future<void> _createNotificationChannel() async {
//     const AndroidNotificationChannel channel = AndroidNotificationChannel(
//       'reminder_channel', // نفس الـ channelKey المستخدم في الإشعارات
//       'تذكير تناول الدواء',
//       description: 'قناة التذكير بتناول الأدوية',
//       importance: Importance.high,
//       playSound: true,
//       enableVibration: true,
//       enableLights: true,
//       sound: RawResourceAndroidNotificationSound('notification_sound'), // اختياري
//     );
//
//     await flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(channel);
//   }
//
//   void _updateDosage(String? medicineType) {
//     setState(() {
//       _selectedMedicineType = medicineType;
//
//       if (medicineType == 'pills') {
//         _dosageOptions = ['حبة واحدة', 'حبتين', 'ثلاث حبات', 'أربع حبات'];
//       } else if (medicineType == 'syrup') {
//         _dosageOptions = ['ملعقة صغيرة', 'ملعقتين صغيرتين', 'ملعقة كبيرة'];
//       } else {
//         _dosageOptions = [];
//       }
//
//       _dosageController.text = '';
//     });
//   }
//
//   Future<bool?> showDeleteDialog(BuildContext context) {
//     return showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text("حذف التذكير"),
//         content: Text("هل أنت متأكد من رغبتك في حذف هذا التذكير؟"),
//         actions: [
//           TextButton(onPressed: Navigator.of(context).pop, child: Text("إلغاء")),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             child: Text("حذف", style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // 🔄 Reschedule All Reminders on App Launch
//   Future<void> _rescheduleAllReminders(String userId) async {
//     final snapshot = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(userId)
//         .collection('reminders')
//         .get();
//
//     for (var doc in snapshot.docs) {
//       final data = doc.data();
//       final String? name = data['medicineName'];
//       final String? time = data['reminderTime'];
//
//       if (name != null && time != null) {
//         _scheduleNotification(doc.id, name, time);
//       }
//     }
//   }
//
//   // 📦 Schedule Daily Reminder
//   Future<void> _scheduleNotification(String docId, String name, String reminderTime) async {
//     final timeParts = reminderTime.split(" ");
//     if (timeParts.length < 2) return;
//
//     final hourMin = timeParts[0].split(":");
//     int hour = int.parse(hourMin[0]);
//     int minute = int.parse(hourMin[1]);
//
//     if (timeParts[1].toLowerCase() == "pm" && hour != 12) hour += 12;
//     if (timeParts[1].toLowerCase() == "am" && hour == 12) hour = 0;
//
//     final AndroidNotificationDetails androidPlatformChannelSpecifics =
//     AndroidNotificationDetails(
//       'reminder_channel',
//       'تذكير تناول الدواء',
//       channelDescription: 'قناة التذكير بتناول الأدوية',
//       importance: Importance.max,
//       priority: Priority.high,
//       ongoing: true,
//       autoCancel: false,
//     );
//
//     final NotificationDetails platformChannelSpecifics =
//     NotificationDetails(android: androidPlatformChannelSpecifics);
//
//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       docId.hashCode,
//       'تذكير تناول الدواء',
//       'حان الوقت لتناول $name',
//       _nextInstanceOfTime(hour, minute),
//       platformChannelSpecifics,
//       androidAllowWhileIdle: true,
//       uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
//       matchDateTimeComponents: DateTimeComponents.time,
//     );
//     // final timeParts = reminderTime.split(" ");
//     // if (timeParts.length < 2) return;
//     //
//     // final hourMin = timeParts[0].split(":");
//     // int hour = int.parse(hourMin[0]);
//     // int minute = int.parse(hourMin[1]);
//     //
//     // if (timeParts[1].toLowerCase() == "pm" && hour != 12) hour += 12;
//     // if (timeParts[1].toLowerCase() == "am" && hour == 12) hour = 0;
//     //
//     // final AndroidNotificationDetails androidPlatformChannelSpecifics =
//     // AndroidNotificationDetails(
//     //   'reminder_channel',
//     //   'تذكير تناول الدواء',
//     //   channelDescription: 'قناة التذكير بتناول الأدوية',
//     //   importance: Importance.max,
//     //   priority: Priority.high,
//     //   ongoing: true,
//     //   autoCancel: false,
//     //   sound: RawResourceAndroidNotificationSound('notification_sound'), // اختياري
//     // );
//     //
//     // final NotificationDetails platformChannelSpecifics =
//     // NotificationDetails(android: androidPlatformChannelSpecifics);
//     //
//     // await flutterLocalNotificationsPlugin.zonedSchedule(
//     //   docId.hashCode,
//     //   'تذكير تناول الدواء',
//     //   'حان الوقت لتناول $name',
//     //   _nextInstanceOfTime(hour, minute),
//     //   platformChannelSpecifics,
//     //   androidAllowWhileIdle: true,
//     //   uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
//     //   matchDateTimeComponents: DateTimeComponents.time, // التكرار يوميًا في نفس الوقت
//     // );
//
//     // final timeParts = reminderTime.split(" ");
//     // if (timeParts.length < 2) return;
//
//     // final hourMin = timeParts[0].split(":");
//     // int hour = int.parse(hourMin[0]);
//     // int minute = int.parse(hourMin[1]);
//
//     // if (timeParts[1].toLowerCase() == "pm" && hour != 12) hour += 12;
//     // if (timeParts[1].toLowerCase() == "am" && hour == 12) hour = 0;
//
//     // Schedule daily at this time
//     // final now = DateTime.now();
//     // final scheduledDate = tz.TZDateTime(
//     //   tz.local,
//     //   now.year,
//     //   now.month,
//     //   now.day,
//     //   hour,
//     //   minute,
//     // );
//
//     // const AndroidNotificationDetails androidPlatformChannelSpecifics =
//     // AndroidNotificationDetails(
//     //   'reminder_channel',
//     //   'تذكير تناول الدواء',
//     //   channelDescription: 'قناة التذكير بتناول الأدوية',
//     //   importance: Importance.max,
//     //   priority: Priority.high,
//     //   ticker: 'ticker',
//     //   autoCancel: false,
//     //   ongoing: true,
//     // );
//
//     // const NotificationDetails platformChannelSpecifics =
//     // NotificationDetails(android: androidPlatformChannelSpecifics);
//
//     // await flutterLocalNotificationsPlugin.zonedSchedule(
//     //   docId.hashCode,
//     //   'تذكير تناول الدواء',
//     //   'حان الوقت لتناول $name',
//     //   _nextInstanceOfTime(hour, minute),
//     //   platformChannelSpecifics,
//     //   androidAllowWhileIdle: true,
//     //   uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
//     //   matchDateTimeComponents: DateTimeComponents.time,
//     // );
//   }
//
//   tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
//     final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
//     tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
//
//     if (scheduledDate.isBefore(now)) {
//       scheduledDate = scheduledDate.add(const Duration(days: 1));
//     }
//
//     return scheduledDate;
//   }
//
//   // ➕ Show Dialog to Add New Reminder
//   void _showAddReminderDialog(BuildContext context) {
//     final _formKey = GlobalKey<FormState>();
//     final _medicineNameController = TextEditingController();
//     final _reminderTimeController = TextEditingController();
//     final _dosageController = TextEditingController();
//     String? _selectedMedicineType;
//     List<String> _dosageOptions = [];
//
//     void _updateDosage(String? medicineType) {
//       setState(() {
//         _selectedMedicineType = medicineType;
//
//         if (medicineType == 'pills') {
//           _dosageOptions = ['حبة واحدة', 'حبتين', 'ثلاث حبات', 'أربع حبات'];
//         } else if (medicineType == 'syrup') {
//           _dosageOptions = ['ملعقة صغيرة', 'ملعقتين صغيرتين', 'ملعقة كبيرة'];
//         } else {
//           _dosageOptions = [];
//         }
//
//         _dosageController.text = '';
//       });
//     }
//
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('لم يتم العثور على المستخدم')),
//       );
//       return;
//     }
//
//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, dialogSetState) {
//           return AlertDialog(
//             title: Text('إضافة تذكير جديد', style: AppTextStyles.header),
//             content: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextFormField(
//                     controller: _medicineNameController,
//                     decoration: InputDecoration(labelText: 'اسم الدواء'),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'اسم الدواء مطلوب';
//                       }
//                       return null;
//                     },
//                   ),
//                   SizedBox(height: 20),
//
//                   // 💊 Medicine Type Dropdown
//                   DropdownButtonFormField<String>(
//                     hint: Text('اختر نوع الدواء'),
//                     items: [
//                       DropdownMenuItem(value: 'pills', child: Text('حبوب')),
//                       DropdownMenuItem(value: 'syrup', child: Text('شراب')),
//                     ],
//                     onChanged: (value) {
//                       dialogSetState(() {
//                         _updateDosage(value);
//                       });
//                     },
//                     validator: (value) {
//                       if (_selectedMedicineType == null) {
//                         return 'نوع الدواء مطلوب';
//                       }
//                       return null;
//                     },
//                     decoration: InputDecoration(labelText: 'نوع الدواء'),
//                   ),
//
//                   SizedBox(height: 20),
//
//                   // ⏰ Time Picker
//                   TextFormField(
//                     controller: _reminderTimeController,
//                     decoration: InputDecoration(
//                       labelText: 'موعد التذكير',
//                       suffixIcon: Icon(Icons.access_time),
//                     ),
//                     onTap: () async {
//                       FocusScope.of(context).requestFocus(FocusNode());
//                       final TimeOfDay? pickedTime = await showTimePicker(
//                         context: context,
//                         initialTime: TimeOfDay.now(),
//                       );
//                       if (pickedTime != null) {
//                         setState(() {
//                           _reminderTimeController.text = pickedTime.format(context);
//                         });
//                       }
//                     },
//                     readOnly: true,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'موعد التذكير مطلوب';
//                       }
//                       return null;
//                     },
//                   ),
//
//                   SizedBox(height: 20),
//
//                   // 🧪 Dosage Dropdown
//                   if (_selectedMedicineType != null &&
//                       _dosageOptions.isNotEmpty)
//                     DropdownButtonFormField<String>(
//                       hint: Text('اختر الجرعة'),
//                       value: _dosageController.text.isNotEmpty
//                           ? _dosageController.text
//                           : null,
//                       items: _dosageOptions.map((value) {
//                         return DropdownMenuItem<String>(
//                           value: value,
//                           child: Text(value),
//                         );
//                       }).toList(),
//                       onChanged: (value) {
//                         dialogSetState(() {
//                           _dosageController.text = value!;
//                         });
//                       },
//                       validator: (value) {
//                         if (_dosageController.text.isEmpty) {
//                           return 'الجرعة مطلوبة';
//                         }
//                         return null;
//                       },
//                       decoration: InputDecoration(labelText: 'الجرعة'),
//                     ),
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: Text('إلغاء'),
//               ),
//               ElevatedButton(
//                 onPressed: () async {
//                   if (_formKey.currentState!.validate()) {
//                     final reminderData = {
//                       'medicineName': _medicineNameController.text.trim(),
//                       'medicineType': _selectedMedicineType,
//                       'reminderTime': _reminderTimeController.text.trim(),
//                       'dosage': _dosageController.text.trim(),
//                       'createdAt': FieldValue.serverTimestamp(),
//                     };
//
//                     try {
//                       final DocumentReference docRef = await FirebaseFirestore
//                           .instance
//                           .collection('users')
//                           .doc(currentUser.uid)
//                           .collection('reminders')
//                           .add(reminderData);
//
//                       _scheduleNotification(
//                         docRef.id,
//                         _medicineNameController.text,
//                         _reminderTimeController.text,
//                       );
//
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('تم إضافة التذكير بنجاح')),
//                       );
//                       Navigator.pop(context);
//                     } catch (e) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                             content: Text('فشل في إضافة التذكير: $e')),
//                       );
//                     }
//                   }
//                 },
//                 child: Text('حفظ'),
//               )
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   // ✏️ Show Edit Reminder Dialog
//   void _showEditReminderDialog(
//       BuildContext context, Map<String, dynamic> reminder, String docId) {
//     final _formKey = GlobalKey<FormState>();
//     final _medicineNameController =
//     TextEditingController(text: reminder['medicineName']);
//     final _reminderTimeController =
//     TextEditingController(text: reminder['reminderTime']);
//     final _dosageController =
//     TextEditingController(text: reminder['dosage'] ?? '');
//     _selectedMedicineType = reminder['medicineType'];
//     if (_selectedMedicineType == 'pills') {
//       _dosageOptions = ['حبة واحدة', 'حبتين', 'ثلاث حبات', 'أربع حبات'];
//     } else {
//       _dosageOptions = ['ملعقة صغيرة', 'ملعقتين صغيرتين', 'ملعقة كبيرة'];
//     }
//
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('لم يتم العثور على المستخدم')),
//       );
//       return;
//     }
//
//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, dialogSetState) {
//           return AlertDialog(
//             title: Text('تعديل التذكير', style: AppTextStyles.header),
//             content: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextFormField(
//                     controller: _medicineNameController,
//                     decoration: InputDecoration(labelText: 'اسم الدواء'),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'اسم الدواء مطلوب';
//                       }
//                       return null;
//                     },
//                   ),
//                   SizedBox(height: 20),
//
//                   // 💊 Medicine Type Dropdown
//                   DropdownButtonFormField<String>(
//                     value: _selectedMedicineType,
//                     hint: Text('اختر نوع الدواء'),
//                     items: [
//                       DropdownMenuItem(value: 'pills', child: Text('حبوب')),
//                       DropdownMenuItem(value: 'syrup', child: Text('شراب')),
//                     ],
//                     onChanged: (value) {
//                       dialogSetState(() {
//                         _updateDosage(value);
//                       });
//                     },
//                     validator: (value) {
//                       if (_selectedMedicineType == null) {
//                         return 'اختر نوع الدواء';
//                       }
//                       return null;
//                     },
//                     decoration: InputDecoration(labelText: 'نوع الدواء'),
//                   ),
//
//                   SizedBox(height: 20),
//
//                   // ⏰ Time Picker
//                   TextFormField(
//                     controller: _reminderTimeController,
//                     decoration: InputDecoration(
//                       labelText: 'موعد التذكير',
//                       suffixIcon: Icon(Icons.access_time),
//                     ),
//                     onTap: () async {
//                       FocusScope.of(context).requestFocus(FocusNode());
//                       final TimeOfDay? pickedTime = await showTimePicker(
//                         context: context,
//                         initialTime: TimeOfDay.now(),
//                       );
//                       if (pickedTime != null) {
//                         setState(() {
//                           _reminderTimeController.text = pickedTime.format(context);
//                         });
//                       }
//                     },
//                     readOnly: true,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'موعد التذكير مطلوب';
//                       }
//                       return null;
//                     },
//                   ),
//
//                   SizedBox(height: 20),
//
//                   // 🧪 Dosage Dropdown
//                   if (_selectedMedicineType != null &&
//                       _dosageOptions.isNotEmpty)
//                     DropdownButtonFormField<String>(
//                       hint: Text('اختر الجرعة'),
//                       value: _dosageController.text.isNotEmpty
//                           ? _dosageController.text
//                           : null,
//                       items: _dosageOptions.map((value) {
//                         return DropdownMenuItem<String>(
//                           value: value,
//                           child: Text(value),
//                         );
//                       }).toList(),
//                       onChanged: (value) {
//                         dialogSetState(() {
//                           _dosageController.text = value!;
//                         });
//                       },
//                       validator: (value) {
//                         if (_dosageController.text.isEmpty) {
//                           return 'الجرعة مطلوبة';
//                         }
//                         return null;
//                       },
//                       decoration: InputDecoration(labelText: 'الجرعة'),
//                     ),
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: Text('إلغاء'),
//               ),
//               ElevatedButton(
//                 onPressed: () async {
//                   if (_formKey.currentState!.validate()) {
//                     final updatedData = {
//                       'medicineName': _medicineNameController.text.trim(),
//                       'medicineType': _selectedMedicineType,
//                       'reminderTime': _reminderTimeController.text.trim(),
//                       'dosage': _dosageController.text.trim(),
//                     };
//
//                     try {
//                       await FirebaseFirestore.instance
//                           .collection('users')
//                           .doc(currentUser.uid)
//                           .collection('reminders')
//                           .doc(docId)
//                           .update(updatedData);
//
//                       // 🗑 Cancel old notification
//                       await flutterLocalNotificationsPlugin.cancel(docId.hashCode);
//
//                       // ✅ Schedule new one
//                       _scheduleNotification(
//                         docId,
//                         _medicineNameController.text,
//                         _reminderTimeController.text,
//                       );
//
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                             content: Text('تم تعديل التذكير بنجاح')),
//                       );
//                       Navigator.pop(context);
//                     } catch (e) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                             content: Text('فشل في تعديل التذكير: $e')),
//                       );
//                     }
//                   }
//                 },
//                 child: Text('تحديث'),
//               )
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) {
//       return Center(child: Text('لم يتم العثور على المستخدم'));
//     }
//
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: Text('منبه الدواء', style: AppTextStyles.header),
//         centerTitle: true,
//         backgroundColor: AppColors.background,
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _buildTimeOption('اليوم', isSelected: false),
//                 _buildTimeOption('الأسبوع', isSelected: true),
//                 _buildTimeOption('الشهر', isSelected: false),
//               ],
//             ),
//             const SizedBox(height: 30),
//
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection('users')
//                     .doc(currentUser.uid)
//                     .collection('reminders')
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                     return const Center(child: Text('لا توجد تذكيرات بعد'));
//                   }
//
//                   final docs = snapshot.data!.docs;
//
//                   return ListView.builder(
//                     itemCount: docs.length,
//                     itemBuilder: (context, index) {
//                       final reminder = docs[index].data() as Map<String, dynamic>;
//                       final docId = docs[index].id;
//
//                       return Dismissible(
//                         key: Key(docId),
//                         direction: DismissDirection.endToStart,
//                         background: Container(
//                           alignment: Alignment.centerRight,
//                           padding: const EdgeInsets.only(right: 20),
//                           color: Colors.red.withOpacity(0.2),
//                           child: const Icon(Icons.delete, color: Colors.red),
//                         ),
//                         onDismissed: (direction) async {
//                           bool? confirm = await showDeleteDialog(context);
//                           if (confirm == true) {
//                             await FirebaseFirestore.instance
//                                 .collection('users')
//                                 .doc(currentUser.uid)
//                                 .collection('reminders')
//                                 .doc(docId)
//                                 .delete();
//
//                             // 🗑 Cancel notification
//                             await flutterLocalNotificationsPlugin.cancel(docId.hashCode);
//                           }
//                         },
//                         child: InkWell(
//                           onTap: () =>
//                               _showEditReminderDialog(context, reminder, docId),
//                           child: Container(
//                             margin: const EdgeInsets.symmetric(vertical: 8),
//                             padding: const EdgeInsets.all(20),
//                             decoration: BoxDecoration(
//                               color: AppColors.secondary,
//                               borderRadius: BorderRadius.circular(23),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 Row(
//                                   mainAxisAlignment:
//                                   MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     IconButton(
//                                       icon: Icon(Icons.edit, color: Colors.blue),
//                                       onPressed: () =>
//                                           _showEditReminderDialog(
//                                               context, reminder, docId),
//                                     ),
//                                     Column(
//                                       crossAxisAlignment:
//                                       CrossAxisAlignment.end,
//                                       children: [
//                                         Text(
//                                           reminder['medicineName'] ?? 'دواء',
//                                           style: AppTextStyles.sectionTitle,
//                                         ),
//                                         Text(
//                                           'نوع الدواء: ${reminder['medicineType'] == 'pills' ? 'حبوب' : 'شراب'}',
//                                           style: AppTextStyles.bodySmall,
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(height: 10),
//                                 Text(
//                                   'موعد التذكير: ${reminder['reminderTime']}',
//                                   style: AppTextStyles.bodyMedium,
//                                 ),
//                                 SizedBox(height: 5),
//                                 Text(
//                                   'الجرعة: ${reminder['dosage']}',
//                                   style: AppTextStyles.bodyMedium,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//
//             CustomButton(
//               text: 'إضافة تذكير جديد',
//               onPressed: () => _showAddReminderDialog(context),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: CustomBottomNavBar(
//         selectedIndex: _currentIndex,
//         onItemSelected: _onItemTapped,
//       ),
//             floatingActionButton: FloatingHomeButton(
//         isSelected: _currentIndex == 4,
//         onPressed: () => _onItemTapped(4),
//         btnHomeColor: AppColors.secondary,
//       ),
//       floatingActionButtonLocation:
//       FloatingActionButtonLocation.centerDocked,
//     );
//   }
//
//   void _onItemTapped(int index) {
//     if (index == _currentIndex) return;
//     setState(() {
//       _currentIndex = index;
//     });
//     switch (index) {
//       case 0: // المفضلة
//         Navigator.pushReplacementNamed(context, '/favorites');
//         break;
//       case 1:
//         break;
//       case 2: // السلة
//         Navigator.pushReplacementNamed(context, '/cart');
//         break;
//       case 3:
//         Navigator.pushReplacementNamed(context, '/profile');
//         break;
//       case 4: // الصفحة الرئيسية
//         Navigator.pushNamed(context, '/home');
//         break;
//     }
//   }
//
//   Widget _buildTimeOption(String text, {bool isSelected = false}) {
//     return Container(
//       width: 80,
//       height: 66,
//       decoration: BoxDecoration(
//         color: isSelected ? AppColors.primary : AppColors.secondary,
//         borderRadius: BorderRadius.circular(19),
//       ),
//       child: Center(
//         child: Text(
//           text,
//           style: AppTextStyles.bodyMedium.copyWith(
//             color: isSelected ? Colors.white : Colors.black,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class Reminder2 extends StatefulWidget {
//   const Reminder2({super.key});
//
//   @override
//   State<Reminder2> createState() => _Reminder2State();
// }

// class _Reminder2State extends State<Reminder2> {
//   int _currentIndex = 1;
//
//   // 💊 Medicine Type & Dosage Logic
//   String? _selectedMedicineType;
//   List<String> _dosageOptions = [];
//   final _dosageController = TextEditingController();
//
//   void _updateDosage(String? medicineType) {
//     setState(() {
//       _selectedMedicineType = medicineType;
//
//       if (medicineType == 'pills') {
//         _dosageOptions = ['حبة واحدة', 'حبتين', 'ثلاث حبات', 'أربع حبات'];
//       } else if (medicineType == 'syrup') {
//         _dosageOptions = ['ملعقة صغيرة', 'ملعقتين صغيرتين', 'ملعقة كبيرة'];
//       } else {
//         _dosageOptions = [];
//       }
//
//       _dosageController.text = '';
//     });
//   }
//
//   Future<bool?> showDeleteDialog(BuildContext context) {
//     return showDialog<bool>(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: Text("حذف التذكير"),
//             content: Text("هل أنت متأكد من رغبتك في حذف هذا التذكير؟"),
//             actions: [
//               TextButton(
//                 onPressed: Navigator.of(context).pop,
//                 child: Text("إلغاء"),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(true),
//                 child: Text("حذف", style: TextStyle(color: Colors.red)),
//               ),
//             ],
//           ),
//     );
//   }
//
//   @override
//   void initState() {
//     super.initState();
//
//     // 🔔 Ask permission to send notifications (iOS only)
//     AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
//       if (!isAllowed) {
//         AwesomeNotifications().requestPermissionToSendNotifications();
//       }
//     });
//
//     // 🔄 Reschedule existing reminders on app launch
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser != null) {
//       _rescheduleAllReminders(currentUser.uid);
//     }
//   }
//
//   // 🔄 Reschedule All Reminders on App Launch
//   Future<void> _rescheduleAllReminders(String userId) async {
//     final snapshot =
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(userId)
//             .collection('reminders')
//             .get();
//
//     for (var doc in snapshot.docs) {
//       final data = doc.data();
//       final String? name = data['medicineName'];
//       final String? time = data['reminderTime'];
//
//       if (name != null && time != null) {
//         _scheduleNotification(doc.id, name, time);
//       }
//     }
//   }
//
//   // 📦 Schedule Daily Reminder
//   void _scheduleNotification(String docId, String name, String reminderTime) {
//     final timeParts = reminderTime.split(" ");
//     if (timeParts.length < 2) return;
//
//     final hourMin = timeParts[0].split(":");
//     int hour = int.parse(hourMin[0]);
//     int minute = int.parse(hourMin[1]);
//
//     if (timeParts[1].toLowerCase() == "pm" && hour != 12) hour += 12;
//     if (timeParts[1].toLowerCase() == "am" && hour == 12) hour = 0;
//
//     // 🛎 Schedule daily at this time
//     final calendar = NotificationCalendar(
//       hour: hour,
//       minute: minute,
//       second: 0,
//       millisecond: 0,
//       repeats: true,
//     );
//
//     AwesomeNotifications().createNotification(
//       content: NotificationContent(
//         id: docId.hashCode,
//         channelKey: 'reminder_channel',
//         title: 'تذكير تناول الدواء',
//         body: 'حان الوقت لتناول $name',
//         category: NotificationCategory.Reminder,
//         wakeUpScreen: true,
//         locked: true,
//         autoDismissible: false,
//       ),
//       schedule: calendar,
//     );
//   }
//
//   // ➕ Show Dialog to Add New Reminder
//   void _showAddReminderDialog(BuildContext context) {
//     final _formKey = GlobalKey<FormState>();
//     final _medicineNameController = TextEditingController();
//     final _reminderTimeController = TextEditingController();
//     final _dosageController = TextEditingController();
//     String? _selectedMedicineType;
//     List<String> _dosageOptions = [];
//
//     void _updateDosage(String? medicineType) {
//       setState(() {
//         _selectedMedicineType = medicineType;
//
//         if (medicineType == 'pills') {
//           _dosageOptions = ['حبة واحدة', 'حبتين', 'ثلاث حبات', 'أربع حبات'];
//         } else if (medicineType == 'syrup') {
//           _dosageOptions = ['ملعقة صغيرة', 'ملعقتين صغيرتين', 'ملعقة كبيرة'];
//         } else {
//           _dosageOptions = [];
//         }
//
//         _dosageController.text = '';
//       });
//     }
//
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('لم يتم العثور على المستخدم')));
//       return;
//     }
//
//     showDialog(
//       context: context,
//       builder:
//           (context) => StatefulBuilder(
//             builder: (context, dialogSetState) {
//               return AlertDialog(
//                 title: Text('إضافة تذكير جديد', style: AppTextStyles.header),
//                 content: Form(
//                   key: _formKey,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       TextFormField(
//                         controller: _medicineNameController,
//                         decoration: InputDecoration(labelText: 'اسم الدواء'),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'اسم الدواء مطلوب';
//                           }
//                           return null;
//                         },
//                       ),
//                       SizedBox(height: 20),
//
//                       // 💊 Medicine Type Dropdown
//                       DropdownButtonFormField<String>(
//                         hint: Text('اختر نوع الدواء'),
//                         items: [
//                           DropdownMenuItem(value: 'pills', child: Text('حبوب')),
//                           DropdownMenuItem(value: 'syrup', child: Text('شراب')),
//                         ],
//                         onChanged: (value) {
//                           dialogSetState(() {
//                             _updateDosage(value);
//                           });
//                         },
//                         validator: (value) {
//                           if (_selectedMedicineType == null) {
//                             return 'نوع الدواء مطلوب';
//                           }
//                           return null;
//                         },
//                         decoration: InputDecoration(labelText: 'نوع الدواء'),
//                       ),
//
//                       SizedBox(height: 20),
//
//                       // ⏰ Time Picker
//                       TextFormField(
//                         controller: _reminderTimeController,
//                         decoration: InputDecoration(
//                           labelText: 'موعد التذكير',
//                           suffixIcon: Icon(Icons.access_time),
//                         ),
//                         onTap: () async {
//                           FocusScope.of(context).requestFocus(FocusNode());
//                           final TimeOfDay? pickedTime = await showTimePicker(
//                             context: context,
//                             initialTime: TimeOfDay.now(),
//                           );
//                           if (pickedTime != null) {
//                             setState(() {
//                               _reminderTimeController.text = pickedTime.format(
//                                 context,
//                               );
//                             });
//                           }
//                         },
//                         readOnly: true,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'موعد التذكير مطلوب';
//                           }
//                           return null;
//                         },
//                       ),
//
//                       SizedBox(height: 20),
//
//                       // 🧪 Dosage Dropdown
//                       if (_selectedMedicineType != null &&
//                           _dosageOptions.isNotEmpty)
//                         DropdownButtonFormField<String>(
//                           hint: Text('اختر الجرعة'),
//                           value:
//                               _dosageController.text.isNotEmpty
//                                   ? _dosageController.text
//                                   : null,
//                           items:
//                               _dosageOptions.map((value) {
//                                 return DropdownMenuItem<String>(
//                                   value: value,
//                                   child: Text(value),
//                                 );
//                               }).toList(),
//                           onChanged: (value) {
//                             dialogSetState(() {
//                               _dosageController.text = value!;
//                             });
//                           },
//                           validator: (value) {
//                             if (_dosageController.text.isEmpty) {
//                               return 'الجرعة مطلوبة';
//                             }
//                             return null;
//                           },
//                           decoration: InputDecoration(labelText: 'الجرعة'),
//                         ),
//                     ],
//                   ),
//                 ),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: Text('إلغاء'),
//                   ),
//                   ElevatedButton(
//                     onPressed: () async {
//                       if (_formKey.currentState!.validate()) {
//                         final reminderData = {
//                           'medicineName': _medicineNameController.text.trim(),
//                           'medicineType': _selectedMedicineType,
//                           'reminderTime': _reminderTimeController.text.trim(),
//                           'dosage': _dosageController.text.trim(),
//                           'createdAt': FieldValue.serverTimestamp(),
//                         };
//
//                         try {
//                           final DocumentReference docRef =
//                               await FirebaseFirestore.instance
//                                   .collection('users')
//                                   .doc(currentUser.uid)
//                                   .collection('reminders')
//                                   .add(reminderData);
//
//                           _scheduleNotification(
//                             docRef.id,
//                             _medicineNameController.text,
//                             _reminderTimeController.text,
//                           );
//
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text('تم إضافة التذكير بنجاح')),
//                           );
//                           Navigator.pop(context);
//                         } catch (e) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text('فشل في إضافة التذكير: $e')),
//                           );
//                         }
//                       }
//                     },
//                     child: Text('حفظ'),
//                   ),
//                 ],
//               );
//             },
//           ),
//     );
//   }
//
//   // ✏️ Show Edit Reminder Dialog
//   void _showEditReminderDialog(
//     BuildContext context,
//     Map<String, dynamic> reminder,
//     String docId,
//   ) {
//     final _formKey = GlobalKey<FormState>();
//     final _medicineNameController = TextEditingController(
//       text: reminder['medicineName'],
//     );
//     final _reminderTimeController = TextEditingController(
//       text: reminder['reminderTime'],
//     );
//     final _dosageController = TextEditingController(
//       text: reminder['dosage'] ?? '',
//     );
//     _selectedMedicineType = reminder['medicineType'];
//     if (_selectedMedicineType == 'pills') {
//       _dosageOptions = ['حبة واحدة', 'حبتين', 'ثلاث حبات', 'أربع حبات'];
//     } else {
//       _dosageOptions = ['ملعقة صغيرة', 'ملعقتين صغيرتين', 'ملعقة كبيرة'];
//     }
//
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('لم يتم العثور على المستخدم')));
//       return;
//     }
//
//     showDialog(
//       context: context,
//       builder:
//           (context) => StatefulBuilder(
//             builder: (context, dialogSetState) {
//               return AlertDialog(
//                 title: Text('تعديل التذكير', style: AppTextStyles.header),
//                 content: Form(
//                   key: _formKey,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       TextFormField(
//                         controller: _medicineNameController,
//                         decoration: InputDecoration(labelText: 'اسم الدواء'),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'اسم الدواء مطلوب';
//                           }
//                           return null;
//                         },
//                       ),
//                       SizedBox(height: 20),
//
//                       // 💊 Medicine Type Dropdown
//                       DropdownButtonFormField<String>(
//                         value: _selectedMedicineType,
//                         hint: Text('اختر نوع الدواء'),
//                         items: [
//                           DropdownMenuItem(value: 'pills', child: Text('حبوب')),
//                           DropdownMenuItem(value: 'syrup', child: Text('شراب')),
//                         ],
//                         onChanged: (value) {
//                           dialogSetState(() {
//                             _updateDosage(value);
//                           });
//                         },
//                         validator: (value) {
//                           if (_selectedMedicineType == null) {
//                             return 'اختر نوع الدواء';
//                           }
//                           return null;
//                         },
//                         decoration: InputDecoration(labelText: 'نوع الدواء'),
//                       ),
//
//                       SizedBox(height: 20),
//
//                       // ⏰ Time Picker
//                       TextFormField(
//                         controller: _reminderTimeController,
//                         decoration: InputDecoration(
//                           labelText: 'موعد التذكير',
//                           suffixIcon: Icon(Icons.access_time),
//                         ),
//                         onTap: () async {
//                           FocusScope.of(context).requestFocus(FocusNode());
//                           final TimeOfDay? pickedTime = await showTimePicker(
//                             context: context,
//                             initialTime: TimeOfDay.now(),
//                           );
//                           if (pickedTime != null) {
//                             setState(() {
//                               _reminderTimeController.text = pickedTime.format(
//                                 context,
//                               );
//                             });
//                           }
//                         },
//                         readOnly: true,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'موعد التذكير مطلوب';
//                           }
//                           return null;
//                         },
//                       ),
//
//                       SizedBox(height: 20),
//
//                       // 🧪 Dosage Dropdown
//                       if (_selectedMedicineType != null &&
//                           _dosageOptions.isNotEmpty)
//                         DropdownButtonFormField<String>(
//                           hint: Text('اختر الجرعة'),
//                           value:
//                               _dosageController.text.isNotEmpty
//                                   ? _dosageController.text
//                                   : null,
//                           items:
//                               _dosageOptions.map((value) {
//                                 return DropdownMenuItem<String>(
//                                   value: value,
//                                   child: Text(value),
//                                 );
//                               }).toList(),
//                           onChanged: (value) {
//                             dialogSetState(() {
//                               _dosageController.text = value!;
//                             });
//                           },
//                           validator: (value) {
//                             if (_dosageController.text.isEmpty) {
//                               return 'الجرعة مطلوبة';
//                             }
//                             return null;
//                           },
//                           decoration: InputDecoration(labelText: 'الجرعة'),
//                         ),
//                     ],
//                   ),
//                 ),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: Text('إلغاء'),
//                   ),
//                   ElevatedButton(
//                     onPressed: () async {
//                       if (_formKey.currentState!.validate()) {
//                         final updatedData = {
//                           'medicineName': _medicineNameController.text.trim(),
//                           'medicineType': _selectedMedicineType,
//                           'reminderTime': _reminderTimeController.text.trim(),
//                           'dosage': _dosageController.text.trim(),
//                         };
//
//                         try {
//                           await FirebaseFirestore.instance
//                               .collection('users')
//                               .doc(currentUser.uid)
//                               .collection('reminders')
//                               .doc(docId)
//                               .update(updatedData);
//
//                           // 🗑 Cancel old notification
//                           await AwesomeNotifications().cancelSchedule(
//                             docId.hashCode,
//                           );
//
//                           // ✅ Schedule new one
//                           _scheduleNotification(
//                             docId,
//                             _medicineNameController.text,
//                             _reminderTimeController.text,
//                           );
//
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text('تم تعديل التذكير بنجاح')),
//                           );
//                           Navigator.pop(context);
//                         } catch (e) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text('فشل في تعديل التذكير: $e')),
//                           );
//                         }
//                       }
//                     },
//                     child: Text('تحديث'),
//                   ),
//                 ],
//               );
//             },
//           ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) {
//       return Center(child: Text('لم يتم العثور على المستخدم'));
//     }
//
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: Text('منبه الدواء', style: AppTextStyles.header),
//         centerTitle: true,
//         backgroundColor: AppColors.background,
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _buildTimeOption('اليوم', isSelected: false),
//                 _buildTimeOption('الأسبوع', isSelected: true),
//                 _buildTimeOption('الشهر', isSelected: false),
//               ],
//             ),
//             const SizedBox(height: 30),
//
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream:
//                     FirebaseFirestore.instance
//                         .collection('users')
//                         .doc(currentUser.uid)
//                         .collection('reminders')
//                         .snapshots(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                     return const Center(child: Text('لا توجد تذكيرات بعد'));
//                   }
//
//                   final docs = snapshot.data!.docs;
//
//                   return ListView.builder(
//                     itemCount: docs.length,
//                     itemBuilder: (context, index) {
//                       final reminder =
//                           docs[index].data() as Map<String, dynamic>;
//                       final docId = docs[index].id;
//
//                       return Dismissible(
//                         key: Key(docId),
//                         direction: DismissDirection.endToStart,
//                         background: Container(
//                           alignment: Alignment.centerRight,
//                           padding: const EdgeInsets.only(right: 20),
//                           color: Colors.red.withOpacity(0.2),
//                           child: const Icon(Icons.delete, color: Colors.red),
//                         ),
//                         onDismissed: (direction) async {
//                           bool? confirm = await showDeleteDialog(context);
//                           if (confirm == true) {
//                             await FirebaseFirestore.instance
//                                 .collection('users')
//                                 .doc(currentUser.uid)
//                                 .collection('reminders')
//                                 .doc(docId)
//                                 .delete();
//
//                             // 🗑 Cancel notification
//                             await AwesomeNotifications().cancel(docId.hashCode);
//                           }
//                         },
//                         child: InkWell(
//                           onTap:
//                               () => _showEditReminderDialog(
//                                 context,
//                                 reminder,
//                                 docId,
//                               ),
//                           child: Container(
//                             margin: const EdgeInsets.symmetric(vertical: 8),
//                             padding: const EdgeInsets.all(20),
//                             decoration: BoxDecoration(
//                               color: AppColors.secondary,
//                               borderRadius: BorderRadius.circular(23),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     IconButton(
//                                       icon: Icon(
//                                         Icons.edit,
//                                         color: Colors.blue,
//                                       ),
//                                       onPressed:
//                                           () => _showEditReminderDialog(
//                                             context,
//                                             reminder,
//                                             docId,
//                                           ),
//                                     ),
//                                     Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.end,
//                                       children: [
//                                         Text(
//                                           reminder['medicineName'] ?? 'دواء',
//                                           style: AppTextStyles.sectionTitle,
//                                         ),
//                                         Text(
//                                           'نوع الدواء: ${reminder['medicineType'] == 'pills' ? 'حبوب' : 'شراب'}',
//                                           style: AppTextStyles.bodySmall,
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(height: 10),
//                                 Text(
//                                   'موعد التذكير: ${reminder['reminderTime']}',
//                                   style: AppTextStyles.bodyMedium,
//                                 ),
//                                 SizedBox(height: 5),
//                                 Text(
//                                   'الجرعة: ${reminder['dosage']}',
//                                   style: AppTextStyles.bodyMedium,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//
//             CustomButton(
//               text: 'إضافة تذكير جديد',
//               onPressed: () => _showAddReminderDialog(context),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: CustomBottomNavBar(
//         selectedIndex: _currentIndex,
//         onItemSelected: _onItemTapped,
//       ),
//       floatingActionButton: FloatingHomeButton(
//         isSelected: _currentIndex == 4,
//         onPressed: () => _onItemTapped(4),
//         btnHomeColor: AppColors.secondary,
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//     );
//   }
//
//   void _onItemTapped(int index) {
//     if (index == _currentIndex) return;
//     setState(() {
//       _currentIndex = index;
//     });
//     switch (index) {
//       case 0: // المفضلة
//         Navigator.pushReplacementNamed(context, '/favorites');
//         break;
//       case 1:
//         break;
//       case 2: // السلة
//         Navigator.pushReplacementNamed(context, '/cart');
//         break;
//       case 3:
//         Navigator.pushReplacementNamed(context, '/profile');
//         break;
//       case 4: // الصفحة الرئيسية
//         Navigator.pushNamed(context, '/home');
//         break;
//     }
//   }
//
//   Widget _buildTimeOption(String text, {bool isSelected = false}) {
//     return Container(
//       width: 80,
//       height: 66,
//       decoration: BoxDecoration(
//         color: isSelected ? AppColors.primary : AppColors.secondary,
//         borderRadius: BorderRadius.circular(19),
//       ),
//       child: Center(
//         child: Text(
//           text,
//           style: AppTextStyles.bodyMedium.copyWith(
//             color: isSelected ? Colors.white : Colors.black,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class Reminder2 extends StatefulWidget {
//   const Reminder2({super.key});
//
//   @override
//   State<Reminder2> createState() => _Reminder2State();
// }
//
// class _Reminder2State extends State<Reminder2> {
//   int _currentIndex = 1;
//
//   void _onItemTapped(int index) {
//     if (index == _currentIndex) return;
//
//     setState(() {
//       _currentIndex = index;
//     });
//
//     switch (index) {
//       case 0: // المفضلة
//         Navigator.pushReplacementNamed(context, '/favorites');
//         break;
//       case 1:
//         break;
//       case 2: // السلة
//         Navigator.pushReplacementNamed(context, '/cart');
//         break;
//       case 3:
//         Navigator.pushReplacementNamed(context, '/profile');
//         break;
//       case 4: // الصفحة الرئيسية
//         Navigator.pushNamed(context, '/home');
//         break;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) {
//       return const Center(child: Text('لم يتم العثور على المستخدم'));
//     }
//
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: Text('منبه الدواء', style: AppTextStyles.header),
//         centerTitle: true,
//         backgroundColor: AppColors.background,
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             //  StreamBuilder to Show Reminders
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream:
//                     FirebaseFirestore.instance
//                         .collection('users')
//                         .doc(currentUser.uid)
//                         .collection('reminders')
//                         .snapshots(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                     return const Center(child: Text('لا توجد تذكيرات بعد'));
//                   }
//                   final docs = snapshot.data!.docs;
//
//                   return ListView.builder(
//                     itemCount: docs.length,
//                     itemBuilder: (context, index) {
//                       final reminder =
//                           docs[index].data() as Map<String, dynamic>;
//                       final docId = docs[index].id;
//
//                       return Dismissible(
//                         key: Key(docId),
//                         direction: DismissDirection.endToStart,
//                         background: Container(
//                           alignment: Alignment.centerRight,
//                           padding: const EdgeInsets.only(right: 20),
//                           color: Colors.red.withOpacity(0.2),
//                           child: const Icon(Icons.delete, color: Colors.red),
//                         ),
//                         onDismissed: (direction) async {
//                           await FirebaseFirestore.instance
//                               .collection('users')
//                               .doc(currentUser.uid)
//                               .collection('reminders')
//                               .doc(docId)
//                               .delete();
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text('تم حذف التذكير')),
//                           );
//                         },
//                         child: InkWell(
//                           onTap:
//                               () => _showEditReminderDialog(
//                                 context,
//                                 reminder,
//                                 docId,
//                               ),
//                           child: Container(
//                             margin: const EdgeInsets.symmetric(vertical: 8),
//                             padding: const EdgeInsets.all(20),
//                             decoration: BoxDecoration(
//                               color: AppColors.secondary,
//                               borderRadius: BorderRadius.circular(23),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     IconButton(
//                                       icon: const Icon(
//                                         Icons.edit,
//                                         color: Colors.blue,
//                                       ),
//                                       onPressed:
//                                           () => _showEditReminderDialog(
//                                             context,
//                                             reminder,
//                                             docId,
//                                           ),
//                                     ),
//                                     Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.end,
//                                       children: [
//                                         Text(
//                                           reminder['medicineName'] ?? 'دواء',
//                                           style: AppTextStyles.sectionTitle,
//                                         ),
//                                         Text(
//                                           'نوع الدواء: ${reminder['medicineType'] == 'pills' ? 'حبوب' : 'شراب'}',
//                                           style: AppTextStyles.bodySmall,
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 10),
//                                 Text(
//                                   'موعد التذكير: ${reminder['reminderTime']}',
//                                   style: AppTextStyles.bodyMedium,
//                                 ),
//                                 const SizedBox(height: 5),
//                                 Text(
//                                   'الجرعة: ${reminder['dosage']}',
//                                   style: AppTextStyles.bodyMedium,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//
//             const SizedBox(height: 20),
//             CustomButton(
//               text: 'إضافة تذكير جديد',
//               onPressed: () => _showAddReminderDialog(context),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: CustomBottomNavBar(
//         selectedIndex: _currentIndex,
//         onItemSelected: _onItemTapped,
//       ),
//       floatingActionButton: FloatingHomeButton(
//         isSelected: _currentIndex == 4,
//         onPressed: () => _onItemTapped(4),
//         btnHomeColor: AppColors.secondary,
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//     );
//   }
//
//   Widget _buildTimeOption(String text, {bool isSelected = false}) {
//     return Container(
//       width: 80,
//       height: 66,
//       decoration: BoxDecoration(
//         color: isSelected ? AppColors.primary : AppColors.secondary,
//         borderRadius: BorderRadius.circular(19),
//       ),
//       child: Center(
//         child: Text(
//           text,
//           style: AppTextStyles.bodyMedium.copyWith(
//             color: isSelected ? Colors.white : Colors.black,
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ✅ Show Dialog to Add New Reminder
//   void _showAddReminderDialog(BuildContext context) {
//     final _formKey = GlobalKey<FormState>();
//     final _medicineNameController = TextEditingController();
//     final _reminderTimeController = TextEditingController();
//     final _dosageController = TextEditingController();
//     String? _selectedMedicineType;
//     List<String> _dosageOptions = [];
//
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('لم يتم العثور على المستخدم')));
//       return;
//     }
//
//     void _updateDosageOptions(String? medicineType) {
//       setState(() {
//         _selectedMedicineType = medicineType;
//         if (medicineType == 'pills') {
//           _dosageOptions = [
//             'حبة واحدة',
//             'حبتين',
//             'ثلاث حبات',
//             'أربع حبات',
//             'حسب الإرشادات الطبية',
//           ];
//         } else if (medicineType == 'syrup') {
//           _dosageOptions = [
//             'ملعقة صغيرة',
//             'ملعقتين صغيرتين',
//             'ملعقة كبيرة',
//             'ملعقتين كبيرتين',
//             'حسب الإرشادات الطبية',
//           ];
//         } else {
//           _dosageOptions = [];
//         }
//         _dosageController.text = '';
//       });
//     }
//
//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: Text('إضافة تذكير جديد', style: AppTextStyles.header),
//             content: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextFormField(
//                     controller: _medicineNameController,
//                     decoration: InputDecoration(
//                       labelText: 'اسم الدواء',
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'اسم الدواء مطلوب';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   // Medicine Type Selection
//                   DropdownButtonFormField<String>(
//                     value: _selectedMedicineType,
//                     hint: Text('اختر نوع الدواء'),
//                     items: [
//                       DropdownMenuItem(value: 'pills', child: Text('حبوب')),
//                       DropdownMenuItem(value: 'syrup', child: Text('شراب')),
//                     ],
//                     onChanged: _updateDosageOptions,
//                     decoration: InputDecoration(
//                       labelText: 'نوع الدواء',
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'نوع الدواء مطلوب';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   TextFormField(
//                     controller: _reminderTimeController,
//                     decoration: InputDecoration(
//                       labelText: 'موعد التذكير',
//                       border: OutlineInputBorder(),
//                       suffixIcon: Icon(Icons.access_time),
//                     ),
//                     onTap: () async {
//                       FocusScope.of(context).requestFocus(FocusNode());
//                       final TimeOfDay? pickedTime = await showTimePicker(
//                         context: context,
//                         initialTime: TimeOfDay.now(),
//                       );
//                       if (pickedTime != null) {
//                         setState(() {
//                           _reminderTimeController.text = pickedTime.format(
//                             context,
//                           );
//                         });
//                       }
//                     },
//                     readOnly: true,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'موعد التذكير مطلوب';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   // Dosage Dropdown
//                   DropdownButtonFormField<String>(
//                     value:
//                         _dosageController.text.isNotEmpty
//                             ? _dosageController.text
//                             : null,
//                     hint: Text('اختر الجرعة'),
//                     items:
//                         _dosageOptions.map((String value) {
//                           return DropdownMenuItem<String>(
//                             value: value,
//                             child: Text(value),
//                           );
//                         }).toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         _dosageController.text = value!;
//                       });
//                     },
//                     decoration: InputDecoration(
//                       labelText: 'الجرعة',
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (value) {
//                       if (_dosageController.text.isEmpty) {
//                         return 'الجرعة مطلوبة';
//                       }
//                       return null;
//                     },
//                   ),
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: Text('إلغاء', style: AppTextStyles.bodyMedium),
//               ),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                 ),
//                 onPressed: () async {
//                   if (_formKey.currentState!.validate()) {
//                     final reminderData = {
//                       'medicineName': _medicineNameController.text.trim(),
//                       'medicineType': _selectedMedicineType,
//                       'reminderTime': _reminderTimeController.text.trim(),
//                       'dosage': _dosageController.text.trim(),
//                       'createdAt': FieldValue.serverTimestamp(),
//                     };
//
//                     try {
//                       await FirebaseFirestore.instance
//                           .collection('users')
//                           .doc(currentUser.uid)
//                           .collection('reminders')
//                           .add(reminderData);
//
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('تم إضافة التذكير بنجاح')),
//                       );
//                       Navigator.pop(context);
//                     } catch (e) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('فشل في إضافة التذكير: $e')),
//                       );
//                     }
//                   }
//                 },
//                 child: Text('حفظ', style: AppTextStyles.button),
//               ),
//             ],
//           ),
//     );
//   }
//
//   // ✅ Show Dialog to Edit Existing Reminder
//   void _showEditReminderDialog(
//     BuildContext context,
//     Map<String, dynamic> reminder,
//     String docId,
//   ) {
//     final _formKey = GlobalKey<FormState>();
//     final _medicineNameController = TextEditingController(
//       text: reminder['medicineName'],
//     );
//     final _reminderTimeController = TextEditingController(
//       text: reminder['reminderTime'],
//     );
//     final _dosageController = TextEditingController(text: reminder['dosage']);
//     String? _selectedMedicineType = reminder['medicineType'];
//     List<String> _dosageOptions = [];
//
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('لم يتم العثور على المستخدم')));
//       return;
//     }
//
//     void _updateDosageOptions(String? medicineType) {
//       setState(() {
//         _selectedMedicineType = medicineType;
//         if (medicineType == 'pills') {
//           _dosageOptions = [
//             'حبة واحدة',
//             'حبتين',
//             'ثلاث حبات',
//             'أربع حبات',
//             'حسب الإرشادات الطبية',
//           ];
//         } else if (medicineType == 'syrup') {
//           _dosageOptions = [
//             'ملعقة صغيرة',
//             'ملعقتين صغيرتين',
//             'ملعقة كبيرة',
//             'ملعقتين كبيرتين',
//             'حسب الإرشادات الطبية',
//           ];
//         } else {
//           _dosageOptions = [];
//         }
//         // Keep current dosage if it exists in new options
//         if (!_dosageOptions.contains(_dosageController.text)) {
//           _dosageController.text = '';
//         }
//       });
//     }
//
//     // Initialize dosage options based on existing medicine type
//     _updateDosageOptions(_selectedMedicineType);
//
//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: Text('تعديل التذكير', style: AppTextStyles.header),
//             content: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextFormField(
//                     controller: _medicineNameController,
//                     decoration: InputDecoration(
//                       labelText: 'اسم الدواء',
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'اسم الدواء مطلوب';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   // Medicine Type Selection
//                   DropdownButtonFormField<String>(
//                     value: _selectedMedicineType,
//                     hint: Text('اختر نوع الدواء'),
//                     items: [
//                       DropdownMenuItem(value: 'pills', child: Text('حبوب')),
//                       DropdownMenuItem(value: 'syrup', child: Text('شراب')),
//                     ],
//                     onChanged: _updateDosageOptions,
//                     decoration: InputDecoration(
//                       labelText: 'نوع الدواء',
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'نوع الدواء مطلوب';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   TextFormField(
//                     controller: _reminderTimeController,
//                     decoration: InputDecoration(
//                       labelText: 'موعد التذكير',
//                       border: OutlineInputBorder(),
//                       suffixIcon: Icon(Icons.access_time),
//                     ),
//                     onTap: () async {
//                       FocusScope.of(context).requestFocus(FocusNode());
//                       final TimeOfDay? pickedTime = await showTimePicker(
//                         context: context,
//                         initialTime: TimeOfDay.now(),
//                       );
//                       if (pickedTime != null) {
//                         setState(() {
//                           _reminderTimeController.text = pickedTime.format(
//                             context,
//                           );
//                         });
//                       }
//                     },
//                     readOnly: true,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'موعد التذكير مطلوب';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   // Dosage Dropdown
//                   DropdownButtonFormField<String>(
//                     value:
//                         _dosageController.text.isNotEmpty
//                             ? _dosageController.text
//                             : null,
//                     hint: Text('اختر الجرعة'),
//                     items:
//                         _dosageOptions.map((String value) {
//                           return DropdownMenuItem<String>(
//                             value: value,
//                             child: Text(value),
//                           );
//                         }).toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         _dosageController.text = value!;
//                       });
//                     },
//                     decoration: InputDecoration(
//                       labelText: 'الجرعة',
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (value) {
//                       if (_dosageController.text.isEmpty) {
//                         return 'الجرعة مطلوبة';
//                       }
//                       return null;
//                     },
//                   ),
//                 ],
//               ),
//             ),
//             actions: [
//               // Delete Button
//               TextButton(
//                 onPressed: () async {
//                   final confirm = await showDialog(
//                     context: context,
//                     builder:
//                         (context) => AlertDialog(
//                           title: Text('تأكيد الحذف'),
//                           content: Text(
//                             'هل أنت متأكد أنك تريد حذف هذا التذكير؟',
//                           ),
//                           actions: [
//                             TextButton(
//                               onPressed: () => Navigator.pop(context, false),
//                               child: Text('إلغاء'),
//                             ),
//                             TextButton(
//                               onPressed: () => Navigator.pop(context, true),
//                               child: Text(
//                                 'حذف',
//                                 style: TextStyle(color: Colors.red),
//                               ),
//                             ),
//                           ],
//                         ),
//                   );
//
//                   if (confirm == true) {
//                     try {
//                       await FirebaseFirestore.instance
//                           .collection('users')
//                           .doc(currentUser.uid)
//                           .collection('reminders')
//                           .doc(docId)
//                           .delete();
//
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('تم حذف التذكير بنجاح')),
//                       );
//                       Navigator.pop(context); // Close edit dialog
//                     } catch (e) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('فشل في حذف التذكير: $e')),
//                       );
//                     }
//                   }
//                 },
//                 child: Text('حذف', style: TextStyle(color: Colors.red)),
//               ),
//               // Cancel Button
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: Text('إلغاء', style: AppTextStyles.bodyMedium),
//               ),
//               // Update Button
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                 ),
//                 onPressed: () async {
//                   if (_formKey.currentState!.validate()) {
//                     final updatedData = {
//                       'medicineName': _medicineNameController.text.trim(),
//                       'medicineType': _selectedMedicineType,
//                       'reminderTime': _reminderTimeController.text.trim(),
//                       'dosage': _dosageController.text.trim(),
//                     };
//
//                     try {
//                       await FirebaseFirestore.instance
//                           .collection('users')
//                           .doc(currentUser.uid)
//                           .collection('reminders')
//                           .doc(docId)
//                           .update(updatedData);
//
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('تم تعديل التذكير بنجاح')),
//                       );
//                       Navigator.pop(context);
//                     } catch (e) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('فشل في تعديل التذكير: $e')),
//                       );
//                     }
//                   }
//                 },
//                 child: Text('تحديث', style: AppTextStyles.button),
//               ),
//             ],
//           ),
//     );
//   }
// }

// class Reminder2 extends StatefulWidget {
//   const Reminder2({super.key});
//
//   @override
//   State<Reminder2> createState() => _Reminder2State();
// }
//
// class _Reminder2State extends State<Reminder2> {
//   int _currentIndex = 1;
//
//   void _onItemTapped(int index) {
//     if (index == _currentIndex) return;
//
//     setState(() {
//       _currentIndex = index;
//     });
//
//     switch (index) {
//       case 0: // المفضلة
//         Navigator.pushReplacementNamed(context, '/favorites');
//         break;
//       case 1:
//         break;
//       case 2: // السلة
//         Navigator.pushReplacementNamed(context, '/cart');
//         break;
//       case 3:
//         Navigator.pushReplacementNamed(context, '/profile');
//         break;
//       case 4: // الصفحة الرئيسية
//         Navigator.pushNamed(context, '/home');
//         break;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: Text('منبه الدواء', style: AppTextStyles.header),
//         centerTitle: true,
//         backgroundColor: AppColors.background,
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _buildTimeOption('اليوم', isSelected: false),
//                 _buildTimeOption('الأسبوع', isSelected: true),
//                 _buildTimeOption('الشهر', isSelected: false),
//               ],
//             ),
//             const SizedBox(height: 30),
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: AppColors.secondary,
//                 borderRadius: BorderRadius.circular(23),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       IconButton(
//                         icon: const Icon(
//                           Icons.delete_outline,
//                           color: Colors.red,
//                         ),
//                         onPressed: () {},
//                       ),
//                       Text(
//                         'فيتامين ارجيفيت',
//                         style: AppTextStyles.sectionTitle,
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//                   Text('مرات الاسخدام: 1', style: AppTextStyles.bodyMedium),
//                   const SizedBox(height: 5),
//                   Text('موعد النذكير: كل يوم', style: AppTextStyles.bodyMedium),
//                   const SizedBox(height: 5),
//                   Text('الجرعة: كبسولة واحدة', style: AppTextStyles.bodyMedium),
//                   const SizedBox(height: 10),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       Text('08:00 ص', style: AppTextStyles.bodyLarge),
//                       const SizedBox(width: 10),
//                       const Icon(Icons.access_time, size: 20),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             const Spacer(),
//             CustomButton(
//               text: 'إضافة تذكير جديد',
//               onPressed: () => _showAddReminderDialog(context),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: CustomBottomNavBar(
//         selectedIndex: _currentIndex,
//         onItemSelected: _onItemTapped,
//       ),
//       floatingActionButton: FloatingHomeButton(
//         isSelected: _currentIndex == 4,
//         onPressed: () => _onItemTapped(4),
//         btnHomeColor: AppColors.secondary,
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//     );
//   }
//
//   Widget _buildTimeOption(String text, {bool isSelected = false}) {
//     return Container(
//       width: 80,
//       height: 66,
//       decoration: BoxDecoration(
//         color: isSelected ? AppColors.primary : AppColors.secondary,
//         borderRadius: BorderRadius.circular(19),
//       ),
//       child: Center(
//         child: Text(
//           text,
//           style: AppTextStyles.bodyMedium.copyWith(
//             color: isSelected ? Colors.white : Colors.black,
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _showAddReminderDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: Text('إضافة تذكير جديد', style: AppTextStyles.header),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   decoration: InputDecoration(
//                     labelText: 'اسم الدواء',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 TextField(
//                   decoration: InputDecoration(
//                     labelText: 'موعد التذكير',
//                     border: OutlineInputBorder(),
//                     suffixIcon: Icon(Icons.access_time),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 TextField(
//                   decoration: InputDecoration(
//                     labelText: 'الجرعة',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: Text('إلغاء', style: AppTextStyles.bodyMedium),
//               ),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                 ),
//                 onPressed: () => Navigator.pop(context),
//                 child: Text('حفظ', style: AppTextStyles.button),
//               ),
//             ],
//           ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(const FigmaToCodeApp());
// }
//
// // Generated by: https://www.figma.com/community/plugin/842128343887142055/
// class FigmaToCodeApp extends StatelessWidget {
//   const FigmaToCodeApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData.dark().copyWith(
//         scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
//       ),
//       home: Scaffold(body: ListView(children: [Reminder()])),
//     );
//   }
// }
//
// class Reminder extends StatelessWidget {
//   const Reminder({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           width: 393,
//           height: 852,
//           clipBehavior: Clip.antiAlias,
//           decoration: BoxDecoration(color: Colors.white),
//           child: Stack(
//             children: [
//               Positioned(
//                 left: 222,
//                 top: 52,
//                 child: Opacity(
//                   opacity: 0.93,
//                   child: Text(
//                     'منبه الدواء',
//                     textAlign: TextAlign.right,
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 25,
//                       fontFamily: 'Inter',
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 left: 26,
//                 top: 770,
//                 child: Container(
//                   width: 342,
//                   height: 56,
//                   decoration: ShapeDecoration(
//                     color: const Color(0xFF00676C),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(13),
//                     ),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 left: 46,
//                 top: 314,
//                 child: Container(
//                   width: 304,
//                   height: 74,
//                   decoration: ShapeDecoration(
//                     color: const Color(0xFFF8F8F8),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(23),
//                     ),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 left: 46,
//                 top: 153,
//                 child: Container(
//                   width: 80,
//                   height: 66,
//                   decoration: ShapeDecoration(
//                     color: const Color(0xFFF8F8F8),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(19),
//                     ),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 left: 276,
//                 top: 153,
//                 child: Container(
//                   width: 80,
//                   height: 66,
//                   decoration: ShapeDecoration(
//                     color: const Color(0xFFF8F8F8),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(19),
//                     ),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 left: 161,
//                 top: 153,
//                 child: Container(
//                   width: 80,
//                   height: 66,
//                   decoration: ShapeDecoration(
//                     color: const Color(0xFF00676C),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(19),
//                     ),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 left: 166,
//                 top: 324,
//                 child: SizedBox(
//                   width: 164,
//                   height: 67,
//                   child: Text(
//                     'فيتامين ارجيفيت \nمرات الاسخدام : 1\nموعد النذكير : كل يوم',
//                     textAlign: TextAlign.right,
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 15,
//                       fontFamily: 'Inter',
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
