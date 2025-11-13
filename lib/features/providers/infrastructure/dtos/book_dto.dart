
class BookDto {
  final String id;
  final String userId;
  final String name;
  final int totalPages;
  final int daysToRead;

  BookDto({
    required this.id,
    required this.userId,
    required this.name,
    required this.totalPages,
    required this.daysToRead,
  });

  factory BookDto.fromMap(Map<String, dynamic> m) => BookDto(
        id: m['id'] as String,
        userId: m['user_id'] as String,
        name: m['name'] as String,
        totalPages: m['total_pages'] as int,
        daysToRead: m['days_to_read'] as int,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'name': name,
        'total_pages': totalPages,
        'days_to_read': daysToRead,
      };

}
