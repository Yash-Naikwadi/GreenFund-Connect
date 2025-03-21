import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'home_screen.dart';
import 'project_details_screen.dart';
import 'add_project_screen.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GreenFund Connect',
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF2E7D32), // Dark green
        secondaryHeaderColor: const Color(0xFF81C784), // Light green
        fontFamily: GoogleFonts.poppins().fontFamily,
        textTheme: TextTheme(
          headlineLarge: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2E7D32),
          ),
          titleLarge: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          bodyLarge: GoogleFonts.poppins(
            color: Colors.black87,
          ),
          bodyMedium: GoogleFonts.poppins(
            color: Colors.black87,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ),
      routes: {
        '/': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/project_details': (context) => const ProjectDetailsScreen(),
        '/add_project': (context) => const AddProjectScreen(),
      },
      initialRoute: '/',
    );
  }
}
