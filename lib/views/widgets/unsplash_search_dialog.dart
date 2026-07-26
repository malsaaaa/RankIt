import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/unsplash_service.dart';

class UnsplashSearchDialog extends StatefulWidget {
  final String? initialQuery;

  const UnsplashSearchDialog({
    super.key,
    this.initialQuery,
  });

  @override
  State<UnsplashSearchDialog> createState() => _UnsplashSearchDialogState();
}

class _UnsplashSearchDialogState extends State<UnsplashSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  final UnsplashService _unsplashService = UnsplashService();

  List<String> _imageUrls = [];
  bool _isLoading = false;
  bool _isLoadMoreLoading = false;
  int _currentPage = 1;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.trim().isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      _performSearch(widget.initialQuery!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _errorMessage = null;
      _imageUrls = [];
    });

    try {
      final urls = await _unsplashService.searchPhotos(query, page: _currentPage);
      setState(() {
        _imageUrls = urls;
        _isLoading = false;
        if (urls.isEmpty) {
          _errorMessage = "No images found for '$query'. Try another term.";
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Error searching images. Please try again.";
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadMoreLoading || _searchController.text.trim().isEmpty) return;

    setState(() {
      _isLoadMoreLoading = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final urls = await _unsplashService.searchPhotos(_searchController.text, page: nextPage);
      setState(() {
        _imageUrls.addAll(urls);
        _currentPage = nextPage;
        _isLoadMoreLoading = false;
        if (urls.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No more images found.")),
          );
        }
      });
    } catch (e) {
      setState(() {
        _isLoadMoreLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
        decoration: BoxDecoration(
          color: const Color(0xFF161520), // Dark background matching main panel
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            // Dialog Title
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Search Unsplash Photos',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Search Input Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: _searchController,
                autofocus: widget.initialQuery == null,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'e.g., Football, Burger, Tokyo...',
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  prefixIcon: const Icon(Icons.search, color: AppColors.accent),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward, color: AppColors.accent),
                    onPressed: () => _performSearch(_searchController.text),
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onSubmitted: _performSearch,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Search Results Grid Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildContent(),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.error),
        ),
      );
    }

    if (_imageUrls.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.image_outlined, size: 48, color: AppColors.textSecondary),
            SizedBox(height: 12),
            Text(
              'Enter a keyword above to find beautiful\nfree photos from Unsplash.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.4,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final url = _imageUrls[index];
              return GestureDetector(
                onTap: () => Navigator.pop(context, url),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    color: Colors.white.withValues(alpha: 0.05),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.broken_image, color: AppColors.error),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
            childCount: _imageUrls.length,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: _isLoadMoreLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                        strokeWidth: 2,
                      ),
                    )
                  : TextButton.icon(
                      onPressed: _loadMore,
                      icon: const Icon(Icons.refresh, size: 18, color: AppColors.accent),
                      label: const Text(
                        'Load More',
                        style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
