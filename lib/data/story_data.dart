import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegionModel {
  final int id;
  final String name;
  RegionModel({required this.id, required this.name});
  factory RegionModel.fromJson(Map<String, dynamic> json) =>
      RegionModel(id: json['id'], name: json['name']);
}

class CategoryModel {
  final int id;
  final String name;
  CategoryModel({required this.id, required this.name});
  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      CategoryModel(id: json['id'], name: json['name']);
}

class StoryModel {
  final int id;
  final String title;
  final String region;
  final String kategori;
  final String imagePlaceholder;
  final String? imageUrl;
  final Color cardColor;
  final String content;

  StoryModel({
    required this.id,
    required this.title,
    required this.region,
    required this.kategori,
    required this.imagePlaceholder,
    this.imageUrl,
    required this.cardColor,
    required this.content,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    final hex = (json['card_color'] as String).replaceAll('#', '');
    final color = Color(int.parse('FF$hex', radix: 16));
    return StoryModel(
      id: json['id'],
      title: json['title'],
      region: json['regions']['name'],
      kategori: json['categories']['name'],
      imagePlaceholder: json['image_name'] ?? 'story_1.png',
      imageUrl: json['image_url'],
      cardColor: color,
      content: json['content'],
    );
  }
}

class StoryService {
  final _db = Supabase.instance.client;

  Future<List<StoryModel>> fetchStories() async {
    final res = await _db
        .from('stories')
        .select('*, regions(name), categories(name)')
        .order('id');
    return (res as List).map((e) => StoryModel.fromJson(e)).toList();
  }

  Future<List<Map<String, dynamic>>> fetchRegionsWithCount() async {
    final regions =
        await _db.from('regions').select('id, name, image_url').order('name');

    final stories = await _db.from('stories').select('region_id');

    final List regionList = regions as List;
    final List storyList = stories as List;

    return regionList.map((r) {
      final count = storyList.where((s) => s['region_id'] == r['id']).length;
      return {
        'id': r['id'],
        'name': r['name'],
        'image_url': r['image_url'],
        'count': count,
      };
    }).toList();
  }

  Future<void> recordVisit() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSession = prefs.getString('last_visit_session');

      // Ambil jam sekarang, bagi 6 untuk dapat blok 6 jam
      // Blok 0: jam 00-05, Blok 1: jam 06-11, Blok 2: jam 12-17, Blok 3: jam 18-23
      final now = DateTime.now();
      final block = now.hour ~/ 6;
      final sessionKey = '${now.toIso8601String().substring(0, 10)}_$block';

      if (lastSession == sessionKey) return;

      await prefs.setString('last_visit_session', sessionKey);
      await _db.from('app_visits').insert({});
    } catch (e) {
      print('Error record visit: $e');
    }
  }
}

class StoryController extends GetxController {
  final _service = StoryService();

  final allStories = <StoryModel>[].obs;
  final allRegions = <Map<String, dynamic>>[].obs;
  final allCategories = <CategoryModel>[].obs;
  final favoriteIndexes = <int>[].obs;
  final isLoading = true.obs;
  final hasError = false.obs;

  @override
  void onReady() {
    super.onReady();
    fetchStories();
    fetchRegions();
    loadFavorites();
    fetchCategories();
    _service.recordVisit();
  }

  // Load favorit dari storage
  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('favorites') ?? [];
    favoriteIndexes.assignAll(saved.map((e) => int.parse(e)).toList());
  }

  // Simpan favorit ke storage
  Future<void> saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'favorites',
      favoriteIndexes.map((e) => e.toString()).toList(),
    );
  }

  Future<void> fetchStories() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      final data = await _service.fetchStories();
      allStories.assignAll(data);
    } catch (e) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchRegions() async {
    try {
      final data = await _service.fetchRegionsWithCount();
      allRegions.assignAll(data);
    } catch (e) {
      print('Error fetch regions: $e');
    }
  }

  Future<void> fetchCategories() async {
    try {
      final res = await Supabase.instance.client
          .from('categories')
          .select('*')
          .order('id');
      allCategories.assignAll(
          (res as List).map((e) => CategoryModel.fromJson(e)).toList());
    } catch (e) {
      print('Error fetch categories: $e');
    }
  }

  bool isFavorite(int index) => favoriteIndexes.contains(index);

  void toggleFavorite(int index) {
    if (favoriteIndexes.contains(index)) {
      favoriteIndexes.remove(index);
    } else {
      favoriteIndexes.add(index);
    }
    saveFavorites(); // ← tambah ini
  }

  List<StoryModel> getByKategori(String kategori) =>
      allStories.where((s) => s.kategori == kategori).toList();

  List<StoryModel> getFavorites() =>
      favoriteIndexes.map((i) => allStories[i]).toList();

  int getIndexOf(StoryModel story) => allStories.indexOf(story);
}

// Helper widget gambar cerita
// Helper widget gambar cerita
Widget storyImage({
  required StoryModel story,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  BorderRadius? borderRadius,
}) {
  final imageWidget = story.imageUrl != null
      ? Image.network(
          story.imageUrl!,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => _storyPlaceholder(width, height),
        )
      : _storyPlaceholder(width, height);

  if (borderRadius != null) {
    return ClipRRect(borderRadius: borderRadius, child: imageWidget);
  }
  return imageWidget;
}

Widget _storyPlaceholder(double? width, double? height) {
  return Container(
    width: width,
    height: height,
    color: const Color(0xFF5A3A20),
    child: const Icon(
      Icons.auto_stories,
      color: Colors.white38,
      size: 40,
    ),
  );
}
