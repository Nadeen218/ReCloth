import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EEFF),
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20,),
            Text(
              'Join ReCloth',
              style:GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold,color: Colors.black87),
            ),
            Text("Choose how you would like to participate",
              style: GoogleFonts.poppins(fontSize: 13,color: Colors.black45),
            ),
            const SizedBox(height: 24,),
            //donor option
            _roleCard(
              role: 'Donor',
              icon: Icons.favorite_outline,
              description: 'Donate clothes and earn rewards',
              features: ['Easy pickup service', 'Earn eco points', 'Track your impact','Affordable donation fee'],
            ),
            const SizedBox(height: 16),
            //buyer option
            _roleCard(
              role: 'Buyer',
              icon: Icons.shopping_bag_outlined,
              description: 'Shop sustainable fashion',
              features: ['Quality recycled items', 'Affordable prices', 'Eco-friendly shopping'],
            ),
            const SizedBox(height: 16),
            //both
            _roleCard(
              role: 'Both',
              icon: Icons.people_outline,
              description: 'Donate and shop together',
              features: ['All features included', 'Maximum rewards', 'Full community access'],
            ),
            const SizedBox(height:16),
            //if user already have an account
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Already have an account?",
                style: GoogleFonts.poppins(fontSize: 13)),
                GestureDetector(onTap: (){
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                  child: Text('Sign In',
                  style: GoogleFonts.poppins(fontSize: 13,color: Colors.deepPurple,fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            )
          ],
        ),
      ),),
    );
  }
  Widget _roleCard({
    required String role,
    required IconData icon,
    required String description,
    required List<String> features,
  }) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
     onTap: () {
        setState(() => _selectedRole = role);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RegisterScreen(role: role),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.purple : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Colors.purple.withOpacity(0.15)
                  : Colors.grey.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF3EEFF),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.purple, size: 28),
            ),
            const SizedBox(height: 12),
            Text(role, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(description, style: GoogleFonts.poppins(fontSize: 12, color: Colors.black45)),
            const SizedBox(height: 12),
            ...features.map((f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Icon(Icons.check, color: Colors.purple, size: 16),
                  const SizedBox(width: 8),
                  Text(f, style: GoogleFonts.poppins(fontSize: 12)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

