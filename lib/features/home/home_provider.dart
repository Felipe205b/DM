import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/data_service.dart';
import '../models/book.dart';
import '../models/reading_progress.dart';

final dataServiceProvider = Provider<DataService>((ref) {
  throw UnimplementedError();
});

final booksProvider = StreamProvider<List<Book>>((ref) {
  final dataService = ref.watch(dataServiceProvider);
  return dataService.getBooks();
});

final readingProgressProvider = FutureProvider.family<ReadingProgress?, String>((ref, bookId) {
  final dataService = ref.watch(dataServiceProvider);
  return dataService.getReadingProgress(bookId);
});

final homeProvider = ChangeNotifierProvider((ref) {
  return HomeProvider(ref);
});

class HomeProvider with ChangeNotifier {
  final Ref _ref;
  List<Book> _books = [];

  HomeProvider(this._ref);

  List<Book> get books => _books;

  set books(List<Book> newBooks) {
    _books = newBooks;
    notifyListeners();
  }

  Future<void> createSprint(Book book, int durationInDays) async {
    final dataService = _ref.read(dataServiceProvider);
    await dataService.createSprint(book, durationInDays);
    _ref.invalidate(booksProvider);
  }

  Future<void> deleteBook(Book book) async {
    final dataService = _ref.read(dataServiceProvider);
    await dataService.deleteBook(book);
    _ref.invalidate(booksProvider);
  }

  Future<void> updateBook(Book book) async {
    final dataService = _ref.read(dataServiceProvider);
    await dataService.updateBook(book);
    _ref.invalidate(booksProvider);
  }

  Future<void> updateReadingProgress(ReadingProgress readingProgress) async {
    final dataService = _ref.read(dataServiceProvider);
    await dataService.updateReadingProgress(readingProgress);
    _ref.invalidate(readingProgressProvider(readingProgress.bookId));
  }
}
