class Sprint {
  final String title;
  int totalPages;
  int durationInDays;
  int pagesRead;
  int daysRead;

  Sprint({
    required this.title,
    required this.totalPages,
    required this.durationInDays,
    this.pagesRead = 0,
    this.daysRead = 0,
  });

  void updateGoals({required int newTotalPages, required int newDurationInDays}) {
    totalPages = newTotalPages;
    durationInDays = newDurationInDays;
    pagesRead = 0;
    daysRead = 0;
  }

  double get progress =>
      durationInDays > 0 ? daysRead / durationInDays : 0.0;

  int getPagesForDay(int dayIndex) {
    if (dayIndex < 0 || dayIndex >= durationInDays) {
      return 0;
    }
    final basePages = totalPages ~/ durationInDays;
    final extraPages = totalPages % durationInDays;
    return dayIndex < extraPages ? basePages + 1 : basePages;
  }

  int get remainingDays {
    return durationInDays - daysRead;
  }
}
