import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  @override
  _RegistryPageState createState() => _RegistryPageState();
}

class _RegistryPageState extends State<SignUpPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController tfEmail = TextEditingController();
  final TextEditingController tfSifre = TextEditingController();
  late String email, sifre;
  final firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Üye Ol'),
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
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: signIn,
                    child: const Text("Üye Ol"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: const Text(
                      "Giriş yapmak için tıklayınız",
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

  void signIn() async {
    bool kontrol = formKey.currentState!.validate();
    if (kontrol) {
      formKey.currentState!.save();
      try {
        var userResult = await firebaseAuth.createUserWithEmailAndPassword(
            email: email, password: sifre);
        print(userResult.user!.uid);
      } catch (e) {
        print(e.toString());
      }
      formKey.currentState!.reset();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Üye olundu.'),
        ),
      );

      Navigator.pop(context);
    }
  }
}
