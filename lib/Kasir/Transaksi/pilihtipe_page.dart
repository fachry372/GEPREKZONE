import 'package:flutter/material.dart';
import 'package:geprekzone/Kasir/Transaksi/pilihmeja_page.dart';
import 'package:geprekzone/Kasir/beranda/kasir_home_page.dart';
import 'package:geprekzone/auth/session.dart';
import 'Transaksi.dart';

class PilihTipePage extends StatefulWidget {
  const PilihTipePage({super.key});

  @override
  State<PilihTipePage> createState() => _PilihTipePageState();
}


class _PilihTipePageState extends State<PilihTipePage> {
  
  @override
  void initState() {
    super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    UserSession.cekAkses(context, ['kasir']);
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
  backgroundColor: Colors.red,
  centerTitle: true,
  iconTheme: const IconThemeData(color: Colors.white),
  title: const Text(
    "Pilih Tipe Pesanan",
    style: TextStyle(color: Colors.white),
  ),
  leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.white),
    onPressed: () {
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const KasirHomepage()),
      );
    },
  ),
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