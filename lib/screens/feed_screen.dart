import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:share_plus/share_plus.dart';
import 'package:like_button/like_button.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final List<Map<String, dynamic>> _posts = [
    {
      'id': 1,
      'title': 'Top 10 Career Paths for Computer Science Graduates',
      'content':
          'The field of computer science offers diverse career opportunities. Here are the top 10 career paths that are in high demand...',
      'author': 'Career Guide',
      'createdAt': '2023-06-15',
      'likeCount': 245,
      'isLiked': false,
      'isSaved': true,
    },
    {
      'id': 2,
      'title': 'How to Prepare for Campus Placements',
      'content':
          'Campus placements are crucial for students. Here are some effective strategies to prepare for campus recruitment...',
      'author': 'Placement Expert',
      'createdAt': '2023-06-10',
      'likeCount': 189,
      'isLiked': true,
      'isSaved': false,
    },
    {
      'id': 3,
      'title': 'Emerging Trends in Artificial Intelligence',
      'content':
          'AI is transforming industries rapidly. Let\'s explore the latest trends and how they impact career opportunities...',
      'author': 'Tech Insights',
      'createdAt': '2023-06-05',
      'likeCount': 320,
      'isLiked': false,
      'isSaved': false,
    },
    {
      'id': 4,
      'title': 'Essential Soft Skills for Professional Success',
      'content':
          'Technical skills alone aren\'t enough. Discover the soft skills that employers value most in candidates...',
      'author': 'HR Advisor',
      'createdAt': '2023-05-28',
      'likeCount': 156,
      'isLiked': false,
      'isSaved': true,
    },
  ];

  bool _isLoading = false;

  Future<void> _refreshFeed() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _onLikeButtonTap(bool isLiked, int postId) async {
    setState(() {
      final index = _posts.indexWhere((post) => post['id'] == postId);
      if (index != -1) {
        _posts[index] = Map<String, dynamic>.from(_posts[index])
          ..['isLiked'] = !isLiked
          ..['likeCount'] = isLiked
              ? _posts[index]['likeCount'] - 1
              : _posts[index]['likeCount'] + 1;
      }
    });
    return !isLiked;
  }

  void _toggleSave(int postId) {
    setState(() {
      final index = _posts.indexWhere((post) => post['id'] == postId);
      if (index != -1) {
        _posts[index] = Map<String, dynamic>.from(_posts[index])
          ..['isSaved'] = !_posts[index]['isSaved'];
      }
    });
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
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
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
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Stay informed with career insights',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              // Posts List
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: SpinKitFadingCircle(
                          color: Color(0xFF6C63FF),
                          size: 40.0,
                        ),
                      )
                    : ListView.separated(
                        itemCount: _posts.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 20),
                        itemBuilder: (context, index) {
                          final post = _posts[index];
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
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
                                          color: const Color(0xFF6C63FF)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Icon(
                                          Icons.person,
                                          color: const Color(0xFF6C63FF),
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              post['author'],
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            Text(
                                              post['createdAt'],
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  // Post Title
                                  Text(
                                    post['title'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  // Post Content
                                  Text(
                                    post['content'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey[800],
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  // Action Buttons
                                  Row(
                                    children: [
                                      // Like Button
                                      LikeButton(
                                        isLiked: post['isLiked'],
                                        likeCount: post['likeCount'],
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
                                        countBuilder: (int? count, bool isLiked,
                                            String text) {
                                          var color = isLiked
                                              ? Colors.red
                                              : Colors.grey;
                                          Widget result;
                                          if (count == 0) {
                                            result = Text(
                                              'Like',
                                              style: GoogleFonts.poppins(
                                                  color: color),
                                            );
                                          } else {
                                            result = Text(
                                              count.toString(),
                                              style: GoogleFonts.poppins(
                                                  color: color),
                                            );
                                          }
                                          return result;
                                        },
                                        onTap: (isLiked) => _onLikeButtonTap(
                                            isLiked, post['id']),
                                      ),
                                      const SizedBox(width: 20),
                                      // Save Button
                                      GestureDetector(
                                        onTap: () => _toggleSave(post['id']),
                                        child: Row(
                                          children: [
                                            Icon(
                                              post['isSaved']
                                                  ? Icons.bookmark
                                                  : Icons.bookmark_border,
                                              color: const Color(0xFF6C63FF),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              'Save',
                                              style: GoogleFonts.poppins(
                                                color: const Color(0xFF6C63FF),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      // Share Button
                                      GestureDetector(
                                        onTap: () => _sharePost(
                                            post['title'], post['content']),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.share,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              'Share',
                                              style: GoogleFonts.poppins(
                                                color: Colors.grey[600],
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
