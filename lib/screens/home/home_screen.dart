import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../donate/donate_screen.dart';
//import '../donate/track_donations_screen.dart';

class HomeScreen extends StatefulWidget {
  final String role;
  final String name;

  const HomeScreen({super.key, required this.role, required this.name});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EEFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hello, ${widget.name}! 👋',
                            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text('Welcome back to ReCloth',
                            style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.stars, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text('120 Points', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Impact st
                    if (widget.role == 'Donor' || widget.role == 'Both') ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.08), blurRadius: 10)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Your Impact This Month',
                                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
                                Row(children: [
                                  const Icon(Icons.location_on, size: 14, color: Colors.purple),
                                  Text('Palestine', style: GoogleFonts.poppins(fontSize: 12, color: Colors.purple)),
                                ]),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _statItem('♻️', '12', 'Items Donated'),
                                _statItem('🤍', '8', 'Lives Impacted'),
                                _statItem('🌿', '15kg', 'CO₂ Saved', color: Colors.deepPurple),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Quick action
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.3,
                      children: [
                        if (widget.role == 'Donor' || widget.role == 'Both')
                          _actionCard(Icons.checkroom, 'Donate Clothes', 'Give your clothes a second life', () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const DonateScreen()));
                          }),
                        if (widget.role == 'Buyer' || widget.role == 'Both')
                          _actionCard(Icons.shopping_bag_outlined, 'Shop', 'Browse recycled fashion', () {}),
                        _actionCard(Icons.card_giftcard, 'Rewards', 'Redeem your eco points', () {}),
                        if (widget.role == 'Donor' || widget.role == 'Both')
                          _actionCard(Icons.track_changes, 'Track Donation', 'Follow your donation journey', () {
                           // Navigator.push(context, MaterialPageRoute(builder: (_) => const TrackDonationsScreen()));
                          }),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Featured offers
                    Text('Featured Offers',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _offerCard('Winter Collection', 'Up to 40% off on recycled winter wear', 'assets/winter.jpg'),
                    const SizedBox(height: 12),
                    _offerCard('Donate & Earn', 'Get 20 bonus points on your next donation', 'assets/donateEarn.jpg'),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // bottom navigation
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            if (widget.role == 'Donor' || widget.role == 'Both') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DonateScreen()));
            }
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.checkroom), label: 'Donate'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: 'Rewards'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _statItem(String emoji, String value, String label, {Color color = Colors.black87}) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45)),
      ],
    );
  }

  Widget _actionCard(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.08), blurRadius: 10)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: Colors.deepPurple, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 8),
            Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold)),
            Text(subtitle, style: GoogleFonts.poppins(fontSize: 10, color: Colors.black45), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _offerCard(String title, String subtitle, String imagePath) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.08), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.asset(imagePath, fit: BoxFit.cover, width: double.infinity),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
                Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: Colors.black45)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}