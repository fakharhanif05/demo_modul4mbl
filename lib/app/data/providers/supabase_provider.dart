// ============ supabase_provider.dart ============
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProvider {
  final SupabaseClient _client = Supabase.instance.client;

  SupabaseClient get client => _client;

  // Helper methods bisa ditambahkan di sini
  Future<PostgrestList> fetchData(String table) async {
    try {
      final response = await _client.from(table).select();
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<PostgrestMap> fetchDataById(String table, String id) async {
    try {
      final response = await _client.from(table).select().eq('id', id).single();
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> insertData(String table, Map<String, dynamic> data) async {
    try {
      await _client.from(table).insert(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateData(String table, String id, Map<String, dynamic> data) async {
    try {
      await _client.from(table).update(data).eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteData(String table, String id) async {
    try {
      await _client.from(table).delete().eq('id', id);
    } catch (e) {
      rethrow;
    }
  }
}