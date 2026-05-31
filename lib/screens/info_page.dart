import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../screens/settings_page.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsCtrl = Get.find<SettingsController>();
    return Scaffold(
      backgroundColor: const Color.fromARGB(1000, 255, 255, 255),
      body: Column(
        children: [
          // Header
          Container(
            height: 56 + MediaQuery.paddingOf(context).top,
            color: const Color.fromARGB(1000, 71, 20, 7),
            child: SafeArea(
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 24),
                  ),
                  const Expanded(
                    child: Text('Info',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Obx(() => Text(
                'Halo, kami adalah tim di balik aplikasi Cerita Nusantara. Aplikasi ini lahir dari keinginan kami untuk menjaga agar cerita-cerita rakyat Indonesia tidak lekang oleh waktu. Kami percaya, di setiap kisah Bawang Merah & Bawang Putih, Malin Kundang, atau Si Pitung, terkandung nilai-nilai luhur yang perlu terus disampaikan. Aplikasi ini kami buat dengan sepenuh hati.\n\n'
                'Dilengkapi dengan:\n'
                '• Koleksi cerita yang terus bertambah: Kami berkomitmen untuk terus menambah cerita dari berbagai daerah di Indonesia.\n'
                '• Visual yang indah: Setiap halaman kami rancang agar pengalaman membaca jadi lebih menyenangkan, seperti membuka buku cerita sungguhan.\n'
                '• Antarmuka yang ramah pengguna: Dibuat agar mudah digunakan oleh anak-anak hingga orang dewasa.\n\n'
                'Melalui aplikasi ini, kami berharap bisa menjadi jembatan antara generasi muda dan kekayaan budaya leluhur. Mari kita bersama-sama melestarikan cerita-cerita ini!',
                style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: settingsCtrl.fontSizeValue,
                    fontFamily: 'Poppins',
                    height: 1.6),)
              ),
            ),
          ),
        ],
      ),
    );
  }
}
