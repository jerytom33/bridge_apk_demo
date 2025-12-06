// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) => Post(
  id: (json['id'] as num).toInt(),
  title: json['content'] as String, // API uses content as the main text
  content: json['content'] as String,
  author: (json['author'] as Map<String, dynamic>)['username'] as String,
  createdAt: json['created_at'] as String,
  likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
  isLiked: json['is_liked'] as bool? ?? false,
  isSaved: json['is_saved'] as bool? ?? false,
);

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
  'id': instance.id,
  'content': instance.content,
  'author': instance.author,
  'created_at': instance.createdAt,
  'like_count': instance.likeCount,
  'is_liked': instance.isLiked,
  'is_saved': instance.isSaved,
};
