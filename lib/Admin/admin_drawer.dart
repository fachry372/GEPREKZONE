import 'package:flutter/material.dart';
import 'package:geprekzone/Admin/admin_page.dart';
import 'package:geprekzone/Admin/Meja/kelola_meja_page.dart';
import 'package:geprekzone/Admin/Menu/kelola_produk_page.dart';
import 'package:geprekzone/Admin/Users/kelola_user_page.dart';
import 'package:geprekzone/login_page.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          /// HEADER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xffe51c23), Color(0xffb31217)],
              ),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.red, size: 20),
                ),
                SizedBox(width: 10),
                Text(
                  "Admin GeprekZone",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),
          ),

          ListTile(
  leading: const Icon(Icons.home),
  title: const Text("Beranda"),
  onTap: () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminPage(),
      ),
    );
  },
),

          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text("Kelola Produk"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const KelolaMenuPage()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.people),
            title: const Text("Kelola User"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const KelolaUserPage()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.table_bar),
            title: const Text("Kelola Meja"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const KelolaMejaPage()),
              );
            },
          ),

          const Divider(),

          /// LOGOUT
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}