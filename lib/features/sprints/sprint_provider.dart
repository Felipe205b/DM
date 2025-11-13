import 'package:flutter/material.dart';
import 'sprint.dart';
import '../models/book.dart';
import '../home/home_provider.dart';

class SprintProvider with ChangeNotifier {
  final HomeProvider _homeProvider;
  final Book _book;
  Sprint? _sprint;

  SprintProvider(this._homeProvider, this._book) {
    _buildSprint();
  }

  Sprint? get sprint => _sprint;

  void _buildSprint() {
    _sprint = Sprint(
      title: _book.name,
      totalPages: _book.totalPages,
      durationInDays: _book.daysToRead,
      pagesRead: _book.pagesRead,
      daysRead: _book.daysRead,
    );
    notifyListeners();
  }

  Future<void> updateSprintProgress(int dayIndex, bool isCompleted) async {
    if (_sprint == null) return;

    final dailyProgress = List<bool>.from(_book.dailyProgress);
    dailyProgress[dayIndex] = isCompleted;

    final newDaysRead = dailyProgress.where((goal) => goal).length;
    int newPagesRead = 0;
    for (int i = 0; i < dailyProgress.length; i++) {
      if (dailyProgress[i]) {
        newPagesRead += _sprint!.getPagesForDay(i);
      }
    }

    final updatedBook = _book.copyWith(
      pagesRead: newPagesRead,
      daysRead: newDaysRead,
      dailyProgress: dailyProgress,
    );

    await _homeProvider.updateBook(updatedBook);
  }

  Future<void> deleteSprint() async {
    await _homeProvider.deleteBook(_book);
  }
}
