import '../../../models/book.dart';
import '../dtos/book_dto.dart';

class BookMapper {
  static Book toEntity(BookDto dto) {
    return Book(
      id: dto.id,
      userId: dto.userId,
      name: dto.name,
      totalPages: dto.totalPages,
      daysToRead: dto.daysToRead,
    );
  }

  static BookDto toDto(Book entity) {
    return BookDto(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      totalPages: entity.totalPages,
      daysToRead: entity.daysToRead,
    );
  }
}
