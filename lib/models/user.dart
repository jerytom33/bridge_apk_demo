import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
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
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

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
    );
  }
}
