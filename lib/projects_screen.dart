import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'project_details_screen.dart';

class ProjectsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Browse Projects")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('projects')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          var projects = snapshot.data!.docs;
          print(projects);

          return ListView.builder(
            itemCount: projects.length,
            itemBuilder: (context, index) {
              var project = projects[index];  // Firestore document snapshot

              // Convert document data to a Map<String, dynamic>
              Map<String, dynamic> projectData = project.data() as Map<String, dynamic>;

              print(projectData);  // Debugging: See full project data
              print(projectData['currentAmountRaised']); // Debugging: See amount raised

              double progress = (projectData['currentAmountRaised'] / projectData['goalAmount']).clamp(0.0, 1.0);

              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text(projectData['title']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Goal: ₹${projectData['goalAmount']} | Raised: ₹${projectData['currentAmountRaised']}"),
                      SizedBox(height: 5),
                      LinearProgressIndicator(value: progress),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProjectDetailsScreen(
                            projectId: project.id, // Pass only the project ID
                          ),
                        ),
                      );
                    },
                    child: Text("View"),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null, // Disables Hero animation
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          Navigator.pushNamed(context, '/add_project');
        },
        child: const Icon(Icons.add),
        tooltip: 'Add new project',
      ),
    );
  }
}
