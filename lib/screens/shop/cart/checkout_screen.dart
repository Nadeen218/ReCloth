import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckoutScreen extends StatefulWidget {
  final double totalAmount;

  const CheckoutScreen({super.key, required this.totalAmount});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // State management for payment selection
  String _selectedPaymentMethod = 'Cash on Delivery';
  String _selectedOnlineType = 'Credit/Debit Card';

  @override
  Widget build(BuildContext context) {
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
        title: Text(
          'Checkout',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSectionCard(
              title: 'Delivery Address',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Address', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter your address',
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            //Payment Method Card
            _buildSectionCard(
              title: 'Payment Method',
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedPaymentMethod,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: ['Cash on Delivery', 'Online Payment'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: GoogleFonts.poppins(fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedPaymentMethod = newValue!;
                          });
                        },
                      ),
                    ),
                  ),

                  // Display online payment options if online payment is selected
                  if (_selectedPaymentMethod == 'Online Payment') ...[
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Select Payment Type',
                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),

                    // Payment Type Selection Cards
                    _buildPaymentTypeCard('Credit/Debit Card', 'Visa, Mastercard', Icons.credit_card),

                    // Card details input fields visible only for Credit Card
                    if (_selectedOnlineType == 'Credit/Debit Card') ...[
                      const SizedBox(height: 20),
                      _buildPaymentTextField('Card Number', '1234 5678 9012 3456', icon: Icons.credit_card),
                      _buildPaymentTextField('Cardholder Name', 'Name on card'),
                      Row(
                        children: [
                          Expanded(child: _buildPaymentTextField('Expiry Date', 'MM/YY')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildPaymentTextField('CVV', '123')),
                        ],
                      ),
                    ],
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Order Summary Card
            _buildSectionCard(
              title: 'Order Summary',
              child: Column(
                children: [
                  _buildSummaryRow('Subtotal:', '₪ ${subtotal.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Shipping:', '₪ ${shipping.toStringAsFixed(2)}'),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(),
                  ),
                  _buildSummaryRow('Total:', '₪ ${widget.totalAmount.toStringAsFixed(2)}', isTotal: true),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Place Order Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Finalize order logic goes here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9C27B0),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Place Order',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for payment type selection cards with active purple border
  Widget _buildPaymentTypeCard(String title, String subtitle, IconData icon) {
    bool isSelected = _selectedOnlineType == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedOnlineType = title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF9C27B0) : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF9C27B0), size: 28),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
                Text(subtitle, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Styled text field for payment information
  Widget _buildPaymentTextField(String label, String hint, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextField(
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: icon != null ? Icon(icon, size: 20) : null,
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  // Generic card wrapper for sections
  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // Row for subtotal, shipping, and total amounts
  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: isTotal ? 16 : 13, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isTotal ? Colors.black : Colors.grey[600])),
        Text(value, style: GoogleFonts.poppins(fontSize: isTotal ? 16 : 13, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isTotal ? const Color(0xFF9C27B0) : Colors.black)),
      ],
    );
  }
}