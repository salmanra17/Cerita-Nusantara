import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../data/story_data.dart';
import '../screens/settings_page.dart';

class RegionPage extends StatefulWidget {
  const RegionPage({super.key});
  @override
  State<RegionPage> createState() => _RegionPageState();
}

class _RegionPageState extends State<RegionPage> {
  bool _searchOpen = false;
  String _searchQuery = '';

  // Icon placeholder per daerah
  IconData _regionIcon(String name) {
    if (name.contains('Jawa')) return Icons.terrain;
    if (name.contains('Sumatera') || name == 'Sunda') return Icons.forest;
    if (name.contains('Kalimantan')) return Icons.park;
    if (name.contains('Sulawesi')) return Icons.waves;
    if (name.contains('Bali')) return Icons.temple_hindu;
    if (name.contains('Nusa')) return Icons.beach_access;
    if (name.contains('Maluku') || name.contains('Papua')) return Icons.water;
    if (name.contains('Jakarta')) return Icons.location_city;
    if (name.contains('Riau')) return Icons.oil_barrel;
    return Icons.map;
  }

  Color _regionColor(String name) {
    if (name.contains('Jawa')) return const Color(0xFF2E6B4F);
    if (name.contains('Sumatera') || name == 'Sunda')
      return const Color(0xFF4A7A3C);
    if (name.contains('Kalimantan')) return const Color(0xFF3D6B2E);
    if (name.contains('Sulawesi')) return const Color(0xFF2B5A3F);
    if (name.contains('Bali')) return const Color(0xFF5C3A1E);
    if (name.contains('Nusa')) return const Color(0xFF2E5A7A);
    if (name.contains('Jakarta')) return const Color(0xFF4A3520);
    if (name.contains('Riau')) return const Color(0xFF6B3A4A);
    return const Color(0xFF3D2B1F);
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<StoryController>();

    if (_searchOpen) {
      return Obx(() => _SearchOverlay(
            regionNames: ctrl.allStories.map((s) => s.region).toSet().toList(),
            onClose: () => setState(() {
              _searchOpen = false;
              _searchQuery = '';
            }),
            onSearch: (query) => setState(() {
              _searchQuery = query.toLowerCase();
              _searchOpen = false;
            }),
          ));
    }

    return Obx(() {
      if (ctrl.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // Hitung jumlah cerita per daerah dari data yang sudah di-fetch
      final regionList = ctrl.allRegions;
      final filtered = _searchQuery.isEmpty
          ? regionList
          : regionList
              .where((e) =>
                  (e['name'] as String).toLowerCase().contains(_searchQuery))
              .toList();

      return Column(
        children: [
          _CustomAppBar(
            title: 'Daerah',
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
            child: filtered.isEmpty
                ? Center(
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
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 14),
                        ...filtered.map((e) => Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              child: GestureDetector(
                                onTap: () => Get.toNamed(
                                    AppRoutes.REGION_DETAIL,
                                    arguments: {'name': e['name']}),
                                child: Column(
                                  children: [
                                    Container(
                                      height: 180,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          color: _regionColor(e['name'])),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Stack(
                                          children: [
                                            // Placeholder icon
                                            e['image_url'] != null
                                                ? Image.network(
                                                    e['image_url'] as String,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (_, __, ___) => Center(
                                                      child: Icon(
                                                        _regionIcon(e['name']
                                                            as String),
                                                        size: 80,
                                                        color: Colors.white
                                                            .withValues(
                                                                alpha: 0.2),
                                                      ),
                                                    ),
                                                  )
                                                : Center(
                                                    child: Icon(
                                                      _regionIcon(
                                                          e['name'] as String),
                                                      size: 80,
                                                      color: Colors.white
                                                          .withValues(
                                                              alpha: 0.2),
                                                    ),
                                                  ),
                                            // Gradient overlay bawah
                                            Positioned(
                                              bottom: 0,
                                              left: 0,
                                              right: 0,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin:
                                                        Alignment.bottomCenter,
                                                    end: Alignment.topCenter,
                                                    colors: [
                                                      Colors.black.withValues(
                                                          alpha: 0.7),
                                                      Colors.transparent,
                                                    ],
                                                  ),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(e['name'] as String,
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 18,
                                                            fontFamily:
                                                                'Poppins',
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700)),
                                                    Text('${e['count']} Cerita',
                                                        style: TextStyle(
                                                            color: Colors.white
                                                                .withValues(
                                                                    alpha: 0.8),
                                                            fontFamily:
                                                                'Poppins',
                                                            fontSize: 13)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
          ),
        ],
      );
    });
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
  final List<String> regionNames;
  final VoidCallback onClose;
  final Function(String) onSearch;
  const _SearchOverlay({
    required this.regionNames,
    required this.onClose,
    required this.onSearch,
  });

  @override
  State<_SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<_SearchOverlay> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _searchHistory = [];
  List<String> _suggestions = [];

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
      _suggestions = widget.regionNames
          .where((r) => r.toLowerCase().contains(query))
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
                        hintText: 'Cari daerah',
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
