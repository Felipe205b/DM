class ReadingProgress {
  final String id;
  final String bookId;
  final int pagesRead;
  final int daysRead;

  ReadingProgress({
    required this.id,
    required this.bookId,
    this.pagesRead = 0,
    this.daysRead = 0,
  });
}
