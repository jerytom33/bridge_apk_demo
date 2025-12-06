class Post {
  final String id;
  final String title;
  final String content;
  final String author;
  final String authorType; // Guide or Company
  final String date;
  final int likes;
  final int shares;
  bool isSaved; // Make this non-final so it can be toggled
  final String category; // Career, Education, Industry News, etc.
  final String imageUrl; // Optional image URL

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.authorType,
    required this.date,
    required this.likes,
    required this.shares,
    required this.isSaved,
    required this.category,
    required this.imageUrl,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      author: json['author'] ?? '',
      authorType: json['author_type'] ?? '',
      date: json['date'] ?? '',
      likes: json['likes'] ?? 0,
      shares: json['shares'] ?? 0,
      isSaved: json['is_saved'] ?? false,
      category: json['category'] ?? '',
      imageUrl: json['image_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author': author,
      'author_type': authorType,
      'date': date,
      'likes': likes,
      'shares': shares,
      'is_saved': isSaved,
      'category': category,
      'image_url': imageUrl,
    };
  }

  Post copyWith({
    String? id,
    String? title,
    String? content,
    String? author,
    String? authorType,
    String? date,
    int? likes,
    int? shares,
    bool? isSaved,
    String? category,
    String? imageUrl,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      author: author ?? this.author,
      authorType: authorType ?? this.authorType,
      date: date ?? this.date,
      likes: likes ?? this.likes,
      shares: shares ?? this.shares,
      isSaved: isSaved ?? this.isSaved,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  void toggleSaved() {
    isSaved = !isSaved;
  }
}
