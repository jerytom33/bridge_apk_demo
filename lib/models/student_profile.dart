import 'package:json_annotation/json_annotation.dart';

part 'student_profile.g.dart';

@JsonSerializable()
class StudentProfile {
  final int? id;
  final String? currentLevel;
  final String? stream;
  final List<String>? interests;
  final String? careerGoals;
  final String? phone;
  final String? dateOfBirth;

  StudentProfile({
    this.id,
    this.currentLevel,
    this.stream,
    this.interests,
    this.careerGoals,
    this.phone,
    this.dateOfBirth,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) =>
      _$StudentProfileFromJson(json);

  Map<String, dynamic> toJson() => _$StudentProfileToJson(this);

  StudentProfile copyWith({
    int? id,
    String? currentLevel,
    String? stream,
    List<String>? interests,
    String? careerGoals,
    String? phone,
    String? dateOfBirth,
  }) {
    return StudentProfile(
      id: id ?? this.id,
      currentLevel: currentLevel ?? this.currentLevel,
      stream: stream ?? this.stream,
      interests: interests ?? this.interests,
      careerGoals: careerGoals ?? this.careerGoals,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }
}
