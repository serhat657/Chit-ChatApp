import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;

class ProfilePage extends StatelessWidget {
  final String username;

  const ProfilePage({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 128, 255, 132), // AppBar arka plan rengi
        elevation: 0, // AppBar gölge miktarı
        centerTitle: true, // Başlık merkezde mi?
        title: Text(
          '$username\'s Profile',
          style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),         
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('thoughts')
            .where('username', isEqualTo: username)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No thoughts found.'));
          }

          final thoughts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: thoughts.length,
            itemBuilder: (context, index) {
              final thought = thoughts[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text(thought['thought']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Posted on: ${_formatTimestamp(thought['timestamp'])}',
                        style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime time = timestamp.toDate();
    return timeago.format(time, locale: 'tr'); // Türkçe dil desteği için 'tr' kullanıyoruz
  }
}
