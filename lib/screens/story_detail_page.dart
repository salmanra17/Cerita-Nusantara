import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/story_data.dart';
import '../screens/settings_page.dart';

class StoryDetailPage extends StatelessWidget {
  const StoryDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<StoryController>();
    final StoryModel story = Get.arguments?['story'] ?? ctrl.allStories.first;
    final settingsCtrl = Get.put(SettingsController());
    final index = ctrl.getIndexOf(story);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      floatingActionButton: Obx(() {
        final isFav = ctrl.isFavorite(index);
        return GestureDetector(
          onTap: () => ctrl.toggleFavorite(index),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 71, 20, 7),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.red : Colors.white,
              size: 26,
            ),
          ),
        );
      }),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 52 + MediaQuery.paddingOf(context).top,
              color: const Color.fromARGB(255, 71, 20, 7),
              child: SafeArea(
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 24),
                    ),
                    Expanded(
                      child: Text(
                        story.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 36),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: story.cardColor,
                ),
                child: storyImage(
                  story: story,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(story.title,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 71, 20, 7),
                    fontSize: 17,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Obx(() => Text(story.content,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 71, 20, 7),
                    fontSize: settingsCtrl.fontSizeValue,
                    fontFamily: 'Poppins',
                    height: 1.7,
                  ))),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}