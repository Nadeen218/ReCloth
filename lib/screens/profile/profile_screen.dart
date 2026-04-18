import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import 'edit_profile_screen.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int donationCount = 5;
  int purchaseCount = 3;
  int points = 150;
  int ordersCount = 3;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userRole = userProvider.role;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("My Profile",
            style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.purple),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildHeader(userRole),
            const SizedBox(height: 24),

            _buildStatsSection(userRole),
            const SizedBox(height: 24),

            _buildProfileOptions(userRole),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String userRole) {
    return Column(
      children: [
        Stack(
          children: [
            const CircleAvatar(
              radius: 55,
              backgroundImage: NetworkImage("https://via.placeholder.com/150"),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.purple, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 12),
        Text("Nadeen Abu Hilweh", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
        Text("nadeenabuhilweh@gmail.com", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: Text("Account Type: $userRole",
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.purple, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildStatsSection(String userRole) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // for buyer or both
          if (userRole == "Buyer" || userRole == "Both")
            _buildStatCard("Purchases", purchaseCount.toString(), Icons.shopping_bag_outlined, Colors.blue),

          if (userRole == "Both") const SizedBox(width: 12),

          // for donor or both
          if (userRole == "Donor" || userRole == "Both")
            _buildStatCard("Donations", donationCount.toString(), Icons.volunteer_activism_outlined, Colors.green),

          const SizedBox(width: 12),
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
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
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

  Widget _buildProfileOptions(String userRole) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          _optionTile("Switch Account Type", Icons.swap_horiz, Colors.blue, () {
            _showAccountTypeDialog();
          }),

          if (userRole == "Buyer" || userRole == "Both") ...[
            const Divider(),
            _optionTile(
              "My Orders",
              Icons.history,
              Colors.orange,
                  () {},
              trailingText: ordersCount > 0 ? "$ordersCount Orders" : "No Orders",
            ),
          ],

          if (userRole == "Donor" || userRole == "Both") ...[
            const Divider(),
            _optionTile(
              "My Donations",
              Icons.volunteer_activism_outlined,
              Colors.green,
                  () {},
              trailingText: donationCount > 0 ? "$donationCount Items" : "No Items",
            ),
          ],

          const Divider(),
          _optionTile("Help & Support", Icons.help_outline, Colors.green, () {}),
          const Divider(),
          _optionTile("Logout", Icons.logout, Colors.grey, () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
            );
          }),
        ],
      ),
    );
  }

  Widget _optionTile(String title, IconData icon, Color color, VoidCallback onTap, {String? trailingText}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (trailingText != null)
            Text(trailingText,
                style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    );
  }

  void _showAccountTypeDialog() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Change Account Type", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ["Donor", "Buyer", "Both"].map((role) {
            return ListTile(
              title: Text(role, style: GoogleFonts.poppins()),
              leading: Radio<String>(
                value: role,
                groupValue: userProvider.role,
                activeColor: Colors.purple,
                onChanged: (value) {
                  userProvider.setRole(value!);
                  Navigator.pop(context);
                },
              ),
              onTap: () {
                userProvider.setRole(role);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}