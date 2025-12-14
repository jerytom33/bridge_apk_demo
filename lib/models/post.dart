import 'package:json_annotation/json_annotation.dart';

part 'post.g.dart';

@JsonSerializable(createFactory: false)
class Post {
  final int id;
  final String title;
  final String content;
  final String author;
  final String createdAt;
  final int likeCount;
  final bool isLiked;
  final bool isSaved;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.createdAt,
    required this.likeCount,
    required this.isLiked,
    required this.isSaved,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      author: (json['author'] is Map)
          ? (json['author']['username'] ?? json['author']['name'] ?? 'Unknown')
                .toString()
          : json['author']?.toString() ?? '',
      createdAt: json['created_at'] ?? '',
      likeCount: int.tryParse(json['like_count']?.toString() ?? '') ?? 0,
      isLiked: json['is_liked'] ?? false,
      isSaved: json['is_saved'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => _$PostToJson(this);

  Post copyWith({
    int? id,
    String? title,
    String? content,
    String? author,
    String? createdAt,
    int? likeCount,
    bool? isLiked,
    bool? isSaved,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}
