import 'package:flutter/material.dart';
import 'package:geprekzone/Kasir/Aturmeja/atur_meja_page.dart';
import 'package:geprekzone/Kasir/Transaksi/pilihtipe_page.dart';
import 'package:geprekzone/Kasir/beranda/Riwayat_page.dart';
import 'package:geprekzone/Kasir/beranda/kasir_home_page.dart';
import 'package:geprekzone/auth/session.dart';
import '../login_page.dart';

class KasirDrawer extends StatelessWidget {
  const KasirDrawer({super.key});

  @override
  Widget build(BuildContext context) {

    String tampilanNama = UserSession.username ?? "kasir";
    
    return Drawer(
      child: ListView(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xffe51c23), Color(0xffb31217)]),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.red),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    tampilanNama, 
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis, 
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
        builder: (context) => const KasirHomepage(),
      ),
    );
  },
),
          ListTile(
            leading: const Icon(Icons.point_of_sale),
            title: const Text("Transaksi"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PilihTipePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.table_restaurant),
            title: const Text("Atur Meja"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AturMejaPage(tipePesanan: '',)),
              );
            },
          ),
           ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text("Riwayat Transaksi"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RiwayatTransaksiPage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {
              UserSession.hapusSession();
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