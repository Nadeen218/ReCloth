import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/user_provider.dart';
import '../admin/admin_dashboard.dart';
import 'role_selection_screen.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Sign In with Google Logic
  Future<void> _signInWithGoogle() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED))),
    );

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        if (mounted) Navigator.pop(context);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'name': user.displayName ?? 'User',
            'email': user.email,
            'role': 'Buyer',
            'points': 0,
            'createdAt': FieldValue.serverTimestamp(),
          });
          userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        }

        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

        if (mounted) {
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          userProvider.setUserDetails(
            name: data['name'] ?? 'User',
            role: data['role'] ?? 'Buyer',
            email: user.email!,
            points: data['points'] ?? 0,
          );

          Navigator.pop(context);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(name: data['name'])));
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Google Sign-In Failed: $e")));
    }
  }

  // Email/Password Sign In Logic
  Future<void> _signIn() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED))),
    );

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (!mounted) return;
        Navigator.pop(context);

        if (userDoc.exists) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          userProvider.setUserDetails(
            name: data['name'] ?? 'User',
            role: data['role'] ?? 'Buyer',
            email: user.email!,
            points: data['points'] ?? 0,
          );

          if (data['role'] == 'admin') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(name: data['name'])));
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "Login Failed")));
    } catch (e) {
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EEFF),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Welcome Back',
                    style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
                Center(
                  child: Text(
                    'Sign in to continue your journey',
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.black45),
                  ),
                ),
                const SizedBox(height: 32),

                // Email Field
                Text('Email', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'your@email.com',
                    prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF7C3AED)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 16),

                // Password Field
                Text('Password', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF7C3AED)),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 24),

                // Updated Login Button with the requested Gradient
                GestureDetector(
                  onTap: () {
                    if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
                      _signIn();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all fields')));
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF6B21A8), // Deep Purple
                          Color(0xFF7C3AED), // Medium Purple
                          Color(0xFF9333EA), // Bright Purple
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7C3AED).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.login, color: Colors.white),
                          const SizedBox(width: 10),
                          Text(
                            'Sign In',
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('OR CONTINUE WITH', style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45)),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),

                // Google Sign In
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _signInWithGoogle,
                    icon: const Icon(Icons.g_mobiledata, size: 32, color: Colors.red),                    label: Text('Sign in with Google', style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Don\'t have an account? '),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoleSelectionScreen())),
                        child: Text(
                          'Create Account',
                          style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF7C3AED), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}