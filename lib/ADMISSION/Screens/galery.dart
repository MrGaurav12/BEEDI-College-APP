import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// ──────────────────────────────────────────────────────────────
//  MODEL
// ──────────────────────────────────────────────────────────────
class PexelsPhoto {
  final int id;
  final String photographer;
  final String photographerUrl;
  final String alt;
  final Map<String, dynamic> src;
  final int width;
  final int height;
  final String avgColor;

  PexelsPhoto({
    required this.id,
    required this.photographer,
    required this.photographerUrl,
    required this.alt,
    required this.src,
    required this.width,
    required this.height,
    required this.avgColor,
  });

  factory PexelsPhoto.fromJson(Map<String, dynamic> json) => PexelsPhoto(
        id: json['id'],
        photographer: json['photographer'] ?? '',
        photographerUrl: json['photographer_url'] ?? '',
        alt: json['alt'] ?? '',
        src: Map<String, dynamic>.from(json['src'] ?? {}),
        width: json['width'] ?? 0,
        height: json['height'] ?? 0,
        avgColor: json['avg_color'] ?? '#000000',
      );

  double get aspectRatio => height > 0 ? width / height : 1.0;
}

// ──────────────────────────────────────────────────────────────
//  ENUMS
// ──────────────────────────────────────────────────────────────
enum GridLayout { compact, comfortable, masonry }

enum SortOrder { latest, popular, alphabetical }

// ──────────────────────────────────────────────────────────────
//  MAIN SCREEN
// ──────────────────────────────────────────────────────────────
class PexelsHomeScreen extends StatefulWidget {
  const PexelsHomeScreen({super.key});

  @override
  State<PexelsHomeScreen> createState() => _PexelsHomeScreenState();
}

