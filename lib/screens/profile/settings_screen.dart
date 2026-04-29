import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../auth/login_screen.dart'; // Ensure this import is correct for Delete Account
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    final userProvider = Provider.of<UserProvider>(context);
    final currentRole = userProvider.role;

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
            Text('App Preferences',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
            const SizedBox(height: 8),
            _buildCard(
              children: [
                _arrowTile('Switch Account Type', Icons.swap_horiz_rounded, Colors.deepPurple, () {
                  _showAccountTypeDialog(context, currentRole);
                }),
              ],
            ),
            const SizedBox(height: 24),

            Text('Notifications',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
            const SizedBox(height: 8),
            _buildCard(
              children: [
                if (currentRole == 'Buyer' || currentRole == 'Both') ...[
                  _switchTile('Order Updates', 'Get notified about your orders',
                      Icons.shopping_bag_outlined, Colors.blue,
                      _orderNotifications, (val) async {
                        setState(() => _orderNotifications = val);
                        //update database in user profile
                        String uid = FirebaseAuth.instance.currentUser!.uid;
                        await FirebaseFirestore.instance.collection('users').doc(uid).update({
                          'settings_order_notifications': val,
                        });

                        if (val) {
                          await FirebaseMessaging.instance.subscribeToTopic("orders");
                        } else {
                          await FirebaseMessaging.instance.unsubscribeFromTopic("orders");
                        }
                      }),
                  const Divider(),
                ],
                if (currentRole == 'Donor' || currentRole == 'Both') ...[
                  _switchTile('Donation Updates', 'Track your donation status',
                      Icons.volunteer_activism_outlined, Colors.green,
                      _donationNotifications, (val) async {
                        setState(() => _donationNotifications = val);
                        String uid = FirebaseAuth.instance.currentUser!.uid;
                        await FirebaseFirestore.instance.collection('users').doc(uid).update({
                          'settings_donation_notifications': val,
                        });

                        if (val) {
                          await FirebaseMessaging.instance.subscribeToTopic("donations");
                        } else {
                          await FirebaseMessaging.instance.unsubscribeFromTopic("donations");
                        }
                      }),
                  const Divider(),
                  _switchTile('Remake Studio', 'New items needing your ideas',
                      Icons.auto_awesome, Colors.purple,
                      _remakeNotifications, (val) async {
                        setState(() => _remakeNotifications = val);
                        String uid = FirebaseAuth.instance.currentUser!.uid;
                        await FirebaseFirestore.instance.collection('users').doc(uid).update({
                          'settings_remake_notifications': val,
                        });

                        if (val) {
                          await FirebaseMessaging.instance.subscribeToTopic("remake");
                        } else {
                          await FirebaseMessaging.instance.unsubscribeFromTopic("remake");
                        }
                      }),
                  const Divider(),
                ],
                _switchTile('Promotions & Offers', 'Deals and special offers',
                    Icons.local_offer_outlined, Colors.orange,
                    _promotionNotifications, (val) async {
                      setState(() => _promotionNotifications = val);
                      String uid = FirebaseAuth.instance.currentUser!.uid;
                      await FirebaseFirestore.instance.collection('users').doc(uid).update({
                        'settings_promo_notifications': val,
                      });

                      if (val) {
                        await FirebaseMessaging.instance.subscribeToTopic("promotions");
                      } else {
                        await FirebaseMessaging.instance.unsubscribeFromTopic("promotions");
                      }
                    }),
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
                      'ReCloth is committed to protecting your privacy. Data is encrypted and secure.');
                }),
                const Divider(),
                _arrowTile('Terms & Conditions', Icons.description_outlined, Colors.grey, () {
                  _showTextDialog('Terms & Conditions',
                      'By using ReCloth, you agree to our community standards and donation policies.');
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

  // Helper Widgets

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

  // Logic & Dialogs

  void _showAccountTypeDialog(BuildContext context, String currentRole) {
    String selectedRole = currentRole;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Switch Account Type', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _roleOption('Buyer', 'I want to shop only', Icons.shopping_bag, selectedRole, (val) {
                setDialogState(() => selectedRole = val!);
              }),
              _roleOption('Donor', 'I want to donate only', Icons.volunteer_activism, selectedRole, (val) {
                setDialogState(() => selectedRole = val!);
              }),
              _roleOption('Both', 'I want to do both', Icons.all_inclusive, selectedRole, (val) {
                setDialogState(() => selectedRole = val!);
              }),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .update({'role': selectedRole});
                if (mounted) {
                  Provider.of<UserProvider>(context, listen: false).setRole(selectedRole);
                  Navigator.pop(context);
                }
              },
              child: Text('Confirm', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleOption(String value, String subtitle, IconData icon, String groupValue, ValueChanged<String?> onChanged) {
    return RadioListTile<String>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: Colors.deepPurple,
      title: Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 11)),
      secondary: Icon(icon, color: Colors.deepPurple, size: 20),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Reset Password', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('A reset link will be sent to your registered email.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.sendPasswordResetEmail(email: FirebaseAuth.instance.currentUser!.email!);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email Sent!')));
            },
            child: Text('Send', style: const TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
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
        title: Text('Change $fieldName'),
        content: _dialogTextField(controller, hint, false),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await _updateUserField(fieldName, controller.text.trim());
              Navigator.pop(context);
            },
            child: Text('Save', style: const TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
          ),
        ],
      ),
    );
  }

  Future<void> _updateUserField(String fieldName, String newValue) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        fieldName.toLowerCase().replaceAll(' ', '_'): newValue,
      });
      if (fieldName == 'Email') await FirebaseAuth.instance.currentUser!.updateEmail(newValue);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _showTextDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(content)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Close'))],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
        content: const Text('This action is permanent.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              String uid = FirebaseAuth.instance.currentUser!.uid;
              await FirebaseFirestore.instance.collection('users').doc(uid).delete();
              await FirebaseAuth.instance.currentUser!.delete();
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
            },
            child: Text('Delete', style: const TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}