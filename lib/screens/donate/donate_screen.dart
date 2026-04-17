import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'donation_submitted_screen.dart';

class DonateScreen extends StatefulWidget {
  const DonateScreen({super.key});

  @override
  State<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends State<DonateScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedCategory;
  String? _selectedCondition;
  String? _selectedOption;
  bool _imageUploaded = false; // Tracks if the user has simulated an image upload

  // Category list with specific pricing for each item type
  final List<Map<String, dynamic>> _categories = [
    {'name': '👕 Tops & T-Shirts', 'price': 3},
    {'name': '👖 Bottoms & Jeans', 'price': 5},
    {'name': '👗 Dresses & Skirts', 'price': 7},
    {'name': '🧥 Outerwear & Jackets', 'price': 10},
    {'name': '👟 Shoes & Footwear', 'price': 8},
    {'name': '👶 Kids & Baby Clothes', 'price': 4},
  ];

  final List<Map<String, String>> _conditions = [
    {'emoji': '✨', 'title': 'Excellent - Like new'},
    {'emoji': '👍', 'title': 'Good - Minor wear'},
    {'emoji': '🧼', 'title': 'Needs Cleaning'},
    {'emoji': '♻️', 'title': 'Damaged'},
  ];

  final List<Map<String, dynamic>> _options = [
    {'emoji': '💰', 'title': 'Symbolic Payment', 'desc': 'Get paid based on item type', 'points': 'Earns 10 points'},
    {'emoji': '❤️', 'title': 'Full Donation', 'desc': 'Help the environment', 'points': 'Earns 20 points'},
  ];

  // Logic to determine if a photo is mandatory based on the selected reward option
  bool _isImageRequired() {
    return _selectedOption == 'Symbolic Payment' ;
  }

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
        title: Text('Donate Clothes', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.08), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Donation Details', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              _buildLabel('Full Name'),
              TextField(decoration: _inputDecoration('Nadeen'), controller: _nameController),
              const SizedBox(height: 16),

              _buildLabel('Pickup Address'),
              Row(
                children: [
                  Expanded(child: TextField(decoration: _inputDecoration('Palestine'), controller: _addressController)),
                  const SizedBox(width: 8),
                  _buildIconBtn(Icons.location_on_outlined),
                ],
              ),
              const SizedBox(height: 16),

              _buildLabel('Clothing Category'),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                hint: Text('Select category', style: GoogleFonts.poppins(fontSize: 13)),
                decoration: _inputDecoration(''),
                items: _categories.map((c) => DropdownMenuItem(
                  value: c['name'] as String,
                  child: Text(c['name'], style: GoogleFonts.poppins(fontSize: 13)),
                )).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
              ),
              const SizedBox(height: 16),

              _buildLabel('Condition'),
              DropdownButtonFormField<String>(
                value: _selectedCondition,
                hint: Text('Select condition', style: GoogleFonts.poppins(fontSize: 13)),
                decoration: _inputDecoration(''),
                items: _conditions.map((c) => DropdownMenuItem(
                  value: c['title'],
                  child: Text('${c['emoji']} ${c['title']}', style: GoogleFonts.poppins(fontSize: 13)),
                )).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedCondition = val;
                    // Automatically force "Full Donation" if item quality is poor
                    if ( _selectedCondition == 'Damaged') {
                      _selectedOption = 'Full Donation';
                    }
                  });
                },
              ),
              const SizedBox(height: 20),

              _buildLabel('Preferred Option'),
              // Filter out payment options if the item condition isn't good enough
              ..._options.where((option) {
                if (_selectedCondition == 'Damaged') {
                  return option['title'] == 'Full Donation';
                }
                return true;
              }).map((option) => GestureDetector(
                onTap: () => setState(() => _selectedOption = option['title']),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _selectedOption == option['title'] ? const Color(0xFFF3EEFF) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _selectedOption == option['title'] ? Colors.purple : Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(_selectedOption == option['title'] ? Icons.check_circle : Icons.circle_outlined, color: _selectedOption == option['title'] ? Colors.purple : Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${option['emoji']} ${option['title']}', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold)),
                            // Display dynamic pricing if Symbolic Payment is chosen
                            Text(
                              (option['title'] == 'Symbolic Payment' && _selectedCategory != null)
                                  ? 'You will get ${_categories.firstWhere((c) => c['name'] == _selectedCategory)['price']} NIS for this item'
                                  : option['desc'],
                              style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45),
                            ),
                            Text(option['points'], style: GoogleFonts.poppins(fontSize: 11, color: Colors.purple, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),

              const SizedBox(height: 16),

              // Image picker section with conditional validation labels
              Row(
                children: [
                  _buildLabel('Photos'),
                  const SizedBox(width: 4),
                  Text(_isImageRequired() ? '(Required)' : '(Optional)',
                      style: GoogleFonts.poppins(fontSize: 11, color: _isImageRequired() ? Colors.red : Colors.black45, fontWeight: _isImageRequired() ? FontWeight.bold : FontWeight.normal)),
                ],
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => setState(() => _imageUploaded = true), // Placeholder for actual image picking logic
                child: Container(
                  height: 120, width: double.infinity,
                  decoration: BoxDecoration(
                    color: _imageUploaded ? Colors.green[50] : Colors.white,
                    border: Border.all(color: _imageUploaded ? Colors.green : Colors.grey.shade300, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_imageUploaded ? Icons.check_circle : Icons.upload_outlined, color: _imageUploaded ? Colors.green : Colors.grey, size: 32),
                        const SizedBox(height: 8),
                        Text(_imageUploaded ? 'Image Uploaded' : 'Click to upload PNG, JPG', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black45)),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              // Final submission with validation check
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Block submission if a required photo is missing
                    if (_isImageRequired() && !_imageUploaded) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please upload a photo to proceed'), backgroundColor: Colors.red),
                      );
                      return;
                    }
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DonationSubmittedScreen()));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: Text('Submit Donation Request', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // UI Helper: Common input field decoration
  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint, filled: true, fillColor: Colors.grey[100],
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  );

  // UI Helper: Label style for form fields
  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(text, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)));

  // UI Helper: Square icon button for location
  Widget _buildIconBtn(IconData icon) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)), child: Icon(icon, color: Colors.purple, size: 20));
}