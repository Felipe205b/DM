import '../../../models/book.dart';
import '../dtos/book_dto.dart';

class BookMapper {
  static Book toEntity(BookDto dto) {
    return Book(
      id: dto.id,
      userId: dto.userId,
      title: dto.title,
      author: dto.author,
      totalPages: dto.totalPages,
    );
  }

  static BookDto toDto(Book entity) {
    return BookDto(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      author: entity.author,
      totalPages: entity.totalPages,
    );
  }
}
