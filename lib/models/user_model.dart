class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? gender;
  final String? dob;
  final String? state;
  final String? district;
  final String? place;
  final String? photo;
  final String? educationLevel; // New field: 10th/12th/UG/PG
  final String? stream; // New field: stream/subject
  final List<String>? interests; // New field: user interests
  final String? careerGoals; // New field: career goals

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.gender,
    this.dob,
    this.state,
    this.district,
    this.place,
    this.photo,
    this.educationLevel,
    this.stream,
    this.interests,
    this.careerGoals,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      gender: json['gender'],
      dob: json['dob'],
      state: json['state'],
      district: json['district'],
      place: json['place'],
      photo: json['photo'],
      educationLevel: json['education_level'],
      stream: json['stream'],
      interests: json['interests'] != null
          ? List<String>.from(json['interests'])
          : null,
      careerGoals: json['career_goals'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'gender': gender,
      'dob': dob,
      'state': state,
      'district': district,
      'place': place,
      'photo': photo,
      'education_level': educationLevel,
      'stream': stream,
      'interests': interests,
      'career_goals': careerGoals,
    };
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? gender,
    String? dob,
    String? state,
    String? district,
    String? place,
    String? photo,
    String? educationLevel,
    String? stream,
    List<String>? interests,
    String? careerGoals,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      state: state ?? this.state,
      district: district ?? this.district,
      place: place ?? this.place,
      photo: photo ?? this.photo,
      educationLevel: educationLevel ?? this.educationLevel,
      stream: stream ?? this.stream,
      interests: interests ?? this.interests,
      careerGoals: careerGoals ?? this.careerGoals,
    );
  }
}
