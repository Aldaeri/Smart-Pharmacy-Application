import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/colors.dart';
import '../constants/styles.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.primary,
                padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text('الدعم والمساندة', style: AppTextStyles.header),
                        const SizedBox(width: 48), // للتوازن
                      ],
                    ),
                  ],
                ),
              ),
            ),
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
                  children: [
                    const SizedBox(height: 20),
                    _buildSupportCard(
                      context,
                      Icons.phone,
                      'اتصل بنا',
                      'اضغط للاتصال بالدعم الفوري',
                      _makePhoneCall,
                    ),
                    const SizedBox(height: 20),
                    _buildSupportCard(
                      context,
                      Icons.chat,
                      'تواصل عبر واتس اب',
                      'اضغط للدردشة مع الدعم عبر واتس اب',
                      _openWhatsAppChat,
                    ),
                    const SizedBox(height: 20),
                    _buildSupportCard(
                      context,
                      Icons.email,
                      'تواصل عبر البريد الإلكتروني',
                      'اضغط لإرسال بريد إلكتروني للدعم',
                      _sendEmail,
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'نحن هنا لمساعدتك على مدار الساعة',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'وقت الاستجابة: 24/7',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
      // bottomNavigationBar: const CustomBottomNavBar2(selectedIndex: 3),
    );
  }

  Widget _buildSupportCard(
      BuildContext context,
      IconData icon,
      String title,
      String subtitle,
      Function() onTap,
      ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, size: 32, color: AppColors.primary),
        title: Text(title, style: AppTextStyles.bodyMedium),
        subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        onTap: onTap,
      ),
    );
  }

  Future<void> _makePhoneCall() async {
    const phoneNumber = 'tel:772720341';
    if (await canLaunchUrl(Uri.parse(phoneNumber))) {
      await launchUrl(Uri.parse(phoneNumber));
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  Future<void> _openWhatsAppChat() async {
    final whatsappUrl = 'https://wa.me/772720341';
    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl));
    } else {
      throw 'Could not launch $whatsappUrl';
    }
  }

  Future<void> _sendEmail() async {
    final emailUrl = 'mailto:alnehmiayoub@gmail.com?subject=طلب دعم&body=السلام عليكم، أريد المساعدة بخصوص...';
    if (await canLaunchUrl(Uri.parse(emailUrl))) {
      await launchUrl(Uri.parse(emailUrl));
    } else {
      throw 'Could not launch $emailUrl';
    }
  }
}