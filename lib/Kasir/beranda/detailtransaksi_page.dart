import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailTransaksiPage extends StatelessWidget {
  final Map trx;
  final List items;

  const DetailTransaksiPage({
    super.key,
    required this.trx,
    required this.items,
  });

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
          "Detail Transaksi",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child:  Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Center(
                child: Text(
                  "GEPREKZONE",
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const Center(child: Text("Jl. Rumah Makan No.10")),
              const Center(child: Text("Telp : 08123456789")),

              const SizedBox(height: 10),

              const Center(
                child: Text(
                  "STRUK PEMBELIAN",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              const Divider(),

             
              Text("Kode Transaksi : ${trx['kode_transaksi']}"),
              Text(
                "Tanggal : ${DateFormat('yyyy-MM-dd').format(DateTime.parse(trx['created_at']))}",
              ),
              Text("Tipe Pesanan : ${trx['tipe_pesanan']}"),
              Text("Meja : ${trx['meja']?['nomor_meja'] ?? '-'}"),

              const Divider(),

              
            ...items.map((p) {
  double subtotal = p['jumlah'] * p['harga'];

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      
      Text(
        "${p['products']?['nama_produk'] ?? 'Produk'} x${p['jumlah']}",
      ),

     
      Text(rupiah(subtotal)),
    ],
  );
}),

              const Divider(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    rupiah(trx['total_harga']),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Bayar"),
                  Text(rupiah(trx['uang_bayar'] ?? 0)),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Kembali"),
                  Text(rupiah(trx['uang_kembali'] ?? 0)),
                ],
              ),
            ],
          ),
        ),
      
    );
  }
}