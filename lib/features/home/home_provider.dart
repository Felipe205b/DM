import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/shared_preferences_services.dart';
import '../models/book.dart';

final booksProvider = FutureProvider<List<Book>>((ref) async {
  return await SharedPreferencesService.getBooks();
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

  Future<void> addBook(Book book) async {
    final books = await SharedPreferencesService.getBooks();
    books.add(book);
    await SharedPreferencesService.saveBooks(books);
    _ref.refresh(booksProvider);
  }

  Future<void> deleteBook(Book book) async {
    final books = await SharedPreferencesService.getBooks();
    books.removeWhere((b) => b.id == book.id);
    await SharedPreferencesService.saveBooks(books);
    _ref.refresh(booksProvider);
  }

  Future<void> updateBook(Book book) async {
    final books = await SharedPreferencesService.getBooks();
    final index = books.indexWhere((b) => b.id == book.id);
    if (index != -1) {
      books[index] = book;
      await SharedPreferencesService.saveBooks(books);
      _ref.refresh(booksProvider);
    }
  }
}
