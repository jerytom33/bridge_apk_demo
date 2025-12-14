import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:share_plus/share_plus.dart';
import 'package:like_button/like_button.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/post.dart';
import '../services/api_service.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<Post> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.getFeedPosts();

      if (result['success']) {
        final responseData = result['data'];
        // print('Feed API Response: $responseData'); // Debug log

        List<dynamic> listCallback = [];
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            listCallback = responseData['data'] as List;
          } else if (responseData.containsKey('results')) {
            listCallback = responseData['results'] as List;
          } else if (responseData.containsKey('posts')) {
            listCallback = responseData['posts'] as List;
          }
        } else if (responseData is List) {
          listCallback = responseData;
        }

        final posts = listCallback.map((post) => Post.fromJson(post)).toList();

        setState(() {
          _posts = posts;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['error'] ?? 'Failed to load feed')),
          );
        }
      }
    } catch (e) {
      // print('Error loading feed: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshFeed() async {
    await _loadPosts();
  }

  Future<bool> _onLikeButtonTap(bool isLiked, int postId) async {
    // Optimistic update - update UI first
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      setState(() {
        _posts[index] = post.copyWith(
          isLiked: !isLiked,
          likeCount: isLiked ? post.likeCount - 1 : post.likeCount + 1,
        );
      });
    }

    try {
      // Call backend API to sync
      final result = await ApiService.likePost(postId);

      if (result['success']) {
        print('✅ Post $postId like status updated to ${!isLiked}');
        return !isLiked; // Return new state
      } else {
        // Revert on failure
        if (index != -1 && mounted) {
          final post = _posts[index];
          setState(() {
            _posts[index] = post.copyWith(
              isLiked: isLiked,
              likeCount: isLiked ? post.likeCount + 1 : post.likeCount - 1,
            );
          });
        }
        print('❌ Failed to update like: ${result['error']}');
        return isLiked; // Revert
      }
    } catch (e) {
      print('❌ Error liking post: $e');
      // Revert on error
      if (index != -1 && mounted) {
        final post = _posts[index];
        setState(() {
          _posts[index] = post.copyWith(
            isLiked: isLiked,
            likeCount: isLiked ? post.likeCount + 1 : post.likeCount - 1,
          );
        });
      }
      return isLiked; // Revert
    }
  }

  Future<void> _toggleSave(int postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = _posts[index];
    setState(() {
      _posts[index] = post.copyWith(isSaved: !post.isSaved);
    });

    try {
      final result = await ApiService.savePost(
        postId,
      ); // Assuming savePost exists for posts, distinct from courses?
      // FeedProvider uses `ApiService.savePost`.
      if (!result['success']) {
        // Revert
        if (mounted) {
          setState(() {
            _posts[index] = post;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _posts[index] = post;
        });
      }
    }
  }

  void _sharePost(String title, String content) {
    Share.share('$title\n\n$content');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Career Feed',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshFeed,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Latest Updates',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Stay informed with career insights',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: SpinKitFadingCircle(
                          color: Color(0xFF6C63FF),
                          size: 40.0,
                        ),
                      )
                    : _posts.isEmpty
                    ? const Center(child: Text("No feeds available"))
                    : ListView.separated(
                        itemCount: _posts.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final post = _posts[index];
                          return Card(
                            // Inherits CardTheme
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Post Header
                                  Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).primaryColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.person,
                                          color: Theme.of(context).primaryColor,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              post.author,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            Text(
                                              post.createdAt,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: Colors.grey[600],
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // Post Title
                                  Text(
                                    post.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  // Post Image
                                  if (post.imageUrl != null &&
                                      post.imageUrl!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12.0,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          post.imageUrl!,
                                          width: double.infinity,
                                          height: 250,
                                          fit: BoxFit.cover,
                                          loadingBuilder:
                                              (
                                                context,
                                                child,
                                                loadingProgress,
                                              ) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Container(
                                                  height: 250,
                                                  width: double.infinity,
                                                  color: Colors.grey[200],
                                                  child: const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                                );
                                              },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  height: 250,
                                                  width: double.infinity,
                                                  color: Colors.grey[200],
                                                  child: const Icon(
                                                    Icons.broken_image,
                                                    size: 50,
                                                    color: Colors.grey,
                                                  ),
                                                );
                                              },
                                        ),
                                      ),
                                    ),
                                  // Post Content
                                  Text(
                                    post.content,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.grey[800],
                                          height: 1.5,
                                        ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Action Buttons
                                  Row(
                                    children: [
                                      // Like Button
                                      LikeButton(
                                        isLiked: post.isLiked,
                                        likeCount: post.likeCount,
                                        likeBuilder: (bool isLiked) {
                                          return Icon(
                                            isLiked
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: isLiked
                                                ? Colors.red
                                                : Colors.grey,
                                          );
                                        },
                                        countBuilder:
                                            (
                                              int? count,
                                              bool isLiked,
                                              String text,
                                            ) {
                                              var color = isLiked
                                                  ? Colors.red
                                                  : Colors.grey;
                                              return Text(
                                                count == 0
                                                    ? 'Like'
                                                    : count.toString(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: color,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              );
                                            },
                                        onTap: (isLiked) =>
                                            _onLikeButtonTap(isLiked, post.id),
                                      ),
                                      const SizedBox(width: 24),
                                      // Save Button
                                      GestureDetector(
                                        onTap: () => _toggleSave(post.id),
                                        child: Row(
                                          children: [
                                            Icon(
                                              post.isSaved
                                                  ? Icons.bookmark
                                                  : Icons.bookmark_border,
                                              color: Theme.of(
                                                context,
                                              ).primaryColor,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Save',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color: Theme.of(
                                                      context,
                                                    ).primaryColor,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      // Share Button
                                      GestureDetector(
                                        onTap: () => _sharePost(
                                          post.title,
                                          post.content,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.share,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Share',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color: Colors.grey[600],
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
