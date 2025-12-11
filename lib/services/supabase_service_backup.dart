import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fresh_petals/models/user.dart' as app_user;
import 'package:flutter/foundation.dart' show kIsWeb;

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  static SupabaseService get instance => _instance;

  SupabaseService._internal();

  final SupabaseClient supabase = Supabase.instance.client;

  // Google Sign In Configuration (different for Web and Mobile)
  late final GoogleSignIn _googleSignIn;

  // Initialize service
  Future<void> initialize() async {
    // Setup Google Sign-In based on platform
    if (kIsWeb) {
      // Web: Only use clientId
      _googleSignIn = GoogleSignIn(
        clientId:
            '516950019018-0qo77cnbvhsil68n0r0jgihq3lh3uf3o.apps.googleusercontent.com',
      );
    } else {
      // Mobile: Use both clientId and serverClientId
      _googleSignIn = GoogleSignIn(
        clientId:
            '516950019018-n0t763s5gd33uchl496gspjpqg0ai849.apps.googleusercontent.com',
        serverClientId:
            '516950019018-0qo77cnbvhsil68n0r0jgihq3lh3uf3o.apps.googleusercontent.com',
      );
    }

    // Setup auth state listener
    supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn) {
        print('User signed in: ');
      } else if (event == AuthChangeEvent.signedOut) {
        print('User signed out');
      }
    });
  }

  // Get current user
  User? get currentUser => supabase.auth.currentUser;

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Sign Up with Email and Password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'role': 'user'},
      );

      if (response.user != null) {
        print('🔍 DEBUG: User signed up successfully: ${response.user!.email}');
        await createUserProfile(
          userId: response.user!.id,
          email: email,
          fullName: fullName,
          role: 'user',
        );
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign In with Email and Password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign In with Google - Web optimized using Supabase OAuth
  Future<AuthResponse> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // For Web: Use Supabase's native OAuth flow (no popup issues)
        final response = await supabase.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: Uri.base.toString(),
          authScreenLaunchMode: LaunchMode.platformDefault,
        );

        // The actual sign-in happens after redirect, so we return a placeholder
        // The auth state listener will handle the successful sign-in
        return AuthResponse(session: null, user: null);
      } else {
        // For Mobile: Use the existing google_sign_in flow
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        if (googleUser == null) {
          throw Exception('Google Sign In cancelled');
        }

        // Obtain auth details
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final String? accessToken = googleAuth.accessToken;
        final String? idToken = googleAuth.idToken;

        if (accessToken == null || idToken == null) {
          throw Exception('Failed to get Google tokens');
        }

        // Sign in to Supabase with Google tokens
        final response = await supabase.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );

        // Create user profile if new user
        if (response.user != null) {
          final existingProfile = await getUserProfile(response.user!.id);
          if (existingProfile == null) {
            await createUserProfile(
              userId: response.user!.id,
              email: response.user!.email ?? '',
              fullName: googleUser.displayName ?? 'User',
              role: 'user',
            );
          }
        }

        return response;
      }
    } catch (e) {
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Create User Profile in Database
  Future<void> createUserProfile({
    required String userId,
    required String email,
    required String fullName,
    required String role,
  }) async {
    try {
      print('🔍 DEBUG: Creating user profile for userId: $userId');
      await supabase.from('users').insert({
        'id': userId,
        'email': email,
        'full_name': fullName,
        'role': role,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('❌ ERROR creating user profile: $e');
      rethrow;
    }
  }

  // Get User Profile from Database
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Error getting user profile: ');
      return null;
    }
  }

  // Update User Profile
  Future<void> updateUserProfile({
    required String userId,
    String? fullName,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updates['full_name'] = fullName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      await supabase.from('users').update(updates).eq('id', userId);
    } catch (e) {
      rethrow;
    }
  }

  // Convert Supabase User to App User
  Future<app_user.User?> getAppUser() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final profile = await getUserProfile(user.id);

      if (profile == null) return null;

      return app_user.User(
        username: user.email?.split('@')[0] ?? 'user',
        password: '',
        role: profile['role'] ?? 'user',
        fullName: profile['full_name'] ?? '',
        email: user.email ?? '',
      );
    } catch (e) {
      print('Error converting to app user: ');
      return null;
    }
  }

  // Product CRUD Operations

  // Create Product
  Future<void> createProduct({
    required String name,
    required String category,
    required String image,
    required String description,
    required double price,
  }) async {
    try {
      await supabase.from('products').insert({
        'name': name,
        'category': category,
        'image': image,
        'description': description,
        'price': price,
        'quantity': 1,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get All Products
  Future<List<Map<String, dynamic>>> getAllProducts() async {
    try {
      final response = await supabase
          .from('products')
          .select()
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting products: ');
      return [];
    }
  }

  // Get Products by Category
  Future<List<Map<String, dynamic>>> getProductsByCategory(
    String category,
  ) async {
    try {
      final response = await supabase
          .from('products')
          .select()
          .eq('category', category)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting products by category: ');
      return [];
    }
  }

  // Update Product
  Future<void> updateProduct({
    required int productId,
    String? name,
    String? category,
    String? image,
    String? description,
    double? price,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updates['name'] = name;
      if (category != null) updates['category'] = category;
      if (image != null) updates['image'] = image;
      if (description != null) updates['description'] = description;
      if (price != null) updates['price'] = price;

      await supabase.from('products').update(updates).eq('id', productId);
    } catch (e) {
      rethrow;
    }
  }

  // Delete Product
  Future<void> deleteProduct(int productId) async {
    try {
      await supabase.from('products').delete().eq('id', productId);
    } catch (e) {
      rethrow;
    }
  }

  // Check if user is admin
  Future<bool> isUserAdmin() async {
    final user = currentUser;
    if (user == null) return false;

    try {
      final profile = await getUserProfile(user.id);
      return profile?['role'] == 'admin';
    } catch (e) {
      return false;
    }
  }
}
