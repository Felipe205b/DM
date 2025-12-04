import '../../../models/book.dart';

class BookDto {
  final String id;
  final String userId;
  final String title;
  final String author;
  final int totalPages;

  BookDto({
    required this.id,
    required this.userId,
    required this.title,
    required this.author,
    required this.totalPages,
  });

  factory BookDto.fromMap(Map<String, dynamic> m) => BookDto(
        id: m['id'] as String,
        userId: m['user_id'] as String,
        title: m['title'] as String,
        author: m['author'] as String,
        totalPages: m['total_pages'] as int,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'author': author,
        'total_pages': totalPages,
      };
}
