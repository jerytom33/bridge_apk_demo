class Exam {
  final String id;
  final String name;
  final String description;
  final String date;
  final String educationLevel; // 10th, 12th, UG, PG
  final String subject;
  final String duration;
  final String examType; // Online, Offline

  Exam({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.educationLevel,
    required this.subject,
    required this.duration,
    required this.examType,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] ?? '',
      educationLevel: json['education_level'] ?? '',
      subject: json['subject'] ?? '',
      duration: json['duration'] ?? '',
      examType: json['exam_type'] ?? '',
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
    };
  }
}
