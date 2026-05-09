import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:graduation_project/screens/auth/login_screen.dart';


class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  String _userSearchQuery = '';
  String _donationSearchQuery = '';
  String _inventorySearchQuery = '';
  String _selectedInventoryCategory = 'All Types';


  static const Color _darkBg = Color(0xFF0D1B2A);
  static const Color _cardBg = Color(0xFF1A2332);
  static const Color _accent = Color(0xFF4F8EF7);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final List<String> _fixedCategories = [
    'All Types',
    'Shirts',
    'Formal',
    'Dresses',
    'Coats',
    'Pants',
    'Shoes',
    'Mixed Items'
  ];

  final List<String> _donationStatuses = [
    'Request Received',
    'Picked Up',
    'Cleaning in Progress',
    'Ready for Sale',
    'Sold'
  ];

  // ─── Streams ───────────────────────────────────
  Stream<List<Map<String, dynamic>>> get _usersStream =>
      _db.collection('users').snapshots().map(
              (s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());

  Stream<List<Map<String, dynamic>>> get _donationsStream =>
      _db.collection('donations').snapshots().map(
              (s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());

  Stream<List<Map<String, dynamic>>> get _ordersStream =>
      _db.collection('orders')
      // if you face an Index error, remove the line below
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());

  Stream<List<Map<String, dynamic>>> get _inventoryStream =>
      _db.collection('products').snapshots().map(
              (s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());

  Stream<List<Map<String, dynamic>>> get _remakeStream =>
      _db.collection('remake_suggestions').snapshots().map(
              (s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());

  Stream<List<Map<String, dynamic>>> get _messagesStream =>
      _db.collection('support_messages')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());

  Stream<List<Map<String, dynamic>>> get _feedbackStream =>
      _db.collection('feedback')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());

  Stream<List<Map<String, dynamic>>> get _companiesStream =>
      _db.collection('companies').snapshots().map(
              (s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());

  // ─────────────────────────────────────────────
  //  HELPERS: format date & time for display
  // ─────────────────────────────────────────────

  /// Converts ISO date string → "DD/MM/YYYY"
  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(isoDate);
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }

  /// Returns an emoji for the pickup time slot
  String _pickupTimeEmoji(String? time) {
    switch (time) {
      case 'Morning':   return '🌅';
      case 'Afternoon': return '☀️';
      case 'Evening':   return '🌙';
      default:          return '🕐';
    }
  }

  /// Returns an emoji for the gender field
  String _genderEmoji(String? gender) {
    switch (gender) {
      case 'Men':   return '👨';
      case 'Women': return '👩';
      case 'Kids':  return '👦';
      case 'Mix':   return '🔀';
      default:      return '👤';
    }
  }

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      appBar: AppBar(
        backgroundColor: _cardBg,
        elevation: 0,
        title: Text('Admin Dashboard',
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await _auth.signOut();
              if (!mounted) return;
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedIndex == 0)
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _usersStream,
              builder: (_, usersSnap) =>
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _donationsStream,
                    builder: (_, donSnap) =>
                        StreamBuilder<List<Map<String, dynamic>>>(
                          stream: _ordersStream,
                          builder: (_, ordSnap) =>
                              _buildOverviewHeader(
                                usersSnap.data ?? [],
                                donSnap.data ?? [],
                                ordSnap.data ?? [],
                              ),
                        ),
                  ),
            ),

          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _donationsStream,
            builder: (_, donSnap) =>
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _messagesStream,
                  builder: (_, msgSnap) {
                    final donations = donSnap.data ?? [];
                    final messages = msgSnap.data ?? [];
                    return Container(
                      color: _cardBg,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(children: [
                          _buildTab(0, 'Overview', Icons.dashboard_outlined),
                          _buildTab(1, 'Users', Icons.people_outline),
                          _buildTab(2, 'Donations', Icons.volunteer_activism_outlined,
                              badgeCount: donations
                                  .where((d) => d['status'] == 'Request Received')
                                  .length),
                          _buildTab(3, 'Orders', Icons.shopping_bag_outlined),
                          _buildTab(4, 'Inventory', Icons.inventory_2_outlined),
                          _buildTab(5, 'Remake', Icons.auto_awesome),
                          _buildTab(6, 'Messages', Icons.message_outlined,
                              badgeCount: messages
                                  .where((m) => m['read'] == false)
                                  .length),
                          _buildTab(7, 'Weekly Report', Icons.analytics_outlined),
                          _buildTab(8, 'Rewards', Icons.emoji_events_outlined),
                          _buildTab(9, 'Feedback', Icons.rate_review_outlined),
                          StreamBuilder<List<Map<String, dynamic>>>(
                            stream: _companiesStream,
                            builder: (_, compSnap) {
                              final companiesCount = compSnap.data?.length ?? 0;
                              return _buildTab(
                                  10, 'Companies', Icons.business_outlined,
                                  badgeCount: companiesCount);
                            },
                          ),
                        ]),
                      ),
                    );
                  },
                ),
          ),

          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                _buildOverviewContent(),
                _buildUsersContent(),
                _buildDonationsContent(),
                _buildOrdersContent(),
                _buildInventoryContent(),
                _buildRemakeContent(),
                _buildMessagesContent(),
                _buildWeeklyReport(),
                _buildRewardsContent(),
                _buildFeedbackPage(),
                _buildCompaniesContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  OVERVIEW HEADER
  // ─────────────────────────────────────────────

  Widget _buildOverviewHeader(List<Map<String, dynamic>> users,
      List<Map<String, dynamic>> donations,
      List<Map<String, dynamic>> orders,) {
    int totalItems =
    users.fold(0, (s, u) => s + ((u['totalDonations'] ?? 0) as int));

    double totalCO2 = users.fold(0.0, (s, u) {
      var val = u['co2Saved'] ?? 0;
      return s + (val is int ? val.toDouble() : val as double);
    });

    return Container(
      padding: const EdgeInsets.all(16),
      color: _cardBg,
      child: Column(children: [
        Row(children: [
          _buildStatCard('Total Users', '${users.length}', Icons.people, Colors.blue),
          const SizedBox(width: 8),
          _buildStatCard(
            'New Donations',
            '${donations.where((d) {
              bool isNewRequest = d['status'] == 'Request Received';
              final DateTime sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
              final timestamp = d['createdAt'];
              bool isWithinThisWeek = timestamp is Timestamp &&
                  timestamp.toDate().isAfter(sevenDaysAgo);
              return isNewRequest && isWithinThisWeek;
            }).length}',
            Icons.volunteer_activism,
            Colors.green,
          ),
          const SizedBox(width: 8),
          _buildStatCard(
              'Pending Orders',
              '${orders.where((o) => o['status'] == 'Pending').length}',
              Icons.shopping_bag,
              Colors.orange),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.green.withOpacity(0.2),
              Colors.blue.withOpacity(0.2)
            ]),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _miniImpactInfo("🌿 Total CO₂ Saved", "${totalCO2.toStringAsFixed(1)}kg"),
            _miniImpactInfo("♻️ Items Recycled", "$totalItems"),
          ]),
        ),
      ]),
    );
  }

  Widget _miniImpactInfo(String label, String value) =>
      Column(children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70)),
        Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
      ]);

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(title, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 9, color: Colors.white70)),
        ]),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  TABS
  // ─────────────────────────────────────────────

  Widget _buildTab(int index, String label, IconData icon, {int badgeCount = 0}) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: isSelected ? _accent : Colors.transparent, width: 2)),
        ),
        child: Row(children: [
          Stack(clipBehavior: Clip.none, children: [
            Icon(icon, size: 18, color: isSelected ? _accent : Colors.white54),
            if (badgeCount > 0)
              Positioned(
                right: -5, top: -5,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                  child: Text('$badgeCount',
                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                ),
              ),
          ]),
          const SizedBox(width: 8),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? _accent : Colors.white54)),
        ]),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  OVERVIEW CONTENT
  // ─────────────────────────────────────────────

  Widget _buildOverviewContent() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _donationsStream,
      builder: (_, donSnap) =>
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _ordersStream,
            builder: (_, ordSnap) {
              final donations = donSnap.data ?? [];
              final orders = ordSnap.data ?? [];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recent Activity',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 12),

                    ...donations.take(2).map((d) {
                      String donorName = d['donorName'] ?? d['donor'] ?? 'Guest Donor';
                      String itemName = d['item'] ?? d['title'] ?? 'Clothes';
                      return _activityTile(
                        Icons.volunteer_activism, Colors.green,
                        '$donorName donated $itemName',
                        d['date'] ?? '', d, true,
                      );
                    }),

                    ...orders.take(2).map((o) {
                      String buyerName = o['userName'] ?? o['buyer'] ?? 'Anonymous';
                      String amount = o['totalAmount']?.toString() ?? '0.0';
                      return _activityTile(
                        Icons.shopping_bag, Colors.blue,
                        '$buyerName ordered items (₪$amount)',
                        '', o, false,
                      );
                    }),

                    if (donations.isEmpty && orders.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Text("No recent activity", style: TextStyle(color: Colors.white54)),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
    );
  }

  Widget _activityTile(IconData icon, Color color, String title, String date,
      Map<String, dynamic> data, bool isDonation) {
    return _buildCard(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          title: Text(title, style: GoogleFonts.poppins(fontSize: 13, color: Colors.white)),
          subtitle: date.isNotEmpty
              ? Text(date, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white38))
              : null,
          trailing: const Icon(Icons.keyboard_arrow_down, color: Colors.white24, size: 16),
          childrenPadding: const EdgeInsets.only(top: 8, bottom: 8),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 12),
            if (isDonation) ...[
              _buildDetailRow("Donor:", data['donorName'] ?? data['userName'] ?? 'Guest'),
              _buildDetailRow("Category:", data['category'] ?? 'General'),
              _buildDetailRow("Condition:", data['condition'] ?? 'N/A'),
              _buildDetailRow("Notes:", data['notes'] ?? 'No notes provided'),
            ] else ...[
              _buildDetailRow("Customer:", data['userName'] ?? 'Anonymous'),
              _buildDetailRow("Total:", "₪${data['totalAmount'] ?? data['totalPrice'] ?? '0.0'}"),
              _buildDetailRow("Address:", data['address'] ?? 'No address'),
              _buildDetailRow("Payment:", data['paymentMethod'] ?? 'Cash'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label ",
              style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF8B00FF), fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(value, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  USERS
  // ─────────────────────────────────────────────

  Widget _buildUsersContent() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _usersStream,
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) return _loadingWidget();

        final users = (snap.data ?? []).where((u) {
          final name = (u['userName'] ?? u['name'] ?? '').toString().toLowerCase();
          final addr = (u['address'] ?? '').toString().toLowerCase();
          return name.contains(_userSearchQuery.toLowerCase()) ||
              addr.contains(_userSearchQuery.toLowerCase());
        }).toList();

        return Column(children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by name or city...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: _accent),
                filled: true,
                fillColor: _cardBg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: (val) => setState(() => _userSearchQuery = val),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: users.length,
              itemBuilder: (_, i) {
                final user = users[i];
                String currentStatus = user['status'] ?? (user['active'] == true ? 'Active' : 'Inactive');

                return _buildCard(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    leading: CircleAvatar(
                      backgroundColor: _accent.withOpacity(0.2),
                      child: Text(
                          (user['userName'] ?? user['name'] ?? '?')[0].toUpperCase(),
                          style: const TextStyle(color: _accent)),
                    ),
                    title: Text(user['userName'] ?? user['name'] ?? 'User',
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        "Status: $currentStatus | Role: ${user['role'] ?? 'User'}",
                        style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    trailing: const Icon(Icons.info_outline, color: _accent),
                    onTap: () => _showUserDetailsDialog(user),
                  ),
                );
              },
            ),
          ),
        ]);
      },
    );
  }

  void _showUserDetailsDialog(Map<String, dynamic> user) {
    bool isBuyer = user['role'] == 'Buyer' || user['role'] == 'Both';
    bool isDonor = user['role'] == 'Donor' || user['role'] == 'Both';
    String accountStatus = user['status'] ?? (user['active'] == true ? "Active" : "Inactive");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(user['userName'] ?? user['name'] ?? 'User Details',
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          _detailRow(Icons.email, "Email", user['email'] ?? 'N/A'),
          _detailRow(Icons.phone, "Phone", user['phone'] ?? 'N/A'),
          _detailRow(Icons.account_circle, "Status", accountStatus),
          const Divider(color: Colors.white12, height: 20),
          if (isBuyer) _detailRow(Icons.shopping_cart, "Total Paid", "₪${user['totalPaid'] ?? 0}"),
          if (isDonor) ...[
            _detailRow(Icons.volunteer_activism, "Donations", "${user['totalDonations'] ?? 0} Times"),
            const SizedBox(height: 10),
            _impactCard("♻️ Items", "${user['totalDonations'] ?? 0}", "Donated"),
          ],
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close", style: TextStyle(color: _accent)))
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  DONATIONS
  // ─────────────────────────────────────────────

  Widget _buildDonationsContent() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _donationsStream,
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) return _loadingWidget();

        final filtered = (snap.data ?? [])
            .where((d) =>
        (d['category'] ?? '').toLowerCase().contains(_donationSearchQuery.toLowerCase()) ||
            (d['donorName'] ?? '').toLowerCase().contains(_donationSearchQuery.toLowerCase()))
            .toList();

        return Column(children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("Search category or donors...").copyWith(
                  prefixIcon: const Icon(Icons.search, color: _accent)),
              onChanged: (val) => setState(() => _donationSearchQuery = val),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState("No matching donations found", Icons.search_off)
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final don = filtered[i];
                bool isPaid = don['option'] == 'Symbolic Payment';

                return _buildCard(
                  child: InkWell(
                    onTap: () => _showDonationDetailsDialog(don),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 60, height: 60,
                              decoration: BoxDecoration(color: _darkBg, borderRadius: BorderRadius.circular(10)),
                              child: don['imageUrl'] != null && don['imageUrl'].toString().isNotEmpty
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(don['imageUrl'], fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, color: Colors.white24)),
                              )
                                  : const Icon(Icons.inventory_2_outlined, color: _accent),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(don['category'] ?? 'General',
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                      IconButton(
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                        onPressed: () => _editDonation(don['id'], don['notes'] ?? ''),
                                        icon: const Icon(Icons.edit, color: Colors.orange, size: 18),
                                      ),
                                    ],
                                  ),
                                  _typeBadge(isPaid),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        Text('Donor: ${don['donorName'] ?? 'Unknown'}',
                            style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        Text('Condition: ${don['condition'] ?? 'N/A'}',
                            style: const TextStyle(color: Colors.white38, fontSize: 11)),

                        //  (Gender / Date / Time)
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            if (don['gender'] != null)
                              _infoBadge(
                                '${_genderEmoji(don['gender'])} ${don['gender']}',
                                Colors.purple,
                              ),
                            if (don['pickupDate'] != null)
                              _infoBadge(
                                '📅 ${_formatDate(don['pickupDate'])}',
                                Colors.blue,
                              ),
                            if (don['pickupTime'] != null)
                              _infoBadge(
                                '${_pickupTimeEmoji(don['pickupTime'])} ${don['pickupTime']}',
                                Colors.teal,
                              ),
                          ],
                        ),

                        const SizedBox(height: 12),
                        // ── Status Dropdown ──
                        DropdownButtonFormField<String>(
                          value: _donationStatuses.contains(don['status'])
                              ? don['status']
                              : _donationStatuses.first,
                          dropdownColor: _cardBg,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: _darkBg,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          ),
                          items: _donationStatuses
                              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              _db.collection('donations').doc(don['id']).update({'status': val});
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ]);
      },
    );
  }

  Widget _infoBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4), width: 0.8),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }

  // ─────────────────────────────────────────────
  //  DONATION DETAILS DIALOG
  // ─────────────────────────────────────────────

  void _showDonationDetailsDialog(Map<String, dynamic> donation) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Donation Details",
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [

            if (donation['imageUrl'] != null && donation['imageUrl'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    donation['imageUrl'],
                    loadingBuilder: (context, child, progress) =>
                    progress == null ? child : const Center(child: CircularProgressIndicator()),
                    errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image, color: Colors.white24, size: 50),
                  ),
                ),
              ),

            // ── بيانات أساسية ──
            _detailRow(Icons.person, "Donor", donation['donorName'] ?? 'Guest'),
            _detailRow(Icons.category, "Category", donation['category'] ?? 'N/A'),
            _detailRow(Icons.info_outline, "Condition", donation['condition'] ?? 'N/A'),
            _detailRow(Icons.volunteer_activism, "Option", donation['option'] ?? 'N/A'),
            _detailRow(Icons.location_on, "Pickup Address", donation['address'] ?? 'No address provided'),

            const Divider(color: Colors.white12, height: 24),

            _detailRow(
              Icons.wc,
              "Gender",
              donation['gender'] != null
                  ? '${_genderEmoji(donation['gender'])}  ${donation['gender']}'
                  : 'N/A',
            ),
            _detailRow(
              Icons.calendar_today,
              "Pickup Date",
              _formatDate(donation['pickupDate']),
            ),
            _detailRow(
              Icons.access_time,
              "Pickup Time",
              donation['pickupTime'] != null
                  ? '${_pickupTimeEmoji(donation['pickupTime'])}  ${donation['pickupTime']}'
                  : 'N/A',
            ),

            const Divider(color: Colors.white12, height: 24),
            const Text("Update Status",
                style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            StatefulBuilder(
              builder: (ctx, setDlg) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: _darkBg, borderRadius: BorderRadius.circular(10)),
                child: DropdownButton<String>(
                  value: _donationStatuses.contains(donation['status'])
                      ? donation['status']
                      : _donationStatuses[0],
                  dropdownColor: _cardBg,
                  underline: const SizedBox(),
                  isExpanded: true,
                  items: _donationStatuses
                      .map((s) => DropdownMenuItem(
                      value: s, child: Text(s, style: const TextStyle(color: Colors.white, fontSize: 12))))
                      .toList(),
                  onChanged: (val) async {
                    if (val != null) {
                      await FirebaseFirestore.instance
                          .collection('donations')
                          .doc(donation['id'])
                          .update({'status': val});
                      if (mounted) Navigator.pop(context);
                    }
                  },
                ),
              ),
            ),
          ]),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close", style: TextStyle(color: _accent)))
        ],
      ),
    );
  }

  Widget _typeBadge(bool isPaid) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: isPaid ? Colors.amber.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: isPaid ? Colors.amber : Colors.blue, width: 0.5),
    ),
    child: Text(isPaid ? "Paid Donation" : "Free Donation",
        style: TextStyle(color: isPaid ? Colors.amber : Colors.blue, fontSize: 9, fontWeight: FontWeight.bold)),
  );

  void _editDonation(String docId, String currentNotes) {
    final ctrl = TextEditingController(text: currentNotes);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _cardBg,
        title: const Text("Edit Donation Details", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(labelText: "Admin Notes", labelStyle: TextStyle(color: Colors.white38)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              _db.collection('donations').doc(docId).update({'notes': ctrl.text});
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  ORDERS
  // ─────────────────────────────────────────────

  Widget _buildOrdersContent() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _ordersStream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) return _loadingWidget();
        final orders = snap.data ?? [];

        if (orders.isEmpty)
          return const Center(child: Text("No orders yet", style: TextStyle(color: Colors.white54)));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, i) {
            final order = orders[i];
            String buyer = order['userName'] ?? 'Anonymous';
            String payment = order['paymentMethod'] ?? 'Cash';
            String total = "₪${order['totalAmount'] ?? '0.0'}";

            return _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          buyer,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      _statusBadge(order['status'] ?? 'Pending'),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Divider(color: Colors.white10, height: 1),
                  const SizedBox(height: 12),

                  _buildOrderInfoRow(Icons.person, "Customer:", buyer),
                  _buildOrderInfoRow(Icons.credit_card, "Payment:", payment),
                  _buildOrderInfoRow(Icons.location_on, "Address:", order['address'] ?? 'No Address'),
                  _buildOrderInfoRow(Icons.payments, "Total Amount:", total),

                  const SizedBox(height: 16),

                  // ───── ADDED ORDER TRACKER ─────
                  _buildOrderTracker(order['status'] ?? 'Pending'),

                  const SizedBox(height: 12),

                  // ───── ADDED ADMIN CONTROL PANEL ─────
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _db
                              .collection('orders')
                              .doc(order['id'])
                              .update({'status': 'Confirmed'}),
                          child: const Text("Confirm"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _db
                              .collection('orders')
                              .doc(order['id'])
                              .update({'status': 'Shipped'}),
                          child: const Text("Ship"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _db
                              .collection('orders')
                              .doc(order['id'])
                              .update({'status': 'Delivered'}),
                          child: const Text("Deliver"),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ───── YOUR ORIGINAL BUTTON (UNCHANGED) ─────
                  if (order['status'] == 'Pending')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.withOpacity(0.1),
                          side: const BorderSide(color: Colors.purple, width: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => _db
                            .collection('orders')
                            .doc(order['id'])
                            .update({'status': 'Shipped'}),
                        child: const Text(
                          "Confirm & Ship Order",
                          style: TextStyle(color: Colors.purpleAccent),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  Widget _buildOrderInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF9C27B0)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
          const SizedBox(width: 5),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white70, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildOrderTracker(String status) {
    int step = 0;

    switch (status) {
      case 'Pending':
        step = 0;
        break;
      case 'Confirmed':
        step = 1;
        break;
      case 'Shipped':
        step = 2;
        break;
      case 'Delivered':
        step = 3;
        break;
      default:
        step = 0;
    }

    List<String> steps = [
      "Pending",
      "Confirmed",
      "Shipped",
      "Delivered"
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Order Tracking",
            style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          Row(
            children: List.generate(steps.length, (index) {
              bool isActive = index <= step;

              return Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.purple : Colors.white10,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      steps[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: isActive ? Colors.purpleAccent : Colors.white38,
                      ),
                    )
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
  // ─────────────────────────────────────────────
  //  INVENTORY
  // ─────────────────────────────────────────────

  Widget _buildInventoryContent() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _inventoryStream,
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) return _loadingWidget();

        final filtered = (snap.data ?? []).where((item) {
          bool matchCat = _selectedInventoryCategory == 'All Types' ||
              item['category'] == _selectedInventoryCategory;
          String itemName = (item['name'] ?? item['title'] ?? '').toLowerCase();
          bool matchSearch = itemName.contains(_inventorySearchQuery.toLowerCase());
          return matchCat && matchSearch;
        }).toList();

        return Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("Search items...").copyWith(
                  prefixIcon: const Icon(Icons.search, color: _accent)),
              onChanged: (val) => setState(() => _inventorySearchQuery = val),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _fixedCategories.map((cat) {
                bool isSel = _selectedInventoryCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat, style: TextStyle(color: isSel ? Colors.white : Colors.white54, fontSize: 12)),
                    selected: isSel,
                    onSelected: (_) => setState(() => _selectedInventoryCategory = cat),
                    backgroundColor: _cardBg,
                    selectedColor: _accent,
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: _showAddItemDialog,
              icon: const Icon(Icons.add),
              label: const Text("Add New Item"),
              style: ElevatedButton.styleFrom(backgroundColor: _accent, minimumSize: const Size(double.infinity, 50)),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState("No items found", Icons.inventory_2_outlined)
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final item = filtered[i];
                final String docId = item['id'] ?? '';
                bool isAvailable = item['isAvailable'] ?? item['available'] ?? false;

                return GestureDetector(
                  onTap: () => _editItemDialog(item, docId),
                  child: _buildCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item['image'] ?? item['imageUrl'] ?? '',
                            width: 50, height: 50, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.white24),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item['name'] ?? item['title'] ?? 'No Name',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${item['category'] ?? 'General'} • ${item['size'] ?? 'N/A'} • Qty: ${item['quantity'] ?? 0}',
                                style: const TextStyle(color: Colors.white54, fontSize: 11),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 80,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('₪${item['price'] ?? 0}',
                                  style: const TextStyle(color: _accent, fontWeight: FontWeight.bold, fontSize: 13)),
                              Transform.scale(
                                scale: 0.7,
                                child: Switch(
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  value: isAvailable,
                                  onChanged: (val) {
                                    _db.collection('products').doc(docId).update({
                                      'isAvailable': val,
                                      'quantity': val
                                          ? ((item['quantity'] != null && item['quantity'] > 0)
                                          ? item['quantity'] : 1)
                                          : 0,
                                    });
                                  },
                                  activeColor: Colors.green,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _db.collection('products').doc(docId).delete(),
                                child: const Padding(
                                  padding: EdgeInsets.only(right: 8.0),
                                  child: Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ]);
      },
    );
  }

  void _showAddItemDialog() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: "1");

    String? selectedCategory;
    String? selectedSize;
    String selectedGender = 'All';
    String? localSelectedCondition = 'Excellent';
    File? pickedImage;
    String imageStatus = "No image selected";

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          backgroundColor: _cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Add Inventory Item",
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              GestureDetector(
                onTap: () async {
                  final picked = await ImagePicker().pickImage(
                      source: ImageSource.gallery, maxWidth: 800, maxHeight: 800, imageQuality: 70);
                  if (picked != null) {
                    setDlg(() { pickedImage = File(picked.path); imageStatus = "📸 ${picked.name}"; });
                  }
                },
                child: Container(
                  height: 100, width: double.infinity,
                  decoration: BoxDecoration(color: _darkBg, borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _accent.withOpacity(0.3))),
                  child: pickedImage != null
                      ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(pickedImage!, fit: BoxFit.cover))
                      : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.add_a_photo_outlined, color: _accent, size: 30),
                    const SizedBox(height: 8),
                    Text(imageStatus, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                  ]),
                ),
              ),
              const SizedBox(height: 15),
              TextField(controller: nameCtrl, style: const TextStyle(color: Colors.white), decoration: _inputDecoration("Item Name")),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: TextField(controller: priceCtrl, keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white), decoration: _inputDecoration("Price (₪)"))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: qtyCtrl, keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white), decoration: _inputDecoration("Qty"))),
              ]),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                dropdownColor: _cardBg, value: selectedGender,
                style: const TextStyle(color: Colors.white), decoration: _inputDecoration("Target Audience (Gender)"),
                items: ['All', 'Men', 'Women', 'Kids'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (val) => setDlg(() => selectedGender = val!),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                dropdownColor: _cardBg, value: selectedSize,
                style: const TextStyle(color: Colors.white), decoration: _inputDecoration("Size"),
                items: ['S', 'M', 'L', 'XL', 'Free Size'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setDlg(() => selectedSize = val),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                dropdownColor: _cardBg, value: selectedCategory,
                style: const TextStyle(color: Colors.white), decoration: _inputDecoration("Category"),
                items: _fixedCategories.where((c) => c != 'All Types')
                    .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setDlg(() => selectedCategory = val),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                dropdownColor: _cardBg, value: localSelectedCondition,
                style: const TextStyle(color: Colors.white), decoration: _inputDecoration("Condition"),
                items: ['New', 'Excellent', 'Good', 'Fair', 'Remade/Upcycled']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setDlg(() => localSelectedCondition = val),
              ),
              const SizedBox(height: 10),
              TextField(controller: descCtrl, maxLines: 2,
                  style: const TextStyle(color: Colors.white), decoration: _inputDecoration("Description")),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: Colors.white54))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _accent),
              onPressed: () async {
                if (nameCtrl.text.isEmpty || selectedCategory == null) return;
                try {
                  String imageUrl = 'https://images.unsplash.com/photo-1523381210434-271e8be1f52b?q=80&w=200';
                  if (pickedImage != null) {
                    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
                    final ref = _storage.ref().child('inventory').child(fileName);
                    UploadTask uploadTask = ref.putFile(pickedImage!);
                    TaskSnapshot snapshot = await uploadTask;
                    imageUrl = await snapshot.ref.getDownloadURL();
                  }
                  await _db.collection('products').add({
                    'title': nameCtrl.text, 'category': selectedCategory, 'type': selectedCategory,
                    'price': double.tryParse(priceCtrl.text) ?? 0.0, 'size': selectedSize ?? 'M',
                    'condition': localSelectedCondition ?? 'Excellent', 'isAvailable': true,
                    'gender': selectedGender, 'imageUrl': imageUrl, 'quantity': int.tryParse(qtyCtrl.text) ?? 1,
                    'description': descCtrl.text.isEmpty ? 'No description' : descCtrl.text,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Item added successfully!"), backgroundColor: Colors.green));
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
                  }
                }
              },
              child: const Text("Confirm Add", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editItemDialog(Map<String, dynamic> item, String docId) async {
    final nameCtrl = TextEditingController(text: item['title'] ?? item['name'] ?? '');
    final priceCtrl = TextEditingController(text: (item['price'] ?? 0).toString());
    final qtyCtrl = TextEditingController(text: (item['quantity'] ?? 1).toString());
    final descCtrl = TextEditingController(text: item['description'] ?? '');

    String selectedSize = item['size'] ?? 'M';
    String selectedCategory = item['category'] ?? 'General';
    String selectedGender = item['gender'] ?? 'All';
    const List<String> validConditions = ['New', 'Excellent', 'Good', 'Fair', 'Remade/Upcycled'];
    String? localSelectedCondition = validConditions.contains(item['condition'])
        ? item['condition']
        : 'Excellent';
    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          backgroundColor: _cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Edit Item Details",
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: nameCtrl, style: const TextStyle(color: Colors.white), decoration: _inputDecoration("Item Name")),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: TextField(controller: priceCtrl, keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white), decoration: _inputDecoration("Price (₪)"))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: qtyCtrl, keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white), decoration: _inputDecoration("Qty"))),
              ]),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                dropdownColor: _cardBg, value: selectedSize,
                style: const TextStyle(color: Colors.white), decoration: _inputDecoration("Size"),
                items: ['S', 'M', 'L', 'XL', 'Free Size'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setDlg(() => selectedSize = val!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                dropdownColor: _cardBg, value: localSelectedCondition,
                style: const TextStyle(color: Colors.white), decoration: _inputDecoration("Condition"),
                items: ['New', 'Excellent', 'Good', 'Fair', 'Remade/Upcycled']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setDlg(() => localSelectedCondition = val),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 16),
              TextField(controller: descCtrl, maxLines: 2,
                  style: const TextStyle(color: Colors.white), decoration: _inputDecoration("Description")),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: Colors.white54))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _accent),
              onPressed: () async {
                int newQty = int.tryParse(qtyCtrl.text) ?? 1;
                try {
                  await _db.collection('products').doc(docId).update({
                    'title': nameCtrl.text, 'price': double.tryParse(priceCtrl.text) ?? 0.0,
                    'quantity': newQty, 'size': selectedSize, 'description': descCtrl.text,
                    'condition': localSelectedCondition ?? 'Excellent', 'isAvailable': newQty > 0,
                    'status': newQty > 0 ? 'Available' : 'Sold Out', 'category': selectedCategory,
                    'type': selectedCategory, 'gender': selectedGender, 'updatedAt': FieldValue.serverTimestamp(),
                  });
                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Item updated and synced with shop!"), backgroundColor: Colors.green));
                  }
                } catch (e) { debugPrint("Update Error: $e"); }
              },
              child: const Text("Save Changes", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  REMAKE
  // ─────────────────────────────────────────────

  Widget _buildRemakeContent() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        mini: true, backgroundColor: _accent,
        child: const Icon(Icons.add_a_photo, color: Colors.white),
        onPressed: () => _showAddRemakePostDialog(),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _remakeStream,
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) return _loadingWidget();
          final items = snap.data ?? [];
          if (items.isEmpty)
            return const Center(child: Text("No suggestions from users yet", style: TextStyle(color: Colors.white54)));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final item = items[i];
              return _buildCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(item['itemTitle'] ?? 'No Title',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1, overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 8),
                        _statusBadge(item['status'] ?? 'pending'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text("User Suggestion:", style: TextStyle(color: _accent, fontSize: 11, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text("Idea: ${item['suggestion'] ?? ''}",
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontStyle: FontStyle.italic),
                        maxLines: 3, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 12),
                    if (item['status'] == 'pending')
                      Row(children: [
                        Expanded(child: SizedBox(height: 35, child: ElevatedButton(
                          style: ElevatedButton.styleFrom(padding: EdgeInsets.zero,
                              backgroundColor: Colors.green.withOpacity(0.2),
                              side: const BorderSide(color: Colors.green, width: 0.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          onPressed: () => _db.collection('remake_suggestions').doc(item['id']).update({'status': 'Accepted'}),
                          child: const Text("Accept", style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
                        ))),
                        const SizedBox(width: 8),
                        Expanded(child: SizedBox(height: 35, child: ElevatedButton(
                          style: ElevatedButton.styleFrom(padding: EdgeInsets.zero,
                              backgroundColor: Colors.red.withOpacity(0.2),
                              side: const BorderSide(color: Colors.red, width: 0.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          onPressed: () => _db.collection('remake_suggestions').doc(item['id']).update({'status': 'Rejected'}),
                          child: const Text("Reject", style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                        ))),
                      ]),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddRemakePostDialog() {
    final nameCtrl = TextEditingController();
    File? selectedImg;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlg) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          scrollable: true,
          title: const Text("Post Item for Remake Ideas", style: TextStyle(color: Colors.white)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: nameCtrl, style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Item Name", labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24))),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                final img = await ImagePicker().pickImage(
                    source: ImageSource.gallery, maxWidth: 800, maxHeight: 800, imageQuality: 70);
                if (img != null) setDlg(() => selectedImg = File(img.path));
              },
              child: Container(
                height: 150, width: double.infinity,
                decoration: BoxDecoration(border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(8)),
                child: selectedImg == null
                    ? const Icon(Icons.add_a_photo, color: Colors.white24, size: 40)
                    : ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(selectedImg!, fit: BoxFit.cover)),
              ),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: Colors.white54))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _accent),
              onPressed: () async {
                if (nameCtrl.text.isEmpty || selectedImg == null) return;
                FocusScope.of(context).unfocus();
                try {
                  final ref = FirebaseStorage.instance.ref()
                      .child('upcycle_requests/${DateTime.now().millisecondsSinceEpoch}.jpg');
                  await ref.putFile(selectedImg!);
                  final url = await ref.getDownloadURL();
                  await _db.collection('upcycle_items').add({
                    'title': nameCtrl.text, 'imageUrl': url, 'issue': 'Needs creative redesign',
                    'material': 'Mixed fabrics', 'status': 'Open', 'timestamp': FieldValue.serverTimestamp(),
                  });
                  if (context.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Post added to Upcycle Studio! ✅")));
                  }
                } catch (e) { debugPrint("Error: $e"); }
              },
              child: const Text("Post Request"),
            )
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  MESSAGES
  // ─────────────────────────────────────────────

  Widget _buildMessagesContent() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _messagesStream,
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) return _loadingWidget();
        final msgs = snap.data ?? [];
        if (msgs.isEmpty) return const Center(child: Text("No messages yet", style: TextStyle(color: Colors.white54)));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: msgs.length,
          itemBuilder: (_, i) {
            final msg = msgs[i];
            bool isReplied = msg['adminReply'] != null && msg['adminReply'].toString().isNotEmpty;
            String name = msg['senderName'] ?? msg['userName'] ?? msg['name'] ?? 'Anonymous';
            String email = msg['senderEmail'] ?? msg['userEmail'] ?? msg['email'] ?? 'No Email';

            return _buildCard(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                leading: Icon(
                  isReplied ? Icons.quickreply : (msg['read'] == true ? Icons.mark_email_read : Icons.mark_email_unread),
                  color: isReplied ? Colors.greenAccent : (msg['read'] == true ? Colors.white24 : _accent),
                ),
                title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(email, style: const TextStyle(color: _accent, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(msg['message'] ?? '', style: const TextStyle(color: Colors.white54, fontSize: 12),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (isReplied)
                    Padding(padding: const EdgeInsets.only(top: 4),
                        child: Text("Replied: ${msg['adminReply']}",
                            style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontStyle: FontStyle.italic),
                            maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
                trailing: IconButton(
                  icon: Icon(Icons.reply, color: isReplied ? Colors.white24 : _accent, size: 20),
                  onPressed: () => _showReplyDialog(msg),
                ),
                onTap: () {
                  _db.collection('support_messages').doc(msg['id']).update({'read': true});
                  _showReplyDialog(msg);
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showReplyDialog(Map<String, dynamic> msg) {
    final replyCtrl = TextEditingController();
    if (msg['adminReply'] != null) replyCtrl.text = msg['adminReply'];
    _db.collection('support_messages').doc(msg['id']).update({'read': true});

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Reply to ${msg['senderName'] ?? msg['name'] ?? ''}",
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
            child: Text("User Message: ${msg['message'] ?? ''}", style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ),
          const SizedBox(height: 15),
          TextField(controller: replyCtrl, maxLines: 3,
              style: const TextStyle(color: Colors.white), decoration: _inputDecoration("Write your response here...")),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              if (replyCtrl.text.trim().isEmpty) return;
              await _db.collection('support_messages').doc(msg['id']).update({
                'adminReply': replyCtrl.text.trim(), 'repliedAt': FieldValue.serverTimestamp(),
              });
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Reply sent to user! ✅"), backgroundColor: Colors.green));
              }
            },
            child: const Text("Send Response", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  WEEKLY REPORT
  // ─────────────────────────────────────────────

  Widget _buildWeeklyReport() {
    // Set the threshold for the last 7 days
    final DateTime sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _usersStream,
      builder: (_, usersSnap) => StreamBuilder<List<Map<String, dynamic>>>(
        stream: _donationsStream,
        builder: (_, donSnap) => StreamBuilder<List<Map<String, dynamic>>>(
          stream: _ordersStream,
          builder: (_, ordSnap) => StreamBuilder<List<Map<String, dynamic>>>(
            stream: _companiesStream,
            builder: (_, compSnap) {
              // Safe data retrieval with default empty lists
              final users = usersSnap.data ?? [];
              final allDonations = donSnap.data ?? [];
              final allOrders = ordSnap.data ?? [];
              final companies = compSnap.data ?? [];

              // 1. Calculate Weekly Revenue (Checking for 'total' or 'totalAmount' fields)
              double weeklyRevenue = allOrders.where((order) {
                final timestamp = order['createdAt'];
                return timestamp is Timestamp && timestamp.toDate().isAfter(sevenDaysAgo);
              }).fold(0.0, (sum, item) {
                var amount = item['total'] ?? item['totalAmount'] ?? 0;
                return sum + (double.tryParse(amount.toString()) ?? 0.0);
              });

              // 2. Count donations created within the last 7 days
              int weeklyDonationsCount = allDonations.where((donation) {
                final timestamp = donation['createdAt'];
                return timestamp is Timestamp && timestamp.toDate().isAfter(sevenDaysAgo);
              }).length;

              // 3. Count new users joined within the last 7 days
              int newUsersCount = users.where((u) {
                final joinDate = u['joinDate'];
                return joinDate is Timestamp && joinDate.toDate().isAfter(sevenDaysAgo);
              }).length;

              // 4. Calculate Overall Impact (Aggregated from all user data)
              int totalItemsRecycled = users.fold(0, (sum, user) =>
              sum + (int.tryParse(user['totalDonations']?.toString() ?? '0') ?? 0));

              int totalCO2 = users.fold(0, (sum, user) =>
              sum + (int.tryParse(user['co2Saved']?.toString() ?? '0') ?? 0));

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Weekly Performance Report',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 16),
                  _buildCard(child: Column(children: [
                    _reportRow("New Users (Last 7 Days)", "+$newUsersCount", Icons.person_add, Colors.blue),
                    const Divider(color: Colors.white12, height: 20),
                    _reportRow("Weekly Revenue", "₪${weeklyRevenue.toStringAsFixed(2)}", Icons.monetization_on, Colors.green),
                    const Divider(color: Colors.white12, height: 20),
                    _reportRow("Weekly Donations", "$weeklyDonationsCount", Icons.check_circle, Colors.orange),
                    const Divider(color: Colors.white12, height: 20),
                    _reportRow("Total CO₂ Impact", "${totalCO2}kg", Icons.eco, Colors.teal),
                    const Divider(color: Colors.white12, height: 20),
                    _reportRow("Total Partners", "${companies.length}", Icons.handshake_outlined, Colors.purpleAccent),
                  ])),
                  const SizedBox(height: 16),
                  Text('Overall Community Impact',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.blue.withOpacity(0.1), Colors.green.withOpacity(0.1)]),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.recycling, color: Colors.greenAccent, size: 30),
                      const SizedBox(width: 15),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text("$totalItemsRecycled Items",
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const Text("Successfully Recycled through ReCloth",
                            style: TextStyle(color: Colors.white54, fontSize: 11)),
                      ]),
                    ]),
                  ),
                ]),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _reportRow(String label, String value, IconData icon, Color color) {
    return Row(children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(width: 12),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      const Spacer(),
      Text(value, style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
    ]);
  }

  // ─────────────────────────────────────────────
  //  REWARDS
  // ─────────────────────────────────────────────

  Widget _buildRewardsContent() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _usersStream,
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) return _loadingWidget();
        final users = snap.data ?? [];
        return ListView(padding: const EdgeInsets.all(16), children: [
          Text('User Rewards & Points',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          ...users.map((u) => _buildCard(
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(u['userName'] ?? u['name'] ?? '',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                Text('${u['points'] ?? 0} Points', style: const TextStyle(color: _accent, fontSize: 12)),
              ]),
              ElevatedButton(
                onPressed: () => _managePoints(u),
                style: ElevatedButton.styleFrom(backgroundColor: _accent.withOpacity(0.1), elevation: 0),
                child: const Text("Manage", style: TextStyle(color: _accent, fontSize: 11)),
              ),
            ]),
          )),
        ]);
      },
    );
  }

  void _managePoints(Map<String, dynamic> user) {
    int tempPoints = (user['points'] ?? 0) as int;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          backgroundColor: _cardBg,
          title: Text("Manage Points: ${user['userName'] ?? user['name'] ?? ''}",
              style: const TextStyle(color: Colors.white, fontSize: 16)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Text("$tempPoints", style: const TextStyle(color: _accent, fontSize: 32, fontWeight: FontWeight.bold)),
            const Text("Current Balance", style: TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _pointAction(Icons.remove, Colors.red, () => setDlg(() => tempPoints -= 5)),
              _pointAction(Icons.add, Colors.green, () => setDlg(() => tempPoints += 5)),
            ]),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            ElevatedButton(onPressed: () => _confirmPointsChange(ctx, user['id'], tempPoints), child: const Text("Save Changes")),
          ],
        ),
      ),
    );
  }

  void _confirmPointsChange(BuildContext dlgCtx, String userId, int newPoints) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _darkBg,
        title: const Text("Confirm Action", style: TextStyle(color: Colors.white)),
        content: Text("Update points to $newPoints?", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
          ElevatedButton(
            onPressed: () {
              _db.collection('users').doc(userId).update({'points': newPoints});
              Navigator.pop(context);
              Navigator.pop(dlgCtx);
            },
            child: const Text("Yes, Update"),
          ),
        ],
      ),
    );
  }

  Widget _pointAction(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  FEEDBACK
  // ─────────────────────────────────────────────

  Widget _buildFeedbackPage() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _feedbackStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator(color: _accent));
        if (snapshot.hasError)
          return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white)));
        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return const Center(child: Text("No feedback received yet.", style: TextStyle(color: Colors.white70, fontSize: 16)));

        final feedbackList = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: feedbackList.length,
          itemBuilder: (context, index) {
            final feedback = feedbackList[index];
            final docId = feedback['id'] as String;
            bool isDonor = feedback['type'] == 'Donor';
            bool isPublished = feedback['isPublished'] ?? false;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _cardBg, borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isDonor ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                  child: Icon(isDonor ? Icons.volunteer_activism : Icons.shopping_bag,
                      color: isDonor ? Colors.green : Colors.blue, size: 20),
                ),
                title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(feedback['userName'] ?? 'User',
                      style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(feedback['type'] ?? '', style: TextStyle(color: _accent, fontSize: 10, fontWeight: FontWeight.bold)),
                ]),
                subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SizedBox(height: 8),
                  Text(feedback['content'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  if (feedback.containsKey('rating'))
                    Row(children: List.generate(5, (i) =>
                        Icon(Icons.star, size: 14, color: i < (feedback['rating'] ?? 0) ? Colors.amber : Colors.white10))),
                ]),
                trailing: Wrap(spacing: 4, children: [
                  IconButton(
                    icon: Icon(isPublished ? Icons.cloud_done : Icons.cloud_upload_outlined,
                        color: isPublished ? Colors.greenAccent : Colors.white38, size: 22),
                    onPressed: () async {
                      await _db.collection('feedback').doc(docId).update({'isPublished': !isPublished});
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(isPublished ? 'Removed from Community' : 'Published to Community Page'),
                          backgroundColor: isPublished ? Colors.orange : Colors.green,
                        ));
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                    onPressed: () {
                      _db.collection('feedback').doc(docId).delete();
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Feedback deleted permanently')));
                    },
                  ),
                ]),
              ),
            );
          },
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  //  SHARED HELPERS
  // ─────────────────────────────────────────────

  Widget _buildCard({required Widget child}) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _cardBg, borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withOpacity(0.08)),
    ),
    child: child,
  );

  Widget _buildEmptyState(String message, IconData icon) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 50, color: Colors.white10),
      const SizedBox(height: 10),
      Text(message, style: GoogleFonts.poppins(color: Colors.white38, fontSize: 14)),
    ]),
  );

  Widget _loadingWidget() => const Center(child: CircularProgressIndicator(color: _accent));

  Widget _statusBadge(String status) {
    Color color = status == 'Accepted' ? Colors.green : status == 'Rejected' ? Colors.red : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Icon(icon, size: 16, color: _accent),
      const SizedBox(width: 8),
      Text("$label: $value", style: const TextStyle(color: Colors.white70, fontSize: 12)),
    ]),
  );

  Widget _impactCard(String emoji, String value, String label) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: _darkBg, borderRadius: BorderRadius.circular(10)),
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(emoji),
      const SizedBox(width: 8),
      Text("$value $label", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    ]),
  );

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
    filled: true, fillColor: _darkBg,
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _accent)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  );

  Widget _buildCompaniesContent() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        mini: true, backgroundColor: _accent,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddCompanyDialog(),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _companiesStream,
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) return _loadingWidget();
          final companies = snap.data ?? [];
          if (companies.isEmpty) return _buildEmptyState("No companies added yet", Icons.business);

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: companies.length,
            itemBuilder: (_, i) {
              final comp = companies[i];
              String description = comp['description'] ?? '';

              return _buildCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      comp['type'] == 'cleaning' ? Icons.local_laundry_service
                          : comp['type'] == 'delivery' ? Icons.local_shipping : Icons.content_cut,
                      color: _accent,
                    ),
                    title: Text(comp['name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text("Type: ${comp['type']} | Phone: ${comp['phone']}",
                        style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => _db.collection('companies').doc(comp['id']).delete(),
                    ),
                  ),
                  if (description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _darkBg, borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Icon(Icons.info_outline, size: 16, color: Colors.white38),
                          const SizedBox(width: 8),
                          Expanded(child: Text(description,
                              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70, height: 1.4))),
                        ]),
                      ),
                    ),
                ]),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddCompanyDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String selectedType = 'cleaning';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlg) => AlertDialog(
          backgroundColor: _cardBg,
          title: const Text("Add New Company", style: TextStyle(color: Colors.white)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nameCtrl, style: const TextStyle(color: Colors.white), decoration: _inputDecoration("Company Name")),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              dropdownColor: _cardBg, value: selectedType,
              style: const TextStyle(color: Colors.white), decoration: _inputDecoration("Service Type"),
              items: ['cleaning', 'delivery', 'tailor'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (val) => setDlg(() => selectedType = val!),
            ),
            const SizedBox(height: 10),
            TextField(controller: phoneCtrl, keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white), decoration: _inputDecoration("Phone Number")),
            const SizedBox(height: 10),
            TextField(controller: descCtrl, maxLines: 3,
                style: const TextStyle(color: Colors.white), decoration: _inputDecoration("Description / Services")),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty) return;
                await _db.collection('companies').add({
                  'name': nameCtrl.text, 'type': selectedType, 'phone': phoneCtrl.text,
                  'description': descCtrl.text, 'createdAt': FieldValue.serverTimestamp(),
                });
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Company added successfully!")));
                }
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}