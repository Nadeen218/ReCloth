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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                'Join ReCloth',
                style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Choose how you would like to participate",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 32),

              // Donor Option
              _roleCard(
                role: 'Donor',
                icon: Icons.favorite_rounded,
                description: 'Donate clothes and earn rewards',
                features: ['Easy pickup service', 'Earn eco points', 'Track your impact', 'Affordable donation fee'],
              ),
              const SizedBox(height: 20),

              // Buyer Option
              _roleCard(
                role: 'Buyer',
                icon: Icons.shopping_bag_rounded,
                description: 'Shop sustainable fashion',
                features: ['Quality recycled items', 'Affordable prices', 'Eco-friendly shopping'],
              ),
              const SizedBox(height: 20),

              // Both Option
              _roleCard(
                role: 'Both',
                icon: Icons.auto_awesome_rounded,
                description: 'Donate and shop together',
                features: ['All features included', 'Maximum rewards', 'Full community access'],
              ),
              const SizedBox(height: 32),

              // Already have an account?
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: Text(
                      'Sign In',
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF7C3AED),
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
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
        // Small delay to show selection effect before moving
        Future.delayed(const Duration(milliseconds: 200), () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RegisterScreen(role: role),
            ),
          );
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          // Gradient border effect when selected
          border: Border.all(
            color: isSelected ? const Color(0xFF7C3AED) : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF7C3AED).withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Icon Container with theme color
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3EEFF),
                shape: BoxShape.circle,
                border: Border.all(
                    color: const Color(0xFFE1BEE7),
                    width: 1
                ),
              ),
              child: Icon(icon, color: const Color(0xFF7C3AED), size: 32),
            ),
            const SizedBox(height: 16),

            // Role Title
            Text(
              role,
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4A148C)
              ),
            ),
            const SizedBox(height: 4),

            // Description
            Text(
              description,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 16),

            // Features List
            ...features.map((f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF4CAF50), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      f,
                      style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}