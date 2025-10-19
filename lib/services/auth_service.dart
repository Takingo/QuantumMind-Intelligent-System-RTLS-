import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/constants.dart';
import 'supabase_service.dart';
import '../models/user_model.dart';

/// Authentication Service
class AuthService {
  final SupabaseService _supabaseService = SupabaseService.instance;
  
  /// Get current session
  Session? get currentSession => _supabaseService.client.auth.currentSession;
  
  /// Get current user
  User? get currentUser => _supabaseService.client.auth.currentUser;
  
  /// Check if user is logged in
  bool get isLoggedIn => currentSession != null;
  
  /// Get user ID
  String? get userId => currentUser?.id;
  
  // ========== Authentication Methods ==========
  
  /// Sign up with email and password
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    String role = 'User',
  }) async {
    try {
      // Create auth user
      final authResponse = await _supabaseService.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'role': role,
        },
      );
      
      if (authResponse.user == null) {
        throw Exception('Failed to create user');
      }
      
      // Create user record in database
      final userData = {
        'id': authResponse.user!.id,
        'name': name,
        'email': email,
        'role': role,
        'created_at': DateTime.now().toIso8601String(),
        'is_active': true,
      };
      
      await _supabaseService.insert(AppConstants.tableUsers, userData);
      
      return UserModel.fromJson(userData);
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }
  
  /// Sign in with email and password
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final authResponse = await _supabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (authResponse.user == null) {
        throw Exception('Login failed');
      }
      
      // Update last login time
      await _supabaseService.update(
        AppConstants.tableUsers,
        authResponse.user!.id,
        {'last_login_at': DateTime.now().toIso8601String()},
      );
      
      // Fetch user data
      final userData = await _supabaseService.getById(
        AppConstants.tableUsers,
        authResponse.user!.id,
      );
      
      if (userData == null) {
        throw Exception('User data not found');
      }
      
      return UserModel.fromJson(userData);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }
  
  /// Sign out
  Future<void> signOut() async {
    try {
      await _supabaseService.client.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }
  
  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _supabaseService.client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }
  
  /// Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabaseService.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw Exception('Password update failed: $e');
    }
  }
  
  /// Get current user data
  Future<UserModel?> getCurrentUserData() async {
    try {
      if (!isLoggedIn || userId == null) return null;
      
      final userData = await _supabaseService.getById(
        AppConstants.tableUsers,
        userId!,
      );
      
      if (userData == null) return null;
      
      return UserModel.fromJson(userData);
    } catch (e) {
      throw Exception('Failed to fetch user data: $e');
    }
  }
  
  /// Update user profile
  Future<UserModel> updateProfile({
    String? name,
    String? avatarUrl,
  }) async {
    try {
      if (!isLoggedIn || userId == null) {
        throw Exception('User not logged in');
      }
      
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      
      final updatedData = await _supabaseService.update(
        AppConstants.tableUsers,
        userId!,
        updates,
      );
      
      return UserModel.fromJson(updatedData);
    } catch (e) {
      throw Exception('Profile update failed: $e');
    }
  }
  
  /// Check user role
  Future<bool> hasRole(String role) async {
    try {
      final userData = await getCurrentUserData();
      return userData?.role == role;
    } catch (e) {
      return false;
    }
  }
  
  /// Check if user is admin
  Future<bool> isAdmin() async {
    return await hasRole(AppConstants.roleAdmin);
  }
  
  /// Listen to auth state changes
  Stream<AuthState> get onAuthStateChange {
    return _supabaseService.client.auth.onAuthStateChange;
  }
}
