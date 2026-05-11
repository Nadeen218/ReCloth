import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../donate/donate_screen.dart';
import '../donate/track_donations_screen.dart';
import '../remake/remake_studio_screen.dart';
import '../shop/shop_screen.dart';
import '../profile/profile_screen.dart';
import '../rewards/rewards_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../shop/track_order.dart';

class HomeScreen extends StatefulWidget {
  final String name;

  const HomeScreen({super.key, required this.name});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Fetch user profile data from Firestore in real-time
  Stream<DocumentSnapshot> _userDataStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
  }

  // Fetch orders related to the current user in real-time
  Stream<QuerySnapshot> _userOrdersStream() {
    return FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userRole = userProvider.role;

    // Define Navigation Bar items based on user role
    List<BottomNavigationBarItem> navItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.home_filled, size: 28), label: 'Home'),
      if (userRole == 'Donor' || userRole == 'Both')
        const BottomNavigationBarItem(icon: Icon(Icons.checkroom, size: 28), label: 'Donate'),
      if (userRole == 'Buyer' || userRole == 'Both')
        const BottomNavigationBarItem(icon: Icon(Icons.shopping_bag, size: 28), label: 'Shop'),
      if (userRole == 'Buyer' || userRole == 'Both')
        const BottomNavigationBarItem(icon: Icon(Icons.auto_awesome, size: 28), label: 'Remake'),
      const BottomNavigationBarItem(icon: Icon(Icons.person, size: 28), label: 'Profile'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(userRole),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Explore ReCloth'),

                    // Quick Action Grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                      children: _buildGridCards(context, userRole),
                    ),

                    const SizedBox(height: 32),
                    _buildAboutUsSection(),
                    const SizedBox(height: 32),
                    _buildFeedbackSection(), // Community Stories
                    const SizedBox(height: 32),

                    // Featured Offers for Buyers
                    if (userRole == 'Buyer' || userRole == 'Both') ...[
                      _buildSectionTitle('Featured Offers'),
                      _offerCard('Browse Collection', 'Sustainable styles, friendly prices', 'assets/winter.jpg', () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen()));
                      }),
                      const SizedBox(height: 24),
                    ],

                    // Campaigns for Donors
                    if (userRole == 'Donor' || userRole == 'Both') ...[
                      _buildSectionTitle('Special Campaigns'),
                      _offerCard('Donate & Earn', 'Get 20 bonus points on your next donation', 'assets/donateEarn.jpg', () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const DonateScreen()));
                      }),
                      const SizedBox(height: 32),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF673AB7),
        unselectedItemColor: Colors.grey.shade500,
        currentIndex: 0,
        elevation: 10,
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
        items: navItems,
        onTap: (index) {
          String label = navItems[index].label!;
          if (label == 'Donate') Navigator.push(context, MaterialPageRoute(builder: (_) => const DonateScreen()));
          else if (label == 'Shop') Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen()));
          else if (label == 'Remake') Navigator.push(context, MaterialPageRoute(builder: (_) => const RemakeStudioScreen()));
          else if (label == 'Profile') Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        },
      ),
    );
  }

  // Adaptive Header showing user stats
  Widget _buildHeader(String userRole) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _userDataStream(),
      builder: (context, userSnapshot) {
        String points = "0";
        int itemsDonated = 0;
        double co2Saved = 0.0;
        int itemsBought = 0;
        double moneySaved = 0.0;

        if (userSnapshot.hasData && userSnapshot.data!.exists) {
          var data = userSnapshot.data!.data() as Map<String, dynamic>;
          points = data['points']?.toString() ?? "0";
          itemsDonated = data['totalDonations'] ?? 0;
          co2Saved = (data['co2Saved']?.toDouble() ?? 0.0);
          itemsBought = data['itemsBought'] ?? 0;
          moneySaved = (data['moneySaved']?.toDouble() ?? 0.0);
        }

        return StreamBuilder<QuerySnapshot>(
          stream: _userOrdersStream(),
          builder: (context, orderSnapshot) {
            int activeOrdersCount = orderSnapshot.hasData ? orderSnapshot.data!.docs.length : 0;

            return Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6B21A8), Color(0xFF7C3AED), Color(0xFF9333EA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(36), bottomRight: Radius.circular(36)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.recycling, color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 10),
                        Text('ReCloth', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text('Welcome, ${widget.name}! 👋', style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildRoleBadge(userRole),
                                  const SizedBox(width: 8),
                                  _buildPointsBadge(points),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      userRole == 'Both'
                          ? 'Shop sustainable fashion & donate your pre-loved items.\nYou are making a double impact today!'
                          : userRole == 'Buyer'
                          ? 'Find your next favorite outfit and save the planet.\nTrack your orders and savings in real-time.'
                          : 'Your sustainable fashion journey continues here.\nTrack your impact and manage your collection.',
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.25)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: userRole == 'Both'
                            ? [
                          _heroStat('$activeOrdersCount', 'Orders'),
                          _verticalDivider(),
                          _heroStat('$itemsDonated', 'Donated'),
                          _verticalDivider(),
                          _heroStat('${co2Saved.toStringAsFixed(1)}kg', 'CO₂ Saved'),
                        ]
                            : userRole == 'Buyer'
                            ? [
                          _heroStat('$activeOrdersCount', 'Orders'),
                          _verticalDivider(),
                          _heroStat('$itemsBought', 'Items'),
                          _verticalDivider(),
                          _heroStat('\$${moneySaved.toStringAsFixed(1)}', 'Saved'),
                        ]
                            : [
                          _heroStat('$itemsDonated', 'Donations'),
                          _verticalDivider(),
                          _heroStat('$itemsDonated', 'Lives Hit'),
                          _verticalDivider(),
                          _heroStat('${co2Saved.toStringAsFixed(1)}kg', 'CO₂ Saved'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Visual divider with purple accent
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(title, style: GoogleFonts.poppins(fontSize: 19, fontWeight: FontWeight.bold, color: const Color(0xFF111827))),
        ],
      ),
    );
  }

  Widget _heroStat(String value, String label) => Column(
    children: [
      Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
      const SizedBox(height: 2),
      Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500)),
    ],
  );

  Widget _verticalDivider() => Container(height: 34, width: 1.5, color: Colors.white.withOpacity(0.4));

  // Build action cards based on user role
  List<Widget> _buildGridCards(BuildContext context, String userRole) {
    List<Widget> cards = [];
    if (userRole == 'Donor' || userRole == 'Both') {
      cards.add(_actionCard(Icons.favorite_rounded, 'Donate', 'Pass the kindness', const Color(0xFF4CAF50), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DonateScreen()))));
      cards.add(_actionCard(Icons.local_shipping_outlined, 'Track', 'Follow your item', const Color(0xFF2196F3), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrackDonationsScreen()))));
    }
    if (userRole == 'Buyer' || userRole == 'Both') {
      cards.add(_actionCard(Icons.shopping_bag_outlined, 'Shop', 'Recycled fashion', const Color(0xFF673AB7), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen()))));
      cards.add(_actionCard(Icons.assignment_turned_in_outlined, 'My Orders', 'Check status', const Color(0xFF009688), () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrackOrderScreen()))));
      cards.add(_actionCard(Icons.brush_outlined, 'Remake', 'Suggest designs', const Color(0xFFE91E63), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RemakeStudioScreen()))));
    }
    cards.add(_actionCard(Icons.card_giftcard_rounded, 'Rewards', 'Redeem points', const Color(0xFFFF9800), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RewardsScreen()))));
    return cards;
  }

  Widget _actionCard(IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: color.withOpacity(0.12), blurRadius: 15, offset: const Offset(0, 8))],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 28),
            ),
            const Spacer(),
            FittedBox(fit: BoxFit.scaleDown, child: Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87))),
            const SizedBox(height: 2),
            Text(subtitle, style: GoogleFonts.poppins(fontSize: 10, color: Colors.black54), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  // Section for community feedback stories
  Widget _buildFeedbackSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Community Stories'),
        SizedBox(
          height: 155,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('feedback').where('isPublished', isEqualTo: true).limit(6).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _feedbackItem('ReCloth', 'Admin', 'Your sustainable fashion stories will appear here!', 5.0);
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  return _feedbackItem(data['userName'] ?? 'User', data['type'] ?? 'Member', data['content'] ?? '', (data['rating'] ?? 5).toDouble());
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Updated Feedback Item with purple accents
  Widget _feedbackItem(String name, String role, String text, double rating) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDE7F6)), // Light purple border
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF673AB7).withOpacity(0.05), // Subtle purple shadow
              blurRadius: 12,
              offset: const Offset(0, 4)
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: List.generate(5, (i) => Icon(Icons.star_rounded, color: i < rating ? const Color(0xFFFFB300) : Colors.grey[300], size: 16))),
          const SizedBox(height: 12),
          Expanded(child: Text('"$text"', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87, fontStyle: FontStyle.italic))),
          const SizedBox(height: 10),
          Text('$name • $role', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF7C3AED))),
        ],
      ),
    );
  }

  // Updated Offer Card with modern UI colors
  Widget _offerCard(String title, String subtitle, String imagePath, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), child: Image.asset(imagePath, height: 140, width: double.infinity, fit: BoxFit.cover)),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937))),
                const SizedBox(height: 4),
                Text(subtitle, style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF6B7280))),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('Explore Now', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF7C3AED))),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF7C3AED)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  // Mission section with eco-friendly colors
  Widget _buildAboutUsSection() => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [const Color(0xFF4CAF50).withOpacity(0.12), Colors.white], begin: Alignment.topLeft),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.15)),
    ),
    child: Column(
      children: [
        const Icon(Icons.eco_rounded, color: Color(0xFF4CAF50), size: 45),
        const SizedBox(height: 12),
        Text('The ReCloth Mission', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('We represent Palestine\'s sustainable fashion movement.', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87)),
      ],
    ),
  );

  Widget _buildRoleBadge(String userRole) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
    child: Text(userRole.toUpperCase(), style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
  );

  Widget _buildPointsBadge(String points) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
    child: Row(
      children: [
        const Icon(Icons.stars_rounded, color: Color(0xFFFFC107), size: 18),
        const SizedBox(width: 6),
        Text('$points Pts', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF512DA8))),
      ],
    ),
  );
}