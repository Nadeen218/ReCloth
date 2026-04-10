import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'track_donations_screen.dart';
class DonationSubmittedScreen extends StatefulWidget {
  const DonationSubmittedScreen({super.key});

  @override
  State<DonationSubmittedScreen> createState() => _DonationSubmittedScreenState();
}

class _DonationSubmittedScreenState extends State<DonationSubmittedScreen> with SingleTickerProviderStateMixin{
  late AnimationController _controller;
  late Animation <double> _scaleAnimation;
  @override
  void initState(){
    super.initState();
    _controller=AnimationController(vsync: this,
      duration: const Duration(microseconds: 800),
    );
    _scaleAnimation=Tween<double>(begin: 0,end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
    //for moving after 3sec
    Future.delayed(const Duration(seconds: 3),(){
      if(mounted){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const TrackDonationsScreen()),);
      }
    });
  }
  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EEFF),
      body: Center(
        child: Padding(padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.purple.withOpacity(0.1),blurRadius: 20),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //true icon with anima
                ScaleTransition(scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.purple,width: 2),
                  ),
                  child: const Icon(Icons.check,color: Colors.purple,size: 48),
                ),),
                const SizedBox(height: 24),
                Text(
                  'Donation Submitted!',
                  style: GoogleFonts.poppins(fontSize: 22,fontWeight: FontWeight.bold,color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text('Thank you for giving clothes a second life.',
                style: GoogleFonts.poppins(fontSize: 13,color: Colors.black45),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text("You have earned 15 points!",
                style:GoogleFonts.poppins(fontSize: 13,fontWeight: FontWeight.bold,color: Colors.black45),
                ),
                const SizedBox(height: 24),

                //track my donation button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(onPressed: (){
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> const TrackDonationsScreen()),
                    );
                  },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Track My Donation', style: GoogleFonts.poppins(fontSize: 14,color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 8),
                Text('Redirecting to tracking...',
                style: GoogleFonts.poppins(fontSize: 11,color: Colors.black38),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
