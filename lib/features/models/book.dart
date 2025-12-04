class Book {
  final String id;
  final String userId;
  final String title;
  final String author;
  final int totalPages;

  Book({
    required this.id,
    required this.userId,
    required this.title,
    required this.author,
    required this.totalPages,
  });

  Book copyWith({
    String? id,
    String? userId,
    String? title,
    String? author,
    int? totalPages,
  }) {
    return Book(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      author: author ?? this.author,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'author': author,
      'total_pages': totalPages,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      author: map['author'],
      totalPages: map['total_pages'],
    );
  }
}
