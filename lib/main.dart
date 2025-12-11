import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fresh_petals/pages/login_screen.dart';
import 'package:fresh_petals/pages/reset_password_screen.dart';
import 'package:fresh_petals/services/supabase_service.dart';
import 'package:fresh_petals/home_page.dart';
import 'package:fresh_petals/admin/admin_home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );
  
  // Initialize Supabase Service
  await SupabaseService.instance.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fresh Petals',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AuthStateHandler(),
    );
  }
}

class AuthStateHandler extends StatefulWidget {
  const AuthStateHandler({super.key});

  @override
  State<AuthStateHandler> createState() => _AuthStateHandlerState();
}

class _AuthStateHandlerState extends State<AuthStateHandler> {
  final _supabaseService = SupabaseService.instance;
  bool _isLoading = true;
  Widget? _initialScreen;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
    _handleDeepLink();
  }

  void _handleDeepLink() {
    // Listen for auth state changes (including password reset)
    _supabaseService.supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      
      if (event == AuthChangeEvent.passwordRecovery) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const ResetPasswordScreen()),
            (route) => false,
          );
        }
      }
    });
  }

  Future<void> _checkAuthState() async {
    try {
      // Check if user is authenticated
      final currentUser = _supabaseService.currentUser;
      
      if (currentUser != null) {
        // Get the app user with profile
        final appUser = await _supabaseService.getAppUser();
        
        if (appUser != null) {
          // Navigate based on role
          if (appUser.role.trim().toLowerCase() == 'admin') {
            setState(() {
              _initialScreen = AdminHome(currentUser: appUser);
              _isLoading = false;
            });
          } else {
            setState(() {
              _initialScreen = HomePage(currentUser: appUser);
              _isLoading = false;
            });
          }
        } else {
          // Profile not found, sign out and go to login
          await _supabaseService.signOut();
          setState(() {
            _initialScreen = const LoginScreen();
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _initialScreen = const LoginScreen();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _initialScreen = const LoginScreen();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
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
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Color(0xFF00BFAE),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _initialScreen ?? const LoginScreen();
  }
}


