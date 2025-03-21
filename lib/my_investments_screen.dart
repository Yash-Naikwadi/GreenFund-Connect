import 'package:flutter/material.dart';

class MyInvestmentsScreen extends StatelessWidget {
  const MyInvestmentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Investments')),
      body: const Center(child: Text('My Investments Screen')),
    );
  }
}
