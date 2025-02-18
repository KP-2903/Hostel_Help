import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'complaint_list_screen.dart';

class StudentDashboard extends StatelessWidget {
  final String userId = "12345"; // Get from Auth (Replace with Firebase UID)

  final List<Map<String, dynamic>> services = [
    {"title": "Wifi", "icon": Icons.wifi},
    {"title": "Carpenter", "icon": Icons.build},
    {"title": "Electrician", "icon": Icons.electrical_services},
    {"title": "Plumber", "icon": Icons.plumbing},
    {"title": "Mess", "icon": Icons.fastfood},
    {"title": "Room Service", "icon": Icons.cleaning_services},
  ];

  void _submitComplaint(String category, BuildContext context) async {
    await FirebaseFirestore.instance.collection('complaints').add({
      'userId': userId,
      'category': category,
      'description': "$category Issue Reported",
      'status': 'Pending',
      'date': DateTime.now().toIso8601String(),
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("$category complaint submitted!"),
      duration: Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard"), actions: [
        IconButton(
          icon: Icon(Icons.logout),
          onPressed: () {}, // Implement logout
        ),
      ]),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome! 😊", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _submitComplaint(services[index]['title'], context),
                    child: Card(
                      color: Colors.orangeAccent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(services[index]['icon'], size: 40, color: Colors.white),
                          SizedBox(height: 10),
                          Text(services[index]['title'], style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context, MaterialPageRoute(builder: (context) => ComplaintListScreen(userId: userId)),
                );
              },
              child: Text("View Complaints"),
            ),
          ],
        ),
      ),
    );
  }
}
