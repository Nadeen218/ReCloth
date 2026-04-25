import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduation_project/screens/auth/login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  String _userSearchQuery = "";
  String _selectedInventoryCategory = 'All Types';


  static const Color _darkBg = Color(0xFF0D1B2A);
  static const Color _cardBg = Color(0xFF1A2332);
  static const Color _accent = Color(0xFF4F8EF7);

  final List<String> _fixedCategories = [
    'All Types', 'Shirts', 'Jackets', 'Dresses', 'Coats', 'Pants', 'Shoes', 'Mixed Items'
  ];

  final List<Map<String, dynamic>> _users = [
    {
      'name': 'Nadeen Abu Hilweh',
      'email': 'nadeenabuhilweh@gmail.com',
      'role': 'Both',
      'active': true,
      'phone': '+970 59 111 1111',
      'address': 'Jerusalem, Palestine',
      'joinDate': '1/1/2026',
      'purchases': 3,
      'totalPaid': 150.0,
      'donations': 5,
      'points': 150,
      'itemsDonated': 12,
      'livesImpacted': 8,
      'co2Saved': 15
    },
    {
      'name': 'Raghad Iyad',
      'email': 'Raghad@gmail.com',
      'role': 'Donor',
      'active': true,
      'phone': '+970 59 111 3333',
      'address': 'Jerusalem, Palestine',
      'joinDate': '1/1/2026',
      'donations': 5,
      'isPaidDonation': false,
      'points': 150,
      'itemsDonated': 12,
      'livesImpacted': 8,
      'co2Saved': 15,
    },
    {
      'name': 'Omar Khalil',
      'email': 'omar@gmail.com',
      'role': 'Buyer',
      'active': true,
      'phone': '+970 59 222 2222',
      'address': 'Ramallah, Palestine',
      'joinDate': '5/2/2026',
      'purchases': 7,
      'totalPaid': 320.5,
      'points': 35,
    },
  ];

  final List<Map<String, dynamic>> _donations = [
    {
      'item': 'Denim Jacket',
      'donor': 'Nadeen',
      'status': 'Request Received',
      'date': '4/6/2026',
      'condition': 'Like New',
      'notes': 'Needs light cleaning',
      'isPaid': true,
    },
    {
      'item': 'Summer Dress',
      'donor': 'Sara',
      'status': 'Picked Up',
      'date': '3/6/2026',
      'condition': 'Good',
      'notes': 'N/A',
      'isPaid': false,
    },
  ];

  final List<Map<String, dynamic>> _orders = [
    {'item': 'Classic Denim Jacket', 'buyer': 'Omar', 'total': 25.0, 'status': 'Pending'},
    {'item': 'Black T-Shirt', 'buyer': 'Nadeen', 'total': 13.0, 'status': 'Processing'},
  ];

  final List<Map<String, dynamic>> _remakeSuggestions = [
    {'item': 'Torn Denim Jeans', 'user': 'Omar', 'idea': 'Turn into shorts', 'status': 'Pending'},

];

  final List<Map<String, dynamic>> _messages = [
    {'name': 'Omar Khalil', 'email': 'omar@gmail.com', 'message': 'Question about delivery.', 'date': '4/6/2026', 'read': false},
  ];

  final List<Map<String, dynamic>> _inventory = [
    {'name': 'Classic Denim Jacket', 'category': 'Jackets', 'price': 20.0, 'size': 'M', 'condition': 'Good', 'available': true, 'image': 'https://images.unsplash.com/photo-1521223890158-f9f7c3d5d504?q=80&w=200'},
  ];

  final List<String> _donationStatuses = ['Request Received', 'Picked Up', 'Cleaning in Progress', 'Ready for Sale', 'Sold'];

  // Helper function to get unique categories from inventory
     List<String> _getCategories() {
        return _inventory.map((item) => item['category'] as String).toSet().toList();
     }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      appBar: AppBar(
        backgroundColor: _cardBg,
        elevation: 0,
        title: Text('Admin Dashboard',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedIndex == 0) _buildOverviewHeader(),
          Container(
            color: _cardBg,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTab(0, 'Overview', Icons.dashboard_outlined),
                  _buildTab(1, 'Users', Icons.people_outline),
                  _buildTab(2, 'Donations', Icons.volunteer_activism_outlined, badgeCount: _donations.length),                  _buildTab(3, 'Orders', Icons.shopping_bag_outlined),
                  _buildTab(4, 'Inventory', Icons.inventory_2_outlined),
                  _buildTab(5, 'Remake', Icons.auto_awesome),
                  _buildTab(6, 'Messages', Icons.message_outlined, badgeCount: _messages.where((m)=>!m['read']).length),
                  _buildTab(7, 'Weekly Report', Icons.analytics_outlined),
                  _buildTab(8, 'Rewards', Icons.emoji_events_outlined),
                ],
              ),
            ),
          ),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildOverviewHeader() {
    int totalCO2 = _users.fold(0, (sum, user) => sum + (user['co2Saved'] ?? 0) as int);
    int totalItems = _users.fold(0, (sum, user) => sum + (user['itemsDonated'] ?? 0) as int);

    return Container(
      padding: const EdgeInsets.all(16),
      color: _cardBg,
      child: Column(
        children: [
          Row(
            children: [
              _buildStatCard('Total Users', '${_users.length}', Icons.people, Colors.blue),
              const SizedBox(width: 8),
              _buildStatCard('New Donations', '${_donations.where((d) => d['status'] == 'Request Received').length}', Icons.volunteer_activism, Colors.green),
              const SizedBox(width: 8),
              _buildStatCard('Pending Orders', '${_orders.where((o) => o['status'] == 'Pending').length}', Icons.shopping_bag, Colors.orange),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.green.withOpacity(0.2), Colors.blue.withOpacity(0.2)]),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _miniImpactInfo("🌿 Total CO₂ Saved", "${totalCO2}kg"),
                _miniImpactInfo("♻️ Items Recycled", "$totalItems"),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _miniImpactInfo(String label, String value) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70)),
        Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(title, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 9, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, String label, IconData icon, {int badgeCount = 0}) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: isSelected ? _accent : Colors.transparent, width: 2)),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 18, color: isSelected ? _accent : Colors.white54),
                if (badgeCount > 0)
                  Positioned(
                    right: -5,
                    top: -5,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                      child: Text('$badgeCount', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? _accent : Colors.white54)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0: return _buildOverviewContent();
      case 1: return _buildUsersContent();
      case 2: return _buildDonationsContent();
      case 3: return _buildOrdersContent();
      case 4: return _buildInventoryContent();
      case 5: return _buildRemakeContent();
      case 6: return _buildMessagesContent();
      case 7: return _buildWeeklyReport();
      case 8: return _buildRewardsContent();
      default: return _buildOverviewContent();
    }
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: child,
    );
  }

  Widget _buildOverviewContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Activity', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          ..._donations.take(2).map((d) => _activityTile(Icons.volunteer_activism, Colors.green, '${d['donor']} donated ${d['item']}', d['date'], d, true)),
          ..._orders.take(2).map((o) => _activityTile(Icons.shopping_bag, Colors.blue, '${o['buyer']} ordered ${o['item']}', '4/6/2026', o, false)),
        ],
      ),
    );
  }

  Widget _activityTile(IconData icon, Color color, String title, String date, Map<String, dynamic> data, bool isDonation) {
    return GestureDetector(
      onTap: () => _showActivityDetails(data, isDonation),
      child: _buildCard(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: GoogleFonts.poppins(fontSize: 13, color: Colors.white))),
            const SizedBox(width: 8),
            Text(date, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white38)),
            const Icon(Icons.chevron_right, color: Colors.white24, size: 16),
          ],
        ),
      ),
    );
  }

  void _showActivityDetails(Map<String, dynamic> data, bool isDonation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isDonation ? "Donation Details" : "Order Details",
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _detailRow(isDonation ? Icons.volunteer_activism : Icons.shopping_bag,
                "Item", data['item']),
            _detailRow(Icons.person, isDonation ? "Donor" : "Buyer",
                isDonation ? data['donor'] : data['buyer']),
            _detailRow(Icons.info_outline, "Status", data['status']),
            if (!isDonation) _detailRow(Icons.payments, "Total", "₪${data['total']}"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))
        ],
      ),
    );
  }

  Widget _buildUsersContent() {
    final filteredUsers = _users.where((u) {
      final name = u['name'].toLowerCase();
      final addr = u['address'].toLowerCase();
      return name.contains(_userSearchQuery.toLowerCase()) || addr.contains(_userSearchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
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
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final user = filteredUsers[index];
              return _buildCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(backgroundColor: _accent.withOpacity(0.2), child: Text(user['name'][0], style: const TextStyle(color: _accent))),
                  title: Text(user['name'], style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: Text("Status: ${user['active'] ? 'Active' : 'Inactive'} | Role: ${user['role']}", style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  trailing: Icon(Icons.info_outline, color: _accent),
                  onTap: () => _showUserDetailsDialog(user, index),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showUserDetailsDialog(Map<String, dynamic> user, int index) {
    bool isBuyer = user['role'] == 'Buyer' || user['role'] == 'Both';
    bool isDonor = user['role'] == 'Donor' || user['role'] == 'Both';

    double totalPaid = (user['totalPaid'] ?? 0.0).toDouble();
    int totalDonations = user['donations'] ?? 0;
    int itemsDonated = user['itemsDonated'] ?? 0;
    bool isPaidDonation = user['isPaidDonation'] ?? false;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(user['name'], style: const TextStyle(color: Colors.white, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _detailRow(Icons.email, "Email", user['email']),
            _detailRow(Icons.phone, "Phone", user['phone']),
            _detailRow(Icons.account_circle, "Status", user['active'] ? "Active" : "Inactive"),

            if (isBuyer)
              _detailRow(Icons.shopping_cart, "Total Paid (Buyer)", "₪$totalPaid"),

            if (isDonor) ...[
              _detailRow(Icons.volunteer_activism, "Total Donations", "$totalDonations Times"),
            ],

            const Divider(color: Colors.white12),
            if (isDonor)
              _impactCard("♻️ Items", "$itemsDonated", "Donated"),

            if (isBuyer && !isDonor)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text("Valued Customer", style: TextStyle(color: _accent.withOpacity(0.7), fontSize: 11, fontStyle: FontStyle.italic)),
              ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [Icon(icon, size: 16, color: _accent), const SizedBox(width: 8), Text("$label: $value", style: const TextStyle(color: Colors.white70, fontSize: 12))]),
    );
  }

  Widget _impactCard(String emoji, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: _darkBg, borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(emoji), const SizedBox(width: 8), Text("$value $label", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
    );
  }
  String _donationSearchQuery = "";

  Widget _buildDonationsContent() {
    final filteredDonations = _donations.where((d) {
      return d['item'].toLowerCase().contains(_donationSearchQuery.toLowerCase()) ||
          d['donor'].toLowerCase().contains(_donationSearchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration("Search items or donors...").copyWith(
              prefixIcon: const Icon(Icons.search, color: _accent),
            ),
            onChanged: (val) => setState(() => _donationSearchQuery = val),
          ),
        ),

        Expanded(
          child: filteredDonations.isEmpty
              ? _buildEmptyState("No matching donations found", Icons.search_off)
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredDonations.length,
            itemBuilder: (context, index) {
              final donation = filteredDonations[index];
              bool isPaid = donation['isPaid'] ?? false;

              int originalIndex = _donations.indexOf(donation);

              return _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(donation['item'],
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isPaid ? Colors.amber.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: isPaid ? Colors.amber : Colors.blue, width: 0.5),
                                ),
                                child: Text(
                                  isPaid ? "Paid Donation" : "Free Donation",
                                  style: TextStyle(
                                    color: isPaid ? Colors.amber : Colors.blue,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                            onPressed: () => _editDonation(originalIndex),
                            icon: const Icon(Icons.edit, color: Colors.orange, size: 18)
                        ),
                      ],
                    ),
                    Text('Donor: ${donation['donor']}',
                        style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    Text('Condition: ${donation['condition']}',
                        style: const TextStyle(color: Colors.white38, fontSize: 11)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: donation['status'],
                      dropdownColor: _cardBg,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: _darkBg,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))
                      ),
                      items: _donationStatuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) => setState(() => _donations[originalIndex]['status'] = val),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _editDonation(int index) {
    final noteController = TextEditingController(text: _donations[index]['notes']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        title: const Text("Edit Donation Details", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: noteController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(labelText: "Admin Notes", labelStyle: TextStyle(color: Colors.white38)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(onPressed: () {
            setState(() => _donations[index]['notes'] = noteController.text);
            Navigator.pop(context);
          }, child: const Text("Save")),
        ],
      ),
    );
  }

  Widget _buildOrdersContent() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index];
        return _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(order['item'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('₪${order['total']}', style: const TextStyle(color: _accent, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 4),
              Text('Buyer: ${order['buyer']}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text("Status: ", style: TextStyle(color: Colors.white38, fontSize: 12)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: order['status'],
                      dropdownColor: _cardBg,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                        filled: true,
                        fillColor: _darkBg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                      items: ['Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s, style: TextStyle(
                          color: s == 'Cancelled' ? Colors.redAccent : (s == 'Delivered' ? Colors.greenAccent : Colors.white)
                      )))).toList(),
                      onChanged: (val) {
                        setState(() => _orders[index]['status'] = val);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  String _inventorySearchQuery = "";

  Widget _buildInventoryContent() {
    final filteredInventory = _inventory.where((item) {
      bool matchesCategory = _selectedInventoryCategory == 'All Types' ||
          item['category'] == _selectedInventoryCategory;
      bool matchesSearch = item['name']
          .toLowerCase()
          .contains(_inventorySearchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration("Search items...").copyWith(
              prefixIcon: const Icon(Icons.search, color: _accent),
            ),
            onChanged: (val) => setState(() => _inventorySearchQuery = val),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: _fixedCategories.map((cat) {
              bool isSelected = _selectedInventoryCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(cat,
                      style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white54,
                          fontSize: 12)),
                  selected: isSelected,
                  onSelected: (selected) =>
                      setState(() => _selectedInventoryCategory = cat),
                  backgroundColor: _cardBg,
                  selectedColor: _accent,
                  checkmarkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              );
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton.icon(
            onPressed: () => _showAddItemDialog(),
            icon: const Icon(Icons.add),
            label: const Text("Add New Item"),
            style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                minimumSize: const Size(double.infinity, 50)),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: filteredInventory.isEmpty
              ? _buildEmptyState("No items found", Icons.inventory_2_outlined)
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredInventory.length,
            itemBuilder: (context, index) {
              final item = filteredInventory[index];
              return _buildCard(
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item['image'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.image,
                            color: Colors.white24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['name'],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          Text(
                              '${item['category']} • Size: ${item['size']} • ${item['condition']}',
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 11)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('₪${item['price']}',
                            style: const TextStyle(
                                color: _accent,
                                fontWeight: FontWeight.bold)),
                        Switch(
                          value: item['available'],
                          onChanged: (val) => setState(() =>
                          _inventory[_inventory.indexOf(item)]
                          ['available'] = val),
                          activeColor: Colors.green,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.redAccent, size: 18),
                          onPressed: () => setState(
                                  () => _inventory.remove(item)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: Colors.white10),
          const SizedBox(height: 10),
          Text(message, style: GoogleFonts.poppins(color: Colors.white38, fontSize: 14)),
        ],
      ),
    );
  }

  void _showAddItemDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descController = TextEditingController();
    String? selectedCategory;
    String? selectedSize;
    String imageStatus = "No image selected";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: _cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Add Inventory Item",
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    setDialogState(() => imageStatus = "📸 item_image.jpg selected");
                  },
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _darkBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _accent.withOpacity(0.3)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, color: _accent, size: 30),
                        const SizedBox(height: 8),
                        Text(imageStatus, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Item Name"),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration("Price (₪)"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        dropdownColor: _cardBg,
                        value: selectedSize,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration("Size"),
                        items: ['S', 'M', 'L', 'XL', 'Free Size'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (val) => setDialogState(() => selectedSize = val),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  dropdownColor: _cardBg,
                  value: selectedCategory,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Category"),
                  items: _fixedCategories.where((c) => c != 'All Types').map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                  onChanged: (val) => setDialogState(() => selectedCategory = val),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Description / Condition"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.white54))),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && selectedCategory != null) {
                  setState(() {
                    _inventory.add({
                      'name': nameController.text,
                      'category': selectedCategory,
                      'price': double.tryParse(priceController.text) ?? 0.0,
                      'size': selectedSize ?? 'N/A',
                      'condition': descController.text.isEmpty ? 'Good' : descController.text,
                      'available': true,
                      'image': 'https://images.unsplash.com/photo-1523381210434-271e8be1f52b?q=80&w=200',
                    });
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Item added successfully!"), backgroundColor: Colors.green));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: _accent),
              child: const Text("Confirm Add"),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
      filled: true,
      fillColor: _darkBg,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white10)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _accent)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildWeeklyReport() {
    int totalDonationsCount = _donations.length;
    double totalRevenue = _orders.fold(0, (sum, order) => sum + (order['total'] ?? 0));
    int itemsRecycled = _users.fold(0, (sum, user) => sum + (user['itemsDonated'] ?? 0) as int);
    int totalCO2 = _users.fold(0, (sum, user) => sum + (user['co2Saved'] ?? 0) as int);

    int newUsersThisMonth = _users.where((u) => u['joinDate'].contains('2026')).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Performance Report',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),

          _buildCard(
            child: Column(
              children: [
                _reportRow("New Users (2026)", "+$newUsersThisMonth", Icons.person_add, Colors.blue),
                const Divider(color: Colors.white12, height: 20),
                _reportRow("Total Revenue", "₪${totalRevenue.toStringAsFixed(2)}", Icons.monetization_on, Colors.green),
                const Divider(color: Colors.white12, height: 20),
                _reportRow("Completed Donations", "$totalDonationsCount", Icons.check_circle, Colors.orange),
                const Divider(color: Colors.white12, height: 20),
                _reportRow("CO₂ Saved This Week", "${totalCO2}kg", Icons.eco, Colors.teal),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Text('Impact Metrics',
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70)),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.blue.withOpacity(0.1), Colors.green.withOpacity(0.1)]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.recycling, color: Colors.greenAccent, size: 30),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("$itemsRecycled Items",
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text("Successfully Recycled through ReCloth",
                        style: TextStyle(color: Colors.white54, fontSize: 11)),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const Spacer(),
        Text(value, style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }


  Widget _buildRewardsContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('User Rewards & Points', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        ..._users.map((u) => _buildCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(u['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('${u['points']} Points', style: const TextStyle(color: _accent, fontSize: 12)),
                ],
              ),
              ElevatedButton(
                onPressed: () => _managePoints(u),
                style: ElevatedButton.styleFrom(backgroundColor: _accent.withOpacity(0.1), elevation: 0),
                child: const Text("Manage", style: TextStyle(color: _accent, fontSize: 11)),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildRemakeContent() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _remakeSuggestions.length,
      itemBuilder: (context, index) {
        final item = _remakeSuggestions[index];
        return _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item['item'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  _statusBadge(item['status']),
                ],
              ),
              Text("User: ${item['user']}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
              Text("Idea: ${item['idea']}", style: const TextStyle(color: _accent, fontSize: 13, fontStyle: FontStyle.italic)),
              const SizedBox(height: 12),
              if (item['status'] == 'Pending')
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green.withOpacity(0.2)),
                        onPressed: () => setState(() => _remakeSuggestions[index]['status'] = 'Accepted'),
                        child: const Text("Accept", style: TextStyle(color: Colors.greenAccent)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.2)),
                        onPressed: () => setState(() => _remakeSuggestions[index]['status'] = 'Rejected'),
                        child: const Text("Reject", style: TextStyle(color: Colors.redAccent)),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _statusBadge(String status) {
    Color color = status == 'Accepted' ? Colors.green : (status == 'Rejected' ? Colors.red : Colors.orange);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(5), border: Border.all(color: color, width: 0.5)),
      child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
  Widget _buildMessagesContent() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        return _buildCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(msg['read'] ? Icons.mark_email_read : Icons.mark_email_unread,
                color: msg['read'] ? Colors.white24 : _accent),
            title: Text(msg['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text(msg['message'], style: const TextStyle(color: Colors.white54, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: IconButton(
              icon: const Icon(Icons.reply, color: _accent, size: 20),
              onPressed: () => _showReplyDialog(msg, index),
            ),
            onTap: () => _showReplyDialog(msg, index),
          ),
        );
      },
    );
  }

  void _showReplyDialog(Map<String, dynamic> msg, int index) {
    final replyController = TextEditingController();
    setState(() => _messages[index]['read'] = true);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Reply to ${msg['name']}", style: const TextStyle(color: Colors.white, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Message: ${msg['message']}", style: const TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 15),
            TextField(
              controller: replyController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("Your Response"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Reply sent successfully!"), backgroundColor: Colors.green)
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: _accent),
            child: const Text("Send Reply"),
          ),
        ],
      ),
    );
  }
  void _managePoints(Map<String, dynamic> user) {
    int tempPoints = user['points'] ?? 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: _cardBg,
          title: Text("Manage Points: ${user['name']}", style: const TextStyle(color: Colors.white, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("$tempPoints", style: const TextStyle(color: _accent, fontSize: 32, fontWeight: FontWeight.bold)),
              const Text("Current Balance", style: TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _pointAction(Icons.remove, Colors.red, () => setDialogState(() => tempPoints -= 5)),
                  _pointAction(Icons.add, Colors.green, () => setDialogState(() => tempPoints += 5)),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
                onPressed: () {
                  _confirmPointsChange(user, tempPoints);
                },
                child: const Text("Save Changes")
            ),
          ],
        ),
      ),
    );
  }

  void _confirmPointsChange(Map<String, dynamic> user, int newPoints) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _darkBg,
        title: const Text("Confirm Action", style: TextStyle(color: Colors.white)),
        content: Text("Are you sure you want to update points to $newPoints?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
          ElevatedButton(
            onPressed: () {
              setState(() => user['points'] = newPoints);
              Navigator.pop(context);
              Navigator.pop(context);
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
}