import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../data/story_data.dart';
import 'explore_page.dart';
import 'region_page.dart';
import 'collection_page.dart';
import '../screens/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _idx = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = Get.arguments;
      if (args != null && args is Map && args.containsKey('initialTab')) {
        setState(() => _idx = args['initialTab'] as int);
      }
    });
  }

  void _changeTab(int index) => setState(() => _idx = index);

  @override
  Widget build(BuildContext context) {
    final pages = [
      _BerandaTab(onChangeTab: _changeTab),
      const ExplorePage(),
      const RegionPage(),
      const CollectionPage(),
    ];
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: pages[_idx],
      bottomNavigationBar: _buildNav(),
    );
  }

  Widget _buildNav() {
    final items = [
      {'icon': Icons.home_filled, 'label': 'Beranda'},
      {'icon': Icons.layers, 'label': 'Jelajah'},
      {'icon': Icons.location_on, 'label': 'Daerah'},
      {'icon': Icons.bookmark, 'label': 'Koleksi'},
    ];
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 71, 20, 7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          items.length,
          (i) => GestureDetector(
            onTap: () => setState(() => _idx = i),
            child: SizedBox(
              width: 72,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    items[i]['icon'] as IconData,
                    color: _idx == i
                        ? Colors.white
                        : const Color.fromARGB(255, 228, 204, 194),
                    size: 24,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    items[i]['label'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'Poppins',
                      color: _idx == i
                          ? Colors.white
                          : const Color.fromARGB(255, 228, 204, 194),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================
// TAB: BERANDA
// =============================================
class _BerandaTab extends StatefulWidget {
  final Function(int) onChangeTab;
  const _BerandaTab({required this.onChangeTab});
  @override
  State<_BerandaTab> createState() => _BerandaTabState();
}

class _BerandaTabState extends State<_BerandaTab> {
  final PageController _pc =
      PageController(initialPage: 0, viewportFraction: 1.0);
  int _curPage = 0;
  bool _searchOpen = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<StoryController>();

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

    return Obx(() {
      if (ctrl.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (ctrl.hasError.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 64, color: Color.fromARGB(255, 71, 20, 7)),
              const SizedBox(height: 16),
              const Text('Gagal memuat data',
                  style: TextStyle(fontFamily: 'Poppins')),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: ctrl.fetchStories,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          Container(
            height: 52 + MediaQuery.paddingOf(context).top,
            color: const Color.fromARGB(255, 71, 20, 7),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _searchOpen = true),
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Row(
                            children: [
                              SizedBox(width: 12),
                              Icon(Icons.search,
                                  color: Color.fromARGB(255, 71, 20, 7),
                                  size: 18),
                              SizedBox(width: 6),
                              Text('Cari cerita rakyat',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                      fontFamily: 'Poppins')),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
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
            child: _searchQuery.isNotEmpty
                ? _buildSearchResults(ctrl)
                : _buildMainContent(ctrl),
          ),
        ],
      );
    });
  }

  Widget _buildSearchResults(StoryController ctrl) {
    final results = ctrl.allStories
        .where((s) => s.title.toLowerCase().contains(_searchQuery))
        .toList();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off,
                size: 64, color: Color.fromARGB(255, 71, 20, 7)),
            const SizedBox(height: 16),
            Text('Tidak ada hasil untuk "$_searchQuery"',
                style: const TextStyle(
                    color: Color.fromARGB(255, 71, 20, 7),
                    fontFamily: 'Poppins',
                    fontSize: 16)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => _searchQuery = ''),
              child: const Text('Hapus pencarian',
                  style: TextStyle(
                      color: Color.fromARGB(255, 71, 20, 7),
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      decoration: TextDecoration.underline)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
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
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: results.length,
            itemBuilder: (_, i) {
              final s = results[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.STORY_DETAIL,
                      arguments: {'story': s}),
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
                            child: storyImage(story: s, fit: BoxFit.cover),
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
                                      color:
                                          Colors.white.withValues(alpha: 0.55),
                                      fontFamily: 'Poppins',
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(StoryController ctrl) {
    final displayStories = ctrl.allStories.toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    final display = displayStories.take(8).toList();
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Cerita apa yang populer?',
                style: TextStyle(
                    color: Color.fromARGB(255, 71, 20, 7),
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 8),
          _buildCarousel(display),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              display.length,
              (i) => Container(
                width: _curPage == i ? 18 : 7,
                height: 7,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: _curPage == i
                      ? const Color.fromARGB(255, 71, 20, 7)
                      : const Color.fromARGB(255, 88, 79, 79),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Daerah',
                    style: TextStyle(
                        color: Color.fromARGB(255, 71, 20, 7),
                        fontSize: 15,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700)),
                GestureDetector(
                  onTap: () => widget.onChangeTab(2),
                  child: const Icon(Icons.arrow_forward,
                      color: Color.fromARGB(255, 71, 20, 7), size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildDaerahCarousel(),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Cerita Terfavorit',
                    style: TextStyle(
                        color: Color.fromARGB(255, 71, 20, 7),
                        fontSize: 15,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700)),
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.FAVORIT),
                  child: const Icon(Icons.arrow_forward,
                      color: Color.fromARGB(255, 71, 20, 7), size: 20),
                ),
              ],
            ),
          ),
          _buildFavGrid(ctrl),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildCarousel(List<StoryModel> displayStories) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFF3A5A30)),
            child: PageView.builder(
              controller: _pc,
              onPageChanged: (i) => setState(() => _curPage = i),
              itemCount: displayStories.length,
              itemBuilder: (_, i) {
                final s = displayStories[i];
                return GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.STORY_DETAIL,
                      arguments: {'story': s}),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(color: s.cardColor),
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
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.8),
                                  Colors.transparent
                                ],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(s.title,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w700),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text(s.region,
                                    style: TextStyle(
                                        color:
                                            Colors.white.withValues(alpha: 0.8),
                                        fontSize: 12,
                                        fontFamily: 'Poppins')),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        _arrowBtn(Icons.chevron_left, () {
          if (_curPage > 0)
            _pc.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease);
        }, true),
        _arrowBtn(Icons.chevron_right, () {
          if (_curPage < displayStories.length - 1)
            _pc.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease);
        }, false),
      ],
    );
  }

  Widget _arrowBtn(IconData icon, VoidCallback tap, bool isLeft) {
    return Positioned(
      left: isLeft ? 4 : null,
      right: isLeft ? null : 4,
      top: 0,
      bottom: 0,
      child: Align(
        alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
        child: GestureDetector(
          onTap: tap,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildDaerahCarousel() {
    final ctrl = Get.find<StoryController>();
    return Obx(() {
      final regions = ctrl.allRegions.take(5).toList();
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 71, 20, 7),
            borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: regions.length,
            itemBuilder: (_, i) {
              final d = regions[i];
              return GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.REGION_DETAIL,
                    arguments: {'name': d['name']}),
                child: Container(
                  width: 105,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    children: [
                      Container(
                        width: 86,
                        height: 72,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xFF5A3A20)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: d['image_url'] != null
                              ? Image.network(
                                  d['image_url'] as String,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Center(
                                    child: Icon(Icons.image_outlined,
                                        color:
                                            Colors.white.withValues(alpha: 0.2),
                                        size: 28),
                                  ),
                                )
                              : Center(
                                  child: Icon(Icons.image_outlined,
                                      color:
                                          Colors.white.withValues(alpha: 0.2),
                                      size: 28),
                                ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(d['name'] as String,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text('${d['count']} Cerita',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontFamily: 'Poppins',
                              fontSize: 10)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }

  Widget _buildFavGrid(StoryController ctrl) {
    final stories = ctrl.allStories.take(6).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.72,
        ),
        itemCount: stories.length,
        itemBuilder: (_, i) {
          final s = stories[i];
          return GestureDetector(
            onTap: () =>
                Get.toNamed(AppRoutes.STORY_DETAIL, arguments: {'story': s}),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14), color: s.cardColor),
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
                              Colors.black.withValues(alpha: 0.7),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600)),
                        Text(s.region,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
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
    );
  }
}

// =============================================
// SEARCH OVERLAY
// =============================================
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
                  const Icon(Icons.search, color: AppColors.bgDark, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      style:
                          const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Cari cerita rakyat',
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
                      child:
                          Icon(Icons.close, color: AppColors.bgDark, size: 20),
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
