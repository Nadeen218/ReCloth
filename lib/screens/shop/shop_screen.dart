import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ItemDetails_Screen.dart';
import 'package:provider/provider.dart';
import '../../../providers/cart_provider.dart';
import 'cart/cart_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String selectedGender = 'All';
  String selectedType = 'All Types';
  String selectedCondition = 'All Conditions';
  bool showFilters = false;
  TextEditingController searchController = TextEditingController();
  List<String> favoriteProducts = [];

  // Theme Colors
  final List<Color> _purpleGradient = const [
    Color(0xFF6B21A8),
    Color(0xFF7C3AED),
    Color(0xFF9333EA),
  ];

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FF), // Subtle purple tint background
      appBar: _buildAppBar(context, cart),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Something went wrong"));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)));
                }

                final allDocs = snapshot.data!.docs;
                final filteredProducts = allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  int qty = data['quantity'] ?? 0;
                  bool isAvailable = (data['isAvailable'] ?? true) && qty > 0;

                  bool matchesSearch = (data['title'] ?? '').toString().toLowerCase().contains(searchController.text.toLowerCase());
                  bool matchesGender = selectedGender == 'All' || (data['gender'] ?? 'All') == selectedGender;
                  bool matchesType = selectedType == 'All Types' || (data['type'] ?? 'All Types') == selectedType;
                  bool matchesCondition = selectedCondition == 'All Conditions' || (data['condition'] ?? 'All Conditions') == selectedCondition;

                  return isAvailable && matchesSearch && matchesGender && matchesType && matchesCondition;
                }).toList();

                if (filteredProducts.isEmpty) return _buildEmptyState();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final productData = filteredProducts[index].data() as Map<String, dynamic>;
                    return _buildProductCard(productData, cart);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  onChanged: (value) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search items...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF7C3AED)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.purple.withOpacity(0.1))
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.purple.withOpacity(0.1))
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _buildFilterToggle(),
            ],
          ),
          const SizedBox(height: 15),
          _buildGenderSelector(),
          if (showFilters) _buildAdvancedFilters(),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, CartProvider cart) {
    int qty = product['quantity'] ?? 1;
    bool isAvailable = (product['isAvailable'] ?? true) && qty > 0;
    String gender = product['gender'] ?? 'All';

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ItemDetailsScreen(item: product))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(color: Colors.purple.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                  child: product['imageUrl'] != null && product['imageUrl'] != ""
                      ? Image.network(product['imageUrl'], height: 280, width: double.infinity, fit: BoxFit.cover)
                      : Container(height: 280, color: Colors.grey[200], child: const Icon(Icons.image)),
                ),
                _buildUniqueBadge(),
                Positioned(
                  top: 15,
                  right: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(gender.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product['title'] ?? 'No Title',
                          style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFF4A148C)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        "₪${product['price']}",
                        style: GoogleFonts.poppins(color: const Color(0xFF7C3AED), fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildChip("Size: ${product['size']}"),
                      const SizedBox(width: 8),
                      Icon(Icons.inventory_2_outlined, size: 14, color: qty > 0 ? Colors.green : Colors.red),
                      const SizedBox(width: 4),
                      Text(qty > 0 ? "$qty available" : "Out of Stock",
                          style: GoogleFonts.poppins(fontSize: 11, color: qty > 0 ? Colors.green : Colors.red, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildAddToCartButton(product, cart, isAvailable),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddToCartButton(Map<String, dynamic> product, CartProvider cart, bool isAvailable) {
    return GestureDetector(
      onTap: isAvailable ? () {
        cart.addItem(product);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("${product['title']} added!"),
          backgroundColor: const Color(0xFF7C3AED),
        ));
      } : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: isAvailable ? LinearGradient(colors: _purpleGradient) : null,
          color: isAvailable ? null : Colors.grey[300],
          borderRadius: BorderRadius.circular(15),
          boxShadow: isAvailable ? [
            BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
          ] : [],
        ),
        child: Center(
          child: Text(
            isAvailable ? "Add to Cart" : "Sold Out",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterToggle() {
    return Container(
      decoration: BoxDecoration(
        color: showFilters ? const Color(0xFF7C3AED).withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: showFilters ? const Color(0xFF7C3AED) : Colors.purple.withOpacity(0.1)),
      ),
      child: IconButton(
        onPressed: () => setState(() => showFilters = !showFilters),
        icon: Icon(Icons.tune, color: showFilters ? const Color(0xFF7C3AED) : Colors.black54),
      ),
    );
  }

  Widget _buildUniqueBadge() {
    return Positioned(
      top: 15,
      left: 15,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: _purpleGradient),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
            const SizedBox(width: 6),
            Text("UNIQUE", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, CartProvider cart) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text('ReCloth Store', style: GoogleFonts.poppins(color: const Color(0xFF4A148C), fontWeight: FontWeight.bold, fontSize: 20)),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
            icon: Badge(
              backgroundColor: const Color(0xFF7C3AED),
              label: Text('${cart.itemCount}'),
              isLabelVisible: cart.itemCount > 0,
              child: const Icon(Icons.shopping_bag_outlined, color: Colors.black, size: 28),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: ['All', 'Men', 'Women', 'Kids'].map((gender) {
        bool isSelected = selectedGender == gender;
        return GestureDetector(
          onTap: () => setState(() => selectedGender = gender),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected ? LinearGradient(colors: _purpleGradient) : null,
              color: isSelected ? null : Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.3), blurRadius: 6)] : [],
            ),
            child: Text(
                gender,
                style: GoogleFonts.poppins(color: isSelected ? Colors.white : Colors.black54, fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickChip(String category) {
    bool isSelected = selectedType == category;
    return GestureDetector(
      onTap: () => setState(() => selectedType = category),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7C3AED).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? const Color(0xFF7C3AED) : Colors.transparent),
        ),
        child: Text(category, style: GoogleFonts.poppins(color: isSelected ? const Color(0xFF7C3AED) : Colors.black54, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFF3EEFF), borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF7C3AED), fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildAdvancedFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text("Categories", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['All Types', 'Shirts', 'Formal', 'Dresses', 'Coats', 'Pants', 'Shoes', 'Others']
                .map((cat) => _buildQuickChip(cat))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.purple.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text("No matches found", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}