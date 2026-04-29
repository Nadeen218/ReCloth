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

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context, cart),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchAndFilters(),

          // Using StreamBuilder to fetch products from Firestore in real-time
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Something went wrong"));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF8B00FF)));
                }

                final allDocs = snapshot.data!.docs;
                final filteredProducts = allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  bool matchesSearch = (data['title'] ?? '').toString().toLowerCase().contains(searchController.text.toLowerCase());
                  bool matchesGender = selectedGender == 'All' || (data['gender'] ?? 'All') == selectedGender;
                  bool matchesType = selectedType == 'All Types' || (data['type'] ?? 'All Types') == selectedType;
                  bool matchesCondition = selectedCondition == 'All Conditions' || (data['condition'] ?? 'All Conditions') == selectedCondition;

                  return matchesSearch && matchesGender && matchesType && matchesCondition;
                }).toList();

                if (filteredProducts.isEmpty) {
                  return _buildEmptyState();
                }

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
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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

  //Product Card UI with Quantity and Gender
  Widget _buildProductCard(Map<String, dynamic> product, CartProvider cart) {
    bool isFav = favoriteProducts.contains(product['title']);
    int qty = product['quantity'] ?? 1;
    bool isAvailable = (product['isAvailable'] ?? true) && qty > 0;
    String gender = product['gender'] ?? 'All';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ItemDetailsScreen(item: product)),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: product['imageUrl'] != null && product['imageUrl'] != ""
                      ? Image.network(product['imageUrl'], height: 260, width: double.infinity, fit: BoxFit.cover)
                      : Container(height: 260, color: Colors.grey[200], child: const Icon(Icons.image)),
                ),
                _buildUniqueBadge(),
                // Gender Badge on Image
                Positioned(
                  top: 15,
                  right: 55,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      gender.toUpperCase(),
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                _buildFavoriteButton(product['title'], isFav),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fixing Overflow in Title and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product['title'] ?? 'No Title',
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "₪${product['price']}",
                        style: GoogleFonts.poppins(color: const Color(0xFF8B00FF), fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildChip("Size: ${product['size']}"),
                      const SizedBox(width: 8),
                      Expanded(child: _buildChip("For: $gender")),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Quantity Display
                  Row(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 14, color: qty > 0 ? Colors.green : Colors.red),
                      const SizedBox(width: 6),
                      Text(
                        qty > 0 ? "$qty pieces available" : "Out of Stock",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: qty > 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildAddToCartButton(product, cart, isAvailable),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterToggle() {
    return Container(
      decoration: BoxDecoration(
        color: showFilters ? const Color(0xFF8B00FF).withOpacity(0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: () => setState(() => showFilters = !showFilters),
        icon: Icon(Icons.tune, color: showFilters ? const Color(0xFF8B00FF) : Colors.black),
      ),
    );
  }

  Widget _buildUniqueBadge() {
    return Positioned(
      top: 15,
      left: 15,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF8B00FF).withOpacity(0.9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.white, size: 13),
            const SizedBox(width: 4),
            Text("UNIQUE PIECE", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(String title, bool isFav) {
    return Positioned(
      top: 10,
      right: 10,
      child: CircleAvatar(
        backgroundColor: Colors.white,
        child: IconButton(
          icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: Colors.red),
          onPressed: () => setState(() => isFav ? favoriteProducts.remove(title) : favoriteProducts.add(title)),
        ),
      ),
    );
  }

  Widget _buildAddToCartButton(Map<String, dynamic> product, CartProvider cart, bool isAvailable) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isAvailable ? () {
          cart.addItem(product);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${product['title']} added!")));
        } : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isAvailable ? const Color(0xFF8B00FF) : Colors.grey,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(isAvailable ? "Add to Cart" : "Sold Out", style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, CartProvider cart) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text('ReCloth Store', style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
      actions: [
        IconButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
          icon: Badge(
            label: Text('${cart.itemCount}'),
            isLabelVisible: cart.itemCount > 0,
            child: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
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
          Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
          Text("No matches found", style: GoogleFonts.poppins(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildAdvancedFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        Text("Categories", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['All Types', 'Shirts', 'Jackets', 'Dresses', 'Coats', 'Pants', 'Shoes', 'Mixed Items']
                .map((cat) => _buildQuickChip(cat))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickChip(String category) {
    bool isSelected = selectedType == category;
    return GestureDetector(
      onTap: () => setState(() => selectedType = category),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF9800).withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFFFF9800) : Colors.transparent),
        ),
        child: Text(category, style: GoogleFonts.poppins(color: isSelected ? const Color(0xFFFF9800) : Colors.black54, fontSize: 12)),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: ['All', 'Men', 'Women', 'Kids'].map((gender) {
        bool isSelected = selectedGender == gender;
        return GestureDetector(
          onTap: () => setState(() => selectedGender = gender),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF8B00FF) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSelected ? const Color(0xFF8B00FF) : Colors.grey[300]!),
            ),
            child: Text(gender, style: GoogleFonts.poppins(color: isSelected ? Colors.white : Colors.black87, fontSize: 12)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(8)),
      child: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}