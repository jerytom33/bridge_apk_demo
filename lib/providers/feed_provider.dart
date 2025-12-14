import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/post.dart';

class FeedProvider with ChangeNotifier {
  List<Post> _posts = [];
  bool _isLoading = false;
  String? _error;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load posts
  Future<void> loadPosts({
    String? level,
    String? stream,
    String? search,
    String? authorType,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ApiService.getFeedPosts(
        level: level,
        stream: stream,
        search: search,
        authorType: authorType,
      );

      if (result['success']) {
        _posts = (result['data']['data'] as List)
            .map((post) => Post.fromJson(post))
            .toList();
      } else {
        _error = result['error'] ?? 'Failed to load posts';
      }
    } catch (e) {
      _error = 'Load failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle like on a post
  Future<void> toggleLike(int postId) async {
    try {
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        final result = await ApiService.likePost(postId);

        if (result['success']) {
          // Update the post with new like status
          _posts[postIndex] = post.copyWith(
            isLiked: result['data']['is_liked'],
            likeCount: result['data']['like_count'],
          );
          notifyListeners();
        } else {
          _error = result['error'];
        }
      }
    } catch (e) {
      _error = 'Like failed: $e';
      // print('Error toggling like: $e');
    }
  }

  // Toggle save on a post
  Future<void> toggleSave(int postId) async {
    try {
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        final result = await ApiService.savePost(postId);

        if (result['success']) {
          // Update the post with new save status
          _posts[postIndex] = post.copyWith(isSaved: !post.isSaved);
          notifyListeners();
        } else {
          _error = result['error'];
        }
      }
    } catch (e) {
      _error = 'Save failed: $e';
      // print('Error toggling save: $e');
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
