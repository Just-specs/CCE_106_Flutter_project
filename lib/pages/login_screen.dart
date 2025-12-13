import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fresh_petals/services/supabase_service.dart';
import 'package:fresh_petals/home_page.dart';
import 'package:fresh_petals/admin/admin_home.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:fresh_petals/pages/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSuccessfulSignIn() async {
    try {
      final appUser = await _supabaseService.getAppUser();

      if (appUser != null && mounted) {
        // Trim the role to remove any whitespace
        final userRole = appUser.role.trim().toLowerCase();
        if (userRole == 'admin') {
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
      } else {
        if (mounted) {
          // Show error to user
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to load user profile. Please try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );

          // Sign out the user since profile couldn't be loaded
          await _supabaseService.signOut();

          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );

        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showForgotPasswordDialog() {
    final TextEditingController emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your email address and we\'ll send you a link to reset your password.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              emailController.dispose();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              
              if (email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter your email'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              Navigator.pop(context);
              
              try {
                await _supabaseService.supabase.auth.resetPasswordForEmail(
                  email,
                  redirectTo: 'io.supabase.flutterquickstart://reset-password',
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Password reset link sent to $email. Please check your inbox.',
                      ),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to send reset email: ${e.toString()}'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              } finally {
                emailController.dispose();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BFAE),
            ),
            child: const Text('Send Reset Link', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _login() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email and password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await _supabaseService.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (response.user != null) {
        await _handleSuccessfulSignIn();
      } else {
        throw Exception('Login failed: No user returned');
      }
    } catch (e) {
      if (!mounted) return;

      String errorMessage = 'Login failed: ${e.toString()}';

      // Provide more user-friendly error messages
      if (e.toString().contains('Invalid login credentials')) {
        errorMessage = 'Invalid email or password';
      } else if (e.toString().contains('Email not confirmed')) {
        errorMessage = 'Please verify your email address';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );

      setState(() {
        isLoading = false;
      });
    }
  }

  void _continueWithGoogle() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await _supabaseService.signInWithGoogle();

      // For Web: OAuth redirect will handle the sign-in
      // The auth state listener will catch the successful sign-in
      if (!kIsWeb && response.user != null) {
        // For Mobile: Handle immediately
        await _handleSuccessfulSignIn();
      } else if (kIsWeb) {
        // For Web: Show a message that redirect is happening
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Redirecting to Google Sign-In...'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google Sign-In failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEDE7F6), // light purple
              Color(0xFFF3F3F7), // very light gray
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 225, 219, 219),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFB39DDB).withOpacity(0.18), // soft purple shadow
                      blurRadius: 32,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28.0,
                    vertical: 36,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Color.fromARGB(255, 147, 130, 178), // lighter purple
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/fresh_petal.png',
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text('Login', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF7C4DFF))),
                      const SizedBox(height: 8),
                      Text('Welcome Back', style: TextStyle(fontSize: 16, color: Color(0xFF7C4DFF).withOpacity(0.7))),
                      const SizedBox(height: 32),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFB39DDB).withOpacity(0.10),
                              blurRadius: 16,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Color(0xFFD1C4E9))),
                            hintText: 'Email or Phone number',
                            filled: true,
                            fillColor: Color(0xFFF3F3F7),
                            prefixIcon: Icon(Icons.email, color: Color(0xFF7C4DFF)),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          enabled: !isLoading,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFB39DDB).withOpacity(0.10),
                              blurRadius: 16,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Color(0xFFD1C4E9))),
                            hintText: 'Password',
                            filled: true,
                            fillColor: Color(0xFFF3F3F7),
                            prefixIcon: Icon(Icons.lock, color: Color(0xFF7C4DFF)),
                          ),
                          obscureText: true,
                          enabled: !isLoading,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Forgot Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: isLoading
                              ? null
                              : _showForgotPasswordDialog,
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Color(0xFF7C4DFF), // softer purple
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C4DFF), // medium purple
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 8,
                            shadowColor: Color(0xFFB39DDB).withOpacity(0.25),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Text('Login', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(child: Divider(color: Color(0xFFD1C4E9), thickness: 1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('or', style: TextStyle(color: Color(0xFF7C4DFF).withOpacity(0.7))),
                          ),
                          Expanded(child: Divider(color: Color(0xFFD1C4E9), thickness: 1)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isLoading ? null : _continueWithGoogle,
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Color(0xFFF3F3F7),
                                side: BorderSide(color: Color(0xFF7C4DFF)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shadowColor: Color(0xFFB39DDB).withOpacity(0.10),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.network(
                                    'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                                    height: 22,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Icon(Icons.login, color: Color(0xFF7C4DFF)),
                                  ),
                                  SizedBox(width: 10),
                                  Text('Google', style: TextStyle(color: Color(0xFF7C4DFF), fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: null, // Placeholder for Facebook
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Color(0xFFF3F3F7),
                                side: BorderSide(color: Color(0xFF9575CD)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Text('Facebook', style: TextStyle(color: Color(0xFF9575CD), fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account? ", style: TextStyle(color: Color(0xFF7C4DFF).withOpacity(0.7))),
                          TextButton(
                            onPressed: isLoading ? null : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const RegisterScreen()),
                              );
                            },
                            child: Text('Sign Up', style: TextStyle(color: Color(0xFF7C4DFF), fontWeight: FontWeight.bold)),
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

