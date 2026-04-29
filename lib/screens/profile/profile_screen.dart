import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/user_provider.dart';
import 'edit_profile_screen.dart';
import '../auth/login_screen.dart';
import 'help_support_screen.dart';
import 'settings_screen.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  // Stream to listen to real-time user data from Firestore
  Stream<DocumentSnapshot> _userStatsStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final String userRole = userProvider.role;
    final String userName = userProvider.name;
    final String userEmail = userProvider.email;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "My Profile",
          style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.purple),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
          )
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _userStatsStream(),
        builder: (context, snapshot) {
          // Initialize counters
          int donations = 0;
          int purchases = 0;
          int points = 0;

          if (snapshot.hasData && snapshot.data!.exists) {
            var data = snapshot.data!.data() as Map<String, dynamic>;

            // Map the fields from Firestore
            donations = data['totalDonations'] ?? 0;
            purchases = data['totalPurchases'] ?? 0; // Ensure this matches your Checkout logic
            points = data['points'] ?? 0;
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildHeader(userName, userEmail, userRole),
                const SizedBox(height: 24),

                // Stats Section focusing only on Donations and Purchases
                _buildStatsSection(userRole, points, donations, purchases),

                const SizedBox(height: 24),
                _buildProfileOptions(context, userRole),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(String name, String email, String role) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 55,
          backgroundColor: Color(0xFFE1BEE7),
          child: Icon(Icons.person, size: 50, color: Colors.purple),
        ),
        const SizedBox(height: 12),
        Text(name, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(email, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "Account Type: $role",
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.purple, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  // Updated stats section to show only Purchases, Donations, and Points
  Widget _buildStatsSection(String role, int points, int donations, int purchases) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Show Purchases if Buyer or Both
          if (role == "Buyer" || role == "Both")
            _buildStatCard("Purchases", purchases.toString(), Icons.shopping_bag_outlined, Colors.blue),

          if (role == "Both") const SizedBox(width: 12),

          // Show Donations if Donor or Both
          if (role == "Donor" || role == "Both")
            _buildStatCard("Donations", donations.toString(), Icons.volunteer_activism_outlined, Colors.green),

          const SizedBox(width: 12),

          // Points are shown for all users
          _buildStatCard("Points", points.toString(), Icons.stars_rounded, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(title, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOptions(BuildContext context, String userRole) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          _optionTile("Settings", Icons.settings_outlined, Colors.grey, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen(role: userRole)));
          }),
          const Divider(),
          _optionTile("Help & Support", Icons.help_outline, Colors.green, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen()));
          }),
          const Divider(),
          _optionTile("Logout", Icons.logout, Colors.redAccent, () async {
            await FirebaseAuth.instance.signOut();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
            );
          }),
        ],
      ),
    );
  }

  Widget _optionTile(String title, IconData icon, Color color, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
    );
  }
}