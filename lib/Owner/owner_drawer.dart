import 'package:flutter/material.dart';
import 'package:geprekzone/Owner/berandaowner.dart';
import 'package:geprekzone/Owner/data%20menu/daftar_menu.dart';
import 'package:geprekzone/Owner/laporan%20transaksi/laporan_page.dart';
import 'package:geprekzone/Owner/log/Log_page.dart';
import 'package:geprekzone/login_page.dart';

class OwnerDrawer extends StatelessWidget {
  const OwnerDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [

      
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xffe51c23), Color(0xffb31217)],
              ),
            ),
            child: Row(
              children: const [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.red, size: 20),
                ),
                SizedBox(width: 10),
                Text(
                  "Owner GeprekZone",
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
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => OwnerPage()));
            },
          ),

          ListTile(
            leading: const Icon(Icons.restaurant_menu),
            title: const Text("Data Menu"),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => DaftarMenu()));
            },
          ),

          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text("Laporan Transaksi"),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => LaporanPage()));
            },
          ),

          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("Log Aktivitas"),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => LogPage()));
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}