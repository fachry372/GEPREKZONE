import 'package:flutter/material.dart';
import 'package:geprekzone/auth/session.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UserSession.cekAkses(context, ['kasir']);
    });
  }

  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  final bayarController = TextEditingController();
  final kembaliController = TextEditingController();
  double kembalian = 0;
  String? errorBayar;
  bool isLoading = false;

  InputDecoration inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalController = TextEditingController(
      text: currencyFormatter.format(widget.total),
    );

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      contentPadding: const EdgeInsets.all(20),
      content: StatefulBuilder(
        builder: (context, setStateDialog) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Pembayaran",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: totalController,
                  readOnly: true,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  decoration: inputStyle(
                    "Total",
                  ).copyWith(filled: true, fillColor: Colors.grey[200]),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: bayarController,
                  keyboardType: TextInputType.number,
                  autofocus: true,

                  decoration: inputStyle(
                    "Nominal Bayar",
                  ).copyWith(errorText: errorBayar),
                  onChanged: (value) {
                    String numericString = value.replaceAll(
                      RegExp(r'[^0-9]'),
                      '',
                    );
                    double bayar = double.tryParse(numericString) ?? 0;

                    setStateDialog(() {
                      if (bayar >= widget.total) {
                        errorBayar = null;
                      }

                      kembalian = bayar - widget.total;
                      kembaliController.text = kembalian >= 0
                          ? currencyFormatter.format(kembalian)
                          : "";
                    });

                    bayarController.value = TextEditingValue(
                      text: currencyFormatter.format(bayar),
                      selection: TextSelection.collapsed(
                        offset: currencyFormatter.format(bayar).length,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: kembaliController,
                  readOnly: true,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    // color: kembalian >= 0 ? Colors.green : Colors.red,
                  ),
                  decoration: inputStyle(
                    "Kembalian",
                  ).copyWith(filled: true, fillColor: Colors.grey[200]),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            235,
                            212,
                            214,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Batal",
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                double bayar =
                                    double.tryParse(
                                      bayarController.text.replaceAll(
                                        RegExp(r'[^0-9]'),
                                        '',
                                      ),
                                    ) ??
                                    0;

                                if (bayar < widget.total) {
                                  setStateDialog(() {
                                    errorBayar = "Uang tidak cukup!";
                                  });
                                  return;
                                }
                                setStateDialog(() => isLoading = true);

                                try {
                                  await widget.onSimpan(bayar);

                                  if (!context.mounted) return;
                                  Navigator.pop(context);

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
                                        meja:
                                            (widget.tipePesanan ==
                                                    "Take Away" ||
                                                widget.meja == null)
                                            ? "-"
                                            : widget.meja!,
                                        kodeTransaksi:
                                            "TRX${DateTime.now().millisecondsSinceEpoch}",
                                        tanggal: DateFormat(
                                          'dd/MM/yyyy HH:mm',
                                        ).format(DateTime.now()),
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  setStateDialog(() => isLoading = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Terjadi kesalahan: $e"),
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "Selesai",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
