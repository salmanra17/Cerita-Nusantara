import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../data/story_data.dart';
import '../screens/settings_page.dart';

class FavoritPage extends StatelessWidget {
  const FavoritPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<StoryController>();

    return Scaffold(
      backgroundColor: const Color.fromARGB(232, 236, 236, 236),
      body: Column(
        children: [
          Container(
            height: 52 + MediaQuery.paddingOf(context).top,
            color: const Color.fromARGB(255, 71, 20, 7),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Text('Cerita Terfavorit',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700)),
                    const Spacer(),
                    const Icon(Icons.search, color: Colors.white, size: 22),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => showSettingsDialog(context),
                      child: const Icon(Icons.settings,
                          color: Colors.white, size: 22),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              final stories = ctrl.allStories;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.68,
                        ),
                        itemCount: stories.length,
                        itemBuilder: (_, i) {
                          final s = stories[i];
                          return GestureDetector(
                            onTap: () => Get.toNamed(AppRoutes.STORY_DETAIL,
                                arguments: {'story': s}),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: s.cardColor),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: storyImage(
                                      story: s,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    height: 90,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(14),
                                            bottomRight: Radius.circular(14)),
                                        gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              Colors.black
                                                  .withValues(alpha: 0.7),
                                              Colors.transparent
                                            ]),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    left: 10,
                                    right: 10,
                                    child: Column(
                                      children: [
                                        Text(s.title,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 2),
                                        Text(s.region,
                                            style: TextStyle(
                                                color: Colors.white
                                                    .withValues(alpha: 0.7),
                                                fontFamily: 'Poppins',
                                                fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
