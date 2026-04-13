import 'package:flutter/material.dart';
import 'package:geprekzone/Kasir/Transaksi/Transaksi.dart';
import 'package:geprekzone/Kasir/beranda/Riwayat_page.dart';
import 'package:geprekzone/Kasir/beranda/menu_page.dart';
import 'package:geprekzone/Kasir/kasir_drawer.dart';
import 'package:geprekzone/auth/session.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
    UserSession.cekAkses(context, ['kasir']);
  });
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

      final produkAll = await supabase.from('products').select();

      int jumlahMenu = produkAll.length;

      final produkResponse = await supabase
          .from('products')
          .select()
          .lt('stok', 5)
          .order('stok', ascending: true);

      final mejaResponse = await supabase.from('meja').select('status');

      int totalMejaDb = mejaResponse.length;
      int terisi = mejaResponse
          .where((m) => m['status'].toString().toLowerCase().trim() == 'terisi')
          .length;

if (!mounted) return;

      setState(() {
        totalTransaksi = trxResponse.length;
        totalPendapatan = pendapatan;
        menuTerjual = jumlahMenu;
        stokMenipis = List<Map<String, dynamic>>.from(produkResponse);

        mejaTerisi = terisi;
        totalMeja = totalMejaDb;
      });
    } catch (e) {
      print("Error fetching dashboard: $e");
    }
  }

  String rupiah(num angka) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return format.format(angka);
  }

  Widget infoCard(
    IconData icon,
    String title,
    String total,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
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
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const KasirDrawer(),
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

            const SizedBox(height: 10),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    "Dashboard Kasir",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
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
                      infoCard(
                        Icons.receipt,
                        "Transaksi Hari Ini",
                        "$totalTransaksi",
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RiwayatTransaksiPage(),
                            ),
                          );
                        },
                      ),

                      infoCard(
                        Icons.payment,
                        "Pendapatan Hari Ini",
                        currencyFormatter.format(totalPendapatan),
                        null,
                      ),

                      infoCard(
                        Icons.fastfood,
                        "Jumlah Menu",
                        "$menuTerjual",
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MenuPage()),
                          );
                        },
                      ),

                      infoCard(
                        Icons.table_restaurant,
                        "Meja Terisi",
                        "$mejaTerisi/$totalMeja",
                        null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    "Stok Produk Menipis",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
           
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(15),
    boxShadow: const [
      BoxShadow(color: Colors.black12, blurRadius: 10),
    ],
  ),
  child: stokMenipis.isEmpty
      ? const Padding(
          padding: EdgeInsets.all(20.0),
          child: Text("Semua stok aman"),
        )
      : Column(
          children: stokMenipis.take(5).map((item) {
            final int index = stokMenipis.indexOf(item);
            return Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.warning,
                    color:  Colors.red,
                  ),
                  title: Text(
                    item['nama_produk'] ?? "Tanpa Nama",
                  ),
                  trailing: Text(
                    "Stok: ${item['stok']}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                       color:  Colors.red,
                      // color: (item['stok'] < 3) ? Colors.red : Colors.orange,
                    ),
                  ),
                ),
               
                if (index < stokMenipis.take(5).length - 1)
                  const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
              ],
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
