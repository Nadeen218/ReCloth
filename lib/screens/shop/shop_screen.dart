import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ItemDetails_Screen.dart';
import 'package:provider/provider.dart';
import '../../../providers/cart_provider.dart';
import 'cart/cart_screen.dart';


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
//example of item until connect firebase
  final List<Map<String, dynamic>> allProducts = [
    {
      "name": "Classic Denim Jacket",
      "title": "Classic Denim Jacket",
      "description": "Vintage-style denim jacket, professionally restored",
      "size": "M",
      "condition": "Good",
      "type": "Jackets",
      "gender": "Men",
      "price": 20,
      "imageUrl": "",
      "images": [
        "",
        "",
      ],
    },
    {
      "name": "Black Cotton T-Shirt",
      "title": "Black Cotton T-Shirt",
      "description": "Premium black cotton tee, almost brand new",
      "size": "L",
      "condition": "Like New",
      "type": "Shirts",
      "gender": "Men",
      "price": 8,
      "imageUrl": "",
      "images": [
        "",
        "",
      ],
    },
    {
      "name": "Floral Summer Dress",
      "title": "Floral Summer Dress",
      "description": "Light and airy floral dress for summer days",
      "size": "S",
      "condition": "Good",
      "type": "Dresses",
      "gender": "Women",
      "price": 15,
      "imageUrl": "",
      "images": [
       "",
       "",
      ],
    },
    {
      "name": "Kids Sporty Hoodie",
      "title": "Kids Sporty Hoodie",
      "description": "Comfortable cotton hoodie for active kids",
      "size": "S",
      "condition": "Like New",
      "type": "Coats",
      "gender": "Kids",
      "price": 12,
      "imageUrl": "",
      "images": [
        "",
        "",
          ],
    },
  ];

  List<Map<String, dynamic>> filteredProducts = [];

  @override
  void initState() {
    super.initState();
    filteredProducts = allProducts;
  }

//filter logic
  void _applyFilters() {
    String searchTerm = searchController.text.toLowerCase();

    setState(() {
      filteredProducts = allProducts.where((product) {
        bool matchesSearch = product["title"]!.toLowerCase().contains(searchTerm);
        bool matchesGender = selectedGender == 'All' || product["gender"] == selectedGender;
        bool matchesType = selectedType == 'All Types' || product["type"] == selectedType;
        bool matchesCondition = selectedCondition == 'All Conditions' || product["condition"] == selectedCondition;

        return matchesSearch && matchesGender && matchesType && matchesCondition;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Shop Fashion',
          style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
                icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
              ),
              if (cart.itemCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.purple, shape: BoxShape.circle),
                    child: Text('${cart.itemCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) => _applyFilters(),
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search items...',
                          hintStyle: GoogleFonts.poppins(),
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: showFilters ? const Color(0xFF8B00FF).withOpacity(0.1) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () => setState(() => showFilters = !showFilters),
                        icon: Icon(Icons.tune, color: showFilters ? const Color(0xFF8B00FF) : Colors.black),
                      ),
                    ),
                  ],
                ),

                // gender selector
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: ['All', 'Men', 'Women', 'Kids','Baby'].map((gender) {
                    bool isSelected = selectedGender == gender;
                    return GestureDetector(
                      onTap: () {
                        setState(() => selectedGender = gender);
                        _applyFilters();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF8B00FF) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? const Color(0xFF8B00FF) : Colors.grey[300]!),
                        ),
                        child: Text(
                          gender,
                          style: GoogleFonts.poppins(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 15),
              ],
            ),
          ),

          if (showFilters)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 15, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // type bar
                  Text("Categories", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All Types', 'Shirts', 'Jackets', 'Dresses', 'Coats', 'Pants','Shoes','Mixed Items']
                          .map((cat) => _buildQuickChip(cat))
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // condition
                  _buildFilterDropdown(
                      "Condition",
                      ['All Conditions','Brand New', 'Like New', 'Good'],
                      selectedCondition, (val) {
                    setState(() => selectedCondition = val!);
                    _applyFilters();
                  }
                  ),
                ],
              ),
            ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "${filteredProducts.length} items found",
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: filteredProducts.isNotEmpty
                ? ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) => _buildProductCard(filteredProducts[index],cart),
            )
                : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
                  Text("No matches found", style: GoogleFonts.poppins(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // item card
  Widget _buildProductCard(Map<String, dynamic> product, CartProvider cart) {
    bool isFav = favoriteProducts.contains(product['title']);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetailsScreen(item: product),
          ),
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
                  child: product['imageUrl']!.isNotEmpty
                      ? Image.network(product['imageUrl']!, height: 260, width: double.infinity, fit: BoxFit.cover)
                      : Container(height: 260, color: Colors.grey[200], child: const Icon(Icons.image)),
                ),
                Positioned(
                  top: 15,
                  left: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(10)),
                    child: Text("₪${product['price']}", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          isFav ? favoriteProducts.remove(product['title']) : favoriteProducts.add(product['title']!);
                        });
                      },
                    ),
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
                      Text(product['title']!, style: GoogleFonts.poppins(fontSize: 15)),
                      Text(product['gender']!, style: GoogleFonts.poppins(color: const Color(0xFF8B00FF), fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(product['description']!, style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildChip("Size: ${product['size']}"),
                      const SizedBox(width: 8),
                      _buildChip(product['condition']!),
                    ],
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        cart.addItem(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${product['title']} added to cart!")),

                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B00FF),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("Add to Cart", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChip(String category) {
    bool isSelected = selectedType == category;
    return GestureDetector(
      onTap: () {
        setState(() => selectedType = category);
        _applyFilters();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B00FF).withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF8B00FF) : Colors.transparent),
        ),
        child: Text(
          category,
          style: GoogleFonts.poppins(
            color: isSelected ? const Color(0xFF8B00FF) : Colors.black54,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(String label, List<String> items, String currentVal, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentVal,
              isExpanded: true,
              style: GoogleFonts.poppins(color: Colors.black, fontSize: 13),
              items: items.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black54)),
    );
  }
}