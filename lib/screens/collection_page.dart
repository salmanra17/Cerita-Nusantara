import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../data/story_data.dart';
import '../screens/settings_page.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});
  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  bool _searchOpen = false;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    if (_searchOpen) {
      return _SearchOverlay(
        onClose: () => setState(() {
          _searchOpen = false;
          _searchQuery = '';
        }),
        onSearch: (query) => setState(() {
          _searchQuery = query.toLowerCase();
          _searchOpen = false;
        }),
      );
    }

    final ctrl = Get.find<StoryController>();

    return Obx(() {
      final allFavs = ctrl.getFavorites();
      final favs = _searchQuery.isEmpty
          ? allFavs
          : allFavs
              .where((s) => s.title.toLowerCase().contains(_searchQuery))
              .toList();

      return Column(
        children: [
          _CustomAppBar(
            title: 'Koleksi',
            onSearchTap: () => setState(() => _searchOpen = true),
          ),
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text('Hasil untuk "$_searchQuery"',
                      style: const TextStyle(
                          color: Color.fromARGB(255, 71, 20, 7),
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _searchQuery = ''),
                    child: const Icon(Icons.close,
                        color: Color.fromARGB(255, 71, 20, 7)),
                  ),
                ],
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  if (allFavs.isEmpty)
                    _emptyState()
                  else if (favs.isEmpty && _searchQuery.isNotEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 80),
                        child: Column(
                          children: [
                            const Icon(Icons.search_off,
                                size: 64,
                                color: Color.fromARGB(255, 71, 20, 7)),
                            const SizedBox(height: 16),
                            Text('Tidak ada hasil untuk "$_searchQuery"',
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 71, 20, 7),
                                    fontFamily: 'Poppins',
                                    fontSize: 16)),
                          ],
                        ),
                      ),
                    )
                  else
                    ...favs.map((s) {
                      final gIdx = ctrl.getIndexOf(s);
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 5),
                        child: Container(
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 71, 20, 7),
                              borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: s.cardColor),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child:
                                      storyImage(story: s, fit: BoxFit.cover),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(s.title,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w600)),
                                    Text(s.region,
                                        style: TextStyle(
                                            color: Colors.white
                                                .withValues(alpha: 0.55),
                                            fontFamily: 'Poppins',
                                            fontSize: 12)),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        _HeartBtn(gIdx),
                                        const SizedBox(width: 8),
                                        _tag(s.kategori),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () => Get.toNamed(
                                              AppRoutes.STORY_DETAIL,
                                              arguments: {'story': s}),
                                          child: _tag('Baca'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _emptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 210),
        child: Column(
          children: [
            Icon(Icons.bookmark,
                color: Color.fromARGB(255, 71, 20, 7), size: 72),
            SizedBox(height: 16),
            Text('Ups!',
                style: TextStyle(
                    color: Color.fromARGB(255, 71, 20, 7),
                    fontSize: 22,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700)),
            SizedBox(height: 8),
            Text(
              'Daftar koleksi Anda kosong karena\nAnda belum menambahkan Cerita\napa pun di menu koleksi',
              style: TextStyle(
                  color: Color.fromARGB(255, 71, 20, 7),
                  fontFamily: 'Poppins',
                  fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomAppBar extends StatelessWidget {
  final String title;
  final VoidCallback onSearchTap;
  const _CustomAppBar({required this.title, required this.onSearchTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52 + MediaQuery.paddingOf(context).top,
      color: const Color.fromARGB(255, 71, 20, 7),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              GestureDetector(
                onTap: onSearchTap,
                child: const Icon(Icons.search, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => showSettingsDialog(context),
                child:
                    const Icon(Icons.settings, color: Colors.white, size: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchOverlay extends StatefulWidget {
  final VoidCallback onClose;
  final Function(String) onSearch;
  const _SearchOverlay({required this.onClose, required this.onSearch});

  @override
  State<_SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<_SearchOverlay> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _searchHistory = [];
  List<String> _suggestions = [];

  List<String> get _allStoryTitles =>
      Get.find<StoryController>().allStories.map((s) => s.title).toList();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final query = _controller.text.toLowerCase();
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    setState(() {
      _suggestions = _allStoryTitles
          .where((title) => title.toLowerCase().contains(query))
          .take(5)
          .toList();
    });
  }

  void _performSearch(String query) {
    if (query.trim().isNotEmpty) {
      if (!_searchHistory.contains(query.trim())) {
        setState(() {
          _searchHistory.insert(0, query.trim());
          if (_searchHistory.length > 5) _searchHistory.removeLast();
        });
      }
      widget.onSearch(query.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final showHistory = _controller.text.isEmpty && _searchHistory.isNotEmpty;
    final showSuggestions =
        _controller.text.isNotEmpty && _suggestions.isNotEmpty;

    return Container(
      color: const Color.fromARGB(232, 236, 236, 236),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4)
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(Icons.search,
                      color: Color.fromARGB(255, 71, 20, 7), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      style:
                          const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Cari koleksi',
                        hintStyle: TextStyle(
                            color: Colors.grey, fontFamily: 'Poppins'),
                      ),
                      onSubmitted: _performSearch,
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onClose,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.close,
                          color: Color.fromARGB(255, 71, 20, 7), size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showSuggestions)
            Expanded(
              child: ListView.builder(
                itemCount: _suggestions.length,
                itemBuilder: (_, i) => ListTile(
                  leading: const Icon(Icons.search, color: Colors.grey),
                  title: Text(_suggestions[i],
                      style: const TextStyle(
                          color: Color.fromARGB(255, 71, 20, 7),
                          fontFamily: 'Poppins',
                          fontSize: 14)),
                  trailing: const Icon(Icons.north_west, color: Colors.grey),
                  onTap: () {
                    _controller.text = _suggestions[i];
                    _performSearch(_suggestions[i]);
                  },
                ),
              ),
            ),
          if (showHistory)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Riwayat Pencarian',
                        style: TextStyle(
                            color: Color.fromARGB(255, 71, 20, 7),
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600)),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _searchHistory.length,
                      itemBuilder: (_, i) => ListTile(
                        leading:
                            const Icon(Icons.access_time, color: Colors.grey),
                        title: Text(_searchHistory[i],
                            style: const TextStyle(
                                color: Color.fromARGB(255, 71, 20, 7),
                                fontFamily: 'Poppins',
                                fontSize: 14)),
                        trailing:
                            const Icon(Icons.north_east, color: Colors.grey),
                        onTap: () {
                          _controller.text = _searchHistory[i];
                          _performSearch(_searchHistory[i]);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (!showHistory && !showSuggestions)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search,
                        size: 64,
                        color: const Color.fromARGB(255, 71, 20, 7)
                            .withValues(alpha: 0.3)),
                    const SizedBox(height: 16),
                    const Text('Mulai ketik untuk mencari',
                        style: TextStyle(
                            color: Color.fromARGB(255, 71, 20, 7),
                            fontFamily: 'Poppins',
                            fontSize: 14)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HeartBtn extends StatelessWidget {
  final int index;
  const _HeartBtn(this.index);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<StoryController>();
    return Obx(() => GestureDetector(
          onTap: () => ctrl.toggleFavorite(index),
          child: Icon(
            ctrl.isFavorite(index) ? Icons.favorite : Icons.favorite_border,
            color: ctrl.isFavorite(index) ? Colors.red : Colors.white,
            size: 22,
          ),
        ));
  }
}

Widget _tag(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14)),
    child: Text(text,
        style: const TextStyle(
            color: Color.fromARGB(255, 71, 20, 7),
            fontSize: 11,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600)),
  );
}
