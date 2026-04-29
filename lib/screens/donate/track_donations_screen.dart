import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TrackDonationsScreen extends StatelessWidget {
  const TrackDonationsScreen({super.key});

  // Configuration for the vertical tracking timeline
  final List<Map<String, dynamic>> _steps = const [
    {'icon': Icons.check_circle_outline, 'label': 'Pending', 'desc': 'Request received'},
    {'icon': Icons.local_shipping_outlined, 'label': 'Picked Up', 'desc': 'Driver is on the way'},
    {'icon': Icons.water_drop_outlined, 'label': 'Cleaning', 'desc': 'At our facility'},
    {'icon': Icons.label_outline, 'label': 'Ready for Sale', 'desc': 'Listed on marketplace'},
    {'icon': Icons.attach_money, 'label': 'Sold', 'desc': 'Completed'},
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
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
        title: Text(
          'Track Donations',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('donations')
            .where('userId', isEqualTo: user?.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.purple));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var donationDoc = snapshot.data!.docs[index];
              var donation = donationDoc.data() as Map<String, dynamic>;

              String formattedDate = "Recently";
              if (donation['createdAt'] != null) {
                DateTime date = (donation['createdAt'] as Timestamp).toDate();
                formattedDate = "${date.day}/${date.month}/${date.year}";
              }

              String currentStatus = donation['status'] ?? 'Pending';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.08),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              donation['category'] ?? 'Clothing Item',
                              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              formattedDate,
                              style: GoogleFonts.poppins(fontSize: 12, color: Colors.black45),
                            ),
                          ],
                        ),
                        _buildStatusBadge(currentStatus),
                      ],
                    ),
                    const SizedBox(height: 20),

                    ..._steps.map((step) {
                      final isActive = step['label'] == currentStatus;
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
                                  Text(
                                    step['label'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: isActive ? Colors.black87 : Colors.grey.shade400,
                                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                  if (isActive)
                                    Text(
                                      step['desc'],
                                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45),
                                    ),
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
                    _detailRow('Condition:', donation['condition'] ?? 'N/A'),
                    _detailRow('Pickup Address:', donation['address'] ?? 'Palestine'),
                    _detailRow(
                      'Points Earned:',
                      '+${donation['pointsEarned'] ?? 0} points',
                      valueColor: Colors.purple,
                    ),

                    const SizedBox(height: 16),

                    if (currentStatus == 'Sold') ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showFeedbackDialog(context, feedbackController),
                          icon: const Icon(Icons.rate_review_outlined, size: 18, color: Colors.white),
                          label: Text('Share your Experience', style: GoogleFonts.poppins(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- RECTIFIED FEEDBACK LOGIC WITH FIREBASE ---
  void _showFeedbackDialog(BuildContext context, TextEditingController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          top: 24, left: 24, right: 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Feedback', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('We value your donation journey!', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black45)),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'How was your experience?',
                hintStyle: GoogleFonts.poppins(fontSize: 13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final feedbackText = controller.text.trim();
                if (feedbackText.isEmpty) return;

                final user = FirebaseAuth.instance.currentUser;

                try {
                  // Save to 'feedback' collection
                  await FirebaseFirestore.instance.collection('feedback').add({
                    'userId': user?.uid,
                    'userName': user?.displayName ?? (user?.email != null ? user!.email!.split('@')[0] : "Donor"),
                    'type': 'Donor',
                    'content': feedbackText,
                    'rating': 5.0,
                    'isPublished': false,
                    'createdAt': FieldValue.serverTimestamp(),
                  });

                  if (context.mounted) {
                    Navigator.pop(sheetContext); // Close using the sheet context
                    controller.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Thank you! Feedback shared with the community.')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Submit Feedback', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EEFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(fontSize: 11, color: Colors.purple, fontWeight: FontWeight.w500),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_shipping_outlined, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text("No Donations Yet", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text("Start your eco-friendly journey now!", style: GoogleFonts.poppins(color: Colors.black45)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B050),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Donate Now", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}