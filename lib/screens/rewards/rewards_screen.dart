import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/user_provider.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  // Rewards list configuration
  final List<Map<String, dynamic>> _rewards = const [
    {
      'title': '10% Off Next Purchase',
      'points': 100,
      'icon': Icons.local_offer_outlined,
      'color': Colors.blue,
      'description': 'Get 10% discount on your next shop order',
    },
    {
      'title': 'Free Shipping',
      'points': 150,
      'icon': Icons.local_shipping_outlined,
      'color': Colors.green,
      'description': 'Free delivery on your next order',
    },
    {
      'title': '20% Off Next Purchase',
      'points': 200,
      'icon': Icons.discount_outlined,
      'color': Colors.orange,
      'description': 'Get 20% discount on your next shop order',
    },
    {
      'title': 'Priority Pickup',
      'points': 250,
      'icon': Icons.star_outlined,
      'color': Colors.purple,
      'description': 'Get priority pickup for your next donation',
      'donorOnly': true,
    },
    {
      'title': 'Exclusive Item Access',
      'points': 300,
      'icon': Icons.lock_open_outlined,
      'color': Colors.red,
      'description': 'Get early access to new shop items',
      'buyerOnly': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final userRole = Provider.of<UserProvider>(context).role;
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Rewards',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
      ),
      // UPDATED: Now listening to the USER document directly
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.purple));
          }

          int userPoints = 0;
          if (snapshot.hasData && snapshot.data!.exists) {
            // Fetch points from the 'points' field that Admin updates
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            userPoints = (userData['points'] as num? ?? 0).toInt();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Points Card displaying the live data from 'users' collection
                _buildPointsCard(userPoints, userRole),

                const SizedBox(height: 24),

                // Progress tracker logic
                _buildProgressBar(userPoints),

                const SizedBox(height: 24),

                // Static UI section for points info
                Text('How to Earn Points',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (userRole == 'Donor' || userRole == 'Both') ...[
                  _earnCard('Symbolic Payment Donation', '+10 points', Icons.favorite_outline, Colors.pink),
                  const SizedBox(height: 8),
                  _earnCard('App Credits Donation', '+15 points', Icons.card_giftcard, Colors.blue),
                  const SizedBox(height: 8),
                  _earnCard('Full Donation', '+20 points', Icons.volunteer_activism, Colors.green),
                ],
                const SizedBox(height: 24),

                // Redeemable rewards list
                Text('Redeem Rewards',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ..._rewards.where((reward) {
                  if (reward['donorOnly'] == true) return userRole == 'Donor' || userRole == 'Both';
                  if (reward['buyerOnly'] == true) return userRole == 'Buyer' || userRole == 'Both';
                  return true;
                }).map((reward) => _buildRewardItem(context, reward, userPoints)),
              ],
            ),
          );
        },
      ),
    );
  }

  // UI Helper Methods (Remain identical to your original design)

  Widget _buildPointsCard(int points, String? role) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.deepPurple, Colors.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.stars_rounded, color: Colors.amber, size: 48),
          const SizedBox(height: 12),
          Text('$points',
              style: GoogleFonts.poppins(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
          Text('Available Points',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              role == 'Donor' ? '🎁 Donate more to earn points!' : '♻️ Keep going!',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(int points) {
    int nextGoal = 150;
    double progress = (points / nextGoal).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Next Reward', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold)),
              Text('$points / $nextGoal points',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.purple, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
            ),
          ),
          const SizedBox(height: 8),
          if (points < nextGoal)
            Text('${nextGoal - points} points away from Free Shipping 🚚',
                style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45)),
        ],
      ),
    );
  }

  Widget _buildRewardItem(BuildContext context, Map<String, dynamic> reward, int userPoints) {
    bool canRedeem = userPoints >= reward['points'];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (reward['color'] as Color).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(reward['icon'] as IconData, color: reward['color'] as Color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reward['title'], style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold)),
                Text(reward['description'], style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45)),
                const SizedBox(height: 4),
                Text('${reward['points']} points',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.purple, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: canRedeem ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${reward['title']} redeemed!')),
              );
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(canRedeem ? 'Redeem' : 'Locked', style: const TextStyle(color: Colors.white, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _earnCard(String title, String points, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500))),
          Text(points, style: GoogleFonts.poppins(fontSize: 12, color: Colors.purple, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}