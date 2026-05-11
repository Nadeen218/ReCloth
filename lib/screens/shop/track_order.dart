import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TrackOrderScreen extends StatelessWidget {
  const TrackOrderScreen({super.key});

  // Steps definition for the order timeline
  final List<Map<String, dynamic>> _steps = const [
    {
      'icon': Icons.receipt_long_outlined,
      'label': 'Pending',
      'desc': 'Order received & being reviewed',
    },
    {
      'icon': Icons.check_circle_outline,
      'label': 'Confirmed',
      'desc': 'Order confirmed by our team',
    },
    {
      'icon': Icons.local_shipping_outlined,
      'label': 'Shipped',
      'desc': 'On its way to you',
    },
    {
      'icon': Icons.door_front_door_outlined,
      'label': 'Delivered',
      'desc': 'Order delivered successfully',
    },
  ];

  // Primary Theme Gradient
  final List<Color> _purpleGradient = const [
    Color(0xFF6B21A8),
    Color(0xFF7C3AED),
    Color(0xFF9333EA),
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Orders',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4A148C),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong', style: GoogleFonts.poppins(color: Colors.grey)));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState(context);
          }

          // Filter orders belonging to the current user
          final userOrders = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['userId'] == user?.uid;
          }).toList();

          // Sort orders by date (Newest first)
          userOrders.sort((a, b) {
            final dataA = a.data() as Map<String, dynamic>;
            final dataB = b.data() as Map<String, dynamic>;
            final dateA = dataA['orderDate'] as Timestamp?;
            final dateB = dataB['orderDate'] as Timestamp?;
            if (dateA == null) return 1;
            if (dateB == null) return -1;
            return dateB.compareTo(dateA);
          });

          if (userOrders.isEmpty) return _buildEmptyState(context);

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: userOrders.length,
            itemBuilder: (context, index) {
              final doc = userOrders[index];
              final order = doc.data() as Map<String, dynamic>;
              final String currentStatus = order['status'] ?? 'Pending';

              // Format Timestamp to readable date
              String formattedDate = 'Recently';
              if (order['orderDate'] != null) {
                final DateTime d = (order['orderDate'] as Timestamp).toDate();
                formattedDate = '${d.day}/${d.month}/${d.year}';
              }

              final List items = order['items'] ?? [];

              return Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Order Header (Fixed Overflow with Expanded) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                items.isNotEmpty ? (items.first['title'] ?? 'Order') : 'Order',
                                style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF4A148C)
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(formattedDate, style: GoogleFonts.poppins(fontSize: 12, color: Colors.black45)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        _buildStatusBadge(currentStatus),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // --- Ordered Items Preview ---
                    if (items.isNotEmpty)
                      SizedBox(
                        height: 60,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: items.length,
                          itemBuilder: (_, i) {
                            return Container(
                              width: 60,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: const Color(0xFFF3EEFF)),
                                image: DecorationImage(
                                  image: NetworkImage(items[i]['imageUrl'] ?? ''),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 20),
                    const Divider(height: 1, color: Color(0xFFF3EEFF)),
                    const SizedBox(height: 20),

                    // --- Tracking Timeline ---
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
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  gradient: isActive ? LinearGradient(colors: _purpleGradient) : null,
                                  color: isActive ? null : (isPassed ? const Color(0xFFF3EEFF) : Colors.grey[100]),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isPassed ? Icons.check : step['icon'] as IconData,
                                  size: 15,
                                  color: isActive ? Colors.white : (isPassed ? const Color(0xFF7C3AED) : Colors.grey[400]),
                                ),
                              ),
                              if (step != _steps.last)
                                Container(
                                  width: 2,
                                  height: 25,
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
                                  step['label'] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                                    color: isActive ? const Color(0xFF7C3AED) : (isPassed ? Colors.black87 : Colors.grey[400]),
                                  ),
                                ),
                                if (isActive)
                                  Text(step['desc'] as String, style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45)),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),

                    const Divider(height: 1, color: Color(0xFFF3EEFF)),
                    const SizedBox(height: 16),

                    // --- Order Details Section ---
                    _detailRow(Icons.location_on_outlined, 'Delivery Address', order['address'] ?? 'N/A'),
                    const SizedBox(height: 8),
                    _detailRow(Icons.payments_outlined, 'Total Amount', '₪${order['totalAmount'] ?? '0'}', isPrice: true),
                    const SizedBox(height: 8),
                    _detailRow(Icons.credit_card_outlined, 'Payment', order['paymentMethod'] ?? 'Cash on Delivery'),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Build colorful status labels
  Widget _buildStatusBadge(String status) {
    Color color = const Color(0xFF7C3AED);
    if (status == 'Confirmed') color = Colors.blue;
    if (status == 'Shipped') color = Colors.orange;
    if (status == 'Delivered') color = Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(fontSize: 11, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Detail row helper with overflow protection
  Widget _detailRow(IconData icon, String label, String value, {bool isPrice = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF7C3AED).withOpacity(0.6)),
        const SizedBox(width: 10),
        Text('$label: ', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isPrice ? const Color(0xFF7C3AED) : Colors.black87,
            ),
            softWrap: true,
          ),
        ),
      ],
    );
  }

  // UI shown when no orders are found
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(color: const Color(0xFFF3EEFF), shape: BoxShape.circle),
            child: Icon(Icons.local_mall_outlined, size: 70, color: const Color(0xFF7C3AED).withOpacity(0.5)),
          ),
          const SizedBox(height: 24),
          Text('No Orders Found', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF4A148C))),
          const SizedBox(height: 10),
          Text('You haven\'t placed any orders yet.', style: GoogleFonts.poppins(fontSize: 14, color: Colors.black45)),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: _purpleGradient),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text('Start Shopping', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}