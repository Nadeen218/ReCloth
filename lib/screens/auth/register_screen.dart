import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';
import 'role_selection_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  final String role;
  const RegisterScreen({super.key, required this.role});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _obscurePassword = true;

  String get _roleLabel {
    if (widget.role == 'Both') return 'Donor & Buyer';
    return widget.role;
  }

  Future<void> _signUp() async {
    // Show Loading Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED))),
    );

    try {
      // Create account in Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Save additional data in firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'role': widget.role,
        'points': 0, // Initial points
        'createdAt': DateTime.now(),
      });

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account Created Successfully!')),
      );

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));

    } on FirebaseAuthException catch (e) {
      if (mounted) Navigator.pop(context);
      String message = "An error occurred";
      if (e.code == 'weak-password') message = "The password is too weak.";
      else if (e.code == 'email-already-in-use') message = "Email already exists.";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
                  color: const Color(0xFF7C3AED).withOpacity(0.1),
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
                    'Create Account',
                    style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
                Center(
                  child: Text(
                    'Joining as $_roleLabel',
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.black45),
                  ),
                ),
                const SizedBox(height: 32),

                // Full Name
                _buildLabel('Full Name'),
                _buildTextField(_nameController, 'e.g. Nadeen Abu Hilweh', Icons.person_outline),
                const SizedBox(height: 16),

                // Email
                _buildLabel('Email'),
                _buildTextField(_emailController, 'your@email.com', Icons.email_outlined, type: TextInputType.emailAddress),
                const SizedBox(height: 16),

                // Password
                _buildLabel('Password'),
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
                const SizedBox(height: 16),

                // Phone
                _buildLabel('Phone Number'),
                _buildTextField(_phoneController, '+970 59x xxx xxx', Icons.phone_outlined, type: TextInputType.phone),
                const SizedBox(height: 16),

                // Address
                _buildLabel('Address'),
                _buildTextField(_addressController, 'e.g. Jerusalem', Icons.location_on_outlined),
                const SizedBox(height: 32),

                // Create Account Button with Gradient
                GestureDetector(
                  onTap: () {
                    if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
                      _signUp();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill in all fields')),
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF6B21A8),
                          Color(0xFF7C3AED),
                          Color(0xFF9333EA),
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
                      child: Text(
                        'Create Account',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Back to Role Selection
                Center(
                  child: TextButton.icon(
                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RoleSelectionScreen())),
                    icon: const Icon(Icons.arrow_back, size: 16, color: Color(0xFF7C3AED)),
                    label: Text('Change User Type', style: GoogleFonts.poppins(color: const Color(0xFF7C3AED), fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),

                // Footer: Sign In Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account? ", style: GoogleFonts.poppins(fontSize: 13)),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                      child: Text('Sign In', style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF7C3AED), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widget for Labels
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)),
    );
  }

  // Helper Widget for TextFields
  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF7C3AED)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}