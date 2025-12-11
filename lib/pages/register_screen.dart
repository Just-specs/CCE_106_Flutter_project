import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fresh_petals/services/supabase_service.dart';
import 'package:fresh_petals/pages/login_screen.dart';
import 'package:fresh_petals/home_page.dart';
import 'package:fresh_petals/admin/admin_home.dart';
import 'package:fresh_petals/models/user.dart' as app_user;
import 'package:flutter/foundation.dart' show kIsWeb;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final _supabaseService = SupabaseService.instance;

  @override
  void initState() {
    super.initState();
    // Listen for auth state changes (important for OAuth redirect)
    _supabaseService.supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn && mounted) {
        _handleSuccessfulSignIn();
      }
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSuccessfulSignIn() async {
    final appUser = await _supabaseService.getAppUser();
    if (appUser != null && mounted) {
      if (appUser.role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminHome(currentUser: appUser),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(currentUser: appUser),
          ),
        );
      }
    }
  }

  void _register() async {
    // Validation
    if (_fullNameController.text.trim().isEmpty) {
      _showSnackBar('Please enter your full name', Colors.red);
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      _showSnackBar('Please enter your email', Colors.red);
      return;
    }

    if (!_isValidEmail(_emailController.text.trim())) {
      _showSnackBar('Please enter a valid email address', Colors.red);
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showSnackBar('Please enter a password', Colors.red);
      return;
    }

    if (_passwordController.text.length < 6) {
      _showSnackBar('Password must be at least 6 characters', Colors.red);
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('Passwords do not match', Colors.red);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await _supabaseService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
      );

      if (response.user != null) {
        if (!mounted) return;
        
        // Show success message
        _showSnackBar('Account created successfully! Please check your email to verify.', Colors.green);
        
        // Wait a moment then navigate to login or home
        await Future.delayed(const Duration(seconds: 2));
        
        if (mounted) {
          // Give time for profile to be created
          await Future.delayed(const Duration(milliseconds: 500));
          await _handleSuccessfulSignIn();
        }
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Registration failed: ${e.toString()}', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _continueWithGoogle() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await _supabaseService.signInWithGoogle();

      // For Web: OAuth redirect will handle the sign-in
      if (!kIsWeb && response.user != null) {
        // For Mobile: Handle immediately
        // Give time for profile to be created
          await Future.delayed(const Duration(milliseconds: 500));
          await _handleSuccessfulSignIn();
      } else if (kIsWeb) {
        // For Web: Show a message that redirect is happening
        if (mounted) {
          _showSnackBar('Redirecting to Google Sign-In...', Colors.blue);
        }
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Google Sign-In failed: ${e.toString()}', Colors.red);
      setState(() {
        isLoading = false;
      });
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F5F5),
              Color(0xFFE0E0E0),
              Color(0xFFBDBDBD),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
              child: Card(
                elevation: 8,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 36),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Color(0xFFE0E0E0),
                        child: Icon(Icons.local_florist, size: 48, color: Color(0xFF00BFAE)),
                      ),
                      const SizedBox(height: 22),
                      Text('Create Account', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF212121))),
                      const SizedBox(height: 8),
                      Text('Sign up to get started', style: TextStyle(fontSize: 16, color: Color(0xFF757575))),
                      const SizedBox(height: 32),
                      
                      // Full Name Field
                      TextField(
                        controller: _fullNameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Color(0xFFBDBDBD)),
                          ),
                          hintText: 'Full Name',
                          filled: true,
                          fillColor: Color(0xFFF5F5F5),
                          prefixIcon: Icon(Icons.person, color: Color(0xFF00BFAE)),
                        ),
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 18),
                      
                      // Email Field
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Color(0xFFBDBDBD)),
                          ),
                          hintText: 'Email',
                          filled: true,
                          fillColor: Color(0xFFF5F5F5),
                          prefixIcon: Icon(Icons.email, color: Color(0xFF00BFAE)),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 18),
                      
                      // Password Field
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Color(0xFFBDBDBD)),
                          ),
                          hintText: 'Password',
                          filled: true,
                          fillColor: Color(0xFFF5F5F5),
                          prefixIcon: Icon(Icons.lock, color: Color(0xFF00BFAE)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Color(0xFF757575),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscurePassword,
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 18),
                      
                      // Confirm Password Field
                      TextField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Color(0xFFBDBDBD)),
                          ),
                          hintText: 'Confirm Password',
                          filled: true,
                          fillColor: Color(0xFFF5F5F5),
                          prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF00BFAE)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                              color: Color(0xFF757575),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscureConfirmPassword,
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 24),
                      
                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00BFAE),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 2,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Text('Create Account', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: Color(0xFFBDBDBD), thickness: 1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('or', style: TextStyle(color: Color(0xFF757575))),
                          ),
                          Expanded(child: Divider(color: Color(0xFFBDBDBD), thickness: 1)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Google Sign-In Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: isLoading ? null : _continueWithGoogle,
                          icon: Image.network(
                            'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                            height: 24,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.login, color: Color(0xFF00BFAE)),
                          ),
                          label: Text('Continue with Google', style: TextStyle(color: Color(0xFF212121), fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Color(0xFFBDBDBD)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Already have an account? ', style: TextStyle(color: Color(0xFF757575))),
                          TextButton(
                            onPressed: isLoading ? null : () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                              );
                            },
                            child: Text('Sign In', style: TextStyle(color: Color(0xFF00BFAE), fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
