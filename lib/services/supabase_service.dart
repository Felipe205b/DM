import 'package:food_safe/features/models/book.dart';
import 'package:food_safe/features/models/reading_progress.dart';
import 'package:food_safe/utils/env_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: EnvUtils.supabaseUrl,
      anonKey: EnvUtils.supabaseAnonKey,
    );
  }

  Future<void> upsertUser(User user) async {
    try {
      final client = Supabase.instance.client;
      await client.from('users').upsert({
        'id': user.id,
        'email': user.email ?? '', // Provide a default value for email if it's null
        'name': '', // Provide a default empty string for name
      });
    } catch (e) {
      // It's better to let the caller handle the exception
      throw Exception('Failed to upsert user: $e');
    }
  }

  Future<List<Book>> getBooks() async {
    try {
      final client = Supabase.instance.client;
      final response = await client.from('books').select();
      final data = response as List;
      return data.map((map) => Book.fromMap(map)).toList();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<ReadingProgress?> getReadingProgress(String bookId) async {
    try {
      final client = Supabase.instance.client;
      final response = await client.from('reading_progress').select().eq('book_id', bookId).single();
      return ReadingProgress.fromMap(response);
    } catch (e) {
      return null;
    }
  }

  Future<void> addBook(Book book) async {
    try {
      final client = Supabase.instance.client;
      await client.from('books').insert(book.toMap()).select();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> addReadingProgress(ReadingProgress readingProgress) async {
    try {
      final client = Supabase.instance.client;
      await client.from('reading_progress').insert(readingProgress.toMap()).select();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> updateBook(Book book) async {
    final client = Supabase.instance.client;
    await client.from('books').update(book.toMap()).eq('id', book.id).select();
  }

  Future<void> updateReadingProgress(ReadingProgress readingProgress) async {
    final client = Supabase.instance.client;
    await client.from('reading_progress').update(readingProgress.toMap()).eq('id', readingProgress.id).select();
  }

  Future<void> deleteBook(Book book) async {
    final client = Supabase.instance.client;
    await client.from('books').delete().eq('id', book.id).select();
  }

  Future<void> deleteReadingProgress(String bookId) async {
    final client = Supabase.instance.client;
    await client.from('reading_progress').delete().eq('book_id', bookId).select();
  }
}
