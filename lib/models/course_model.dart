class Course {
  final int id;
  final String title;
  final String provider;
  final String careerPath;
  final String duration;
  final String price;
  final double rating;
  final String link;
  final String description;
  final bool isCertified;
  final bool isActive;
  final String createdAt;
  bool isSaved;
  final String? imageUrl;

  Course({
    required this.id,
    required this.title,
    required this.provider,
    required this.careerPath,
    required this.duration,
    required this.price,
    required this.rating,
    required this.link,
    required this.description,
    required this.isCertified,
    required this.isActive,
    required this.createdAt,
    this.isSaved = false,
    this.imageUrl,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title'] ?? '',
      provider: json['provider'] ?? '',
      careerPath: json['career_path'] ?? '',
      duration: json['duration'] ?? '',
      price: json['price']?.toString() ?? '',
      rating: double.tryParse(json['rating']?.toString() ?? '') ?? 0.0,
      link: json['link'] ?? '',
      description: json['description'] ?? '',
      isCertified: json['is_certified'] ?? false,
      isActive: json['is_active'] ?? false,
      createdAt: json['created_at'] ?? '',
      isSaved: json['is_saved'] ?? false,
      imageUrl: json['image'] as String? ?? json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'provider': provider,
      'career_path': careerPath,
      'duration': duration,
      'price': price,
      'rating': rating,
      'link': link,
      'description': description,
      'is_certified': isCertified,
      'is_active': isActive,
      'created_at': createdAt,
      'is_saved': isSaved,
    };
  }

  Course copyWith({
    int? id,
    String? title,
    String? provider,
    String? careerPath,
    String? duration,
    String? price,
    double? rating,
    String? link,
    String? description,
    bool? isCertified,
    bool? isActive,
    String? createdAt,
    bool? isSaved,
    String? imageUrl,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      provider: provider ?? this.provider,
      careerPath: careerPath ?? this.careerPath,
      duration: duration ?? this.duration,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      link: link ?? this.link,
      description: description ?? this.description,
      isCertified: isCertified ?? this.isCertified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      isSaved: isSaved ?? this.isSaved,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  void toggleSaved() {
    isSaved = !isSaved;
  }
}
