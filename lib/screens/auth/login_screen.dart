import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    'Sign in to continue your journey',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black45,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Email
                Text('Email', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'your@email.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 16),

                // Password
                Text('Password', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 24),
                //sign in button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    // Temporary until I connect Firebase
                    onPressed: () {
                      String email = _emailController.text.trim();

                      if (email == 'Admin@gmail.com') {//ADMIN MAIL
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const AdminDashboard()),
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HomeScreen(role: 'Both', name: 'Nadeen'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.login, color: Colors.white),
                    label: Text('Sign In', style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                //or
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('OR CONTINUE WITH',style: GoogleFonts.poppins(fontSize: 11,color: Colors.black45)),
                    ),
                    const Expanded(child: Divider()),//mid it
                  ],
                ),
                const SizedBox(height: 16),
                //google button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(onPressed: (){

                  },
                    icon:const Icon(Icons.g_mobiledata,size: 28),
                    label: Text('Sign in with Google',style:GoogleFonts.poppins(fontSize:14)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                //forget pass
                Center(
                  child: TextButton(onPressed:(){},
                    child: Text('Forget Password?',style: GoogleFonts.poppins(color: Colors.deepPurple)),
                  ),
                ),
                //register
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Dont have an account?',style: GoogleFonts.poppins(fontSize: 13)),
                      GestureDetector(
                        onTap: (){
                          Navigator.push(context,MaterialPageRoute(builder: (_) => RoleSelectionScreen()),);
                          },
                        child: Text('Create Account',style: GoogleFonts.poppins(fontSize: 13,color: Colors.deepPurple,fontWeight: FontWeight.bold),),
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