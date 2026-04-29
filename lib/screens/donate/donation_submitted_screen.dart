import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'track_donations_screen.dart';

class DonationSubmittedScreen extends StatefulWidget {
  final int pointsEarned; // Receiving earned points from DonateScreen

  const DonationSubmittedScreen({super.key, required this.pointsEarned});

  @override
  State<DonationSubmittedScreen> createState() => _DonationSubmittedScreenState();
}

class _DonationSubmittedScreenState extends State<DonationSubmittedScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize elastic animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    // Auto redirect to tracking screen after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _navigateToTracking();
      }
    });
  }

  void _navigateToTracking() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const TrackDonationsScreen()),
    );
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.purple.withOpacity(0.1), blurRadius: 20),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Icon with scale animation
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.purple, width: 2),
                    ),
                    child: const Icon(Icons.check, color: Colors.purple, size: 48),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Donation Submitted!',
                  style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  'Thank you for giving clothes a second life.',
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.black45),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Dynamic Points Reward Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "You earned ${widget.pointsEarned} points! 🎉",
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green[700]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Manual Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _navigateToTracking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Track My Donation', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Redirecting to tracking...',
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.black38),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}