import 'package:flutter/material.dart';

class StrukPage extends StatelessWidget {

  final List produk;
  final double total;
  final double bayar;
  final double kembali;
  final String tipe;
  final String meja;
  final String kodeTransaksi;
  final String tanggal;

  const StrukPage({
    super.key,
    required this.produk,
    required this.total,
    required this.bayar,
    required this.kembali,
    required this.tipe,
    required this.meja,
    required this.kodeTransaksi,
    required this.tanggal,
  });

  String rupiah(num angka) {
    return "Rp ${angka.toStringAsFixed(0)}";
  }

  @override
  Widget build(BuildContext context) {

    final items = produk.where((p) => p["qty"] > 0).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text("Preview Struk"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Center(
              child: Text(
                "GEPREKZONE",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            const Center(child: Text("Jl. Rumah Makan No.10")),
            const Center(child: Text("Telp : 08123456789")),

            const SizedBox(height: 10),

            const Center(
              child: Text("STRUK PEMBELIAN",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),

            const Divider(),

            Text("Kode Transaksi : $kodeTransaksi"),
            Text("Tanggal : $tanggal"),
            Text("Tipe Pesanan : $tipe"),
            Text("Meja : $meja"),

            const Divider(),

            ...items.map((p) {
              double subtotal = p["qty"] * p["harga"];
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${p["nama_produk"]} x${p["qty"]}"),
                  Text(rupiah(subtotal)),
                ],
              );
            }),

            const Divider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(rupiah(total),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Bayar"),
                Text(rupiah(bayar)),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Kembali"),
                Text(rupiah(kembali)),
              ],
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red),
                onPressed: () {},
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text("Download PDF"),
              ),
            ),

          ],
        ),
      ),
    );
  }
}