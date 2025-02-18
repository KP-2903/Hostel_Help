import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting

class WardenDashboard extends StatelessWidget {
  void _updateStatus(String complaintId, String newStatus) {
    FirebaseFirestore.instance.collection('complaints').doc(complaintId).update({
      'status': newStatus,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Warden Dashboard")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('complaints').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No complaints found"));
          }

          var complaints = snapshot.data!.docs;
          return ListView.builder(
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              var data = complaints[index].data() as Map<String, dynamic>;
              String complaintId = complaints[index].id;

              // ✅ Handle both String and Timestamp for the 'date' field
              String formattedDate = "N/A";
              if (data['date'] is Timestamp) {
                formattedDate = DateFormat('yyyy-MM-dd').format((data['date'] as Timestamp).toDate());
              } else if (data['date'] is String) {
                formattedDate = data['date']; // Use directly if already a string
              }

              return Card(
                child: ListTile(
                  title: Text(data['category']),
                  subtitle: Text("User: ${data['userId']} \nDate: $formattedDate"),
                  trailing: DropdownButton<String>(
                    value: data['status'],
                    items: ['Pending', 'Resolved'].map((status) {
                      return DropdownMenuItem(value: status, child: Text(status));
                    }).toList(),
                    onChanged: (newStatus) {
                      if (newStatus != null) _updateStatus(complaintId, newStatus);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
