import '../../../models/reading_progress.dart';
import '../dtos/reading_progress_dto.dart';

class ReadingProgressMapper {
  static ReadingProgress toEntity(ReadingProgressDto dto) {
    return ReadingProgress(
      id: dto.id,
      bookId: dto.bookId,
      pagesRead: dto.pagesRead,
      daysRead: dto.daysRead,
      durationInDays: dto.durationInDays,
    );
  }

  static ReadingProgressDto toDto(ReadingProgress entity) {
    return ReadingProgressDto(
      id: entity.id,
      bookId: entity.bookId,
      pagesRead: entity.pagesRead,
      daysRead: entity.daysRead,
      durationInDays: entity.durationInDays,
    );
  }
}
