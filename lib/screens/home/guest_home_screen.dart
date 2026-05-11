import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/login_screen.dart';
import '../auth/role_selection_screen.dart';

class GuestHomeScreen extends StatefulWidget {
  const GuestHomeScreen({super.key});

  @override
  State<GuestHomeScreen> createState() => _GuestHomeScreenState();
}

class _GuestHomeScreenState extends State<GuestHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final List<Map<String, dynamic>> _features = const [
    {
      'icon': Icons.volunteer_activism_outlined,
      'color': Color(0xFF4CAF50),
      'title': 'Donate Clothes',
      'desc': 'Give pre-loved items a second life & earn points',
    },
    {
      'icon': Icons.shopping_bag_outlined,
      'color': Color(0xFF7C3AED),
      'title': 'Shop Sustainably',
      'desc': 'Quality recycled fashion at affordable prices',
    },
    {
      'icon': Icons.auto_awesome_outlined,
      'color': Color(0xFFEC4899),
      'title': 'Remake Studio',
      'desc': 'Submit creative ideas & earn 30 bonus points',
    },
    {
      'icon': Icons.emoji_events_outlined,
      'color': Color(0xFFF59E0B),
      'title': 'Earn Rewards',
      'desc': 'Redeem points for discounts and free shipping',
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(
        begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EEFF),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeroSection(),
                  const SizedBox(height: 28),
                  _buildFeaturesSection(),
                  const SizedBox(height: 28),
                  _buildImpactSection(),
                  const SizedBox(height: 32),
                  _buildCTAButtons(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6B21A8), Color(0xFF7C3AED), Color(0xFF9333EA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 36, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.recycling, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 10),
                Text(
                  'ReCloth',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Headline
            Text(
              'Fashion with\na Purpose 🌿',
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Palestine\'s sustainable fashion community.\nDonate, shop, and give clothes a second life.',
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                color: Colors.white.withOpacity(0.85),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),

            // Stats row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _heroStat('500+', 'Items Donated'),
                  _verticalDivider(),
                  _heroStat('200+', 'Happy Buyers'),
                  _verticalDivider(),
                  _heroStat('1.2t', 'CO₂ Saved'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroStat(String value, String label) => Column(
    children: [
      Text(value,
          style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white)),
      Text(label,
          style: GoogleFonts.poppins(
              fontSize: 10, color: Colors.white70)),
    ],
  );

  Widget _verticalDivider() => Container(
    height: 32,
    width: 1,
    color: Colors.white.withOpacity(0.3),
  );

  Widget _buildFeaturesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What You Can Do',
            style: GoogleFonts.poppins(
                fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _features.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.05,
            ),
            itemBuilder: (_, i) => _featureCard(_features[i]),
          ),
        ],
      ),
    );
  }

  Widget _featureCard(Map<String, dynamic> f) {
    final color = f['color'] as Color;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(f['icon'] as IconData, color: color, size: 22),
          ),
          const Spacer(),
          Text(
            f['title'] as String,
            style: GoogleFonts.poppins(
                fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 3),
          Text(
            f['desc'] as String,
            style: GoogleFonts.poppins(fontSize: 10, color: Colors.black45, height: 1.4),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildImpactSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF4CAF50).withOpacity(0.08),
              const Color(0xFF7C3AED).withOpacity(0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.eco_rounded, color: Color(0xFF4CAF50), size: 22),
                const SizedBox(width: 8),
                Text(
                  'Our Community Impact',
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Every item donated reduces textile waste and supports '
                  'families in Palestine. Join a movement that cares about '
                  'people and the planet. 🌍',
              style: GoogleFonts.poppins(
                  fontSize: 12.5, color: Colors.black54, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCTAButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Sign In
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
              icon: const Icon(Icons.login_rounded, color: Colors.white, size: 20),
              label: Text(
                'Sign In to Your Account',
                style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Create Account
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
              ),
              icon: const Icon(Icons.person_add_outlined,
                  color: Color(0xFF7C3AED), size: 20),
              label: Text(
                'Create New Account',
                style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF7C3AED)),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFF7C3AED), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Footer note
          Text(
            '🔒  Your data is safe & encrypted',
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.black38),
          ),
        ],
      ),
    );
  }
}