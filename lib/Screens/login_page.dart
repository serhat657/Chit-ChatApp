import 'package:anketproje/Screens/register_page.dart';
import 'package:anketproje/Screens/userview_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LoginForm(),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() async {
    String email = _emailController.text.trim(); // stringin başında veya sonunda bulunan gereksiz boşluk karakterlerini kaldırır 
    String password = _passwordController.text.trim();

    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        print('Logged in as: ${userCredential.user?.email}');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserViewPage()), //sayfa geçişlerini yönetmek için
        );
      } on FirebaseAuthException catch (e) {
        print('Error: $e');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(e.message ?? 'Unknown error occurred.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Please enter both email and password.'),
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

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            hintText: 'Email giriniz',
            prefixIcon: Icon(Icons.email),
          ),
        ),
        const SizedBox(height: 20.0),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(
            hintText: 'Şifre giriniz',
            prefixIcon: Icon(Icons.lock),
          ),
          obscureText: true, // kullanıcının girdiği texti görünmez yapar. giridiği metni * gibi karakterlerle gizler
        ),
        const SizedBox(height: 20.0),
        ElevatedButton(
          onPressed: _login,
          child: const Text('Giriş Yap'),
        ),
        ElevatedButton(
          onPressed: _navigateToRegister,
          child: const Text('Kayıt Ol'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
