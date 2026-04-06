import 'package:flutter/material.dart';
import 'package:geprekzone/Kasir/Aturmeja/atur_meja_page.dart';
import 'package:geprekzone/Kasir/Transaksi/pilihtipe_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import '../login_page.dart';

class KasirHomepage extends StatefulWidget {
  const KasirHomepage({super.key});

  @override
  State<KasirHomepage> createState() => _KasirHomepageState();
}

class _KasirHomepageState extends State<KasirHomepage> {
  final supabase = Supabase.instance.client;

  
  int totalTransaksi = 0;
  double totalPendapatan = 0;
  int menuTerjual = 0;
  int mejaTerisi = 0;
  int totalMeja = 0;
  List<Map<String, dynamic>> stokMenipis = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {

    setState(() {
      isLoading = true;
    });
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day).toIso8601String();

   
      final trxResponse = await supabase
          .from('transactions')
          .select('total_harga')
          .gte('created_at', today);
      
   
      double pendapatan = 0;
      for (var item in trxResponse) {
        pendapatan += (item['total_harga'] as num).toDouble();
      }

      final detailResponse = await supabase
          .from('transaksi_detail')
          .select('jumlah');
      
      int terjual = 0;
      for (var item in detailResponse) {
        terjual += (item['jumlah'] as int);
      }

     
      final produkResponse = await supabase
          .from('products')
          .select()
          .lt('stok', 5) 
          .order('stok', ascending: true);

       final mejaResponse = await supabase
        .from('meja')
        .select('status');

    int totalMejaDb = mejaResponse.length;
   int terisi = mejaResponse
    .where((m) =>
        m['status']
            .toString()
            .toLowerCase()
            .trim() == 'terisi')
    .length;


      setState(() {
        totalTransaksi = trxResponse.length;
        totalPendapatan = pendapatan;
        menuTerjual = terjual;
        stokMenipis = List<Map<String, dynamic>>.from(produkResponse);

        mejaTerisi = terisi;
        totalMeja = totalMejaDb;
      });

    } catch (e) {
      print("Error fetching dashboard: $e");

    }
  }

  Widget infoCard(IconData icon, String title, String total) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6)
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.red, size: 24),
          const SizedBox(height: 4),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 2),
          Text(total, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xffe51c23), Color(0xffb31217)]),
              ),
              child: const Row(
                children: [
                  CircleAvatar(radius: 20, backgroundColor: Colors.white, child: Icon(Icons.person, color: Colors.red)),
                  SizedBox(width: 10),
                  Text("Kasir GeprekZone", style: TextStyle(color: Colors.white, fontSize: 16))
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.point_of_sale),
              title: const Text("Transaksi"),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PilihTipePage())),
            ),
             ListTile(
              leading: const Icon(Icons.table_restaurant),
              title: const Text("Atur Meja"),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AturMejaPage(tipePesanan: '',))),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage())),
            ),
          ],
        ),
      ),
      body: RefreshIndicator( 
        onRefresh: fetchDashboardData,
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

const SizedBox(height: 10,),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text("Dashboard Kasir", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
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
                      infoCard(Icons.payment, "Pendapatan", "Rp ${totalPendapatan.toStringAsFixed(0)}"),
                      infoCard(Icons.fastfood, "Menu Terjual", "$menuTerjual"),
                      infoCard(Icons.table_restaurant, "Meja Terisi", "$mejaTerisi/$totalMeja"),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const Text("Stok Produk Menipis", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                    ),
                    child: stokMenipis.isEmpty 
                      ? const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text("Semua stok aman"),
                        )
                      : Column(
                        children: stokMenipis.map((item) {
                          return ListTile(
                            leading: Icon(Icons.warning_amber_rounded, 
                                          color: (item['stok'] < 3) ? Colors.red : Colors.orange),
                            title: Text(item['nama_produk'] ?? "Tanpa Nama"),
                            trailing: Text("Stok: ${item['stok']}", 
                                          style: TextStyle(fontWeight: FontWeight.bold, 
                                          color: (item['stok'] < 3) ? Colors.red : Colors.orange)),
                          );
                        }).toList(),
                      ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}