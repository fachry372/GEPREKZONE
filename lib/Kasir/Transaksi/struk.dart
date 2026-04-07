import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geprekzone/Kasir/Transaksi/Transaksi.dart';
import 'package:geprekzone/Kasir/beranda/kasir_home_page.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

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
  final format = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  return format.format(angka);
}

Future<void> exportPDF(BuildContext context) async {
  final pdf = pw.Document();

  final items = produk.where((p) => p["qty"] > 0).toList();

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
            pw.Text("Kode Transaksi : $kodeTransaksi"),
            pw.Text("Tanggal : $tanggal"),
            pw.Text("Tipe Pesanan : $tipe"),
            pw.Text("Meja : $meja"),
            pw.Divider(),
            ...items.map((p) {
              double subtotal = p["qty"] * p["harga"];
              return pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("${p["nama_produk"]} x${p["qty"]}"),
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
                pw.Text(rupiah(total)),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Bayar"),
                pw.Text(rupiah(bayar)),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Kembali"),
                pw.Text(rupiah(kembali)),
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


  String tanggalFormat = DateTime.now().toString().split(" ").first;

  final file = File(
    "${directory.path}/STRUK_${tanggalFormat}_$kodeTransaksi.pdf",
  );

  await file.writeAsBytes(await pdf.save());

 
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("PDF berhasil disimpan di Download/GeprekZone"),
      backgroundColor: Colors.green,
    ),
  );
}
  
  
  @override
  Widget build(BuildContext context) {

    final items = produk.where((p) => p["qty"] > 0).toList();

    return Scaffold(
    appBar: AppBar(
  backgroundColor: Colors.red,
  centerTitle: true,
  iconTheme: const IconThemeData(color: Colors.white),
  leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const KasirHomepage(),
        ),
        (route) => false, 
      );
    },
  ),
  title: const Text(
    "Preview Struk",
    style: TextStyle(color: Colors.white),
  ),
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
                  Text(currencyFormatter.format(subtotal)),
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
                Text(currencyFormatter.format(bayar)),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Kembali"),
                Text(currencyFormatter.format(kembali)),
              ],
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red),
                onPressed: () {
                  exportPDF(context);
                },
                icon: const Icon(Icons.picture_as_pdf,color: Colors.white,),
                label: const Text("Download PDF",style: TextStyle(color: Colors.white),),
              ),
            ),

          ],
        ),
      ),
    );
  }
}