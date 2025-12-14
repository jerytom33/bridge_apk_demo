import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/post.dart';
import '../services/api_service.dart';

class SavedFeedsScreen extends StatefulWidget {
  const SavedFeedsScreen({super.key});

  @override
  State<SavedFeedsScreen> createState() => _SavedFeedsScreenState();
}

class _SavedFeedsScreenState extends State<SavedFeedsScreen> {
  List<Post> _savedPosts = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSavedPosts();
  }

  Future<void> _loadSavedPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ApiService.getSavedPosts();

      // Debug logging
      print('🔍 Saved Posts API Response:');
      print('Success: ${result['success']}');
      print('Data type: ${result['data'].runtimeType}');
      print('Data: ${result['data']}');

      if (!mounted) return;

      if (result['success']) {
        // Handle different response structures
        List<dynamic> postsData = [];

        if (result['data'] is List) {
          postsData = result['data'] as List<dynamic>;
          print('✅ Data is List, count: ${postsData.length}');
        } else if (result['data'] is Map) {
          final dataMap = result['data'] as Map<String, dynamic>;
          // Check for nested {success: true, data: [...]} structure
          if (dataMap['data'] is List) {
            postsData = dataMap['data'] as List<dynamic>;
            print(
              '✅ Data is nested Map with data array, count: ${postsData.length}',
            );
          } else if (dataMap['posts'] != null) {
            postsData = dataMap['posts'] as List<dynamic>;
            print('✅ Data is Map with posts array, count: ${postsData.length}');
          }
        } else {
          print('❌ Unexpected data structure');
        }

        setState(() {
          _savedPosts = postsData.map((data) => Post.fromJson(data)).toList();
          _isLoading = false;
        });

        print('📊 Loaded ${_savedPosts.length} saved posts');
      } else {
        print('❌ API returned success=false: ${result['error']}');
        setState(() {
          _errorMessage = result['error'] ?? 'Failed to load saved posts';
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('❌ Error loading saved posts: $e');
      print('Stack trace: $stackTrace');
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _unsavePost(int postId) async {
    try {
      // Optimistic UI update
      setState(() {
        _savedPosts.removeWhere((post) => post.id == postId);
      });

      final result = await ApiService.savePost(postId); // Toggle save (unsave)

      if (!result['success']) {
        // Reload if failed
        _loadSavedPosts();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Failed to unsave post'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post unsaved'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      _loadSavedPosts(); // Reload on error
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Saved Feeds',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadSavedPosts,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? _buildErrorState()
            : _savedPosts.isEmpty
            ? _buildEmptyState()
            : _buildSavedPostsList(),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSavedPosts,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Saved Posts',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Posts you save will appear here',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedPostsList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _savedPosts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final post = _savedPosts[index];
        return _buildPostCard(post);
      },
    );
  }

  Widget _buildPostCard(Post post) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              post.title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // Post Image
            if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    post.imageUrl!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
              ),

            // Content
            Text(
              post.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 12),

            // Actions Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Like count
                Row(
                  children: [
                    Icon(
                      post.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: post.isLiked ? Colors.red : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post.likeCount}',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ],
                ),

                // Unsave button
                TextButton.icon(
                  onPressed: () => _unsavePost(post.id),
                  icon: const Icon(Icons.bookmark, color: Color(0xFF6C63FF)),
                  label: const Text('Unsave'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF6C63FF),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
