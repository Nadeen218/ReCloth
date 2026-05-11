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
  String? _selectedGender;
  String? _selectedPickupTime;
  DateTime? _selectedDate;
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  // Primary Theme Colors
  final List<Color> _purpleGradient = const [
    Color(0xFF6B21A8),
    Color(0xFF7C3AED),
    Color(0xFF9333EA),
  ];

  final double _co2PerItem = 2.5;

  final List<Map<String, dynamic>> _categories = [
    {'name': '👕 Tops & T-Shirts', 'price': 3},
    {'name': '👖 Bottoms & Jeans', 'price': 5},
    {'name': '👗 Dresses & Skirts', 'price': 7},
    {'name': '🧥 Outerwear & Formal', 'price': 10},
    {'name': '👟 Shoes & Footwear', 'price': 8},
    {'name': '👶 Kids & Baby Clothes', 'price': 4},
    {'name': '🧩 Others', 'price': 2},
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

  final List<Map<String, String>> _genderOptions = [
    {'emoji': '👨', 'title': 'Men'},
    {'emoji': '👩', 'title': 'Women'},
    {'emoji': '👦', 'title': 'Kids'},
    {'emoji': '🔀', 'title': 'Mix'},
  ];

  final List<Map<String, String>> _pickupTimes = [
    {'emoji': '🌅', 'title': 'Morning', 'range': '8:00 AM – 12:00 PM'},
    {'emoji': '☀️', 'title': 'Afternoon', 'range': '12:00 PM – 4:00 PM'},
    {'emoji': '🌙', 'title': 'Evening', 'range': '4:00 PM – 8:00 PM'},
  ];

  // Date Picker with custom theme
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF7C3AED),
              onPrimary: Colors.white,
              onSurface: Color(0xFF4A148C),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 70,
    );
    if (image != null) {
      setState(() => _pickedImage = File(image.path));
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

  bool _isImageRequired() => _selectedOption == 'Symbolic Payment';

  Future<void> _submitDonation() async {
    if (_isImageRequired() && _pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a photo to proceed'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_selectedCategory == null ||
        _selectedCondition == null ||
        _selectedOption == null ||
        _selectedGender == null ||
        _selectedDate == null ||
        _selectedPickupTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isUploading = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED))),
    );

    try {
      String? imageUrl;
      if (_pickedImage != null) {
        imageUrl = await _uploadImage(_pickedImage!);
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      int pointsToEarn = _selectedOption == 'Full Donation' ? 20 : 10;

      await FirebaseFirestore.instance.collection('donations').add({
        'userId': user.uid,
        'donorName': _nameController.text,
        'address': _addressController.text,
        'category': _selectedCategory,
        'condition': _selectedCondition,
        'option': _selectedOption,
        'gender': _selectedGender,
        'pickupDate': _selectedDate?.toIso8601String(),
        'pickupTime': _selectedPickupTime,
        'imageUrl': imageUrl,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
        'pointsEarned': pointsToEarn,
        'co2Saved': _co2PerItem,
      });

      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(userRef);
        if (snapshot.exists) {
          transaction.update(userRef, {
            'totalDonations': FieldValue.increment(1),
            'points': FieldValue.increment(pointsToEarn),
            'co2Saved': FieldValue.increment(_co2PerItem),
            'status': 'Active',
            'lastActivity': FieldValue.serverTimestamp(),
          });
        }
      });

      if (!mounted) return;
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DonationSubmittedScreen(pointsEarned: pointsToEarn)),
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
      backgroundColor: const Color(0xFFF9F7FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Donate Clothes',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF4A148C)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Donation Details', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2D0C57))),
              const SizedBox(height: 24),

              // Inputs
              _buildLabel('Full Name'),
              TextField(decoration: _inputDecoration('Your Name'), controller: _nameController),
              const SizedBox(height: 20),

              _buildLabel('Pickup Address'),
              TextField(
                controller: _addressController,
                decoration: _inputDecoration('Address').copyWith(
                  prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF7C3AED), size: 22),
                ),
              ),
              const SizedBox(height: 20),

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
              const SizedBox(height: 20),

              // Gender Selector with updated colors
              _buildLabel('Gender'),
              Row(
                children: _genderOptions.map((g) {
                  final isSelected = _selectedGender == g['title'];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedGender = g['title']),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF7C3AED).withOpacity(0.1) : Colors.grey[50],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF7C3AED) : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(g['emoji']!, style: const TextStyle(fontSize: 22)),
                            const SizedBox(height: 6),
                            Text(
                              g['title']!,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? const Color(0xFF7C3AED) : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

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
                    if (_selectedCondition == 'Damaged') _selectedOption = 'Full Donation';
                  });
                },
              ),
              const SizedBox(height: 24),

              // Options with Purple styling
              _buildLabel('Preferred Option'),
              ..._options.where((option) {
                if (_selectedCondition == 'Damaged') return option['title'] == 'Full Donation';
                return true;
              }).map((option) => GestureDetector(
                onTap: () => setState(() => _selectedOption = option['title']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _selectedOption == option['title'] ? const Color(0xFF7C3AED).withOpacity(0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: _selectedOption == option['title'] ? const Color(0xFF7C3AED) : const Color(0xFFF3EEFF),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _selectedOption == option['title'] ? Icons.check_circle_rounded : Icons.circle_outlined,
                        color: _selectedOption == option['title'] ? const Color(0xFF7C3AED) : Colors.grey[300],
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${option['emoji']} ${option['title']}',
                                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF2D0C57))),
                            Text(option['desc'], style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45)),
                            const SizedBox(height: 4),
                            Text(option['points'],
                                style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF7C3AED), fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
              const SizedBox(height: 20),

              _buildLabel('Pickup Date'),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _selectedDate != null ? const Color(0xFF7C3AED) : Colors.transparent),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded, color: Color(0xFF7C3AED), size: 20),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate != null ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}' : 'Select a date',
                        style: GoogleFonts.poppins(fontSize: 13, color: _selectedDate != null ? Colors.black87 : Colors.black38),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _buildLabel('Preferred Pickup Time'),
              ..._pickupTimes.map((t) {
                final isSelected = _selectedPickupTime == t['title'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedPickupTime = t['title']),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF7C3AED).withOpacity(0.05) : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFFF3EEFF)),
                    ),
                    child: Row(
                      children: [
                        Icon(isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                            color: isSelected ? const Color(0xFF7C3AED) : Colors.grey[300], size: 20),
                        const SizedBox(width: 15),
                        Text(t['emoji']!, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t['title']!, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF7C3AED) : Colors.black87)),
                            Text(t['range']!, style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 20),
              _buildLabel('Photos'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border.all(color: _pickedImage != null ? Colors.green : const Color(0xFFF3EEFF), width: 1.5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: _pickedImage != null
                      ? ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(_pickedImage!, fit: BoxFit.cover))
                      : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_a_photo_outlined, color: Color(0xFF7C3AED), size: 35),
                        const SizedBox(height: 10),
                        Text('Click to upload photo', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black45)),
                        if (_isImageRequired()) Text('(Required)', style: GoogleFonts.poppins(fontSize: 10, color: Colors.redAccent)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 35),

              // Gradient Submit Button
              GestureDetector(
                onTap: _isUploading ? null : _submitDonation,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: _purpleGradient),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Submit Donation Request',
                      style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.black26),
    filled: true,
    fillColor: Colors.grey[50],
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFF3EEFF))),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 4),
    child: Text(text, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF4A148C))),
  );
}