class _PexelsHomeScreenState extends State<PexelsHomeScreen>
    with TickerProviderStateMixin {
  // Controllers
  final TextEditingController _searchController =
      TextEditingController(text: 'nature');
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fabAnimController;

  // API
  final String _apiKey =
      'QOeH3tmmfXydEjXC4dWAj6B4k0XuQkMVy6A3meWFeemwKFXaqFw5sOfh';

  // State
  List<PexelsPhoto> _photos = [];
  List<PexelsPhoto> _favourites = [];
  List<PexelsPhoto> _selectedPhotos = [];
  List<String> _searchHistory = [];

  bool _isLoading = false;
  bool _isFetchingMore = false;
  bool _isDarkMode = true;
  bool _isSelectionMode = false;
  bool _showFab = false;
  bool _showSearchSuggestions = false;

  int _currentPage = 1;
  int _totalResults = 0;

  GridLayout _gridLayout = GridLayout.comfortable;
  SortOrder _sortOrder = SortOrder.latest;
  String _activeCategory = 'All';
  String _colorFilter = 'Any';

  final List<String> _categories = [
    'All', 'Nature', 'City', 'People', 'Animals',
    'Food', 'Travel', 'Architecture', 'Technology', 'Fashion',
  ];

  final List<String> _colorFilters = [
    'Any', 'Red', 'Orange', 'Yellow', 'Green',
    'Turquoise', 'Blue', 'Violet', 'Pink', 'Brown', 'Black', 'White',
  ];

  // ── Lifecycle ──────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _scrollController.addListener(_onScroll);
    _searchPhotos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _fabAnimController.dispose();
    super.dispose();
  }

  // ── Scroll ─────────────────────────────────────────────────
  void _onScroll() {
    final showFab = _scrollController.offset > 300;
    if (showFab != _showFab) {
      setState(() => _showFab = showFab);
      showFab ? _fabAnimController.forward() : _fabAnimController.reverse();
    }
    // Feature 1 – Infinite scroll / load more
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 400 &&
        !_isFetchingMore &&
        !_isLoading) {
      _loadMorePhotos();
    }
  }

  // ── API calls ──────────────────────────────────────────────
  Future<void> _searchPhotos({bool append = false}) async {
    if (!append) {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
        _photos = [];
      });
    }

    final query = _activeCategory == 'All'
        ? _searchController.text.trim()
        : _activeCategory;

    final colorParam =
        _colorFilter == 'Any' ? '' : '&color=${_colorFilter.toLowerCase()}';

    final url = Uri.parse(
      'https://api.pexels.com/v1/search?query=$query&per_page=30&page=$_currentPage$colorParam',
    );

    try {
      final response = await http.get(url, headers: {'Authorization': _apiKey});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newPhotos = (data['photos'] as List)
            .map((p) => PexelsPhoto.fromJson(p))
            .toList();

        _addToHistory(_searchController.text.trim());

        setState(() {
          _totalResults = data['total_results'] ?? 0;
          if (append) {
            _photos.addAll(newPhotos);
          } else {
            _photos = newPhotos;
          }
          _applySortOrder();
        });
      } else {
        _showSnack('API Error: ${response.statusCode}', isError: true);
      }
    } catch (e) {
      _showSnack('Connection error: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
        _isFetchingMore = false;
      });
    }
  }

  Future<void> _loadMorePhotos() async {
    if (_isFetchingMore) return;
    setState(() {
      _isFetchingMore = true;
      _currentPage++;
    });
    await _searchPhotos(append: true);
  }

  // Feature 2 – Curated feed
  Future<void> _loadCurated() async {
    setState(() => _isLoading = true);
    final url = Uri.parse('https://api.pexels.com/v1/curated?per_page=30');
    try {
      final response = await http.get(url, headers: {'Authorization': _apiKey});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _photos = (data['photos'] as List)
              .map((p) => PexelsPhoto.fromJson(p))
              .toList();
          _totalResults = data['total_results'] ?? 0;
        });
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  // ── Helpers ────────────────────────────────────────────────
  void _addToHistory(String query) {
    if (query.isEmpty) return;
    setState(() {
      _searchHistory.remove(query);
      _searchHistory.insert(0, query);
      if (_searchHistory.length > 10) _searchHistory.removeLast();
    });
  }

  void _applySortOrder() {
    switch (_sortOrder) {
      case SortOrder.alphabetical:
        _photos.sort((a, b) => a.photographer.compareTo(b.photographer));
        break;
      case SortOrder.popular:
        _photos.sort((a, b) => (b.width * b.height) - (a.width * a.height));
        break;
      case SortOrder.latest:
        break;
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Feature 3 – Download single image
  Future<void> _downloadImage(String imageUrl, {String? fileName}) async {
    if (kIsWeb) {
      _showSnack('Download not supported on web');
      return;
    }
    try {
      _showSnack('Downloading…');
      final dir = await getApplicationDocumentsDirectory();
      final name = fileName ?? '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '${dir.path}/$name';
      await Dio().download(imageUrl, path);
      _showSnack('Saved: $path');
    } catch (e) {
      _showSnack('Download failed: $e', isError: true);
    }
  }

  // Feature 4 – Batch download selected
  Future<void> _batchDownload() async {
    if (_selectedPhotos.isEmpty) return;
    _showSnack('Downloading ${_selectedPhotos.length} photos…');
    for (final photo in _selectedPhotos) {
      await _downloadImage(photo.src['original'] ?? '',
          fileName: 'pexels_${photo.id}.jpg');
    }
    _exitSelectionMode();
  }

  // Feature 5 – Toggle favourite
  void _toggleFavourite(PexelsPhoto photo) {
    setState(() {
      if (_favourites.any((f) => f.id == photo.id)) {
        _favourites.removeWhere((f) => f.id == photo.id);
        _showSnack('Removed from favourites');
      } else {
        _favourites.add(photo);
        _showSnack('Added to favourites ❤️');
      }
    });
  }

  bool _isFavourite(PexelsPhoto photo) =>
      _favourites.any((f) => f.id == photo.id);

  // Feature 6 – Share image URL
  Future<void> _sharePhoto(PexelsPhoto photo) async {
    await Share.share(
      '${photo.alt}\nPhoto by ${photo.photographer}\n${photo.src['large'] ?? ''}',
      subject: 'Check out this Pexels photo!',
    );
  }

  // Feature 7 – Copy link to clipboard
  void _copyLink(PexelsPhoto photo) {
    Clipboard.setData(ClipboardData(text: photo.src['original'] ?? ''));
    _showSnack('Link copied to clipboard 📋');
  }

  // Feature 8 – Toggle selection mode
  void _toggleSelection(PexelsPhoto photo) {
    setState(() {
      if (_selectedPhotos.any((p) => p.id == photo.id)) {
        _selectedPhotos.removeWhere((p) => p.id == photo.id);
      } else {
        _selectedPhotos.add(photo);
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedPhotos.clear();
    });
  }

  // Feature 9 – Select all
  void _selectAll() => setState(() => _selectedPhotos = List.from(_photos));

  // ── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = _isDarkMode ? _darkTheme() : _lightTheme();

    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: _buildAppBar(theme),
        body: Column(
          children: [
            _buildSearchBar(theme),
            _buildCategoryChips(theme),
            _buildFilterRow(theme),
            _buildStatsBar(theme),
            Expanded(child: _buildBody(theme)),
          ],
        ),
        floatingActionButton: _buildFABs(theme),
        bottomNavigationBar:
            _isSelectionMode ? _buildSelectionBar(theme) : null,
        drawer: _buildDrawer(theme),
      ),
    );
  }

  // ── App Bar ────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: theme.appBarTheme.backgroundColor,
      elevation: 0,
      title: _isSelectionMode
          ? Text('${_selectedPhotos.length} selected',
              style: const TextStyle(fontWeight: FontWeight.bold))
          : const Text('BEEDI College GALLERY',
              style: TextStyle(
                  fontWeight: FontWeight.w900, letterSpacing: 2)),
      actions: [
        if (_isSelectionMode) ...[
          IconButton(
              icon: const Icon(Icons.select_all),
              tooltip: 'Select All',
              onPressed: _selectAll),
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: _exitSelectionMode),
        ] else ...[
          // Feature 10 – Grid layout toggle
          PopupMenuButton<GridLayout>(
            icon: Icon(_gridIcon()),
            tooltip: 'Grid Layout',
            onSelected: (v) => setState(() => _gridLayout = v),
            itemBuilder: (_) => const [
              PopupMenuItem(
                  value: GridLayout.compact,
                  child: ListTile(
                      leading: Icon(Icons.grid_on),
                      title: Text('Compact'))),
              PopupMenuItem(
                  value: GridLayout.comfortable,
                  child: ListTile(
                      leading: Icon(Icons.grid_view),
                      title: Text('Comfortable'))),
              PopupMenuItem(
                  value: GridLayout.masonry,
                  child: ListTile(
                      leading: Icon(Icons.view_quilt),
                      title: Text('Masonry'))),
            ],
          ),
          // Feature 11 – Dark/light theme toggle
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                  _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  key: ValueKey(_isDarkMode)),
            ),
            onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
            tooltip: 'Toggle Theme',
          ),
          // Feature 12 – Favourites view badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.favorite),
                onPressed: _showFavouritesSheet,
                tooltip: 'Favourites',
              ),
              if (_favourites.isNotEmpty)
                Positioned(
                  right: 6,
                  top: 6,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.red,
                    child: Text('${_favourites.length}',
                        style: const TextStyle(
                            fontSize: 10, color: Colors.white)),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  IconData _gridIcon() {
    switch (_gridLayout) {
      case GridLayout.compact:
        return Icons.grid_on;
      case GridLayout.comfortable:
        return Icons.grid_view;
      case GridLayout.masonry:
        return Icons.view_quilt;
    }
  }

  // ── Search Bar ─────────────────────────────────────────────
  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style:
                      TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Search photos…',
                    hintStyle: TextStyle(
                        color: theme.colorScheme.onSurface
                            .withOpacity(0.5)),
                    prefixIcon: const Icon(Icons.search),
                    // Feature 13 – Clear search button
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            })
                        : null,
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (_) =>
                      setState(() => _showSearchSuggestions = true),
                  onSubmitted: (_) {
                    setState(() => _showSearchSuggestions = false);
                    _searchPhotos();
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _showSearchSuggestions = false);
                  _searchPhotos();
                },
                icon: const Icon(Icons.search, size: 18),
                label: const Text('Search'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
          // Feature 14 – Search history suggestions
          if (_showSearchSuggestions && _searchHistory.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8)
                ],
              ),
              child: Column(
                children: _searchHistory
                    .take(5)
                    .map((h) => ListTile(
                          dense: true,
                          leading: const Icon(Icons.history, size: 18),
                          title: Text(h,
                              style: TextStyle(
                                  color: theme.colorScheme.onSurface)),
                          onTap: () {
                            _searchController.text = h;
                            setState(
                                () => _showSearchSuggestions = false);
                            _searchPhotos();
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.north_west,
                                size: 16),
                            onPressed: () =>
                                setState(() => _searchController.text = h),
                          ),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  // ── Category Chips ─────────────────────────────────────────
  // Feature 15 – Category filtering
  Widget _buildCategoryChips(ThemeData theme) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = _categories[i];
          final active = _activeCategory == cat;
          return FilterChip(
            label: Text(cat),
            selected: active,
            onSelected: (_) {
              setState(() => _activeCategory = cat);
              if (cat != 'All') _searchController.text = cat;
              _searchPhotos();
            },
          );
        },
      ),
    );
  }

  // ── Filter Row ─────────────────────────────────────────────
  Widget _buildFilterRow(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // Feature 16 – Sort order
          _FilterDropdown<SortOrder>(
            label: 'Sort',
            icon: Icons.sort,
            value: _sortOrder,
            items: const {
              SortOrder.latest: 'Latest',
              SortOrder.popular: 'Popular',
              SortOrder.alphabetical: 'A–Z',
            },
            onChanged: (v) {
              setState(() => _sortOrder = v!);
              _applySortOrder();
            },
            theme: theme,
          ),
          const SizedBox(width: 8),
          // Feature 17 – Color filter
          _FilterDropdown<String>(
            label: 'Color',
            icon: Icons.palette,
            value: _colorFilter,
            items: {for (final c in _colorFilters) c: c},
            onChanged: (v) {
              setState(() => _colorFilter = v!);
              _searchPhotos();
            },
            theme: theme,
          ),
          const SizedBox(width: 8),
          // Feature 18 – Curated feed
          ActionChip(
            avatar: const Icon(Icons.auto_awesome, size: 16),
            label: const Text('Curated'),
            onPressed: _loadCurated,
          ),
          const SizedBox(width: 8),
          // Feature 19 – Refresh
          ActionChip(
            avatar: const Icon(Icons.refresh, size: 16),
            label: const Text('Refresh'),
            onPressed: _searchPhotos,
          ),
        ],
      ),
    );
  }

  // ── Stats Bar ──────────────────────────────────────────────
  Widget _buildStatsBar(ThemeData theme) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        children: [
          Text(
            _totalResults > 0
                ? '${_formatNumber(_totalResults)} results · ${_photos.length} loaded'
                : '',
            style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onBackground
                    .withOpacity(0.55)),
          ),
          const Spacer(),
          if (_isFetchingMore)
            const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2)),
        ],
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  // ── Body ───────────────────────────────────────────────────
  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text('Fetching photos…',
                style: TextStyle(
                    color: theme.colorScheme.onBackground
                        .withOpacity(0.6))),
          ],
        ),
      );
    }

    if (_photos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_not_supported_outlined,
                size: 64,
                color:
                    theme.colorScheme.onBackground.withOpacity(0.3)),
            const SizedBox(height: 12),
            Text('No photos found',
                style: TextStyle(
                    fontSize: 18,
                    color: theme.colorScheme.onBackground
                        .withOpacity(0.5))),
            const SizedBox(height: 8),
            ElevatedButton(
                onPressed: _searchPhotos,
                child: const Text('Retry')),
          ],
        ),
      );
    }

    return _gridLayout == GridLayout.masonry
        ? _buildMasonryGrid(theme)
        : _buildRegularGrid(theme);
  }

  // ── Regular Grid ───────────────────────────────────────────
  Widget _buildRegularGrid(ThemeData theme) {
    final width = MediaQuery.of(context).size.width;
    final cols = _gridLayout == GridLayout.compact
        ? _compactCols(width)
        : _comfyCols(width);

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      itemCount: _photos.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.7,
      ),
      itemBuilder: (_, i) => _PhotoCard(
        photo: _photos[i],
        isFavourite: _isFavourite(_photos[i]),
        isSelected: _selectedPhotos.any((p) => p.id == _photos[i].id),
        isSelectionMode: _isSelectionMode,
        isDarkMode: _isDarkMode,
        onFavourite: () => _toggleFavourite(_photos[i]),
        onDownload: () =>
            _downloadImage(_photos[i].src['original'] ?? ''),
        onShare: () => _sharePhoto(_photos[i]),
        onCopy: () => _copyLink(_photos[i]),
        onTap: () => _isSelectionMode
            ? _toggleSelection(_photos[i])
            : _openDetail(_photos[i]),
        onLongPress: () {
          setState(() => _isSelectionMode = true);
          _toggleSelection(_photos[i]);
        },
      ),
    );
  }

  // ── Masonry Grid ───────────────────────────────────────────
  // Feature 20 – Masonry layout
  Widget _buildMasonryGrid(ThemeData theme) {
    final width = MediaQuery.of(context).size.width;
    final cols = _comfyCols(width);

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      child: LayoutBuilder(builder: (ctx, constraints) {
        final colWidth =
            (constraints.maxWidth - 8 * (cols - 1)) / cols;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(cols, (col) {
            final colPhotos = <PexelsPhoto>[];
            for (int i = col; i < _photos.length; i += cols) {
              colPhotos.add(_photos[i]);
            }
            return SizedBox(
              width: colWidth,
              child: Column(
                children: colPhotos
                    .map((photo) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: 8),
                          child: AspectRatio(
                            aspectRatio:
                                photo.aspectRatio.clamp(0.5, 1.5),
                            child: _PhotoCard(
                              photo: photo,
                              isFavourite: _isFavourite(photo),
                              isSelected: _selectedPhotos
                                  .any((p) => p.id == photo.id),
                              isSelectionMode: _isSelectionMode,
                              isDarkMode: _isDarkMode,
                              onFavourite: () =>
                                  _toggleFavourite(photo),
                              onDownload: () => _downloadImage(
                                  photo.src['original'] ?? ''),
                              onShare: () => _sharePhoto(photo),
                              onCopy: () => _copyLink(photo),
                              onTap: () => _isSelectionMode
                                  ? _toggleSelection(photo)
                                  : _openDetail(photo),
                              onLongPress: () {
                                setState(
                                    () => _isSelectionMode = true);
                                _toggleSelection(photo);
                              },
                            ),
                          ),
                        ))
                    .toList(),
              ),
            );
          })
              .expand((w) => [
                    w,
                    if (w != cols - 1) const SizedBox(width: 8)
                  ])
              .toList(),
        );
      }),
    );
  }

  int _comfyCols(double w) {
    if (w > 1200) return 5;
    if (w > 900) return 4;
    if (w > 600) return 3;
    return 2;
  }

  int _compactCols(double w) {
    if (w > 1200) return 8;
    if (w > 900) return 6;
    if (w > 600) return 4;
    return 3;
  }

  // ── FABs ───────────────────────────────────────────────────
  Widget _buildFABs(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Feature 21 – Scroll to top FAB
        ScaleTransition(
          scale: _fabAnimController,
          child: FloatingActionButton.small(
            heroTag: 'top',
            tooltip: 'Scroll to top',
            onPressed: () => _scrollController.animateTo(0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut),
            child: const Icon(Icons.arrow_upward),
          ),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.extended(
          heroTag: 'reload',
          onPressed: _searchPhotos,
          icon: const Icon(Icons.refresh),
          label: const Text('Reload'),
        ),
      ],
    );
  }

  // ── Selection Bottom Bar ────────────────────────────────────
  Widget _buildSelectionBar(ThemeData theme) {
    return SafeArea(
      child: Container(
        height: 60,
        color: theme.colorScheme.surface,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Download All'),
              onPressed: _batchDownload,
            ),
            TextButton.icon(
              icon: const Icon(Icons.favorite),
              label: const Text('Fav All'),
              onPressed: () {
                for (final p in _selectedPhotos) {
                  if (!_isFavourite(p)) _toggleFavourite(p);
                }
                _exitSelectionMode();
              },
            ),
            TextButton.icon(
              icon: const Icon(Icons.close),
              label: const Text('Cancel'),
              onPressed: _exitSelectionMode,
            ),
          ],
        ),
      ),
    );
  }

  // ── Drawer ─────────────────────────────────────────────────
  Widget _buildDrawer(ThemeData theme) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration:
                BoxDecoration(color: theme.colorScheme.primary),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.photo_library, color: Colors.white, size: 40),
                SizedBox(height: 8),
                Text('Pexels Gallery',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                Text('v2.0 · 20+ Features',
                    style:
                        TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          // Feature 22 – Search history management from drawer
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Search History'),
            subtitle: Text('${_searchHistory.length} items'),
            onTap: () {
              Navigator.pop(context);
              _showHistorySheet();
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favourites'),
            subtitle: Text('${_favourites.length} photos'),
            onTap: () {
              Navigator.pop(context);
              _showFavouritesSheet();
            },
          ),
          const Divider(),
          // Feature 23 – Clear history
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Clear History'),
            onTap: () {
              setState(() => _searchHistory.clear());
              Navigator.pop(context);
              _showSnack('History cleared');
            },
          ),
          // Feature 24 – About dialog
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'Pexels Gallery',
              applicationVersion: '2.0.0',
              applicationLegalese: 'Photos provided by Pexels API',
            ),
          ),
        ],
      ),
    );
  }

  // ── Sheets ─────────────────────────────────────────────────
  // Feature 25 – Favourites bottom sheet
  void _showFavouritesSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.95,
        minChildSize: 0.3,
        expand: false,
        builder: (_, ctrl) => Column(
          children: [
            const _SheetHandle(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('Favourites',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text('${_favourites.length} photos',
                      style:
                          const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            Expanded(
              child: _favourites.isEmpty
                  ? const Center(
                      child: Text('No favourites yet ❤️'))
                  : GridView.builder(
                      controller: ctrl,
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 0.75),
                      itemCount: _favourites.length,
                      itemBuilder: (_, i) => _PhotoCard(
                        photo: _favourites[i],
                        isFavourite: true,
                        isSelected: false,
                        isSelectionMode: false,
                        isDarkMode: _isDarkMode,
                        onFavourite: () {
                          _toggleFavourite(_favourites[i]);
                          Navigator.pop(context);
                        },
                        onDownload: () => _downloadImage(
                            _favourites[i].src['original'] ?? ''),
                        onShare: () =>
                            _sharePhoto(_favourites[i]),
                        onCopy: () => _copyLink(_favourites[i]),
                        onTap: () => _openDetail(_favourites[i]),
                        onLongPress: () {},
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Feature 26 – History bottom sheet
  void _showHistorySheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocalState) => Column(
          children: [
            const _SheetHandle(),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Search History',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: _searchHistory.isEmpty
                  ? const Center(child: Text('No history yet'))
                  : ListView.builder(
                      itemCount: _searchHistory.length,
                      itemBuilder: (_, i) => ListTile(
                        leading: const Icon(Icons.history),
                        title: Text(_searchHistory[i]),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            setState(() =>
                                _searchHistory.removeAt(i));
                            setLocalState(() {});
                          },
                        ),
                        onTap: () {
                          _searchController.text =
                              _searchHistory[i];
                          Navigator.pop(context);
                          _searchPhotos();
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Feature 27 – Full-screen detail view with zoom
  void _openDetail(PexelsPhoto photo) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => FadeTransition(
          opacity: anim,
          child: _PhotoDetailScreen(
            photo: photo,
            isFavourite: _isFavourite(photo),
            isDarkMode: _isDarkMode,
            onFavourite: () => _toggleFavourite(photo),
            onDownload: () =>
                _downloadImage(photo.src['original'] ?? ''),
            onShare: () => _sharePhoto(photo),
            onCopy: () => _copyLink(photo),
          ),
        ),
      ),
    );
  }

  // ── Themes ─────────────────────────────────────────────────
  ThemeData _darkTheme() => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF38BDF8),
          secondary: Color(0xFF818CF8),
          surface: Color(0xFF1E293B),
          background: Color(0xFF0F172A),
          onBackground: Colors.white,
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F172A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFF1E293B),
          selectedColor: const Color(0xFF38BDF8),
          labelStyle: const TextStyle(color: Colors.white),
          secondaryLabelStyle: const TextStyle(color: Colors.black),
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF38BDF8),
            foregroundColor: Colors.black,
          ),
        ),
        popupMenuTheme: const PopupMenuThemeData(
            color: Color(0xFF1E293B)),
      );

  ThemeData _lightTheme() => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0284C7),
          secondary: Color(0xFF6366F1),
          surface: Colors.white,
          background: Color(0xFFF8FAFC),
          onBackground: Colors.black,
          onSurface: Colors.black,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFE2E8F0),
          selectedColor: const Color(0xFF0284C7),
          labelStyle: const TextStyle(color: Colors.black87),
          secondaryLabelStyle: const TextStyle(color: Colors.white),
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0284C7),
            foregroundColor: Colors.white,
          ),
        ),
      );
}

