import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'sign_up.dart';
import '../home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController tfEmail = TextEditingController();
  final TextEditingController tfSifre = TextEditingController();
  late String email, sifre;
  final firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giriş Yap'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person, size: 80),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: tfEmail,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      hintText: "Email",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Email boş olamaz!";
                      }
                      if (!RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(value)) {
                        return "Geçerli bir Email giriniz!";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      email = value!;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: tfSifre,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Şifre",
                      hintText: "Şifre",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Şifre boş olamaz!";
                      }
                      if (value.length < 6) {
                        return "Şifre 6 karakterden az olamaz!";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      sifre = value!;
                    },
                  ),
                  const SizedBox(height: 8.0),
                  ElevatedButton(
                    onPressed: logIn,
                    child: const Text("Giriş Yap"),
                  ),
                  TextButton(
                    onPressed: () {
                      formKey.currentState!.reset();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                      );
                    },
                    child: const Text(
                      "Üye olmak için tıklayınız",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void logIn() async {
    bool kontrol = formKey.currentState!.validate();

    if (kontrol) {
      formKey.currentState!.save();
      try {
        final userResult = await firebaseAuth.signInWithEmailAndPassword(
            email: email, password: sifre);
        formKey.currentState!.reset();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Giriş yapıldı.'),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email veya şifre hatalı.'),
          ),
        );
      }
    }
  }
}
