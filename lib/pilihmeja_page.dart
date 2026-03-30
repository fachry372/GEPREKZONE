import 'package:flutter/material.dart';
import 'kasir_page.dart';

class PilihMejaPage extends StatelessWidget {

  final String tipePesanan;

  const PilihMejaPage({
    super.key,
    required this.tipePesanan,
  });

  final List meja = const [
    {"nama": "Meja 1", "status": "kosong"},
    {"nama": "Meja 2", "status": "terisi"},
    {"nama": "Meja 3", "status": "kosong"},
    {"nama": "Meja 4", "status": "terisi"},
    {"nama": "Meja 5", "status": "kosong"},
    {"nama": "Meja 6", "status": "kosong"},
    {"nama": "Meja 7", "status": "terisi"},
    {"nama": "Meja 8", "status": "kosong"},
    {"nama": "Meja 9", "status": "kosong"},
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text("Pilih Meja"),
      ),

      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
        ),
        itemCount: meja.length,
        itemBuilder: (context, index) {

          var item = meja[index];
          bool terisi = item["status"] == "terisi";

          return InkWell(

            onTap: terisi ? null : () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => KasirPage(
                    tipePesanan: tipePesanan,
                    meja: item["nama"],
                  ),
                ),
              );

            },

            child: Container(
              decoration: BoxDecoration(
                color: terisi ? Colors.red : Colors.green,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 5)
                ],
              ),

              child: Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [

    const Icon(
      Icons.table_restaurant_rounded,
      color: Colors.white,
      size: 40,
    ),

    const SizedBox(height: 5),

    Text(
      item["nama"],
      style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.white
      ),
    ),

    Text(
      terisi ? "Terisi" : "Kosong",
      style: const TextStyle(color: Colors.white70),
    ),

  ],
)
            ),
          );
        },
      ),
    );
  }
}