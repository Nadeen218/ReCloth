import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TrackDonationsScreen extends StatelessWidget {
  const TrackDonationsScreen({super.key});

  // Steps for the donation lifecycle timeline
  final List<Map<String, dynamic>> _steps = const [
    {'icon': Icons.receipt_long_outlined, 'label': 'Pending', 'desc': 'Request received'},
    {'icon': Icons.local_shipping_outlined, 'label': 'Picked Up', 'desc': 'Driver is on the way'},
    {'icon': Icons.water_drop_outlined, 'label': 'Cleaning', 'desc': 'At our facility'},
    {'icon': Icons.label_outline, 'label': 'Ready for Sale', 'desc': 'Listed on marketplace'},
    {'icon': Icons.attach_money, 'label': 'Sold', 'desc': 'Process completed'},
  ];

  // Theme Colors
  final List<Color> _purpleGradient = const [
    Color(0xFF6B21A8),
    Color(0xFF7C3AED),
    Color(0xFF9333EA),
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final TextEditingController feedbackController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FF), // Soft purple background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Track Donations',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4A148C),
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
            return Center(child: Text('Error: ${snapshot.error}', style: GoogleFonts.poppins()));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)));
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
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Header Section ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                donation['category'] ?? 'Clothing Item',
                                style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2D0C57)
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                formattedDate,
                                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black45),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        _buildStatusBadge(currentStatus),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- Timeline Section ---
                    ..._steps.map((step) {
                      final stepIndex = _steps.indexOf(step);
                      final currentIndex = _steps.indexWhere((s) => s['label'] == currentStatus);
                      final isActive = step['label'] == currentStatus;
                      final isPassed = stepIndex < currentIndex;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  gradient: isActive ? LinearGradient(colors: _purpleGradient) : null,
                                  color: isActive ? null : (isPassed ? const Color(0xFFF3EEFF) : Colors.grey[100]),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isPassed ? Icons.check : step['icon'] as IconData,
                                  size: 14,
                                  color: isActive ? Colors.white : (isPassed ? const Color(0xFF7C3AED) : Colors.grey[400]),
                                ),
                              ),
                              if (step != _steps.last)
                                Container(
                                  width: 2,
                                  height: 20,
                                  color: isPassed ? const Color(0xFF7C3AED).withOpacity(0.3) : Colors.grey[200],
                                ),
                            ],
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  step['label'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                                    color: isActive ? const Color(0xFF7C3AED) : (isPassed ? Colors.black87 : Colors.grey[400]),
                                  ),
                                ),
                                if (isActive)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Text(
                                      step['desc'],
                                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45),
                                    ),
                                  ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),

                    const Divider(height: 32, color: Color(0xFFF3EEFF)),

                    // --- Details Section ---
                    _detailRow('Condition', donation['condition'] ?? 'N/A'),
                    const SizedBox(height: 8),
                    _detailRow('Pickup Address', donation['address'] ?? 'Palestine'),
                    const SizedBox(height: 8),
                    _detailRow(
                      'Points Earned',
                      '+${donation['pointsEarned'] ?? 0} Points',
                      isPoints: true,
                    ),

                    if (currentStatus == 'Sold') ...[
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => _showFeedbackDialog(context, feedbackController),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: _purpleGradient),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF7C3AED).withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.rate_review_rounded, color: Colors.white, size: 18),
                              const SizedBox(width: 10),
                              Text(
                                'Share your Experience',
                                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ],
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text('Feedback', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2D0C57))),
            const SizedBox(height: 8),
            Text('We value your donation journey!', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black45)),
            const SizedBox(height: 24),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'How was your experience?',
                hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.black26),
                filled: true,
                fillColor: const Color(0xFFF9F7FF),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFF3EEFF))),
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () async {
                final feedbackText = controller.text.trim();
                if (feedbackText.isEmpty) return;

                final user = FirebaseAuth.instance.currentUser;
                try {
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
                    Navigator.pop(sheetContext);
                    controller.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Feedback shared! Thank you.'), backgroundColor: Color(0xFF7C3AED)),
                    );
                  }
                } catch (e) {
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: _purpleGradient),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text('Submit Feedback', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF7C3AED).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF7C3AED), fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool isPoints = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.black45)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.poppins(
                fontSize: 12,
                color: isPoints ? const Color(0xFF7C3AED) : const Color(0xFF2D0C57),
                fontWeight: FontWeight.bold
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: const BoxDecoration(color: Color(0xFFF3EEFF), shape: BoxShape.circle),
            child: Icon(Icons.volunteer_activism_outlined, size: 70, color: const Color(0xFF7C3AED).withOpacity(0.5)),
          ),
          const SizedBox(height: 24),
          Text("No Donations Yet", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF4A148C))),
          const SizedBox(height: 10),
          Text("Start your eco-friendly journey now!", style: GoogleFonts.poppins(color: Colors.black45)),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: _purpleGradient),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text("Donate Now", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}