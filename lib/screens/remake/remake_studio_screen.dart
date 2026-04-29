import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class RemakeStudioScreen extends StatefulWidget {
  const RemakeStudioScreen({super.key});

  @override
  State<RemakeStudioScreen> createState() => _RemakeStudioScreenState();
}

class _RemakeStudioScreenState extends State<RemakeStudioScreen> {
  final TextEditingController _suggestionController = TextEditingController();
  bool _isLoading = false;

  // Function to submit user idea and increment points
  Future<void> _submitIdea(String itemTitle) async {
    final idea = _suggestionController.text.trim();
    if (idea.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw "User not logged in";

      // 1. Add suggestion to database
      await FirebaseFirestore.instance.collection('remake_suggestions').add({
        'userId': user.uid,
        'itemTitle': itemTitle,
        'suggestion': idea,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 2. Increment points in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'points': FieldValue.increment(30),
      });

      // 3. Sync local UI state
      if (mounted) {
        Provider.of<UserProvider>(context, listen: false).addPoints(30);
      }

      if (mounted) {
        _suggestionController.clear();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Amazing! Your idea was sent. +30 Points! 🎉'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Remake Studio 🎨',
            style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Fetching real-time data added by Admin
        stream: FirebaseFirestore.instance
            .collection('upcycle_items')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text("No items available at the moment.",
                  style: GoogleFonts.poppins(color: Colors.grey)),
            );
          }

          final items = snapshot.data!.docs;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroBanner(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Materials Waiting for Your Magic ✨",
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    var itemData = items[index].data() as Map<String, dynamic>;
                    return _buildUpcycleCard(itemData);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUpcycleCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Container(
              height: 180,
              width: double.infinity,
              color: Colors.grey[200],
              child: (item['imageUrl'] != null && item['imageUrl'] != "")
                  ? Image.network(item['imageUrl'], fit: BoxFit.cover)
                  : const Icon(Icons.hide_image_outlined, size: 50, color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['title'] ?? 'Untitled',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                _issueInfo(Icons.warning_amber_rounded, "Issue: ${item['issue'] ?? 'N/A'}"),
                _issueInfo(Icons.layers_outlined, "Material: ${item['material'] ?? 'N/A'}"),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showSuggestionSheet(context, item['title'] ?? 'this item'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[600],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text("Submit My Design Idea", style: GoogleFonts.poppins(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _issueInfo(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: GoogleFonts.poppins(fontSize: 12))),
      ]),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity, margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF8B00FF), Color(0xFF00D2FF)]),
          borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Be the Designer!", style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text("Suggest ideas and earn 30 points!", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
      ]),
    );
  }

  void _showSuggestionSheet(BuildContext context, String title) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(builder: (context, setModalState) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 20, right: 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text("Your Idea for $title", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
              controller: _suggestionController,
              maxLines: 3,
              decoration: InputDecoration(
                  hintText: "Describe your idea...",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none))),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : () async {
              setModalState(() => _isLoading = true);
              await _submitIdea(title);
              if (mounted) setModalState(() => _isLoading = false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B00FF), minimumSize: const Size(double.infinity, 50)),
            child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white)) : const Text("Submit (+30 Points)", style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 20),
        ]),
      )),
    );
  }
}