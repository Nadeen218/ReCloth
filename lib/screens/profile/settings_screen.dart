import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  final String role;
  const SettingsScreen({super.key, required this.role});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _orderNotifications = true;
  bool _donationNotifications = true;
  bool _remakeNotifications = true;
  bool _promotionNotifications = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Settings',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notifications',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
            const SizedBox(height: 8),
            _buildCard(
              children: [
                if (widget.role == 'Buyer' || widget.role == 'Both') ...[
                  _switchTile('Order Updates', 'Get notified about your orders',
                      Icons.shopping_bag_outlined, Colors.blue,
                      _orderNotifications, (val) => setState(() => _orderNotifications = val)),
                  const Divider(),
                ],
                if (widget.role == 'Donor' || widget.role == 'Both') ...[
                  _switchTile('Donation Updates', 'Track your donation status',
                      Icons.volunteer_activism_outlined, Colors.green,
                      _donationNotifications, (val) => setState(() => _donationNotifications = val)),
                  const Divider(),
                  _switchTile('Remake Studio', 'New items needing your ideas',
                      Icons.auto_awesome, Colors.purple,
                      _remakeNotifications, (val) => setState(() => _remakeNotifications = val)),
                  const Divider(),
                ],
                _switchTile('Promotions & Offers', 'Deals and special offers',
                    Icons.local_offer_outlined, Colors.orange,
                    _promotionNotifications, (val) => setState(() => _promotionNotifications = val)),
              ],
            ),
            const SizedBox(height: 24),

            Text('Account',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
            const SizedBox(height: 8),
            _buildCard(
              children: [
                _arrowTile('Change Password', Icons.lock_outline, Colors.purple, () {
                  _showChangePasswordDialog();
                }),
                const Divider(),
                _arrowTile('Change Email', Icons.email_outlined, Colors.blue, () {
                  _showChangeFieldDialog('Email', 'Enter new email');
                }),
                const Divider(),
                _arrowTile('Change Phone Number', Icons.phone_outlined, Colors.green, () {
                  _showChangeFieldDialog('Phone Number', 'Enter new phone number');
                }),
              ],
            ),
            const SizedBox(height: 24),

            Text('Privacy',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
            const SizedBox(height: 8),
            _buildCard(
              children: [
                _arrowTile('Privacy Policy', Icons.privacy_tip_outlined, Colors.grey, () {
                  _showTextDialog('Privacy Policy',
                      'ReCloth is committed to protecting your privacy. We collect only the information necessary to provide our services. Your personal data is never sold to third parties. All data is stored securely and encrypted. You may request deletion of your account and data at any time.');
                }),
                const Divider(),
                _arrowTile('Terms & Conditions', Icons.description_outlined, Colors.grey, () {
                  _showTextDialog('Terms & Conditions',
                      'By using ReCloth, you agree to donate or purchase pre-loved clothing in good faith. All sales are final unless the item does not match its description. ReCloth reserves the right to remove listings that violate our community standards. Users must be 13 years or older to use this app.');
                }),
              ],
            ),
            const SizedBox(height: 24),

            Text('Danger Zone',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red[400])),
            const SizedBox(height: 8),
            _buildCard(
              children: [
                _arrowTile('Delete Account', Icons.delete_outline, Colors.red, () {
                  _showDeleteAccountDialog();
                }),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
      ),
      child: Column(children: children),
    );
  }

  Widget _switchTile(String title, String subtitle, IconData icon, Color color, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45)),
      trailing: Switch(value: value, onChanged: onChanged, activeColor: Colors.purple),
    );
  }

  Widget _arrowTile(String title, IconData icon, Color color, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title,
          style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color == Colors.red ? Colors.red : Colors.black87)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Change Password', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogTextField(currentPasswordController, 'Current Password', true),
            const SizedBox(height: 12),
            _dialogTextField(newPasswordController, 'New Password', true),
            const SizedBox(height: 12),
            _dialogTextField(confirmPasswordController, 'Confirm New Password', true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (currentPasswordController.text.isEmpty ||
                  newPasswordController.text.isEmpty ||
                  confirmPasswordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please fill in all fields!', style: GoogleFonts.poppins()), backgroundColor: Colors.red),
                );
                return;
              }
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Passwords do not match!', style: GoogleFonts.poppins()), backgroundColor: Colors.red),
                );
                return;
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Password changed successfully!', style: GoogleFonts.poppins()), backgroundColor: Colors.green),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text('Save', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showChangeFieldDialog(String fieldName, String hint) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Change $fieldName', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: _dialogTextField(controller, hint, false),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter your $fieldName!', style: GoogleFonts.poppins()), backgroundColor: Colors.red),
                );
                return;
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$fieldName updated successfully!', style: GoogleFonts.poppins()), backgroundColor: Colors.green),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text('Save', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showTextDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Text(content, style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54, height: 1.6)),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text('Close', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Account', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.red)),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text('Delete', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _dialogTextField(TextEditingController controller, String hint, bool obscure) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(fontSize: 13),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }
}