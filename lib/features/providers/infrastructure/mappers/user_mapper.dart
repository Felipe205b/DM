import '../../../models/user.dart';
import '../dtos/user_dto.dart';

class UserMapper {
  static User toEntity(UserDto dto) {
    return User(
      id: dto.id,
      name: dto.name,
      profilePictureUrl: dto.profilePictureUrl,
    );
  }

  static UserDto toDto(User entity) {
    return UserDto(
      id: entity.id,
      name: entity.name,
      profilePictureUrl: entity.profilePictureUrl,
    );
  }
}
