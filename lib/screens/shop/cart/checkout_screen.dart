import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../providers/cart_provider.dart';
import 'order_placed_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final double totalAmount;

  const CheckoutScreen({super.key, required this.totalAmount});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'Cash on Delivery';
  final TextEditingController _addressController = TextEditingController();

  /// Processes the order, updates user stats, and manages inventory stock
  Future<void> _placeOrder(CartProvider cart) async {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your delivery address")),
      );
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.purple)),
      );

      final user = FirebaseAuth.instance.currentUser;

      // Determine the display name for the record
      String displayName = "Anonymous User";
      if (user != null) {
        displayName = (user.displayName != null && user.displayName!.isNotEmpty)
            ? user.displayName!
            : (user.email != null ? user.email!.split('@')[0] : "Guest");
      }

      // 1. Create the order document in Firestore
      await FirebaseFirestore.instance.collection('orders').add({
        'userId': user?.uid ?? 'Guest_ID',
        'userName': displayName,
        'address': _addressController.text,
        'paymentMethod': _selectedPaymentMethod,
        'totalAmount': widget.totalAmount,
        'items': cart.cartItems,
        'orderDate': FieldValue.serverTimestamp(),
        'status': 'Pending',
      });

      // 2. Update User Statistics (to reflect in Admin Dashboard and Profile)
      if (user != null) {
        final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

        await FirebaseFirestore.instance.runTransaction((transaction) async {
          DocumentSnapshot snapshot = await transaction.get(userRef);

          if (snapshot.exists) {
            Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
            double currentPaid = 0.0;

            if (userData.containsKey('totalPaid')) {
              currentPaid = (userData['totalPaid'] is int)
                  ? (userData['totalPaid'] as int).toDouble()
                  : (userData['totalPaid'] as double);
            }

            transaction.update(userRef, {
              'totalPaid': currentPaid + widget.totalAmount,
              'totalPurchases': FieldValue.increment(1), // Added: Increment purchase count
              'status': 'Active',
              'lastActivity': FieldValue.serverTimestamp(),
            });
          } else {
            // Create user document if it doesn't exist (first-time buyer)
            transaction.set(userRef, {
              'userName': displayName,
              'email': user.email,
              'totalPaid': widget.totalAmount,
              'totalPurchases': 1, // Added: Initialize with 1
              'totalDonations': 0,
              'status': 'Active',
              'createdAt': FieldValue.serverTimestamp(),
            });
          }
        });
      }

      // 3. Inventory Management: Update stock levels for each product
      for (var item in cart.cartItems) {
        int purchasedQty = item['cartQuantity'] ?? 1;

        var productQuery = await FirebaseFirestore.instance
            .collection('products')
            .where('title', isEqualTo: item['title'])
            .get();

        for (var doc in productQuery.docs) {
          int currentStock = doc.data().containsKey('quantity') ? (doc.data()['quantity'] as int) : 1;
          int newStock = currentStock - purchasedQty;

          if (newStock > 0) {
            await doc.reference.update({'quantity': newStock, 'isAvailable': true});
          } else {
            await doc.reference.update({'quantity': 0, 'isAvailable': false});
          }
        }
      }

      // 4. Clear local cart and navigate to success screen
      cart.clearCart();

      if (!mounted) return;
      Navigator.pop(context); // Dismiss loading dialog
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OrderPlacedScreen()),
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  //UI Builder
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    const double shipping = 5.0;
    double subtotal = widget.totalAmount - shipping;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Checkout',
            style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSectionCard(
              title: 'Delivery Address',
              child: TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  hintText: 'Enter your full address',
                  filled: true,
                  fillColor: const Color(0xFFF3F4F6),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
                style: GoogleFonts.poppins(fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'Payment Method',
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Row(
                  children: [
                    const Icon(Icons.money, size: 20, color: Color(0xFF4B5563)),
                    const SizedBox(width: 10),
                    Text(
                      'Cash on Delivery',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'Order Summary',
              child: Column(
                children: [
                  _buildSummaryRow('Subtotal', '₪${subtotal.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Shipping', '₪${shipping.toStringAsFixed(2)}'),
                  const Divider(height: 24),
                  _buildSummaryRow('Total', '₪${widget.totalAmount.toStringAsFixed(2)}', isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _placeOrder(cart),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Place Order',
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        child,
      ]),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: isTotal ? 16 : 13, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: GoogleFonts.poppins(
            fontSize: isTotal ? 16 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.purple : Colors.black)),
      ],
    );
  }
}