import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserViewSharePage extends StatelessWidget {
  const UserViewSharePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Color.fromARGB(255, 128, 255, 132), // AppBar arka plan rengi
        elevation: 0, // AppBar gölge miktarı
        centerTitle: true, // Başlık merkezde mi?
        title: const Text(
          'Share Your View',
          style: TextStyle(
              color: Color.fromARGB(255, 0, 0, 0)), // Text rengi beyaz
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ShareThoughtForm(),
        ),
      ),
    );
  }
}

class ShareThoughtForm extends StatefulWidget {
  const ShareThoughtForm({Key? key}) : super(key: key);

  @override
  _ShareThoughtFormState createState() => _ShareThoughtFormState();
}

class _ShareThoughtFormState extends State<ShareThoughtForm> {
  final TextEditingController _thoughtController = TextEditingController();

  void _shareThought(BuildContext context) async {
    String thought = _thoughtController.text.trim();
    String email = FirebaseAuth.instance.currentUser!.email!;

    // Fetch username from Firestore
    String username = '';
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      username = userDoc['username'];
    } catch (e) {
      print('Error fetching username: $e');
    }

    // Add data to Firestore
    try {
      await FirebaseFirestore.instance.collection('thoughts').add({
        'email': email,
        'username': username,
        'thought': thought,
        'timestamp': Timestamp.now(),
      });
      print('Shared thought: $thought');
      Navigator.pop(context); // Close share thought form
    } catch (e) {
      print('Error sharing thought: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('An error occurred while sharing your thought.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _thoughtController,
              decoration: const InputDecoration(
                hintText: 'Share your thought',
                prefixIcon: Icon(Icons.comment),
                border: InputBorder.none,
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 20.0),
            ElevatedButton.icon(
              onPressed: () => _shareThought(context),
              icon: const Icon(Icons.share_outlined),
              label: const Text('Share'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _thoughtController.dispose();
    super.dispose();
  }
}

// ctrl k + c tüm kodu yorum satırına ekleriz 