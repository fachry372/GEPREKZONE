import 'package:flutter/material.dart';
import 'package:geprekzone/Admin/Users/kelola_user_page.dart';
import 'login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://sjxobgspztbrmspesbsc.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNqeG9iZ3NwenRicm1zcGVzYnNjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMwNzQ2MjUsImV4cCI6MjA4ODY1MDYyNX0.52GydkLoINjVlR7_lcFJJLimgvrrXIHRiJVMwe1uOlc',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lontar POS',
      theme: ThemeData(
        primaryColor: Colors.red,
      ),
      home: LoginPage(),
    );
  }
}