import 'package:supabase_flutter/supabase_flutter.dart';
import '../dtos/user_dto.dart';
import '../dtos/book_dto.dart';
import '../dtos/reading_progress_dto.dart';

class SupabaseProvider {
  final SupabaseClient client;

  SupabaseProvider(this.client);

  Future<UserDto> getUser(String id) async {
    final data = await client.from('users').select().eq('id', id).single();
    return UserDto.fromMap(data);
  }

  Future<void> saveUser(UserDto user) async {
    await client.from('users').upsert(user.toMap());
  }

  Future<BookDto> getBook(String id) async {
    final data = await client.from('books').select().eq('id', id).single();
    return BookDto.fromMap(data);
  }

  Future<void> saveBook(BookDto book) async {
    await client.from('books').upsert(book.toMap());
  }

  Future<ReadingProgressDto> getReadingProgress(String id) async {
    final data = await client.from('reading_progress').select().eq('id', id).single();
    return ReadingProgressDto.fromMap(data);
  }

  Future<void> saveReadingProgress(ReadingProgressDto progress) async {
    await client.from('reading_progress').upsert(progress.toMap());
  }

  Future<void> deleteBook(String id) async {
    await client.from('books').delete().eq('id', id);
  }

  Future<void> updateReadingProgress(
      String bookId, int pagesRead, int daysRead) async {
    await client.from('reading_progress').update({
      'pages_read': pagesRead,
      'days_read': daysRead,
    }).eq('book_id', bookId);
  }

  Future<ReadingProgressDto?> getReadingProgressByBookId(String bookId) async {
    final data = await client
        .from('reading_progress')
        .select()
        .eq('book_id', bookId)
        .maybeSingle();
    if (data == null) {
      return null;
    }
    return ReadingProgressDto.fromMap(data);
  }

  Future<List<BookDto>> getAllBooks() async {
    try {
      final data = await client.from('books').select();

      if (data is! List) {
        return [];
      }

      final List<BookDto> books = [];
      for (final item in data) {
        if (item is Map<String, dynamic>) {
          books.add(BookDto.fromMap(item));
        }
      }
      return books;
    } catch (e) {
      print('Error fetching books: $e');
      return [];
    }
  }
}
