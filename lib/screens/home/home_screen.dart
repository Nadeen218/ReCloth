import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../donate/donate_screen.dart';
import '../donate/track_donations_screen.dart';
import '../shop/shop_screen.dart';

class HomeScreen extends StatefulWidget {
  final String role; //Buyer, Donor, Both
  final String name;

  const HomeScreen({super.key, required this.role, required this.name});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // select item depend on role
    List<BottomNavigationBarItem> navItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      if (widget.role == 'Donor' || widget.role == 'Both')
        const BottomNavigationBarItem(icon: Icon(Icons.checkroom), label: 'Donate'),
      const BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: 'Shop'),
      if (widget.role == 'Buyer' || widget.role == 'Both')
        const BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'Remake'),
      const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF3EEFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header
              _buildHeader(),

              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Impact st
                    if (widget.role == 'Donor' || widget.role == 'Both') ...[
                      _buildImpactCard(),
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
                      children: _buildGridCards(context),
                    ),
                    _buildAboutUsSection(),
                    const SizedBox(height: 20),
                    // featured offers
                    Text('Featured Offers',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _offerCard('Winter Collection', 'Up to 40% off on recycled winter wear', 'assets/winter.jpg'),
                    const SizedBox(height: 12),
                    if (widget.role != 'Buyer')
                      _offerCard('Donate & Earn', 'Get 20 bonus points on your next donation', 'assets/donateEarn.jpg'),
                    const SizedBox(height: 16),
                    _buildFeedbackSection(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        items: navItems,
        onTap: (index) {
          // move depend on label
          String label = navItems[index].label!;
          if (label == 'Donate') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const DonateScreen()));
          } else if (label == 'Shop') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen()));
          } else if (label == 'Remake') {
          }
        },
      ),
    );
  }

  // build depend on role
  List<Widget> _buildGridCards(BuildContext context) {
    List<Widget> cards = [];

    // doner option
    if (widget.role == 'Donor' || widget.role == 'Both') {
      cards.add(_actionCard(Icons.checkroom, 'Donate', 'Give a second life', () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const DonateScreen()));
      }));
      cards.add(_actionCard(Icons.track_changes, 'Track', 'Follow your item', () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const TrackDonationsScreen()));
      }));
    }

    // buyer option
    if (widget.role == 'Buyer' || widget.role == 'Both') {
      cards.add(_actionCard(Icons.shopping_bag_outlined, 'Shop', 'Recycled fashion', () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen()));
      }));
      cards.add(_actionCard(Icons.auto_awesome, 'Remake Studio', 'Suggest designs', () {
        // Navigator.push(context, MaterialPageRoute(builder: (_) => const RemakeStudioScreen()));
      }));
    }

    // both
    cards.add(_actionCard(Icons.card_giftcard, 'Rewards', 'Redeem points', () {}));

    return cards;
  }


  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello, ${widget.name}! 👋',
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              _buildRoleBadge(),
              Text('Welcome back to ReCloth',
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70)),
            ],
          ),
          _buildPointsBadge(),
        ],
      ),
    );
  }

  Widget _buildRoleBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white30),
      ),
      child: Text(
        widget.role.toUpperCase(),
        style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  //feedback section
  Widget _buildFeedbackSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Community Voices',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _feedbackItem('Sarah J.', 'Donor', 'Amazing quality for refurbished clothes!'),
              _feedbackItem('Omar K.', 'Buyer', 'Fast delivery and very clean items.'),
              _feedbackItem('Hiba M.', 'Both', 'Love the sustainable mission of this app.'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _feedbackItem(String name, String userRole, String text) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.purple.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
                5, (i) => const Icon(Icons.star, color: Colors.amber, size: 14)),
          ),
          const SizedBox(height: 8),
          Text(text,
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.black87),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('- $name',
                  style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  userRole,
                  style: GoogleFonts.poppins(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildAboutUsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.deepPurple.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          const Icon(Icons.eco_rounded, color: Colors.green, size: 40),
          const SizedBox(height: 12),
          Text(
            'Our Mission',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'ReCloth is a sustainable fashion community in Palestine. We collect, refurbish, and give your pre-loved clothes a second life to protect our planet.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          const Icon(Icons.stars, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text('120 Points', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildImpactCard() {
    return Container(
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
              Text('Your Impact This Month', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
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
            Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            Text(subtitle, style: GoogleFonts.poppins(fontSize: 9, color: Colors.black45), textAlign: TextAlign.center),
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
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              child: imagePath.startsWith('assets')
                  ? Image.asset(imagePath, fit: BoxFit.cover)
                  : Container(color: Colors.grey[200], child: const Icon(Icons.image_outlined)),
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