import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:anketproje/Screens/login_page.dart';
import 'package:anketproje/Screens/userviewshare_page.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'profile_page.dart';

class UserViewPage extends StatefulWidget {
  const UserViewPage({Key? key}) : super(key: key);

  @override
  _UserViewPageState createState() => _UserViewPageState();
}

class _UserViewPageState extends State<UserViewPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _thoughts = []; // paylaşılan düşünceleri bir liste çine kayıt edicez

  @override
  void initState() {
    super.initState();
    _fetchThoughts(); // firestore'dan düşünceleri çekmek için
  }

  void _fetchThoughts() async {
    // data read için kod bloğum
    QuerySnapshot querySnapshot = await _firestore
        .collection('thoughts')
        .orderBy('timestamp', descending: true)
        .get();
    setState(() {
      _thoughts =
          querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _navigateToUserViewShare(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserViewSharePage()),
    ).then((_) {
      // Geri dönüldüğünde düşünceleri tekrar yükle
      _fetchThoughts();
    });
  }

  void _navigateToProfile(BuildContext context, String username) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage(username: username)),
    );
  }

  void _navigateToMyProfile(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String username = user.email!.split('@')[0]; // Kullanıcı adını email'den alıyoruz
      _navigateToProfile(context, username);
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime time = timestamp.toDate();
    return timeago.format(time, locale: 'tr'); // Türkçe dil desteği için 'tr' kullanıyoruz
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 128, 255, 132), // AppBar arka plan rengi
        elevation: 0, // AppBar gölge miktarı
        centerTitle: true, // Başlık merkezde mi?
        title: const Text(
          'Chit-ChatForm',
          style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)), // Text rengi beyaz
        ),

      ),
      backgroundColor: Color.fromARGB(255, 55, 132, 64),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _thoughts.length,
              itemBuilder: (context, index) {
                final thought = _thoughts[index];
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Icon(Icons.account_circle, color: Color.fromARGB(255, 126, 175, 166)),
                        const SizedBox(width: 8.0),
                        Text(thought['username'] ?? ''), // 'username' alanını kullan
                        const SizedBox(width: 18.0),
                        Text(
                          _formatTimestamp(thought['timestamp']),
                          style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(thought['thought']),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _navigateToProfile(context, thought['username']),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      elevation: 3,
                      foregroundColor: Colors.white, backgroundColor: Color.fromARGB(255, 188, 194, 186), // Buton üzerindeki yazı rengi
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(48), // Butonun kenar yuvarlama miktarı
                      )
                    ),
                    onPressed: () => _navigateToUserViewShare(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Share View'),
                  ),


                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      elevation: 3,
                      foregroundColor: Colors.white, backgroundColor: Color.fromARGB(255, 29, 141, 1), // Buton üzerindeki yazı rengi
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32), // Butonun kenar yuvarlama miktarı
                      )                    
                    ),
                    onPressed: () => _navigateToMyProfile(context),
                    icon: const Icon(Icons.home),
                    label: const Text('My Profile'),                   
                  ),


                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      elevation: 3,
                      foregroundColor: Colors.white, backgroundColor: Color.fromARGB(255, 90, 0, 38),
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                      )
                    ),
                    onPressed: () => _signOut(context),
                    icon: const Icon(Icons.exit_to_app),
                    label: const Text('Exit'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
