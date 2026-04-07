import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class RiwayatTransaksiPage extends StatefulWidget {
  const RiwayatTransaksiPage({super.key});

  @override
  State<RiwayatTransaksiPage> createState() => _RiwayatTransaksiPageState();
}

class _RiwayatTransaksiPageState extends State<RiwayatTransaksiPage> {
  final supabase = Supabase.instance.client;
  List data = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final res = await supabase
        .from('transactions')
        .select()
        .order('created_at', ascending: false);

    setState(() => data = res);
  }

  String rupiah(num angka) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return format.format(angka);
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xfff2f2f2),

    appBar: AppBar(
      backgroundColor: Colors.red,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
      title: const Text(
        "Laporan Transaksi",
        style: TextStyle(color: Colors.white),
      ),
    ),

    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [

          /// FILTER TANGGAL
          Row(
            children: [
              Expanded(
                child: filterButton("Tanggal Awal"),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: filterButton("Tanggal Akhir"),
              ),
            ],
          ),

          const SizedBox(height: 15),

          /// TOTAL PENDAPATAN
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 5)
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Pendapatan",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  rupiah(
                    data.fold(0, (sum, item) => sum + (item['total_harga'] ?? 0)),
                  ),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          /// DROPDOWN TIPE
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonFormField<String>(
              value: "Semua",
              items: const [
                DropdownMenuItem(value: "Semua", child: Text("Semua Tipe Pesanan")),
                DropdownMenuItem(value: "Dine In", child: Text("Dine In")),
                DropdownMenuItem(value: "Take Away", child: Text("Take Away")),
              ],
              onChanged: (value) {},
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 15),

          /// LIST TRANSAKSI
          Expanded(
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, i) {
                var trx = data[i];

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xffd7c3c3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [

                      /// ICON
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.receipt, color: Colors.white),
                      ),

                      const SizedBox(width: 10),

                      /// TEXT
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trx['kode_transaksi'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              trx['created_at'].toString().split(" ").first,
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),

                      /// TOTAL
                      Text(
                        rupiah(trx['total_harga']),
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
}

Widget filterButton(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 14),
    decoration: BoxDecoration(
      color: Colors.red,
      borderRadius: BorderRadius.circular(25),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.calendar_month, color: Colors.white, size: 18),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    ),
  );
}