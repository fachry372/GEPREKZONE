import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

class DetailLaporan extends StatelessWidget {
  final Map trx;
  final List items;

  const DetailLaporan({
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

Future<void> exportPDF(BuildContext context) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text("GEPREKZONE",
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ),
            pw.Center(child: pw.Text("Jl. Rumah Makan No.10")),
            pw.Center(child: pw.Text("Telp : 08123456789")),
            pw.SizedBox(height: 10),

            pw.Center(
              child: pw.Text("STRUK PEMBELIAN",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),

            pw.Divider(),

            pw.Text("Kode Transaksi : ${trx['kode_transaksi']}"),
            pw.Text("Tanggal : ${trx['created_at']}"),
            pw.Text("Tipe Pesanan : ${trx['tipe_pesanan']}"),
            pw.Text("Meja : ${trx['meja'] ?? '-'}"),

            pw.Divider(),

            ...items.map((p) {
              double subtotal = p['jumlah'] * p['harga'];

              return pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                      "${p['products']?['nama_produk'] ?? 'Produk'} x${p['jumlah']}"),
                  pw.Text(rupiah(subtotal)),
                ],
              );
            }),

            pw.Divider(),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Total",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(rupiah(trx['total_harga'])),
              ],
            ),

            pw.SizedBox(height: 10),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Bayar"),
                pw.Text(rupiah(trx['uang_bayar'] ?? 0)),
              ],
            ),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Kembali"),
                pw.Text(rupiah(trx['uang_kembali'] ?? 0)),
              ],
            ),
          ],
        );
      },
    ),
  );

 
  PermissionStatus status = await Permission.manageExternalStorage.status;

  if (status.isDenied) {
    status = await Permission.manageExternalStorage.request();
  }

  if (status.isPermanentlyDenied) {
    await openAppSettings();
    return;
  }

  if (!status.isGranted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Izin storage ditolak")),
    );
    return;
  }



  final directory = Directory('/storage/emulated/0/Download/GeprekZone');

  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }

  String waktu = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

final file = File(
  "${directory.path}/STRUK_${trx['kode_transaksi']}_$waktu.pdf",
);

  await file.writeAsBytes(await pdf.save());

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("PDF disimpan: STRUK_${trx['kode_transaksi']}_$waktu.pdf"),
      backgroundColor: Colors.green,
    ),
  );
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
          "Detail Laporan",
          style: TextStyle(color: Colors.white),
        ),
      ),

     body: Column(
  children: [
    Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
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
              Text("Meja : ${trx['meja'] ?? '-'}"),

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
    ),

    Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => exportPDF(context),
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text("Download PDF"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    ),
  ],
),
    );
  }
}