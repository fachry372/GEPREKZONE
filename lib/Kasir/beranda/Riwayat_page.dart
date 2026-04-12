import 'package:flutter/material.dart';
import 'package:geprekzone/Kasir/beranda/detailtransaksi_page.dart';
import 'package:geprekzone/auth/session.dart';
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

  DateTime? startDate;
  DateTime? endDate;

  String selectedTipe = "Semua";

bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    UserSession.cekAkses(context, ['kasir']);
  });
    getData();
  }

  Future<void> getData() async {
  setState(() {
    isLoading = true;
  });

  try {
    var query = supabase
        .from('transactions')
        .select('''
          *,
          meja (
            nomor_meja
          )
        ''') // Tambahkan join ke tabel meja di sini
        .gte('created_at', startDate?.toIso8601String() ?? '2000-01-01')
        .lte(
          'created_at',
          endDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
        );

    if (selectedTipe != "Semua") {
      query = query.eq('tipe_pesanan', selectedTipe);
    }

    final res = await query.order('created_at', ascending: false);

    setState(() {
      data = res;
    });
  } catch (e) {
    print("Error getData: $e");
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}

  Future<void> pickDate(bool isStart) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });

      getData();
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

      body: RefreshIndicator(
        color: Colors.red,
        onRefresh: () async {
          
  setState(() {
    startDate = null;
    endDate = null;
    selectedTipe = "Semua";
  });

  await getData();
},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: filterButton(
                      startDate == null
                          ? "Tanggal Awal"
                          : DateFormat('yyyy-MM-dd').format(startDate!),
                      () => pickDate(true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: filterButton(
                      endDate == null
                          ? "Tanggal Akhir"
                          : DateFormat('yyyy-MM-dd').format(endDate!),
                      () => pickDate(false),
                    ),
                  ),
                ],
              ),
        
             
              const SizedBox(height: 15),
              
        
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 5),
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
                        data.fold(
                          0,
                          (sum, item) => sum + (item['total_harga'] ?? 0),
                        ),
                      ),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
        
              const SizedBox(height: 15),
        
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonFormField<String>(
                  value: selectedTipe,
                  items: const [
                    DropdownMenuItem(
                      value: "Semua",
                      child: Text("Semua Tipe Pesanan"),
                    ),
                    DropdownMenuItem(value: "Dine In", child: Text("Dine In")),
                    DropdownMenuItem(
                      value: "Take Away",
                      child: Text("Take Away"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedTipe = value!;
                    });
                    getData();
                  },
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
        
              const SizedBox(height: 15),
        
              Expanded(
                child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.red),
                        )
                     : data.isEmpty
    ? ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 200),
          Center(child: Text("Tidak ada data")),
        ],
      )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                 itemCount: data.length,
                 itemBuilder: (context, i) {
                   var trx = data[i];
                
                return GestureDetector(
                 onTap: () async {
                    try {
                      final trxId = trx['id'];
                
                      final detail = await supabase
                          .from('transaksi_detail')
                          .select('''
            jumlah,
            harga,
            subtotal,
            products (
              nama_produk
            )
          ''')
                          .eq('id_transactions', trxId);
                
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailTransaksiPage(
                            trx: trx,
                            items: detail,
                          ),
                        ),
                      );
                    } catch (e) {
                      print(e);
                
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Gagal membuka detail"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                 },
                  child: Container(
                     margin: const EdgeInsets.only(bottom: 10),
                     padding: const EdgeInsets.all(12),
                     decoration: BoxDecoration(
                       color: Colors.white,
                       borderRadius: BorderRadius.circular(12),
                       boxShadow: const [
                         BoxShadow(
                           color: Colors.black12,
                           blurRadius: 5,
                           offset: Offset(0, 2),
                         ),
                       ],
                     ),
                     child: Row(
                       children: [
                         Container(
                           padding: const EdgeInsets.all(10),
                           decoration: BoxDecoration(
                             color: Colors.red,
                             borderRadius: BorderRadius.circular(8),
                           ),
                           child: const Icon(Icons.receipt, color: Colors.white),
                         ),
                
                         const SizedBox(width: 10),
                
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
                                 DateFormat(
                                   'yyyy-MM-dd',
                                 ).format(DateTime.parse(trx['created_at'])),
                                 style: const TextStyle(color: Colors.black54),
                               ),
                
                               const SizedBox(height: 5),
                
                               Container(
                                 padding: const EdgeInsets.symmetric(
                                   horizontal: 10,
                                   vertical: 4,
                                 ),
                                 decoration: BoxDecoration(
                                   color: Colors.red.shade200,
                                   borderRadius: BorderRadius.circular(5),
                                 ),
                                 child: Text(
                                   trx['tipe_pesanan'] ?? '-',
                                   style: const TextStyle(
                                     color: Colors.white,
                                     fontSize: 12,
                                   ),
                                 ),
                               ),
                             ],
                           ),
                         ),
                
                         
                         Text(
                           rupiah(trx['total_harga']),
                           style: const TextStyle(color: Colors.black54),
                         ),
                       ],
                     ),
                  ),
                   );
                 },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget filterButton(String text, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
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
          Text(text, style: const TextStyle(color: Colors.white)),
        ],
      ),
    ),
  );
}
