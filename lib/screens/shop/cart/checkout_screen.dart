import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../providers/cart_provider.dart';
import 'order_placed_screen.dart';

// --- Custom Formatter to split card number: XXXX XXXX XXXX XXXX ---
class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll(' ', '');
    if (text.length > 16) text = text.substring(0, 16);

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class CheckoutScreen extends StatefulWidget {
  final double totalAmount;

  const CheckoutScreen({super.key, required this.totalAmount});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'Cash on Delivery';
  final TextEditingController _addressController = TextEditingController();

  final TextEditingController _cardNumController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  /// Processes the order, updates user statistics, and manages inventory stock
  Future<void> _placeOrder(CartProvider cart) async {
    // 1. Validate delivery address
    if (_addressController.text.isEmpty) {
      _showErrorSnackBar("Please enter your delivery address");
      return;
    }

    // 2. Validate card details if Credit Card is selected
    if (_selectedPaymentMethod == 'Credit Card') {
      String cleanCardNum = _cardNumController.text.replaceAll(' ', '');
      if (cleanCardNum.length < 16 || _cvvController.text.isEmpty || _cvvController.text.length < 3) {
        _showErrorSnackBar("Please enter valid card details");
        return;
      }
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.purple)),
      );

      final user = FirebaseAuth.instance.currentUser;
      String displayName = "Anonymous User";
      if (user != null) {
        displayName = (user.displayName != null && user.displayName!.isNotEmpty)
            ? user.displayName!
            : (user.email != null ? user.email!.split('@')[0] : "Guest");
      }

      final firstItem = cart.cartItems.isNotEmpty ? cart.cartItems.first : null;

      // Calculate total items in the cart to update 'itemsBought'
      int totalItemsInCart = 0;
      for (var item in cart.cartItems) {
        totalItemsInCart += (item['cartQuantity'] as int? ?? 1);
      }

      // Calculate estimated money saved (Example: 20% of total price is considered saving)
      // You can replace this with actual originalPrice - currentPrice logic
      double estimatedSavings = widget.totalAmount * 0.20;

      // 1. Create the order document in Firestore
      await FirebaseFirestore.instance.collection('orders').add({
        'userId': user?.uid ?? 'Guest_ID',
        'userName': displayName,
        'address': _addressController.text,
        'paymentMethod': _selectedPaymentMethod,
        'paymentStatus': _selectedPaymentMethod == 'Credit Card' ? 'Paid' : 'Pending',
        'totalAmount': widget.totalAmount,
        'items': cart.cartItems,
        'orderDate': FieldValue.serverTimestamp(),
        'status': 'Pending',
        'productName': firstItem != null ? (firstItem['title'] ?? 'Product') : 'Item',
        'productImage': firstItem != null ? (firstItem['imageUrl'] ?? '') : '',
      });

      // 2. Update User Statistics (Corrected fields for HomeScreen)
      if (user != null) {
        final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

        await userRef.update({
          'totalPaid': FieldValue.increment(widget.totalAmount),
          'itemsBought': FieldValue.increment(totalItemsInCart), // Updates 'Items' on HomeScreen
          'moneySaved': FieldValue.increment(estimatedSavings), // Updates 'Saved' on HomeScreen
          'totalPurchases': FieldValue.increment(1),
          'status': 'Active',
          'lastActivity': FieldValue.serverTimestamp(),
        });
      }

      // 3. Inventory Management: Decrement stock
      for (var item in cart.cartItems) {
        int purchasedQty = item['cartQuantity'] ?? 1;
        var productQuery = await FirebaseFirestore.instance
            .collection('products')
            .where('title', isEqualTo: item['title'])
            .get();

        for (var doc in productQuery.docs) {
          int currentStock = doc.data().containsKey('quantity') ? (doc.data()['quantity'] as int) : 0;
          int newStock = currentStock - purchasedQty;
          await doc.reference.update({
            'quantity': newStock > 0 ? newStock : 0,
            'isAvailable': newStock > 0,
          });
        }
      }

      cart.clearCart();
      if (!mounted) return;
      Navigator.pop(context); // Dismiss loading dialog
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OrderPlacedScreen()));
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showErrorSnackBar("Error: $e");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

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
                decoration: _inputDecoration('Enter your full address', Icons.location_on),
                style: GoogleFonts.poppins(fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'Payment Method',
              child: Column(
                children: [
                  _buildPaymentOption('Cash on Delivery', Icons.money),
                  const SizedBox(height: 8),
                  _buildPaymentOption('Credit Card', Icons.credit_card),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'Order Summary',
              child: Column(
                children: [
                  _buildSummaryRow('Subtotal', '₪${subtotal.toStringAsFixed(2)}'),
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

  Widget _buildPaymentOption(String title, IconData icon) {
    bool isSelected = _selectedPaymentMethod == title;
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.purple.withOpacity(0.05) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.purple : Colors.grey.shade200,
              width: 1.5,
            ),
          ),
          child: RadioListTile<String>(
            title: Row(
              children: [
                Icon(icon, size: 20, color: isSelected ? Colors.purple : Colors.grey),
                const SizedBox(width: 10),
                Text(title,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal
                    )),
                const Spacer(),
                if (title == 'Credit Card')
                  const Row(
                    children: [
                      Icon(Icons.credit_card, size: 16, color: Colors.blue),
                      SizedBox(width: 4),
                      Icon(Icons.add_card, size: 16, color: Colors.orange),
                    ],
                  ),
              ],
            ),
            value: title,
            groupValue: _selectedPaymentMethod,
            activeColor: Colors.purple,
            onChanged: (val) => setState(() => _selectedPaymentMethod = val!),
          ),
        ),
        if (title == 'Credit Card' && isSelected)
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _cardNumController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CardNumberFormatter(),
                  ],
                  decoration: _inputDecoration('Card Number', Icons.payment)
                      .copyWith(hintText: 'XXXX XXXX XXXX XXXX', counterText: ""),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _expiryController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        decoration: _inputDecoration('MM/YY', Icons.date_range),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: _cvvController,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        decoration: _inputDecoration('CVV', Icons.lock_outline)
                            .copyWith(counterText: ""),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.security, size: 12, color: Colors.green),
                    SizedBox(width: 4),
                    Text("Secure & Encrypted Payment",
                        style: TextStyle(fontSize: 10, color: Colors.green)),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 18, color: Colors.purple),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.purple)),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(
              fontSize: isTotal ? 16 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: GoogleFonts.poppins(
              fontSize: isTotal ? 16 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.purple : Colors.black)),
        ],
      ),
    );
  }
}