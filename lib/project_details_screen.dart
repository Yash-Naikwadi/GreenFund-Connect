import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final String projectId;

  const ProjectDetailsScreen({Key? key, required this.projectId}) : super(key: key);

  @override
  _ProjectDetailsScreenState createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  final TextEditingController amountController = TextEditingController();

  void contributeToProject() async {
    double contribution = double.tryParse(amountController.text) ?? 0.0;
    if (contribution <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a valid amount.")),
      );
      return;
    }

    String userId = FirebaseAuth.instance.currentUser?.uid ?? "unknown";
    String userEmail = FirebaseAuth.instance.currentUser?.email ?? "unknown@example.com";

    try {
      DocumentReference projectRef = FirebaseFirestore.instance.collection('projects').doc(widget.projectId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(projectRef);
        if (!snapshot.exists) throw Exception("Project not found!");

        double newAmount = (snapshot['currentAmountRaised'] ?? 0) + contribution;
        transaction.update(projectRef, {'currentAmountRaised': newAmount});
      });

      await FirebaseFirestore.instance.collection('investments').add({
        'projectId': widget.projectId,
        'investorId': userId,
        'investorEmail': userEmail,
        'amount': contribution,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Successfully contributed ₹$contribution!")),
      );

      amountController.clear();
    } catch (e) {
      print("Error contributing to project: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to contribute. Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Project Details")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('projects').doc(widget.projectId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("Project not found!"));
          }

          var projectData = snapshot.data!.data() as Map<String, dynamic>?;

          if (projectData == null) {
            return Center(child: Text("Project data is missing!"));
          }

          String projectOwnerId = projectData['ownerId'] ?? ""; // Fetch owner ID
          String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? ""; // Current user ID
          bool isOwner = projectOwnerId == currentUserId; // Check if the logged-in user is the owner

          double goalAmount = projectData['goalAmount'].toDouble();
          double currentAmountRaised = projectData['currentAmountRaised'].toDouble();
          double progress = (currentAmountRaised / goalAmount).clamp(0.0, 1.0);
          String? imageUrl = projectData['imageUrl'];

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: "project-${widget.projectId}",
                    child: Icon(Icons.lightbulb, color: Colors.green, size: 40),
                  ),
                  SizedBox(height: 10),

                  // Display project image if available, otherwise show a placeholder
                  imageUrl != null && imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            imageUrl,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          height: 200,
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.image, size: 50, color: Colors.grey[600]),
                        ),

                  SizedBox(height: 10),
                  Text(
                    projectData['title'], // Fetch title from Firestore
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(projectData['description']), // Fetch description
                  SizedBox(height: 20),
                  Text("Goal: ₹$goalAmount"),
                  Text("Raised: ₹$currentAmountRaised"),
                  SizedBox(height: 10),
                  LinearProgressIndicator(value: progress),
                  SizedBox(height: 20),

                  // Contribution input & button (Disabled if the user is the owner)
                  if (!isOwner) ...[
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Enter Amount (₹)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: contributeToProject,
                      child: Text("Contribute"),
                    ),
                  ] else ...[
                    Text(
                      "You are the project owner and cannot contribute.",
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
