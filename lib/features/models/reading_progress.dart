class ReadingProgress {
  final String id;
  final String bookId;
  final int pagesRead;
  final int daysRead;
  final int durationInDays;

  ReadingProgress({
    required this.id,
    required this.bookId,
    required this.durationInDays,
    this.pagesRead = 0,
    this.daysRead = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'book_id': bookId,
      'pages_read': pagesRead,
      'days_read': daysRead,
      'duration_in_days': durationInDays,
    };
  }

  factory ReadingProgress.fromMap(Map<String, dynamic> map) {
    return ReadingProgress(
      id: map['id'],
      bookId: map['book_id'],
      pagesRead: map['pages_read'],
      daysRead: map['days_read'],
      durationInDays: map['duration_in_days'],
    );
  }
}
