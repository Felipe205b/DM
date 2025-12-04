import '../../../models/user.dart';

class UserDto {
  final String id;
  final String name;
  final String? profilePictureUrl;

  UserDto({
    required this.id,
    required this.name,
    this.profilePictureUrl,
  });

  factory UserDto.fromMap(Map<String, dynamic> m) => UserDto(
        id: m['id'] as String,
        name: m['name'] as String,
        profilePictureUrl: m['profile_picture_url'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'profile_picture_url': profilePictureUrl,
      };

  User toEntity() => User(
        id: id,
        name: name,
        profilePictureUrl: profilePictureUrl,
      );
}
