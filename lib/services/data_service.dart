import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:food_safe/features/models/book.dart';
import 'package:food_safe/features/models/reading_progress.dart';
import 'package:food_safe/services/shared_preferences_services.dart';
import 'package:food_safe/services/supabase_service.dart';
import 'package:uuid/uuid.dart';

class DataService {
  final SupabaseService _supabaseService;

  DataService(this._supabaseService);

  static Future<DataService> getInstance(SupabaseService supabaseService) async {
    return DataService(supabaseService);
  }

  Stream<List<Book>> getBooks() async* {
    final localBooks = await SharedPreferencesService.getBooks();
    yield localBooks;

    final connectivityResult = await (Connectivity().checkConnectivity());
    if (!connectivityResult.contains(ConnectivityResult.none)) {
      try {
        final remoteBooks = await _supabaseService.getBooks();
        await SharedPreferencesService.saveBooks(remoteBooks);
        yield remoteBooks;
      } catch (e) {
        // Silently fail, the user will see the local data
      }
    }
  }

  Future<ReadingProgress?> getReadingProgress(String bookId) async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      // This is a simplified offline implementation. A real app would need a more robust solution.
      return null;
    } else {
      return await _supabaseService.getReadingProgress(bookId);
    }
  }

  Future<void> createSprint(Book book, int durationInDays) async {
    final readingProgress = ReadingProgress(
      id: const Uuid().v4(),
      bookId: book.id,
      durationInDays: durationInDays,
    );

    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      // Handle offline logic for both book and reading progress
      final books = await SharedPreferencesService.getBooks();
      books.add(book);
      await SharedPreferencesService.saveBooks(books);
      await SharedPreferencesService.addToQueue('add_book', book.toMap());
      await SharedPreferencesService.addToQueue('add_reading_progress', readingProgress.toMap());
    } else {
      await _supabaseService.addBook(book);
      await _supabaseService.addReadingProgress(readingProgress);
    }
  }

  Future<void> updateBook(Book book) async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      final books = await SharedPreferencesService.getBooks();
      final index = books.indexWhere((b) => b.id == book.id);
      if (index != -1) {
        books[index] = book;
        await SharedPreferencesService.saveBooks(books);
        await SharedPreferencesService.addToQueue('update_book', book.toMap());
      }
    } else {
      await _supabaseService.updateBook(book);
    }
  }

  Future<void> updateReadingProgress(ReadingProgress readingProgress) async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      // For offline, we might need a more complex logic to update reading progress
      // For now, let's just queue the update
      await SharedPreferencesService.addToQueue('update_reading_progress', readingProgress.toMap());
    } else {
      await _supabaseService.updateReadingProgress(readingProgress);
    }
  }

  Future<void> deleteBook(Book book) async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      final books = await SharedPreferencesService.getBooks();
      books.removeWhere((b) => b.id == book.id);
      await SharedPreferencesService.saveBooks(books);
      await SharedPreferencesService.addToQueue('delete_book', book.toMap());
      await SharedPreferencesService.addToQueue('delete_reading_progress', {'book_id': book.id});
    } else {
      await _supabaseService.deleteBook(book);
      await _supabaseService.deleteReadingProgress(book.id);
    }
  }

  Future<void> syncQueue() async {
    final queue = await SharedPreferencesService.getQueue();
    if (queue.isEmpty) {
      return;
    }

    final connectivityResult = await (Connectivity().checkConnectivity());
    if (!connectivityResult.contains(ConnectivityResult.none)) {
      for (final item in queue) {
        if (item['action'] == 'add_book') {
          final book = Book.fromMap(item['data']);
          await _supabaseService.addBook(book);
        } else if (item['action'] == 'add_reading_progress') {
          final readingProgress = ReadingProgress.fromMap(item['data']);
          await _supabaseService.addReadingProgress(readingProgress);
        } else if (item['action'] == 'update_book') {
          final book = Book.fromMap(item['data']);
          await _supabaseService.updateBook(book);
        } else if (item['action'] == 'update_reading_progress') {
          final readingProgress = ReadingProgress.fromMap(item['data']);
          await _supabaseService.updateReadingProgress(readingProgress);
        } else if (item['action'] == 'delete_book') {
          final book = Book.fromMap(item['data']);
          await _supabaseService.deleteBook(book);
        } else if (item['action'] == 'delete_reading_progress') {
          await _supabaseService.deleteReadingProgress(item['data']['book_id']);
        }
      }
      await SharedPreferencesService.clearQueue();
    }
  }
}
