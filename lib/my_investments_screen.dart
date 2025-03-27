import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyInvestmentsScreen extends StatelessWidget {
  const MyInvestmentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('My Investments')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('investments')
            .where('investorId', isEqualTo: userId) // Get user investments
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("You haven't invested in any projects yet."));
          }

          var investments = snapshot.data!.docs;

          return ListView.builder(
            itemCount: investments.length,
            itemBuilder: (context, index) {
              var investment = investments[index];
              var projectId = investment['projectId'];
              var amountInvested = investment['amount'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('projects').doc(projectId).get(),
                builder: (context, projectSnapshot) {
                  if (!projectSnapshot.hasData) {
                    return const ListTile(title: Text("Loading project details..."));
                  }

                  var project = projectSnapshot.data!;
                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      leading: project['imageUrl'] != null
                          ? Image.network(project['imageUrl'], width: 50, height: 50, fit: BoxFit.cover)
                          : const Icon(Icons.image, size: 50),
                      title: Text(project['title']),
                      subtitle: Text("Invested: ₹$amountInvested"),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
