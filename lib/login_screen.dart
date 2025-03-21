import 'package:flutter/material.dart';
import 'reset_password.dart';
import 'auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();
  bool isLoading = false;
  String? errorMessage;

  // Email & Password Sign-In
  void signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      String email = emailController.text.trim();
      String password = passwordController.text.trim();

      var user = await authService.signIn(email, password);
      setState(() => isLoading = false);

      if (user != null) {
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        setState(() => errorMessage = "Login failed. Please check your credentials.");
      }
    }
  }

  // Google Sign-In
  void googleLogin() async {
    var user = await authService.signInWithGoogle();
    if (user != null) {
      print("Google Sign-In Successful!");
      Navigator.pushReplacementNamed(context, "/home");
    } else {
      setState(() => errorMessage = "Google Sign-In Failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ResetPasswordPage()),
                  );
                },
                child: const Text(
                  "Forgot Password?",
                  style: TextStyle(
                    color: Color(0xFF007BFF), // Blue text for link
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),

              if (errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(errorMessage!, style: TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 20),

              isLoading
                  ? CircularProgressIndicator()
                  : Column(
                      children: [
                        ElevatedButton(
                          onPressed: signIn,
                          child: const Text('Login'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: googleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            side: BorderSide(color: Colors.grey),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset('assets/images/google_logo.png', height: 20), // Add Google logo in assets
                              const SizedBox(width: 10),
                              const Text("Sign in with Google"),
                            ],
                          ),
                        ),
                      ],
                    ),

              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: const Text("Don't have an account? Sign up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
