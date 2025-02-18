import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintListScreen extends StatelessWidget {
  final String userId;
  ComplaintListScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Complaints")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('complaints')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Center(child: Text("No complaints found"));

          var complaints = snapshot.data!.docs;
          return ListView.builder(
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              var data = complaints[index].data() as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  title: Text(data['category']),
                  subtitle: Text("Date: ${data['date'].substring(0, 10)}"),
                  trailing: Text(data['status'], style: TextStyle(color: data['status'] == 'Pending' ? Colors.red : Colors.green)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
