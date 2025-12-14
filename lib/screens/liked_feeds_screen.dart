import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/post.dart';
import '../services/api_service.dart';

class LikedFeedsScreen extends StatefulWidget {
  const LikedFeedsScreen({super.key});

  @override
  State<LikedFeedsScreen> createState() => _LikedFeedsScreenState();
}

class _LikedFeedsScreenState extends State<LikedFeedsScreen> {
  List<Post> _likedPosts = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLikedPosts();
  }

  Future<void> _loadLikedPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ApiService.getLikedPosts();

      // Debug logging
      print('🔍 Liked Posts API Response:');
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
          _likedPosts = postsData.map((data) => Post.fromJson(data)).toList();
          _isLoading = false;
        });

        print('📊 Loaded ${_likedPosts.length} liked posts');
      } else {
        print('❌ API returned success=false: ${result['error']}');
        setState(() {
          _errorMessage = result['error'] ?? 'Failed to load liked posts';
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('❌ Error loading liked posts: $e');
      print('Stack trace: $stackTrace');
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _unlikePost(int postId) async {
    try {
      // Optimistic UI update
      setState(() {
        _likedPosts.removeWhere((post) => post.id == postId);
      });

      final result = await ApiService.likePost(postId); // Toggle like (unlike)

      if (!result['success']) {
        // Reload if failed
        _loadLikedPosts();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Failed to unlike post'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post unliked'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      _loadLikedPosts(); // Reload on error
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
          'Liked Feeds',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadLikedPosts,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? _buildErrorState()
            : _likedPosts.isEmpty
            ? _buildEmptyState()
            : _buildLikedPostsList(),
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
              onPressed: _loadLikedPosts,
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
            Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Liked Posts',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Posts you like will appear here',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLikedPostsList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _likedPosts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final post = _likedPosts[index];
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
                    const Icon(Icons.favorite, color: Colors.red, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${post.likeCount}',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ],
                ),

                // Unlike button
                TextButton.icon(
                  onPressed: () => _unlikePost(post.id),
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  label: const Text('Unlike'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
