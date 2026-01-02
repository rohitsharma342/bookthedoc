import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final SupabaseClient _client = Supabase.instance.client;
  
  SupabaseClient get client => _client;

  // Authentication methods
  Future<AuthResponse?> signUp(String email, String password, String name) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      
      if (response.user != null) {
        await _saveUserToken(response.session?.accessToken);
        await _saveUserId(response.user!.id);
        
        // Create user profile in database
        await _client.from('user_profiles').insert({
          'id': response.user!.id,
          'name': name,
          'email': email,
          'phone': '',
          'profile_image': '',
          'insurance': '',
          'date_of_birth': null,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
      
      return response;
    } catch (e) {
      print('Error signing up: $e');
      rethrow;
    }
  }

  Future<AuthResponse?> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        await _saveUserToken(response.session?.accessToken);
        await _saveUserId(response.user!.id);
      }
      
      return response;
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      await _clearUserData();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  Stream<AuthState> authStateChanges() {
    return _client.auth.onAuthStateChange;
  }

  // Database CRUD operations
  Future<List<Map<String, dynamic>>> fetchData(String table, {String? orderBy, bool ascending = true}) async {
    try {
      var query = _client.from(table).select();
      
      if (orderBy != null) {
        final response = await query.order(orderBy, ascending: ascending);
        return List<Map<String, dynamic>>.from(response);
      }
      
      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching data from $table: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> fetchById(String table, String id) async {
    try {
      final response = await _client
          .from(table)
          .select()
          .eq('id', id)
          .maybeSingle();
      
      return response;
    } catch (e) {
      print('Error fetching $table by id $id: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> insertData(String table, Map<String, dynamic> data) async {
    try {
      data['created_at'] = DateTime.now().toIso8601String();
      data['updated_at'] = DateTime.now().toIso8601String();
      
      final response = await _client
          .from(table)
          .insert(data)
          .select()
          .single();
      
      return response;
    } catch (e) {
      print('Error inserting data into $table: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateData(String table, String id, Map<String, dynamic> data) async {
    try {
      data['updated_at'] = DateTime.now().toIso8601String();
      
      final response = await _client
          .from(table)
          .update(data)
          .eq('id', id)
          .select()
          .single();
      
      return response;
    } catch (e) {
      print('Error updating data in $table: $e');
      rethrow;
    }
  }

  Future<void> deleteData(String table, String id) async {
    try {
      await _client
          .from(table)
          .delete()
          .eq('id', id);
    } catch (e) {
      print('Error deleting data from $table: $e');
      rethrow;
    }
  }

  // Storage operations
  Future<String> uploadFile(String bucket, String path, File file) async {
    try {
      await _client.storage
          .from(bucket)
          .upload(path, file);
      
      final url = _client.storage
          .from(bucket)
          .getPublicUrl(path);
      
      return url;
    } catch (e) {
      print('Error uploading file: $e');
      rethrow;
    }
  }

  Future<void> deleteFile(String bucket, String path) async {
    try {
      await _client.storage
          .from(bucket)
          .remove([path]);
    } catch (e) {
      print('Error deleting file: $e');
      rethrow;
    }
  }

  // User-specific queries
  Future<List<Map<String, dynamic>>> fetchUserAppointments(String userId) async {
    try {
      final response = await _client
          .from('appointments')
          .select('*, doctors(*)')
          .eq('user_id', userId)
          .order('date_time', ascending: true);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching user appointments: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserSavedDoctors(String userId) async {
    try {
      final response = await _client
          .from('saved_doctors')
          .select('*, doctors(*)')
          .eq('user_id', userId);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching saved doctors: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> searchDoctors({
    String? query,
    String? specialty,
    String? sortBy,
  }) async {
    try {
      var queryBuilder = _client.from('doctors').select();
      
      if (query != null && query.isNotEmpty) {
        queryBuilder = queryBuilder.or('name.ilike.%$query%,specialty.ilike.%$query%');
      }
      
      if (specialty != null && specialty.isNotEmpty && specialty != 'All') {
        queryBuilder = queryBuilder.eq('specialty', specialty);
      }
      
      List<Map<String, dynamic>> response;
      
      switch (sortBy) {
        case 'rating':
          response = await queryBuilder.order('rating', ascending: false);
          break;
        case 'price_low':
          response = await queryBuilder.order('consultation_fee', ascending: true);
          break;
        case 'price_high':
          response = await queryBuilder.order('consultation_fee', ascending: false);
          break;
        default:
          response = await queryBuilder.order('rating', ascending: false);
      }
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error searching doctors: $e');
      rethrow;
    }
  }

  // Local storage helpers
  Future<void> _saveUserToken(String? token) async {
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_token', token);
    }
  }

  Future<void> _saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
  }

  Future<String?> getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_token');
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_token');
    await prefs.remove('user_id');
  }
}