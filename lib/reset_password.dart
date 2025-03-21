import 'package:flutter/material.dart';
import 'auth_service.dart';

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final AuthService authService = AuthService();

  void resetPassword() async {
    String email = emailController.text.trim();

    if (email.isNotEmpty) {
      bool success = await authService.resetPassword(email);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Password reset link sent! Check your email.")),
        );
        Navigator.pop(context); // Go back to the login screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to send reset email. Try again.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reset Password")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: InputDecoration(labelText: "Enter your email")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: resetPassword, child: Text("Send Reset Link")),
          ],
        ),
      ),
    );
  }
}
