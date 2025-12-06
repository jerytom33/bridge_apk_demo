class Exam {
  final int id;
  final String name;
  final String description;
  final String date;
  final String educationLevel; // 10th, 12th, UG, PG
  final String subject;
  final String duration;
  final String examType; // Online, Offline

  final bool isSaved;

  Exam({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.educationLevel,
    required this.subject,
    required this.duration,
    required this.examType,
    this.isSaved = false,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] ?? '',
      educationLevel: json['education_level'] ?? '',
      subject: json['subject'] ?? '',
      duration: json['duration'] ?? '',
      examType: json['exam_type'] ?? '',
      isSaved: json['is_saved'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'date': date,
      'education_level': educationLevel,
      'subject': subject,
      'duration': duration,
      'exam_type': examType,
      'is_saved': isSaved,
    };
  }

  Exam copyWith({
    int? id,
    String? name,
    String? description,
    String? date,
    String? educationLevel,
    String? subject,
    String? duration,
    String? examType,
    bool? isSaved,
  }) {
    return Exam(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      date: date ?? this.date,
      educationLevel: educationLevel ?? this.educationLevel,
      subject: subject ?? this.subject,
      duration: duration ?? this.duration,
      examType: examType ?? this.examType,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}
