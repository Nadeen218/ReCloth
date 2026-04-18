import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TrackDonationsScreen extends StatelessWidget {
  const TrackDonationsScreen({super.key});

  // Added expectedPayment and isFullDonation to reflect your new donation logic
  final List<Map<String, dynamic>> _donations = const [
    {
      'category': 'bottoms',
      'date': '4/6/2026',
      'status': 'Request Received',
      'condition': 'excellent',
      'address': 'Palestine',
      'points': '+15 points',
      'expectedPayment': '5 NIS', // Dynamic price based on category
      'isFullDonation': false,   // To decide if we show the payment box
    },
    {
      'category': 'dresses',
      'date': '4/6/2026',
      'status': 'Sold',
      'condition': 'excellent',
      'address': 'Palestine',
      'points': '+25 points',
      'expectedPayment': null,    // No payment for full donation
      'isFullDonation': true,
    },
  ];

  final List<Map<String, dynamic>> _steps = const [
    {'icon': Icons.check_circle_outline, 'label': 'Request Received', 'desc': 'Currently in progress'},
    {'icon': Icons.local_shipping_outlined, 'label': 'Picked Up', 'desc': 'Driver is on the way'},
    {'icon': Icons.water_drop_outlined, 'label': 'Cleaning in Progress', 'desc': 'At our facility'},
    {'icon': Icons.label_outline, 'label': 'Ready for Sale', 'desc': 'Listed on marketplace'},
    {'icon': Icons.attach_money, 'label': 'Sold', 'desc': 'Completed'},
  ];

  @override
  Widget build(BuildContext context) {
    final TextEditingController feedbackController = TextEditingController();
    return Scaffold(
      backgroundColor: const Color(0xFFF3EEFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Track Donations',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
      ),
      body: _donations.isEmpty
          ? _buildEmptyState(context) // if empty
          : ListView.builder( // if there is donation to track
        padding: const EdgeInsets.all(16),
        itemCount: _donations.length,
        itemBuilder: (context, index) {
          final donation = _donations[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.08), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(donation['category'],
                            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold)),
                        Text(donation['date'],
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black45)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3EEFF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(donation['status'],
                          style: GoogleFonts.poppins(fontSize: 11, color: Colors.purple, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Tracking Steps logic
                ..._steps.map((step) {
                  final isActive = step['label'] == donation['status'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(
                          step['icon'] as IconData,
                          color: isActive ? Colors.purple : Colors.grey.shade300,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(step['label'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: isActive ? Colors.black87 : Colors.grey.shade400,
                                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                                  )),
                              if (isActive && step['desc'] != '')
                                Text(step['desc'],
                                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45)),
                            ],
                          ),
                        ),
                        if (isActive)
                          Icon(Icons.check_circle, color: Colors.purple.shade200, size: 18),
                      ],
                    ),
                  );
                }),

                const Divider(height: 32),

                // Donation details summary
                _detailRow('Condition:', donation['condition']),
                _detailRow('Pickup Address:', donation['address']),
                _detailRow('Points Earned:', donation['points'], valueColor: Colors.purple),

                const SizedBox(height: 16),

                // Conditional Payment Info Box
                // Only shows if it's NOT a full donation and there is an expected payment
                if (!donation['isFullDonation'] && donation['expectedPayment'] != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3EEFF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.payments_outlined, color: Colors.purple, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Payment Information',
                                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              // Displaying the specific payout amount
                              Text('Estimated Payout: ${donation['expectedPayment']}',
                                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.green[700], fontWeight: FontWeight.bold)),
                              Text('Payment will be processed once your donated item is sold.',
                                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                if (donation['status'] == 'Sold') ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showFeedbackDialog(context, feedbackController);
                      },
                      icon: const Icon(Icons.rate_review_outlined, size: 18, color: Colors.white),
                      label: Text('Share your Experience',
                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _detailRow(String label, String value, {Color valueColor = Colors.black87}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.black45)),
          Text(value, style: GoogleFonts.poppins(fontSize: 12, color: valueColor, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.05), blurRadius: 20)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_shipping_outlined, size: 100, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text("No Donations Yet",
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text("Start your eco-friendly journey by donating clothes",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black45)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B050),
                minimumSize: const Size(180, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("Donate Now", style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
  void _showFeedbackDialog(BuildContext context, TextEditingController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 24,
          left: 24,
          right: 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('How was your donation experience?',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Write your feedback here...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  print("User Feedback: ${controller.text}");

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Feedback submitted! It will appear on Home Page.'),
                      backgroundColor: Colors.deepPurple,
                    ),
                  );
                  controller.clear();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Submit Feedback', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}