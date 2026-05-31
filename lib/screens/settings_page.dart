import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../routes/app_routes.dart';

class SettingsController extends GetxController {
  final fontSize = 2.obs;
  final userRating = 0.obs;
  final isSubmittingRating = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFontSize();
    loadUserRating();
  }

  Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('device_id');
    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString('device_id', deviceId);
    }
    return deviceId;
  }

  Future<void> loadUserRating() async {
    try {
      final deviceId = await _getDeviceId();
      final res = await Supabase.instance.client
          .from('ratings')
          .select('rating')
          .eq('device_id', deviceId)
          .maybeSingle();
      if (res != null) {
        userRating.value = res['rating'];
      }
    } catch (e) {
      print('Error load rating: $e');
    }
  }

  Future<void> submitRating(int star) async {
    try {
      isSubmittingRating.value = true;
      final deviceId = await _getDeviceId();
      await Supabase.instance.client.from('ratings').upsert({
        'device_id': deviceId,
        'rating': star,
      }, onConflict: 'device_id');
      userRating.value = star;
    } catch (e) {
      print('Error submit rating: $e');
    } finally {
      isSubmittingRating.value = false;
    }
  }

  Future<void> _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    fontSize.value = prefs.getInt('font_size') ?? 2;
  }

  Future<void> setFontSize(int size) async {
    fontSize.value = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('font_size', size);
  }

  double get fontSizeValue {
    switch (fontSize.value) {
      case 1: return 14.0;
      case 3: return 20.0;
      default: return 16.0;
    }
  }
}

void showSettingsDialog(BuildContext context) {
  final controller = Get.put(SettingsController());

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Settings',
    barrierColor: Colors.black.withOpacity(0.3),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (ctx, animation, _) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              width: MediaQuery.sizeOf(context).width * 0.85,
              constraints: const BoxConstraints(maxWidth: 500),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 35),
                    padding: const EdgeInsets.fromLTRB(24, 50, 24, 28),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5C3317),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFF8B4513), width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Ukuran Teks
                        Obx(() => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ukuran Teks Cerita',
                              style: TextStyle(
                                color: Color(0xFFD4A85A),
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: const Color(0xFFD4A85A),
                                inactiveTrackColor: const Color(0xFF3A1A08),
                                thumbColor: const Color(0xFFD4A85A),
                                overlayColor: const Color(0x29D4A85A),
                              ),
                              child: Slider(
                                value: controller.fontSize.value.toDouble(),
                                min: 1,
                                max: 3,
                                divisions: 2,
                                onChanged: (v) => controller.setFontSize(v.toInt()),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [1, 2, 3].map((i) {
                                final labels = ['Kecil', 'Sedang', 'Besar'];
                                final isSelected = controller.fontSize.value == i;
                                return GestureDetector(
                                  onTap: () => controller.setFontSize(i),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFFD4A85A) : const Color(0xFF3A1A08),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      labels[i - 1],
                                      style: TextStyle(
                                        color: isSelected ? const Color(0xFF4A2510) : const Color(0xFFD4A85A),
                                        fontSize: 12,
                                        fontFamily: 'Poppins',
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3A1A08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Dahulu kala, di sebuah hutan yang lebat...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: controller.fontSizeValue,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        )),

                        const SizedBox(height: 24),

                        // Tombol INFO
                        _buildActionButton(
                          icon: Icons.info_outline,
                          label: 'INFO',
                          onTap: () {
                            Get.back();
                            Get.toNamed(AppRoutes.INFO);
                          },
                        ),
                        const SizedBox(height: 12),

                        // Tombol NILAI KAMI
                        _buildActionButton(
                          icon: Icons.star,
                          label: 'NILAI KAMI',
                          onTap: () => _showRatingDialog(ctx, controller),
                        ),
                        const SizedBox(height: 12),

                        // Tombol FACEBOOK
                        _buildActionButton(
                          icon: Icons.facebook,
                          label: 'FACEBOOK',
                          iconColor: const Color(0xFF1877F2),
                          onTap: () {
                            Get.snackbar(
                              'Facebook',
                              'Membuka halaman Facebook...',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.white.withOpacity(0.9),
                              colorText: Colors.black,
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Header
                  Positioned(
                    top: 0, left: 0, right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: const Color(0xFF5C3317), width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: const Text(
                          'Pengaturan',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Tombol Close
                  Positioned(
                    top: 0, right: 8,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF5C3317),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF8B4513), width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 28),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (ctx, animation, _, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  );
}

void _showRatingDialog(BuildContext context, SettingsController controller) {
  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF5C3317),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF8B4513), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Nilai Aplikasi Kami!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Seberapa suka kamu dengan\nCerita Nusantara?',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final star = i + 1;
                return GestureDetector(
                  onTap: () => controller.userRating.value = star,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      star <= controller.userRating.value
                          ? Icons.star
                          : Icons.star_border,
                      color: const Color(0xFFD4A85A),
                      size: 32,
                    ),
                  ),
                );
              }),
            )),
            const SizedBox(height: 20),
            Obx(() => GestureDetector(
              onTap: controller.userRating.value == 0
                  ? null
                  : () async {
                      await controller.submitRating(controller.userRating.value);
                      Navigator.pop(ctx);
                      Get.snackbar(
                        '⭐ Terima kasih!',
                        'Rating kamu sudah tersimpan!',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.white.withOpacity(0.9),
                        colorText: Colors.black,
                      );
                    },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: controller.userRating.value == 0
                      ? Colors.grey
                      : const Color(0xFFD4A85A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: controller.isSubmittingRating.value
                    ? const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : const Text(
                        'Kirim Rating',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
              ),
            )),
          ],
        ),
      ),
    ),
  );
}

Widget _buildActionButton({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
  Color? iconColor,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF3D1F0A).withOpacity(0.6),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: const Color(0xFF8B4513).withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor ?? Colors.white, size: 24),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    ),
  );
}