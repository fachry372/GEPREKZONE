import 'package:flutter/material.dart';
import 'package:geprekzone/Admin/kelola_meja_page.dart';
import 'package:geprekzone/Admin/kelola_produk_page.dart';
import 'package:geprekzone/Admin/kelola_user_page.dart';
import 'package:geprekzone/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
  fontFamily: 'Roboto',
  scaffoldBackgroundColor: const Color(0xfff5f5f5),
  primaryColor: const Color(0xffe53935),
),
      debugShowCheckedModeBanner: false,
      home: AdminPage(),
    );
  }
}

class AdminPage extends StatelessWidget {
   AdminPage({super.key});

  final List<Map<String, dynamic>> menuList = [
  {"nama": "Ayam Geprek", "stok": 10},
  {"nama": "Ayam Crispy", "stok": 4},
  {"nama": "Es Teh", "stok": 3},
  {"nama": "Nasi", "stok": 20},
  {"nama": "Mie Goreng", "stok": 2},
];

List<Map<String, dynamic>> getMenuMenipis() {
  return menuList.where((menu) => menu["stok"] < 5).toList();
}
  

  Widget infoCard(IconData icon, String title, String total) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.red, size: 30),
          const SizedBox(height: 10),
          Text(title),
          const SizedBox(height: 5),
          Text(
            total,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),

      /// HAMBURGER MENU
      drawer: Drawer(
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
              leading: const Icon(Icons.inventory),
              title: const Text("Kelola Produk"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => KelolaMenuPage()));
              },
            ),

            ListTile(
              leading: const Icon(Icons.people),
              title: const Text("Kelola User"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => KelolaUserPage()));
              },
            ),

            ListTile(
              leading: const Icon(Icons.table_bar),
              title: const Text("Kelola Meja"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => KelolaMejaPage()));
              },
            ),

            const Divider(),

           ListTile(
  leading: const Icon(Icons.logout),
  title: const Text("Logout"),
  onTap: () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>  LoginPage(),
      ),
    );
  },
),
          ],
        ),
      ),

      body: Column(
        children: [

          /// HEADER
          Container(
            padding: const EdgeInsets.fromLTRB(16, 35, 16, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xffe51c23), Color(0xffb31217)],
              ),
              borderRadius: BorderRadius.only(
                // bottomLeft: Radius.circular(25),
                // bottomRight: Radius.circular(25),
              ),
            ),
            child: Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [

    Builder(
      builder: (context) => IconButton(
        icon: const Icon(Icons.menu, color: Colors.white, size: 22),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
    ),

    const Text(
      "GEPREKZONE",
      style: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),

    const CircleAvatar(
      radius: 16,
      backgroundColor: Colors.white,
      child: Icon(Icons.person, color: Colors.red, size: 18),
    ),
  ],
)
          ),

          /// CONTENT
          Expanded(
            child: Padding(
             padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: ListView(
                children: [

                  const Text(
                    "Dashboard Admin",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.2,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [

                      infoCard(Icons.restaurant_menu, "Total Menu", "120"),

                      infoCard(Icons.people, "Total User", "6"),

                      infoCard(Icons.table_bar, "Total Meja", "15"),

                    ],
                  ),
                  const SizedBox(height: 25),

                ],
                
              ),
            ),
          ),

        ],

      ),

      
    );
  }
}