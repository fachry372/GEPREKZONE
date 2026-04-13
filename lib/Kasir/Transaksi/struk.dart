import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geprekzone/Kasir/Transaksi/Transaksi.dart';
import 'package:geprekzone/Kasir/beranda/kasir_home_page.dart';
import 'package:geprekzone/auth/session.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';

class StrukPage extends StatefulWidget {

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

  @override
  State<StrukPage> createState() => _StrukPageState();
}

class _StrukPageState extends State<StrukPage> {

   @override
  void initState() {
    super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    UserSession.cekAkses(context, ['kasir']);
  });
}

  String rupiah(num angka) {
  final format = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  return format.format(angka);
}

Future<pw.Document> _generateDocument() async {
  final pdf = pw.Document();
  final items = widget.produk.where((p) => p["qty"] > 0).toList();

  pdf.addPage(
    pw.Page(
   
      pageFormat: PdfPageFormat.roll80,
      margin: const pw.EdgeInsets.all(10),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
          
            pw.Center(
              child: pw.Text("GEPREKZONE",
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            ),
            pw.Center(child: pw.Text("Jl. Rumah Makan No.10", style: const pw.TextStyle(fontSize: 8))),
            pw.Center(child: pw.Text("Telp : 08123456789", style: const pw.TextStyle(fontSize: 8))),
            pw.SizedBox(height: 8),
            
            pw.Center(
              child: pw.Text("STRUK PEMBELIAN",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
            ),
            
            pw.Divider(borderStyle: pw.BorderStyle.dashed, thickness: 0.5),

            
            pw.Text("Kode : ${widget.kodeTransaksi}", style: const pw.TextStyle(fontSize: 8)),
            pw.Text("Tgl  : ${widget.tanggal}", style: const pw.TextStyle(fontSize: 8)),
            pw.Text("Tipe : ${widget.tipe}", style: const pw.TextStyle(fontSize: 8)),
            // if (widget.meja != "" && widget.meja != "-")
              pw.Text("Meja : ${widget.meja}", style: const pw.TextStyle(fontSize: 8)),
            
            pw.Divider(borderStyle: pw.BorderStyle.dashed, thickness: 0.5),

          
            ...items.map((p) {
              double subtotal = (p["qty"] ?? 0) * (p["harga"] ?? 0);
              return pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 1),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text("${p["nama_produk"]} x${p["qty"]}", 
                          style: const pw.TextStyle(fontSize: 8)),
                    ),
                    pw.Text(rupiah(subtotal), style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
              );
            }),

            pw.Divider(borderStyle: pw.BorderStyle.dashed, thickness: 0.5),
          
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Total", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                pw.Text(rupiah(widget.total), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
              ],
            ),
            pw.SizedBox(height: 2),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Bayar", style: const pw.TextStyle(fontSize: 8)),
                pw.Text(rupiah(widget.bayar), style: const pw.TextStyle(fontSize: 8)),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Kembali", style: const pw.TextStyle(fontSize: 8)),
                pw.Text(rupiah(widget.kembali), style: const pw.TextStyle(fontSize: 8)),
              ],
            ),

            pw.SizedBox(height: 15),
            pw.Center(
              child: pw.Text("Terima Kasih Atas Kunjungan Anda", 
                  style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic)),
            ),
          ],
        );
      },
    ),
  );
  return pdf;
}

  Future<void> printStruk() async {
    final pdf = await _generateDocument();
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Struk_${widget.kodeTransaksi}',
    );
  }

  Future<void> exportPDF(BuildContext context) async {

    PermissionStatus status = await Permission.manageExternalStorage.status;
    if (status.isDenied) status = await Permission.manageExternalStorage.request();
    
    if (status.isGranted) {
      final pdf = await _generateDocument();
      final directory = Directory('/storage/emulated/0/Download/GeprekZone');
      if (!await directory.exists()) await directory.create(recursive: true);

      String tanggalFormat = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final file = File("${directory.path}/STRUK_${tanggalFormat}_${widget.kodeTransaksi}.pdf");

      await file.writeAsBytes(await pdf.save());
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PDF disimpan di Download/GeprekZone"), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    final items = widget.produk.where((p) => p["qty"] > 0).toList();

    return PopScope(
    canPop: false, 
    onPopInvokedWithResult: (didPop, result) {
      if (didPop) return;
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const KasirHomepage()),
        (route) => false,
      );
    },
    child: Scaffold(
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
      body: SingleChildScrollView(
        child: Padding(
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
        
              Text("Kode Transaksi : ${widget.kodeTransaksi}"),
              Text("Tanggal : ${widget.tanggal}"),
              Text("Tipe Pesanan : ${widget.tipe}"),
              Text("Meja : ${widget.meja}"),
        
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
                  Text(rupiah(widget.total),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
        
              const SizedBox(height: 10),
        
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Bayar"),
                  Text(currencyFormatter.format(widget.bayar)),
                ],
              ),
        
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Kembali"),
                  Text(currencyFormatter.format(widget.kembali)),
                ],
              ),
        
              const SizedBox(height: 30),
        
          
        
            ],
          ),
        ),
      ),
   
  bottomNavigationBar: Container(
    padding: const EdgeInsets.all(16),
  
    child: SafeArea(
          child: Row( 
            children: [
              // Expanded(
              //   child: OutlinedButton.icon(
              //     onPressed: () => exportPDF(context),
              //     icon: const Icon(Icons.download),
              //     label: const Text("Simpan PDF"),
              //     style: OutlinedButton.styleFrom(
              //       padding: const EdgeInsets.symmetric(vertical: 14),
              //       side: const BorderSide(color: Colors.red),
              //       foregroundColor: Colors.red,
              //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              //     ),
              //   ),
              // ),
              // const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: printStruk, 
                  icon: const Icon(Icons.print),
                  label: const Text("Cetak"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}