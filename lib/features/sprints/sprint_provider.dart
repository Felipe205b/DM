import 'package:flutter/material.dart';
import 'package:food_safe/features/models/reading_progress.dart';
import 'sprint.dart';
import '../models/book.dart';
import '../home/home_provider.dart';

class SprintProvider with ChangeNotifier {
  final HomeProvider _homeProvider;
  final Book _book;
  final ReadingProgress _readingProgress;
  Sprint? _sprint;

  SprintProvider(this._homeProvider, this._book, this._readingProgress) {
    _sprint = Sprint(
      title: _book.title,
      totalPages: _book.totalPages,
      durationInDays: _readingProgress.durationInDays,
      pagesRead: _readingProgress.pagesRead,
      daysRead: _readingProgress.daysRead,
    );
  }

  Sprint? get sprint => _sprint;

  Future<void> updateSprintProgress(int dayIndex, bool isCompleted) async {
    if (_sprint == null) return;

    // This logic ensures sequential progress
    if (isCompleted) {
      if (dayIndex != _readingProgress.daysRead) {
        return; // Can only complete the next day in sequence
      }
    } else {
      if (dayIndex != _readingProgress.daysRead - 1) {
        return; // Can only un-complete the last completed day
      }
    }

    final newDaysRead = isCompleted ? _readingProgress.daysRead + 1 : _readingProgress.daysRead - 1;
    final pagesForDay = _sprint!.getPagesForDay(dayIndex);
    final newPagesRead = isCompleted ? _readingProgress.pagesRead + pagesForDay : _readingProgress.pagesRead - pagesForDay;

    final updatedReadingProgress = ReadingProgress(
      id: _readingProgress.id,
      bookId: _readingProgress.bookId,
      durationInDays: _readingProgress.durationInDays,
      pagesRead: newPagesRead,
      daysRead: newDaysRead,
    );

    await _homeProvider.updateReadingProgress(updatedReadingProgress);
  }

  Future<void> deleteSprint() async {
    await _homeProvider.deleteBook(_book);
  }
}
