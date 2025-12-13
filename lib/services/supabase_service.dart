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

      if (event == AuthChangeEvent.signedIn) {
        print('User signed in');
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
        print('✅ DEBUG: User signed up successfully: ${response.user!.email}');
        
        // Wait a moment for the auth user to be fully created
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Create profile with retry logic
        await createUserProfileWithRetry(
          userId: response.user!.id,
          email: email,
          fullName: fullName,
          role: 'user',
        );
      }

      return response;
    } catch (e) {
      print('❌ ERROR in signUpWithEmail: $e');
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
        await supabase.auth.signInWithOAuth(
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
            await createUserProfileWithRetry(
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
      print('DEBUG: Starting sign out process...');
      
      // Try to sign out from Google (don't wait if it fails)
      try {
        await _googleSignIn.signOut().timeout(
          const Duration(seconds: 2),
          onTimeout: () {
            print('DEBUG: Google sign out timed out (user may not have used Google login)');
            return null;
          },
        );
        print('DEBUG: Google sign out completed');
      } catch (e) {
        print('DEBUG: Google sign out error (ignoring): $e');
        // Ignore Google sign out errors - user might not have signed in with Google
      }
      
      // Sign out from Supabase (this is the important one)
      print('DEBUG: Signing out from Supabase...');
      await supabase.auth.signOut(scope: SignOutScope.global);
      print('DEBUG: Supabase sign out completed');
      
    } catch (e) {
      print('ERROR: Sign out failed: $e');
      rethrow;
    }
  }

  // Create User Profile with Retry Logic
  Future<void> createUserProfileWithRetry({
    required String userId,
    required String email,
    required String fullName,
    required String role,
    int maxRetries = 3,
  }) async {
    int retryCount = 0;
    
    while (retryCount < maxRetries) {
      try {
        print('🔄 DEBUG: Creating user profile (attempt ${retryCount + 1}/$maxRetries) for userId: $userId');
        
        await supabase.from('users').insert({
          'id': userId,
          'email': email,
          'full_name': fullName,
          'role': role,
          'created_at': DateTime.now().toIso8601String(),
        });
        
        print('✅ DEBUG: User profile created successfully!');
        return; // Success, exit the function
        
      } catch (e) {
        retryCount++;
        print('⚠️ ERROR creating user profile (attempt $retryCount/$maxRetries): $e');
        
        if (retryCount >= maxRetries) {
          print('❌ FATAL: Failed to create user profile after $maxRetries attempts');
          rethrow;
        }
        
        // Wait before retrying (exponential backoff)
        await Future.delayed(Duration(milliseconds: 500 * retryCount));
      }
    }
  }

  // Create User Profile in Database (original method for backward compatibility)
  Future<void> createUserProfile({
    required String userId,
    required String email,
    required String fullName,
    required String role,
  }) async {
    try {
      print('🔄 DEBUG: Creating user profile for userId: $userId');
      await supabase.from('users').insert({
        'id': userId,
        'email': email,
        'full_name': fullName,
        'role': role,
        'created_at': DateTime.now().toIso8601String(),
      });
      print(' DEBUG: User profile created successfully!');
    } catch (e) {
      print(' ERROR creating user profile: $e');
      rethrow;
    }
  }

  // Get User Profile from Database
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      print(' DEBUG: Fetching user profile for userId: $userId');
      final response = await supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        print(' DEBUG: User profile found: ${response['email']}');
      } else {
        print(' WARNING: User profile not found for userId: $userId');
      }
      
      return response;
    } catch (e) {
      print(' ERROR getting user profile: $e');
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

  // Convert Supabase User to App User with Retry Logic
  Future<app_user.User?> getAppUser({int maxRetries = 5}) async {
    final user = currentUser;
    if (user == null) {
      print('⚠️ WARNING: No authenticated user found');
      return null;
    }

    int retryCount = 0;
    
    while (retryCount < maxRetries) {
      try {
        print('🔍 DEBUG: Getting app user (attempt ${retryCount + 1}/$maxRetries) for user: ${user.email}');
        
        final profile = await getUserProfile(user.id);

        if (profile == null) {
          retryCount++;
          print('⚠️ WARNING: Profile not found (attempt $retryCount/$maxRetries), retrying...');
          
          if (retryCount >= maxRetries) {
            print('❌ FATAL: Profile not found after $maxRetries attempts');
            return null;
          }
          
          // Wait before retrying (exponential backoff)
          await Future.delayed(Duration(milliseconds: 500 * retryCount));
          continue;
        }

        final appUser = app_user.User(
          username: user.email?.split('@')[0] ?? 'user',
          password: '',
          role: profile['role'] ?? 'user',
          fullName: profile['full_name'] ?? '',
          email: user.email ?? '',
        );
        
        print('✅ DEBUG: Successfully created app user: ${appUser.email} with role: ${appUser.role}');
        return appUser;
        
      } catch (e) {
        retryCount++;
        print('❌ ERROR converting to app user (attempt $retryCount/$maxRetries): $e');
        
        if (retryCount >= maxRetries) {
          print('❌ FATAL: Failed to get app user after $maxRetries attempts');
          return null;
        }
        
        await Future.delayed(Duration(milliseconds: 500 * retryCount));
      }
    }
    
    return null;
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
      print('Error getting products: $e');
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
      print('Error getting products by category: $e');
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

  // Cart Operations

  // Add item to cart
  Future<void> addToCart({
    required int productId,
    int quantity = 1,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('User not authenticated');

      print('DEBUG: Adding product $productId to cart (quantity: $quantity)');

      // Check if item already in cart
      final existing = await supabase
          .from('cart_items')
          .select()
          .eq('user_id', user.id)
          .eq('product_id', productId)
          .maybeSingle();

      if (existing != null) {
        // Update quantity if already exists
        final newQuantity = existing['quantity'] + quantity;
        await supabase
            .from('cart_items')
            .update({'quantity': newQuantity})
            .eq('id', existing['id']);
        print('DEBUG: Updated cart item quantity to $newQuantity');
      } else {
        // Insert new cart item
        await supabase.from('cart_items').insert({
          'user_id': user.id,
          'product_id': productId,
          'quantity': quantity,
        });
        print('DEBUG: Added new item to cart');
      }
    } catch (e) {
      print('ERROR: Failed to add to cart: $e');
      rethrow;
    }
  }

  // Get cart items with product details
  Future<List<Map<String, dynamic>>> getCartItems() async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('User not authenticated');

      print('DEBUG: Fetching cart items for user ${user.id}');

      final response = await supabase
          .from('cart_with_products')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      print('DEBUG: Found ${response.length} cart items');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('ERROR: Failed to get cart items: $e');
      return [];
    }
  }

  // Update cart item quantity
  Future<void> updateCartItemQuantity({
    required int cartItemId,
    required int quantity,
  }) async {
    try {
      print('DEBUG: Updating cart item $cartItemId quantity to $quantity');

      if (quantity <= 0) {
        // Remove item if quantity is 0 or less
        await removeFromCart(cartItemId);
      } else {
        await supabase
            .from('cart_items')
            .update({'quantity': quantity})
            .eq('id', cartItemId);
        print('DEBUG: Cart item quantity updated');
      }
    } catch (e) {
      print('ERROR: Failed to update cart item: $e');
      rethrow;
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(int cartItemId) async {
    try {
      print('DEBUG: Removing cart item $cartItemId');

      await supabase
          .from('cart_items')
          .delete()
          .eq('id', cartItemId);

      print('DEBUG: Cart item removed');
    } catch (e) {
      print('ERROR: Failed to remove from cart: $e');
      rethrow;
    }
  }

  // Clear entire cart
  Future<void> clearCart() async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('User not authenticated');

      print('DEBUG: Clearing cart for user ${user.id}');

      await supabase
          .from('cart_items')
          .delete()
          .eq('user_id', user.id);

      print('DEBUG: Cart cleared');
    } catch (e) {
      print('ERROR: Failed to clear cart: $e');
      rethrow;
    }
  }

  // Get cart count
  Future<int> getCartCount() async {
    try {
      final user = currentUser;
      if (user == null) return 0;

      final response = await supabase
          .from('cart_items')
          .select('quantity')
          .eq('user_id', user.id);

      if (response.isEmpty) return 0;

      // Sum all quantities
      final count = response.fold<int>(
        0,
        (sum, item) => sum + (item['quantity'] as int),
      );

      return count;
    } catch (e) {
      print('ERROR: Failed to get cart count: $e');
      return 0;
    }
  }

  // Get cart total price
  Future<double> getCartTotal() async {
    try {
      final user = currentUser;
      if (user == null) return 0.0;

      final response = await supabase
          .from('cart_with_products')
          .select('total_price')
          .eq('user_id', user.id);

      if (response.isEmpty) return 0.0;

      // Sum all totals
      final total = response.fold<double>(
        0.0,
        (sum, item) => sum + ((item['total_price'] as num).toDouble()),
      );

      return total;
    } catch (e) {
      print('ERROR: Failed to get cart total: $e');
      return 0.0;
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


