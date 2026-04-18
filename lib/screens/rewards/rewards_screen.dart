import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

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
    int userPoints = 120; //  Firebase

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Points Card
            Container(
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
                  Text('$userPoints',
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
                      userRole == 'Donor'
                          ? '🎁 Donate more to earn points!'
                          : userRole == 'Buyer'
                          ? '🛍️ Shop more to earn points!'
                          : '♻️ Donate & Shop to earn more points!',
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SizedBox(height: 16),
            // Progress to next reward
            Container(
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
                      Text('Next Reward',
                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold)),
                      Text('$userPoints / 150 points',
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.purple, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: userPoints / 150,
                      minHeight: 10,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('${150 - userPoints} points away from Free Shipping 🚚',
                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45)),
                ],
              ),
            ),

            // How to earn points
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
            if (userRole == 'Buyer'|| userRole == 'Both') ...[
              _earnCard('Purchase an Item', '+5 points', Icons.shopping_bag_outlined, Colors.blue),
              const SizedBox(height: 8),
              _earnCard('Remake Studio Suggestion', '+30 points', Icons.auto_awesome, Colors.orange),
            ],
            const SizedBox(height: 24),

            // Redeem Rewards
            Text('Redeem Rewards',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._rewards.where((reward) {
              if (reward['donorOnly'] == true) return userRole == 'Donor' || userRole == 'Both';
              if (reward['buyerOnly'] == true) return userRole == 'Buyer' || userRole == 'Both';
              return true;
            }).map((reward) {
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
                          Text(reward['title'],
                              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold)),
                          Text(reward['description'],
                              style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45)),
                          const SizedBox(height: 4),
                          Text('${reward['points']} points',
                              style: GoogleFonts.poppins(fontSize: 12, color: Colors.purple, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: canRedeem ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${reward['title']} redeemed!', style: GoogleFonts.poppins())),
                        );
                      } : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        canRedeem ? 'Redeem' : 'Locked',
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
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
          Expanded(
            child: Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(points, style: GoogleFonts.poppins(fontSize: 12, color: Colors.purple, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}