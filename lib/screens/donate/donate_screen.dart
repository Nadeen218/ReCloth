import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'donation_submitted_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonateScreen extends StatefulWidget {
  const DonateScreen({super.key});

  @override
  State<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends State<DonateScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedCategory;
  String? _selectedCondition;
  String? _selectedOption;
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  // Constants for environmental impact calculation
  final double _co2PerItem = 2.5; // Each donated item saves ~2.5kg of CO2

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

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      String fileName = 'donations/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  bool _isImageRequired() {
    return _selectedOption == 'Symbolic Payment';
  }

  /// Main function to submit donation and update user statistics for Admin Dashboard
  Future<void> _submitDonation() async {
    if (_isImageRequired() && _pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a photo to proceed'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_selectedCategory == null || _selectedCondition == null || _selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isUploading = true);

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.purple)),
    );

    try {
      String? imageUrl;
      if (_pickedImage != null) {
        imageUrl = await _uploadImage(_pickedImage!);
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Logic: Full Donation grants more points than Symbolic Payment
      int pointsToEarn = _selectedOption == 'Full Donation' ? 20 : 10;

      // 1. Save the donation request to 'donations' collection
      await FirebaseFirestore.instance.collection('donations').add({
        'userId': user.uid,
        'donorName': _nameController.text,
        'address': _addressController.text,
        'category': _selectedCategory,
        'condition': _selectedCondition,
        'option': _selectedOption,
        'imageUrl': imageUrl,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
        'pointsEarned': pointsToEarn,
        'co2Saved': _co2PerItem, // Track individual donation impact
      });

      // 2. Update User Document for real-time Admin Dashboard stats
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(userRef);

        if (snapshot.exists) {
          // Increment existing user statistics
          transaction.update(userRef, {
            'totalDonations': FieldValue.increment(1), // Counter for "Items Recycled"
            'points': FieldValue.increment(pointsToEarn),
            'co2Saved': FieldValue.increment(_co2PerItem), // Aggregated CO2 for Dashboard
            'status': 'Active',
            'lastActivity': FieldValue.serverTimestamp(),
          });
        } else {
          // Create new user record if it doesn't exist (first-time donor)
          transaction.set(userRef, {
            'userName': _nameController.text,
            'email': user.email,
            'totalDonations': 1,
            'points': pointsToEarn,
            'co2Saved': _co2PerItem,
            'totalPaid': 0.0,
            'status': 'Active',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      });

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      // Navigate to Success Screen
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DonationSubmittedScreen(pointsEarned: pointsToEarn))
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
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
              TextField(decoration: _inputDecoration('Your Name'), controller: _nameController),
              const SizedBox(height: 16),
              _buildLabel('Pickup Address'),
              Row(
                children: [
                  Expanded(child: TextField(decoration: _inputDecoration('Address'), controller: _addressController)),
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
                    if (_selectedCondition == 'Damaged') {
                      _selectedOption = 'Full Donation';
                    }
                  });
                },
              ),
              const SizedBox(height: 20),
              _buildLabel('Preferred Option'),
              ..._options.where((option) {
                if (_selectedCondition == 'Damaged') return option['title'] == 'Full Donation';
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
              Row(
                children: [
                  _buildLabel('Photos'),
                  const SizedBox(width: 4),
                  Text(_isImageRequired() ? '(Required)' : '(Optional)',
                      style: GoogleFonts.poppins(fontSize: 11, color: _isImageRequired() ? Colors.red : Colors.black45)),
                ],
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150, width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border.all(color: _pickedImage != null ? Colors.green : Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _pickedImage != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(_pickedImage!, fit: BoxFit.cover),
                  )
                      : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.upload_outlined, color: Colors.grey, size: 32),
                        const SizedBox(height: 8),
                        Text('Click to upload item photo', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black45)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _submitDonation,
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

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint, filled: true, fillColor: Colors.grey[100],
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  );

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(text, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)));

  Widget _buildIconBtn(IconData icon) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)), child: Icon(icon, color: Colors.purple, size: 20));
}