import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:anketproje/Screens/login_page.dart';
import 'package:anketproje/Screens/userview_page.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(), //uygulama başlatıldığında gösterilcek ilk widget
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) { // eğer anlık durum bekleme durumundaysa
          return const Center(child: CircularProgressIndicator());  
        } else if (snapshot.hasData) { //kullanıcı oturum açmışsa 
          return const UserViewPage();
        } else { // kullanıcı oturum açmamışsa
          return const LoginPage();
        }
      },
    );
  }
}

/* authentication yapar ve duruma göre login page veya userview page ekranlarına geçiş yapar */