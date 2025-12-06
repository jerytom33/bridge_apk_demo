class Career {
  final int id;
  final String title;
  final String description;
  final String salary;
  final String growth;
  final List<String> skills;
  bool isSaved;

  Career({
    required this.id,
    required this.title,
    required this.description,
    required this.salary,
    required this.growth,
    required this.skills,
    this.isSaved = false,
  });

  factory Career.fromJson(Map<String, dynamic> json) {
    return Career(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      salary: json['salary'] ?? '',
      growth: json['growth'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      isSaved: json['is_saved'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'salary': salary,
      'growth': growth,
      'skills': skills,
      'is_saved': isSaved,
    };
  }

  Career copyWith({
    int? id,
    String? title,
    String? description,
    String? salary,
    String? growth,
    List<String>? skills,
    bool? isSaved,
  }) {
    return Career(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      salary: salary ?? this.salary,
      growth: growth ?? this.growth,
      skills: skills ?? this.skills,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  void toggleSaved() {
    isSaved = !isSaved;
  }
}