// ──────────────────────────────────────────────────────────────
//  FILTER DROPDOWN
// ──────────────────────────────────────────────────────────────
class _FilterDropdown<T> extends StatelessWidget {
  final String label;
  final IconData icon;
  final T value;
  final Map<T, String> items;
  final ValueChanged<T?> onChanged;
  final ThemeData theme;

  const _FilterDropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: theme.colorScheme.onSurface.withOpacity(0.15)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isDense: true,
          icon: const Icon(Icons.expand_more, size: 18),
          style: TextStyle(
              color: theme.colorScheme.onSurface, fontSize: 13),
          items: items.entries
              .map((e) => DropdownMenuItem<T>(
                  value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
//  PHOTO CARD
// ──────────────────────────────────────────────────────────────
class _PhotoCard extends StatefulWidget {
  final PexelsPhoto photo;
  final bool isFavourite;
  final bool isSelected;
  final bool isSelectionMode;
  final bool isDarkMode;
  final VoidCallback onFavourite;
  final VoidCallback onDownload;
  final VoidCallback onShare;
  final VoidCallback onCopy;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _PhotoCard({
    required this.photo,
    required this.isFavourite,
    required this.isSelected,
    required this.isSelectionMode,
    required this.isDarkMode,
    required this.onFavourite,
    required this.onDownload,
    required this.onShare,
    required this.onCopy,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<_PhotoCard> createState() => _PhotoCardState();
}

class _PhotoCardState extends State<_PhotoCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: widget.isSelected
                ? Border.all(color: Colors.blue, width: 3)
                : null,
            boxShadow: _hovering
                ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6))
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Network image with avg_color placeholder
                Image.network(
                  widget.photo.src['medium'] ?? '',
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: _hexColor(widget.photo.avgColor),
                      child: const Center(
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white54)),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[800],
                    child: const Icon(Icons.broken_image,
                        color: Colors.white38, size: 40),
                  ),
                ),
                // Bottom gradient overlay
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.center,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                ),
                // Selection overlay
                if (widget.isSelected)
                  Container(
                    color: Colors.blue.withOpacity(0.3),
                    child: const Center(
                      child: Icon(Icons.check_circle,
                          color: Colors.blue, size: 40),
                    ),
                  ),
                // Action buttons
                Positioned(
                  top: 8,
                  right: 8,
                  child: Column(
                    children: [
                      _CircleBtn(
                        icon: widget.isFavourite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: widget.isFavourite
                            ? Colors.red
                            : Colors.white,
                        onTap: widget.onFavourite,
                        tooltip: 'Favourite',
                      ),
                      const SizedBox(height: 6),
                      _CircleBtn(
                        icon: Icons.download,
                        onTap: widget.onDownload,
                        tooltip: 'Download',
                      ),
                      const SizedBox(height: 6),
                      _CircleBtn(
                        icon: Icons.share,
                        onTap: widget.onShare,
                        tooltip: 'Share',
                      ),
                      const SizedBox(height: 6),
                      _CircleBtn(
                        icon: Icons.link,
                        onTap: widget.onCopy,
                        tooltip: 'Copy link',
                      ),
                    ],
                  ),
                ),
                // Photographer info
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 56,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.photo.photographer,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                      if (widget.photo.alt.isNotEmpty)
                        Text(
                          widget.photo.alt,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
//  CIRCLE BUTTON
// ──────────────────────────────────────────────────────────────
class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String tooltip;

  const _CircleBtn({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: CircleAvatar(
          radius: 16,
          backgroundColor: Colors.black54,
          child: Icon(icon, color: color, size: 16),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
//  PHOTO DETAIL SCREEN  (Feature 27)
// ──────────────────────────────────────────────────────────────
class _PhotoDetailScreen extends StatelessWidget {
  final PexelsPhoto photo;
  final bool isFavourite;
  final bool isDarkMode;
  final VoidCallback onFavourite;
  final VoidCallback onDownload;
  final VoidCallback onShare;
  final VoidCallback onCopy;

  const _PhotoDetailScreen({
    required this.photo,
    required this.isFavourite,
    required this.isDarkMode,
    required this.onFavourite,
    required this.onDownload,
    required this.onShare,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
                isFavourite ? Icons.favorite : Icons.favorite_border,
                color: isFavourite ? Colors.red : Colors.white),
            onPressed: () {
              onFavourite();
              Navigator.pop(context);
            },
          ),
          IconButton(
              icon: const Icon(Icons.download, color: Colors.white),
              onPressed: onDownload),
          IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: onShare),
          IconButton(
              icon: const Icon(Icons.link, color: Colors.white),
              onPressed: onCopy),
        ],
      ),
      body: Column(
        children: [
          // Feature 28 – Pinch-to-zoom with InteractiveViewer
          Expanded(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 5.0,
              child: Center(
                child: Image.network(
                  photo.src['large2x'] ?? photo.src['large'] ?? '',
                  fit: BoxFit.contain,
                  loadingBuilder: (_, child, prog) {
                    if (prog == null) return child;
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            value: prog.expectedTotalBytes != null
                                ? prog.cumulativeBytesLoaded /
                                    prog.expectedTotalBytes!
                                : null,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 12),
                          const Text('Loading full resolution…',
                              style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          // Photo metadata panel
          Container(
            color: const Color(0xFF1E1E1E),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(photo.photographer,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                const SizedBox(height: 4),
                if (photo.alt.isNotEmpty)
                  Text(photo.alt,
                      style:
                          const TextStyle(color: Colors.white60)),
                const SizedBox(height: 8),
                // Feature 29 – Photo metadata (dimensions + avg color)
                Row(
                  children: [
                    _InfoChip(
                        label: '${photo.width}×${photo.height}'),
                    const SizedBox(width: 8),
                    _InfoChip(label: photo.avgColor),
                    const Spacer(),
                    Tooltip(
                      message: 'Average color: ${photo.avgColor}',
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _hexColor(photo.avgColor),
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.white30),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip({required this.label});
  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(20)),
        child: Text(label,
            style:
                const TextStyle(color: Colors.white70, fontSize: 12)),
      );
}

// ──────────────────────────────────────────────────────────────
//  SHEET HANDLE
// ──────────────────────────────────────────────────────────────
class _SheetHandle extends StatelessWidget {
  const _SheetHandle();
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(top: 12, bottom: 4),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(2)),
      );
}

// ──────────────────────────────────────────────────────────────
//  UTILITY
// ──────────────────────────────────────────────────────────────
Color _hexColor(String hex) {
  try {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  } catch (_) {
    return Colors.grey;
  }
}