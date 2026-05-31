import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../screens/settings_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.sizeOf(context).width;
    final sh = MediaQuery.sizeOf(context).height;

    return Scaffold(
      body: Stack(
        children: [
          // --- BG Image ---
          Positioned(
            top: 0,
            left: 0,
            width: sw,
            height: sh,
            child: Image.asset(
              'assets/images/landing_bg.jpeg',
              fit: BoxFit.contain, // ← UBAH INI: cover (full screen) / contain (fit all) / fill (stretched)
              // Bisa juga dikasih scale biar lebih kecil/besar:
              // scale: 1.0, // ← angka > 1.0 = lebih kecil, < 1.0 = lebih besar
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromARGB(255, 255, 255, 255),
                      Color.fromARGB(255, 255, 255, 255),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // --- KONTEN UTAMA ---
          SafeArea(
            child: SizedBox(
              width: sw,
              height: sh,
              child: Column(
                children: [
                  const SizedBox(height: 0), // ← UBAH ANGKA INI UNTUK NAIKIN/TURUNIN LOGO (makin kecil = makin atas)
                  
                  // Logo Image Area
                  Expanded(
                    child: Container(
                      alignment: Alignment.topCenter, // ← UBAH INI: topCenter (atas), center (tengah), bottomCenter (bawah)
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildLogoImage(),
                    ),
                  ),

                  // Menu Container
                  _buildMenuContainer(sw),
                ],
              ),
            ),
          ),

          // --- Tombol Settings Pojok Kanan Atas ---
          Positioned(
            top: MediaQuery.paddingOf(context).top + 16,
            right: 16,
            child: GestureDetector(
              onTap: () => showSettingsDialog(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B4513).withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: const Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoImage() {
    return Image.asset(
      'assets/images/logo_cerita_nusantara.png',
      width: 250,  // ← UBAH ANGKA INI UNTUK NGATUR LEBAR LOGO
      height: 250, // ← UBAH ANGKA INI UNTUK NGATUR TINGGI LOGO
      fit: BoxFit.contain, // ← Bisa ganti: contain, cover, fill, fitWidth, fitHeight
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );
  }

  Widget _buildMenuContainer(double sw) {
    return Container(
      width: sw,
      padding: const EdgeInsets.fromLTRB(40, 50, 40, 50),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tombol "Ayo Jelajahi"
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.HOME),
            child: Container(
              width: sw * 0.75,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
                border: Border.all(
                  color: const Color(0xFF8B4513),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: const Text(
                'Ayo Jelajahi',
                style: TextStyle(
                  color: Color(0xFF3D2416),
                  fontSize: 18,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Text "atau"
          const Text(
            'atau',
            style: TextStyle(
              color: Color(0xFF666666),
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Tombol "Lihat Koleksi"
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.HOME, arguments: {'initialTab': 3}),
            child: Container(
              width: sw * 0.75,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF5C2E0F),
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: const Text(
                'Lihat Koleksi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}