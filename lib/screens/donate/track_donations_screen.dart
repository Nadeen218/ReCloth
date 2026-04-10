import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TrackDonationsScreen extends StatelessWidget {
  const TrackDonationsScreen({super.key});

  final List<Map<String, dynamic>> _donations = const [
    {
      'category': 'bottoms',
      'date': '4/6/2026',
      'status': 'Request Received',
      'condition': 'excellent',
      'address': 'Palestine',
      'points': '+15 points',
    },
    {
      'category': 'dresses',
      'date': '4/6/2026',
      'status': 'Request Received',
      'condition': 'excellent',
      'address': 'Palestine',
      'points': '+15 points',
    },
  ];

  final List<Map<String, dynamic>> _steps = const [
    {'icon': Icons.check_circle_outline, 'label': 'Request Received', 'desc': 'Currently in progress'},
    {'icon': Icons.local_shipping_outlined, 'label': 'Picked Up', 'desc': ''},
    {'icon': Icons.water_drop_outlined, 'label': 'Cleaning in Progress', 'desc': ''},
    {'icon': Icons.label_outline, 'label': 'Ready for Sale', 'desc': ''},
    {'icon': Icons.attach_money, 'label': 'Sold', 'desc': ''},
  ];

  @override
  Widget build(BuildContext context) {
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
      body: ListView.builder(
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
                // Header
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
                const SizedBox(height: 16),

                // Steps
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

                const Divider(),
                const SizedBox(height: 8),

                // Details
                _detailRow('Condition:', donation['condition']),
                _detailRow('Pickup Address:', donation['address']),
                _detailRow('Points Earned:', donation['points'], valueColor: Colors.purple),
                const SizedBox(height: 12),

                // Payment Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3EEFF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.attach_money, color: Colors.purple, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Payment Information',
                                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold)),
                            Text('Payment will be processed once your donated item is sold.',
                                style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _detailRow(String label, String value, {Color valueColor = Colors.black87}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.black45)),
          Text(value, style: GoogleFonts.poppins(fontSize: 12, color: valueColor, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}