import 'package:flutter/material.dart';
import 'package:geprekzone/Owner/berandaowner.dart';
import 'package:geprekzone/auth/session.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geprekzone/Admin/admin_page.dart';
import 'package:geprekzone/Kasir/kasir_home_page.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();

  bool isLoading = false;

 Future<void> login() async {
  if (username.text.isEmpty || password.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Username & Password tidak boleh kosong")),
    );
    return;
  }

  setState(() => isLoading = true);

  try {
    final supabase = Supabase.instance.client;

    final res = await supabase.rpc('login_user', params: {
      'p_username': username.text.trim(),
      'p_password': password.text,
    });

   

    if (res.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Username atau password salah")),
  );
  setState(() => isLoading = false);
  return;
}

final user = res[0];

if (user['status'] != 'aktif') {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("User tidak aktif")),
  );
  setState(() => isLoading = false);
  return;
}


UserSession.fromJson(user);

String role = user['role'];
Widget page;
switch (role) {
  case 'admin':
    page = AdminPage();
    break;
  case 'kasir':
    page = KasirHomepage();
    break;
  case 'owner':
    page = OwnerPage();
    break;
  default:
    throw Exception("Role tidak dikenali");
}

Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (_) => page),
);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }

  setState(() => isLoading = false);
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffb31217), Color(0xffe52d27)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SingleChildScrollView(
          child: Column(
            children: [

              const SizedBox(height: 120),

              Image.asset(
                "assets/logo.png",
                height: 120,
              ),

              const SizedBox(height: 15),

              const Text(
                "LOGIN",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 5),

              Container(
                width: 80,
                height: 3,
                color: Colors.white,
              ),

              const SizedBox(height: 30),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 25),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Column(
                  children: [

                    TextField(
                      controller: username,
                      decoration: InputDecoration(
                        hintText: "Username",
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: password,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Password",
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "Masuk",
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}