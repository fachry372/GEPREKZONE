import 'package:flutter/material.dart';
import 'package:geprekzone/Owner/owner_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


void main() {
  runApp(const OwnerPage());
}

class OwnerPage extends StatefulWidget {
  const OwnerPage({super.key});

  @override
  State<OwnerPage> createState() => _OwnerPageState();
}

class _OwnerPageState extends State<OwnerPage> {

  final supabase = Supabase.instance.client;

  int totalTransaksi = 0;
String pendapatan = "Rp 0";
int totalMenu = 0;
int logAktivitas = 0;



  bool isLoading = false;

 Future<void> refreshData() async {
  await getDashboardData();
}

 Future<void> getDashboardData() async {
  setState(() {
    isLoading = true;
  });

  try {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day).toIso8601String();

    final transaksiRes = await supabase
        .from('transactions')
        .select('total_harga')
        .gte('created_at', start);

    double totalPendapatan = 0;
    for (var item in transaksiRes) {
      totalPendapatan += double.tryParse(item['total_harga'].toString()) ?? 0;
    }

    final produkRes = await supabase.from('products').select('id');
    final logRes = await supabase.from('log').select('id');

    setState(() {
      totalTransaksi = transaksiRes.length;
      pendapatan = "Rp ${totalPendapatan.toStringAsFixed(0)}";
      totalMenu = produkRes.length;
      logAktivitas = logRes.length;
    });

    print("OWNER UPDATE BERHASIL");
  } catch (e) {
    print("Error Owner: $e");
  }

  setState(() {
    isLoading = false;
  });
}

@override
void initState() {
  super.initState();
  getDashboardData();
}

  Widget infoCard(
    IconData icon,
    String title,
    String total,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.red, size: 24),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            total,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const OwnerDrawer(),

      body: RefreshIndicator(
        color: Colors.red,
        onRefresh: refreshData,

        child: Column(
          children: [

           AppBar(
              backgroundColor: const Color(0xffe53935),
              centerTitle: true,
              elevation: 0,
              title: const Text(
                "Beranda",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
            ),

            const SizedBox(height: 10),

           
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [

                  const Text(
                    "Dashboard Owner",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  GridView.count(
                    padding: EdgeInsets.only(top: 0),
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.8,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [

                      infoCard(Icons.receipt, "Transaksi Hari Ini", "$totalTransaksi"),
                      infoCard(Icons.payment, "Pendapatan Hari Ini", pendapatan),
                      infoCard(Icons.fastfood, "Total Menu", "$totalMenu"),
                      infoCard(Icons.history, "Log Aktivitas", "$logAktivitas"),

                    ],
                  ),

                  const SizedBox(height: 25),

                
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}