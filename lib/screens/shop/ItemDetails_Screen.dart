import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cart/cart_screen.dart';
import 'package:provider/provider.dart';
import '../../../providers/cart_provider.dart';

class ItemDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> item;

  const ItemDetailsScreen({super.key, required this.item});

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  bool isFavorite = false;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  List<String> productImages = [];

  @override
  void initState() {
    super.initState();
    if (widget.item['images'] != null && widget.item['images'] is List) {
      productImages = List<String>.from(widget.item['images']);
    } else if (widget.item['imageUrl'] != null && widget.item['imageUrl'] != "") {
      productImages = [widget.item['imageUrl']];
    } else {
      productImages = [""];
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int qty = widget.item['quantity'] ?? 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Item Details',
            style: GoogleFonts.poppins(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.black,
            ),
            onPressed: () => setState(() => isFavorite = !isFavorite),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageGallery(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(widget.item['title'] ?? widget.item['name'] ?? "Product Name",
                            style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
                      ),
                      Text("₪${widget.item['price'] ?? '0'}",
                          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.purple[700])),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Availability Row
                  Row(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 14, color: qty > 0 ? Colors.green : Colors.red),
                      const SizedBox(width: 6),
                      Text(
                        qty > 0 ? "$qty pieces in stock" : "Out of Stock",
                        style: GoogleFonts.poppins(fontSize: 13, color: qty > 0 ? Colors.green : Colors.red, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(widget.item['description'] ?? "No description provided for this unique piece.",
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600], height: 1.5)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildBadge("Size: ${widget.item['size'] ?? 'N/A'}"),
                      _buildBadge("Condition: ${widget.item['condition'] ?? 'Good'}"),
                      _buildBadge("Type: ${widget.item['type'] ?? 'Clothing'}"),
                      _buildBadge("For: ${widget.item['gender'] ?? 'All'}"), // Gender Badge
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildFeaturesCard(),
                  const SizedBox(height: 16),
                  _buildDetailsCard(qty),
                  const SizedBox(height: 24),
                  _buildActionButtons(qty),
                  const SizedBox(height: 16),
                  _buildEcoNote(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    return Container(
      height: 420,
      width: double.infinity,
      color: Colors.white,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: productImages.length,
            onPageChanged: (int page) => setState(() => _currentPage = page),
            itemBuilder: (context, index) {
              if (productImages[index].isEmpty) {
                return const Center(child: Icon(Icons.image_outlined, size: 100, color: Colors.grey));
              }
              return Image.network(
                productImages[index],
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
              );
            },
          ),
          if (productImages.length > 1)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(productImages.length, (index) => _buildIndicator(index)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIndicator(int index) {
    bool isSelected = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isSelected ? 24 : 8,
      decoration: BoxDecoration(
        color: isSelected ? Colors.purple[600] : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildFeaturesCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey[100]!)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Why ReCloth?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 16),
            _featureRow(Icons.eco_outlined, "Eco-Friendly Choice", "Sustainable fashion that saves resources"),
            _featureRow(Icons.verified_user_outlined, "Quality Inspected", "Hand-picked and professionally cleaned"),
          ],
        ),
      ),
    );
  }

  Widget _featureRow(IconData icon, String title, String sub) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(sub, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDetailsCard(int qty) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey[100]!)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _dataRow("Condition", widget.item['condition'] ?? "Like New"),
            const Divider(),
            _dataRow("Size", widget.item['size'] ?? "Medium"),
            const Divider(),
            _dataRow("Section", widget.item['gender'] ?? "All"), // Gender Row
            const Divider(),
            _dataRow("Category", widget.item['type'] ?? "Clothing"),
            const Divider(),
            _dataRow("Stock Availability", qty > 0 ? "$qty available" : "Out of stock"),
          ],
        ),
      ),
    );
  }

  Widget _dataRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildActionButtons(int qty) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        bool isAvailable = (widget.item['isAvailable'] ?? true) && qty > 0;
        String itemName = widget.item['title'] ?? widget.item['name'] ?? "";
        bool isAlreadyInCart = cart.cartItems.any((item) => (item['title'] ?? item['name']) == itemName);

        return Column(
          children: [
            ElevatedButton(
              onPressed: isAvailable
                  ? () {
                if (isAlreadyInCart) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Already in your cart!"), backgroundColor: Colors.redAccent),
                  );
                } else {
                  cart.addItem(widget.item);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("$itemName added!"), backgroundColor: Colors.purple[600], duration: const Duration(seconds: 1)),
                  );
                }
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isAvailable ? Colors.purple[600] : Colors.grey[400],
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                  isAvailable ? (isAlreadyInCart ? "Already in Cart" : "Add to Cart") : "Sold Out",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                side: BorderSide(color: Colors.grey[300]!),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text("Go to Cart", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEcoNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF3EEFF), borderRadius: BorderRadius.circular(14)),
      child: Text(
        "🌿 Every purchase supports the circular economy and reduces textile waste.",
        style: GoogleFonts.poppins(fontSize: 12, color: Colors.purple[900]),
        textAlign: TextAlign.center,
      ),
    );
  }
}