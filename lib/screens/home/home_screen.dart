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

  // Real time stream to listen to the current user's document for points and profile updates
  Stream<DocumentSnapshot> _userDataStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    // Access UserProvider to check user role (Donor, Buyer, or Both)
    final userProvider = Provider.of<UserProvider>(context);
    final userRole = userProvider.role;

    // Define navigation items dynamically based on the user's role
    List<BottomNavigationBarItem> navItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      if (userRole == 'Donor' || userRole == 'Both')
        const BottomNavigationBarItem(icon: Icon(Icons.checkroom), label: 'Donate'),
      if (userRole == 'Buyer' || userRole == 'Both')
        const BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: 'Shop'),
      if (userRole == 'Buyer' || userRole == 'Both')
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
              _buildHeader(userRole),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Impact Section: Shows environmental statistics for donors
                    StreamBuilder<DocumentSnapshot>(
                      stream: _userDataStream(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data!.exists) {
                          var userData = snapshot.data!.data() as Map<String, dynamic>;
                          if (userRole == 'Donor' || userRole == 'Both') {
                            return Column(
                              children: [
                                _buildImpactCard(userData),
                                const SizedBox(height: 16),
                              ],
                            );
                          }
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    // Feature Grid: Navigates to core modules
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.3,
                      children: _buildGridCards(context, userRole),
                    ),

                    _buildAboutUsSection(),
                    const SizedBox(height: 20),

                    // COMMUNITY VOICES SECTION (feedback)
                    // This section shows feedback approved by the Admin (isPublished: true)
                    _buildFeedbackSection(),

                    const SizedBox(height: 30),

                    // Promotions for Buyers
                    if (userRole == 'Buyer' || userRole == 'Both') ...[
                      Text('Featured Offers', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _offerCard('Browse Collection', 'Sustainable styles, friendly prices', 'assets/winter.jpg', () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen()));
                      }),
                      const SizedBox(height: 12),
                    ],

                    // Campaigns for Donors
                    if (userRole == 'Donor' || userRole == 'Both') ...[
                      Text('Special Campaigns', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _offerCard('Donate & Earn', 'Get 20 bonus points on your next donation', 'assets/donateEarn.jpg', () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const DonateScreen()));
                      }),
                      const SizedBox(height: 16),
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
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        items: navItems,
        onTap: (index) {
          String label = navItems[index].label!;
          if (label == 'Donate') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const DonateScreen()));
          } else if (label == 'Shop') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen()));
          } else if (label == 'Remake') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const RemakeStudioScreen()));
          } else if (label == 'Profile') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
          }
        },
      ),
    );
  }

  //  HEADER UI COMPONENT
  Widget _buildHeader(String userRole) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _userDataStream(),
      builder: (context, snapshot) {
        String points = "0";
        if (snapshot.hasData && snapshot.data!.exists) {
          var data = snapshot.data!.data() as Map<String, dynamic>;
          points = data['points']?.toString() ?? "0";
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello, ${widget.name}! 👋',
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    _buildRoleBadge(userRole),
                    const SizedBox(height: 4),
                    Text('Welcome back to ReCloth', style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70)),
                  ],
                ),
              ),
              _buildPointsBadge(points),
            ],
          ),
        );
      },
    );
  }

  // IMPACT CARD COMPONENT
  Widget _buildImpactCard(Map<String, dynamic> userData) {
    int itemsDonated = userData['totalDonations'] ?? 0;
    double co2Saved = 0.0;
    if (userData['co2Saved'] != null) {
      co2Saved = (userData['co2Saved'] is int)
          ? (userData['co2Saved'] as int).toDouble()
          : (userData['co2Saved'] as double);
    }

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
              Text('Your Impact Overall', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
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
              _statItem('♻️', '$itemsDonated', 'Items Donated'),
              _statItem('🤍', '$itemsDonated', 'Lives Impacted'),
              _statItem('🌿', '${co2Saved.toStringAsFixed(1)}kg', 'CO₂ Saved', color: Colors.deepPurple),
            ],
          ),
        ],
      ),
    );
  }

  // FEEDBACK SECTION (COMMUNITY STORIES)
  Widget _buildFeedbackSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Community Voices',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: StreamBuilder<QuerySnapshot>(
            // Note: If data doesn't appear, check the Debug Console for the Firebase Index URL
            stream: FirebaseFirestore.instance
                .collection('feedback')
                .where('isPublished', isEqualTo: true)
            // .orderBy('createdAt', descending: true)
                .limit(6)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.purple));
              }

              // Error handling for missing Index or connection issues
              if (snapshot.hasError) {
                return Center(child: Text("Waiting for approval...", style: TextStyle(fontSize: 12, color: Colors.grey)));
              }

              // Placeholder if no feedback documents match the criteria
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _feedbackItem('ReCloth', 'Admin', 'Be the first to share your experience!', 5.0),
                  ],
                );
              }

              var feedbackDocs = snapshot.data!.docs;

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: feedbackDocs.length,
                itemBuilder: (context, index) {
                  var data = feedbackDocs[index].data() as Map<String, dynamic>;
                  String userName = data['userName'] ?? 'User';
                  String type = data['type'] ?? 'Member';
                  String content = data['content'] ?? '';

                  double rating = 5.0;
                  if (data.containsKey('rating')) {
                    rating = (data['rating'] is int)
                        ? (data['rating'] as int).toDouble()
                        : (data['rating'] as double);
                  }

                  return _feedbackItem(userName, type, content, rating);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // FEEDBACK ITEM CARD DESIGN
  Widget _feedbackItem(String name, String userRole, String text, double rating) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(5, (i) => Icon(
                Icons.star,
                color: i < rating ? Colors.amber : Colors.grey[300],
                size: 14
            )),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.black87),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '- $name ($userRole)',
            style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),
        ],
      ),
    );
  }

  // HELPER COMPONENTS (GRID, BADGES, CARDS)
  List<Widget> _buildGridCards(BuildContext context, String userRole) {
    List<Widget> cards = [];
    if (userRole == 'Donor' || userRole == 'Both') {
      cards.add(_actionCard(Icons.checkroom, 'Donate', 'Give a second life', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DonateScreen()))));
      cards.add(_actionCard(Icons.track_changes, 'Track', 'Follow your item', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrackDonationsScreen()))));
    }
    if (userRole == 'Buyer' || userRole == 'Both') {
      cards.add(_actionCard(Icons.shopping_bag_outlined, 'Shop', 'Recycled fashion', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen()))));
      cards.add(
        _actionCard(
          Icons.local_shipping,
          'My Orders',
          'Track your orders',
              () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TrackOrderScreen(),),
          ),
        ),
      );
      cards.add(_actionCard(Icons.auto_awesome, 'Remake Studio', 'Suggest designs', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RemakeStudioScreen()))));
    }
    cards.add(_actionCard(Icons.card_giftcard, 'Rewards', 'Redeem points', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RewardsScreen()))));
    return cards;
  }

  Widget _buildRoleBadge(String userRole) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
    child: Text(userRole.toUpperCase(), style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
  );

  Widget _buildPointsBadge(String points) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(20)),
    child: Row(children: [
      const Icon(Icons.stars, color: Colors.white, size: 16),
      const SizedBox(width: 4),
      Text('$points Points', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
    ]),
  );

  Widget _statItem(String emoji, String value, String label, {Color color = Colors.black87}) => Column(
    children: [
      Text(emoji, style: const TextStyle(fontSize: 24)),
      Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45)),
    ],
  );

  Widget _actionCard(IconData icon, String title, String subtitle, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.08), blurRadius: 10)]),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: Colors.deepPurple, shape: BoxShape.circle), child: Icon(icon, color: Colors.white, size: 22)),
        const SizedBox(height: 8),
        Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        Text(subtitle, style: GoogleFonts.poppins(fontSize: 9, color: Colors.black45), textAlign: TextAlign.center),
      ]),
    ),
  );

  Widget _offerCard(String title, String subtitle, String imagePath, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.08), blurRadius: 10)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)), child: Image.asset(imagePath, height: 120, width: double.infinity, fit: BoxFit.cover)),
        Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
          Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: Colors.black45)),
        ])),
      ]),
    ),
  );

  Widget _buildAboutUsSection() => Container(
    margin: const EdgeInsets.symmetric(vertical: 20),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
    child: Column(children: [
      const Icon(Icons.eco_rounded, color: Colors.green, size: 40),
      const SizedBox(height: 12),
      Text('Our Mission', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text('ReCloth is a sustainable fashion community in Palestine. We refurbish and give pre-loved clothes a second life.', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54)),
    ]),
  );
}