import '../../../models/reading_progress.dart';

class ReadingProgressDto {
  final String id;
  final String bookId;
  final int pagesRead;
  final int daysRead;

  ReadingProgressDto({
    required this.id,
    required this.bookId,
    this.pagesRead = 0,
    this.daysRead = 0,
  });

  factory ReadingProgressDto.fromMap(Map<String, dynamic> m) =>
      ReadingProgressDto(
        id: m['id'] as String,
        bookId: m['book_id'] as String,
        pagesRead: m['pages_read'] as int,
        daysRead: m['days_read'] as int,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'book_id': bookId,
        'pages_read': pagesRead,
        'days_read': daysRead,
      };

  ReadingProgress toEntity() => ReadingProgress(
        id: id,
        bookId: bookId,
        pagesRead: pagesRead,
        daysRead: daysRead,
      );
}
