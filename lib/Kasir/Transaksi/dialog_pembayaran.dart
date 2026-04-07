import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geprekzone/Kasir/Transaksi/struk.dart';

class PembayaranDialog extends StatefulWidget {
  final double total;
  final List<Map<String, dynamic>> produk;
  final String tipePesanan;
  final String meja;
  final Future<void> Function(double bayar) onSimpan;

  const PembayaranDialog({
    super.key,
    required this.total,
    required this.produk,
    required this.tipePesanan,
    required this.meja,
    required this.onSimpan,
  });

  @override
  State<PembayaranDialog> createState() => _PembayaranDialogState();
}

class _PembayaranDialogState extends State<PembayaranDialog> {
  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final bayarController = TextEditingController();
  final kembaliController = TextEditingController();
  double kembalian = 0;

  @override
  Widget build(BuildContext context) {
    final totalController =
        TextEditingController(text: currencyFormatter.format(widget.total));

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: const Text(
        "Pembayaran",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
      content: StatefulBuilder(
        builder: (context, setStateDialog) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Total
              TextFormField(
                controller: totalController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Total",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Nominal Bayar
              TextFormField(
                controller: bayarController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Nominal Bayar",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) {
                  String numericString = value.replaceAll(RegExp(r'[^0-9]'), '');
                  double bayar = double.tryParse(numericString) ?? 0;

                  setStateDialog(() {
                    kembalian = bayar - widget.total;
                    kembaliController.text =
                        kembalian >= 0 ? currencyFormatter.format(kembalian) : "";
                  });

                  bayarController.value = TextEditingValue(
                    text: currencyFormatter.format(bayar),
                    selection: TextSelection.collapsed(
                        offset: currencyFormatter.format(bayar).length),
                  );
                },
              ),
              const SizedBox(height: 15),

              // Kembalian
              TextFormField(
                controller: kembaliController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Kembalian",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () async {
            double bayar = double.tryParse(
                    bayarController.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
                0;
            kembalian = bayar - widget.total;

            if (bayar < widget.total) {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Uang tidak cukup")),
              );
              return;
            }

          
            await widget.onSimpan(bayar);

          
            Navigator.pop(context);

  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Transaksi berhasil!"),
      backgroundColor: Colors.green,
    ),
  );
          
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StrukPage(
                  produk: widget.produk,
                  total: widget.total,
                  bayar: bayar,
                  kembali: kembalian,
                  tipe: widget.tipePesanan,
                  meja: widget.meja,
                  kodeTransaksi: "TRX${DateTime.now().millisecondsSinceEpoch}",
                  tanggal: DateTime.now().toString(),
                ),
              ),
            ).then((value) {
              // bisa panggil resetKeranjang di parent
            });
          },
          child: const Text("Selesai", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}