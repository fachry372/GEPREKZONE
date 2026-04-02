import 'package:flutter/material.dart';
import 'package:geprekzone/Kasir/pilihmeja_page.dart';
import 'Transaksi.dart';

class PilihTipePage extends StatelessWidget {
  const PilihTipePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        backgroundColor: Colors.red,
        centerTitle: true,
        iconTheme: const IconThemeData(
    color: Colors.white, 
  ),
        title: const Text("Pilih Tipe Pesanan",style: TextStyle(color: Colors.white),),
      ),

      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            
            tipeButton(
              context,
              "Dine In",
              Icons.restaurant,
              () {
               Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const PilihMejaPage(
      tipePesanan: "Dine In",
    ),
  ),
);
              },
            ),

            const SizedBox(width: 30),

            /// TAKE AWAY
            tipeButton(
              context,
              "Take Away",
              Icons.takeout_dining,
              () {
               Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const TransaksiPage(
      tipePesanan: "Take Away",
      meja: "-",
    ),
  ),
);
              },
            ),

          ],
        ),
      ),
    );
  }

  Widget tipeButton(
      BuildContext context,
      String text,
      IconData icon,
      Function() onTap,
      ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 8)
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(icon, size: 50, color: Colors.red),

            const SizedBox(height: 10),

            Text(
              text,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold
              ),
            )

          ],
        ),
      ),
    );
  }
}