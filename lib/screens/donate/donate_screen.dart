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

  final List<String> _categories = [
    '👕 Tops & T-Shirts',
    '👖 Bottoms & Jeans',
    '👗 Dresses & Skirts',
    '🧥 Outerwear & Jackets',
    '🏃 Activewear & Sportswear',
    '👟 Shoes & Footwear',
    '👜 Accessories (bags, scarves)',
    '👶 Kids & Baby Clothes',
    '👔 Formal & Business Wear',
    '🎁 Mixed Items Bundle',
  ];

  final List<Map<String, String>> _conditions = [
    {'emoji': '✨', 'title': 'Excellent - Like new', 'desc': 'No visible signs of wear'},
    {'emoji': '👍', 'title': 'Good - Minor wear', 'desc': 'Minor signs of use, still in good condition'},
    {'emoji': '🧼', 'title': 'Needs Cleaning', 'desc': 'Good condition but needs washing or minor repairs'},
  ];

  final List<Map<String, dynamic>> _options = [
    {'emoji': '🔥', 'title': 'Symbolic Payment', 'desc': 'Get paid for your donation', 'points': 'Earns 15 points'},
    {'emoji': '🎁', 'title': 'App Credits', 'desc': 'Shop with store credit', 'points': 'Earns 20 points'},
    {'emoji': '❤️', 'title': 'Full Donation', 'desc': 'Help the environment', 'points': 'Earns 25 points'},
  ];

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
              const SizedBox(height: 16),

              // Full Name
              Text('Full Name', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  label: Text(
                    'Nadeen Abu Hilweh',
                    style: GoogleFonts.poppins(fontSize: 12.5),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 16),

              // Pickup Address
              Text('Pickup Address', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        label: Text(
                          'Jerusalem',
                          style: GoogleFonts.poppins(fontSize: 12.5),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Icon(Icons.location_on_outlined, color: Colors.purple),
                  ),
                ],
              ),
              Text('Click the pin icon to use your current location',
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45)),
              const SizedBox(height: 16),

              // Clothing Category
              Text('Clothing Category', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                hint: Text('Select category', style: GoogleFonts.poppins(fontSize: 13)),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
              ),
              const SizedBox(height: 16),

              // Condition
              Text('Condition', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedCondition,
                hint: Text('Select condition', style: GoogleFonts.poppins(fontSize: 13)),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                items: _conditions.map((c) => DropdownMenuItem(
                  value: c['title'],
                  child: Text('${c['emoji']} ${c['title']}', style: GoogleFonts.poppins(fontSize: 13)),
                )).toList(),
                onChanged: (val) => setState(() => _selectedCondition = val),
              ),
              const SizedBox(height: 16),

              // Preferred Option
              Text('Preferred Option', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              ..._options.map((option) => GestureDetector(
                onTap: () => setState(() => _selectedOption = option['title']),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _selectedOption == option['title'] ? const Color(0xFFF3EEFF) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedOption == option['title'] ? Colors.purple : Colors.grey.shade200,
                      width: _selectedOption == option['title'] ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      if (_selectedOption == option['title'])
                        const Icon(Icons.circle, color: Colors.purple, size: 12),
                      if (_selectedOption != option['title'])
                        const SizedBox(width: 12),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${option['emoji']} ${option['title']}',
                                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold)),
                            Text(option['desc'], style: GoogleFonts.poppins(fontSize: 12, color: Colors.black45)),
                            Text(option['points'], style: GoogleFonts.poppins(fontSize: 12, color: Colors.purple, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
              Text('Select your preferred way to donate. Points can be used for rewards in the app.',
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45)),
              const SizedBox(height: 16),

              // Additional Notes
              Text('Additional Notes (Optional)', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Any special instructions or details about the items...',
                  hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.black38),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 16),

              // Photos
              Text('Photos (Optional)', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.upload_outlined, color: Colors.grey, size: 32),
                      const SizedBox(height: 8),
                      Text('Click to upload or drag and drop', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black45)),
                      Text('PNG, JPG up to 10MB', style: GoogleFonts.poppins(fontSize: 11, color: Colors.black38)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const DonationSubmittedScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Submit Donation Request', style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}