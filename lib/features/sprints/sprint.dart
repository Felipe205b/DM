class Sprint {
  final String title;
  int totalPages;
  int durationInDays;
  int pagesRead;
  final DateTime startDate;
  late List<bool> dailyGoals;

  Sprint({
    required this.title,
    required this.totalPages,
    required this.durationInDays,
    this.pagesRead = 0,
  }) : startDate = DateTime.now() {
    dailyGoals = List<bool>.filled(durationInDays, false);
  }

  void updateGoals({required int newTotalPages, required int newDurationInDays}) {
    totalPages = newTotalPages;
    durationInDays = newDurationInDays;
    pagesRead = 0;
    dailyGoals = List<bool>.filled(durationInDays, false);
  }

  double get progress => totalPages > 0 ? pagesRead / totalPages : 0.0;

  int get pagesPerDay => (totalPages / durationInDays).ceil();

  int getPagesForDay(int dayIndex) {
    if (dayIndex < 0 || dayIndex >= durationInDays) {
      return 0;
    }
    if (dayIndex == durationInDays - 1) {
      final pagesForPreviousDays = pagesPerDay * (durationInDays - 1);
      final remainingPages = totalPages - pagesForPreviousDays;
      return remainingPages > 0 ? remainingPages : pagesPerDay;
    }
    return pagesPerDay;
  }

  int get remainingDays {
    return durationInDays - dailyGoals.where((goal) => goal).length;
  }
}