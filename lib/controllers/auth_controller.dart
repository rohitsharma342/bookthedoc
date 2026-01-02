import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../models/user.dart' as app_user;

class AuthController extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  
  app_user.User? _currentUser;
  bool _isLoading = false;
  String _error = '';
  bool _isAuthenticated = false;

  app_user.User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  AuthController() {
    _initializeAuth();
  }

  void _initializeAuth() {
    // Listen to auth state changes
    _supabaseService.authStateChanges().listen((AuthState state) {
      _handleAuthStateChange(state);
    });
    
    // Check current user
    _checkCurrentUser();
  }

  void _handleAuthStateChange(AuthState state) {
    if (state.event == AuthChangeEvent.signedIn) {
      _isAuthenticated = true;
      _fetchUserProfile();
    } else if (state.event == AuthChangeEvent.signedOut) {
      _isAuthenticated = false;
      _currentUser = null;
      notifyListeners();
    }
  }

  Future<void> _checkCurrentUser() async {
    try {
      final user = _supabaseService.getCurrentUser();
      if (user != null) {
        _isAuthenticated = true;
        await _fetchUserProfile();
      }
    } catch (e) {
      print('Error checking current user: $e');
    }
  }

  Future<void> _fetchUserProfile() async {
    try {
      final user = _supabaseService.getCurrentUser();
      if (user != null) {
        final userProfile = await _supabaseService.fetchById('user_profiles', user.id);
        if (userProfile != null) {
          _currentUser = app_user.User.fromJson(userProfile);
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    try {
      _setLoading(true);
      _setError('');
      
      final response = await _supabaseService.signUp(email, password, name);
      
      if (response?.user != null) {
        _isAuthenticated = true;
        await _fetchUserProfile();
        return true;
      }
      
      return false;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _setError('');
      
      final response = await _supabaseService.signIn(email, password);
      
      if (response?.user != null) {
        _isAuthenticated = true;
        await _fetchUserProfile();
        return true;
      }
      
      return false;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _supabaseService.signOut();
      _isAuthenticated = false;
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfile(app_user.User user) async {
    try {
      _setLoading(true);
      _setError('');
      
      await _supabaseService.updateData('user_profiles', user.id, user.toJson());
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  String _getErrorMessage(dynamic error) {
    if (error is AuthException) {
      switch (error.message) {
        case 'Invalid login credentials':
          return 'Invalid email or password';
        case 'Email not confirmed':
          return 'Please check your email and confirm your account';
        case 'User already registered':
          return 'An account with this email already exists';
        default:
          return error.message;
      }
    }
    return 'An unexpected error occurred. Please try again.';
  }
}