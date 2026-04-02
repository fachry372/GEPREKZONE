import 'package:flutter/material.dart';

import 'package:geprekzone/Kasir/pilihtipe_page.dart';
import '../login_page.dart';

class KasirHomepage extends StatelessWidget {
  KasirHomepage({super.key});

 Widget infoCard(IconData icon, String title, String total) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6,
        )
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.red, size: 24), // icon lebih kecil
        const SizedBox(height: 4),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12, // font lebih kecil
          ),
        ),
        const SizedBox(height: 2),
        Text(
          total,
          style: const TextStyle(
            fontSize: 14,
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

      /// DRAWER
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
                    child: Icon(Icons.person, color: Colors.red),
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Kasir GeprekZone",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  )
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.point_of_sale),
              title: const Text("Transaksi"),
              onTap: () {

                Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PilihTipePage(),
                          ),
                        );

              },
            ),

            // ListTile(
            //   leading: const Icon(Icons.table_bar),
            //   title: const Text("Atur Meja"),
            //   onTap: () {
            //     Navigator.push(
            //               context,
            //               MaterialPageRoute(
            //                 builder: (context) => AturMejaPage(),
            //               ),);

            //   },
            // ),

            

            const Divider(),

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
              // borderRadius: BorderRadius.only(
              //   bottomLeft: Radius.circular(25),
              //   bottomRight: Radius.circular(25),
              // ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
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
            ),
          ),

          /// CONTENT
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: ListView(
                children: [

                  const Text(
                    "Dashboard Kasir",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  GridView.count(
  shrinkWrap: true,
  crossAxisCount: 2,
  crossAxisSpacing: 10,
  mainAxisSpacing: 10,
  childAspectRatio: 1.8, // membuat card lebih pendek
  physics: const NeverScrollableScrollPhysics(),
  children: [

    infoCard(Icons.receipt, "Transaksi Hari Ini", "18"),
    infoCard(Icons.attach_money, "Pendapatan Hari Ini", "Rp 1.250.000"),
    infoCard(Icons.fastfood, "Menu Terjual", "42"),
    infoCard(Icons.table_bar, "Meja Terisi", "5 / 9"),

  ],
),

                  const SizedBox(height: 25),

                /// STOK PRODUK MENIPIS
const Text(
  "Stok Produk Menipis",
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 10),

Container(
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
    children: const [

      ListTile(
        leading: Icon(
          Icons.warning_amber_rounded,
          color: Colors.red,
        ),
        title: Text("Ayam Geprek"),
        trailing: Text(
          "Stok: 3",
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      Divider(height: 1),

      ListTile(
        leading: Icon(
          Icons.warning_amber_rounded,
          color: Colors.orange,
        ),
        title: Text("Es Teh"),
        trailing: Text(
          "Stok: 2",
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      Divider(height: 1),

      ListTile(
        leading: Icon(
          Icons.warning_amber_rounded,
          color: Colors.orange,
        ),
        title: Text("Ayam Crispy"),
        trailing: Text(
          "Stok: 4",
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
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

        ],
      ),
    );
  }
}