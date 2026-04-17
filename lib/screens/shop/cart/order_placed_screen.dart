import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderPlacedScreen extends StatefulWidget {
  const OrderPlacedScreen({super.key});

  @override
  State<OrderPlacedScreen> createState() => _OrderPlacedScreenState();
}

class _OrderPlacedScreenState extends State<OrderPlacedScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _feedbackController.addListener(() {
      setState(() {
        _isTyping = _feedbackController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
              const SizedBox(height: 20),

              Text(
                'Order Placed Successfully!',
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              Text(
                'Thank you for shopping sustainably. Your order will be delivered soon.',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              Align(
                alignment: Alignment.centerLeft,
                child: Text('Leave Feedback', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _feedbackController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Your thoughts about your shopping experience',
                  hintStyle: GoogleFonts.poppins(fontSize: 12),
                  filled: true,
                  fillColor: const Color(0xFFF3F4F6),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isTyping ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Thank you! Your feedback has been submitted.',
                            style: GoogleFonts.poppins(fontSize: 12)),
                        backgroundColor: Colors.grey,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    _feedbackController.clear();
                    FocusScope.of(context).unfocus();
                    setState(() {
                      _isTyping = false;
                    });
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isTyping ? const Color(0xFF3F51B5) : const Color(0xFF91A7FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Submit Feedback', style: GoogleFonts.poppins(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),

              // Navigation Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C27B0),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Back to Home', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    int count = 0;
                    Navigator.popUntil(context, (route) {
                      return count++ == 2;
                    });                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Continue Shopping', style: GoogleFonts.poppins(color: Colors.black)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}