import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.green.shade100,
            child: Icon(
              Icons.person,
              size: 60,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'User Profile',
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 32),
          ProfileMenuItem(
            icon: Icons.person_outline,
            title: 'Personal Information',
            onTap: () {
              _showPersonalInfoDialog(context);
            },
          ),
          ProfileMenuItem(
            icon: Icons.credit_card,
            title: 'Payment Methods',
            onTap: () {
              _showPaymentMethodsDialog(context);
            },
          ),
          ProfileMenuItem(
            icon: Icons.history,
            title: 'Investment History',
            onTap: () {
              _showInvestmentHistoryDialog(context);
            },
          ),
          ProfileMenuItem(
            icon: Icons.eco_outlined,
            title: 'Impact Dashboard',
            onTap: () {
              _showImpactDashboardDialog(context);
            },
          ),
          ProfileMenuItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () {
              _navigateToSettingsScreen(context);
            },
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () {
              _showLogoutConfirmationDialog(context);
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            label: Text(
              'Logout',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to show a generic dialog
  void _showGenericDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Personal Information Dialog
  void _showPersonalInfoDialog(BuildContext context) {
    _showGenericDialog(
      context, 
      'Personal Information', 
      'Manage your personal details like name, email, and contact information.'
    );
  }

  // Payment Methods Dialog
  void _showPaymentMethodsDialog(BuildContext context) {
    _showGenericDialog(
      context, 
      'Payment Methods', 
      'Add, remove, or manage your payment methods for investments.'
    );
  }

  // Investment History Dialog
  void _showInvestmentHistoryDialog(BuildContext context) {
    _showGenericDialog(
      context, 
      'Investment History', 
      'View your past and current investments in renewable energy projects.'
    );
  }

  // Impact Dashboard Dialog
  void _showImpactDashboardDialog(BuildContext context) {
    _showGenericDialog(
      context, 
      'Impact Dashboard', 
      'See the environmental impact of your investments, including CO2 reduction and energy generated.'
    );
  }

  // Navigate to Settings Screen (you can create a separate SettingsScreen)
  void _navigateToSettingsScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(),
      ),
    );
  }

  // Logout Confirmation Dialog
  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut(); // Firebase logout
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/', // Route to login screen
                    (Route<dynamic> route) => false,
                  );
                } catch (e) {
                  print("Logout failed: $e");
                }
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}

// Optional: Settings Screen
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Notifications'),
            subtitle: const Text('Receive project updates'),
            value: true,
            onChanged: (bool value) {
              // Implement notification settings logic
            },
          ),
          ListTile(
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to change password screen
            },
          ),
          ListTile(
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Show privacy policy
            },
          ),
        ],
      ),
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ProfileMenuItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).primaryColor,
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}