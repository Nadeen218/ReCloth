import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TrackOrderScreen extends StatelessWidget {
  const TrackOrderScreen({super.key});

  // Steps for order tracking
  final List<Map<String, dynamic>> _steps = const [
    {'icon': Icons.shopping_bag_outlined, 'label': 'Pending', 'desc': 'Order received'},
    {'icon': Icons.inventory_2_outlined, 'label': 'Processing', 'desc': 'Preparing your order'},
    {'icon': Icons.local_shipping_outlined, 'label': 'Shipped', 'desc': 'On the way'},
    {'icon': Icons.door_front_door_outlined, 'label': 'Out for Delivery', 'desc': 'Almost there'},
    {'icon': Icons.check_circle, 'label': 'Delivered', 'desc': 'Order completed'},
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF3EEFF),

      // APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Track Orders',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),

      // BODY
      body: StreamBuilder<QuerySnapshot>(
        // Fetching all orders without complex query to avoid Index error
        stream: FirebaseFirestore.instance
            .collection('orders')
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _emptyState();
          }

          // Filter by userId and sort by createdAt manually inside the code
          final userOrders = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['userId'] == user?.uid;
          }).toList();

          // Sorting: Latest first (descending)
          userOrders.sort((a, b) {
            final dataA = a.data() as Map<String, dynamic>;
            final dataB = b.data() as Map<String, dynamic>;
            final dateA = dataA['createdAt'] as Timestamp?;
            final dateB = dataB['createdAt'] as Timestamp?;
            if (dateA == null) return 1;
            if (dateB == null) return -1;
            return dateB.compareTo(dateA);
          });

          if (userOrders.isEmpty) {
            return _emptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: userOrders.length,

            itemBuilder: (context, index) {
              var doc = userOrders[index];
              var order = doc.data() as Map<String, dynamic>;

              String status = order['status'] ?? 'Pending';

              String date = "Recently";
              if (order['createdAt'] != null) {
                DateTime d = (order['createdAt'] as Timestamp).toDate();
                date = "${d.day}/${d.month}/${d.year}";
              }

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

                    // HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order['productName'] ?? 'Product',
                              style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              date,
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.black45),
                            ),
                          ],
                        ),
                        _statusBadge(status),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // TIMELINE
                    ..._steps.map((step) {
                      bool active = step['label'] == status;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Icon(
                              step['icon'],
                              color: active
                                  ? Colors.deepPurple
                                  : Colors.grey.shade300,
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
                                      fontWeight: active
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: active
                                          ? Colors.black87
                                          : Colors.grey,
                                    ),
                                  ),
                                  if (active)
                                    Text(
                                      step['desc'],
                                      style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: Colors.black45),
                                    ),
                                ],
                              ),
                            ),

                            if (active)
                              Icon(Icons.check_circle,
                                  color: Colors.deepPurple.shade200,
                                  size: 18),
                          ],
                        ),
                      );
                    }),

                    const Divider(height: 30),

                    // DETAILS
                    _detailRow("Address:", order['address']?.toString() ?? 'N/A'),
                    _detailRow("Total:", "₪${(order['total'] ?? 0).toString()}"),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // STATUS BADGE
  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EEFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.deepPurple,
            fontWeight: FontWeight.w500),
      ),
    );
  }

  // DETAIL ROW
  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 12, color: Colors.black45)),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // EMPTY STATE
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined,
              size: 100, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            "No Orders Yet",
            style: GoogleFonts.poppins(
                fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Start shopping to see your orders here",
            style: GoogleFonts.poppins(
                fontSize: 12, color: Colors.black45),
          ),
        ],
      ),
    );
  }
}