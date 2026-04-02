import 'package:flutter/material.dart';
import 'package:geprekzone/Kasir/struk.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geprekzone/auth/session.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TransaksiPage(tipePesanan: '', meja: '',),
    );
  }
}

class TransaksiPage extends StatefulWidget {
  final String tipePesanan;
  final String meja;

  const TransaksiPage({
    super.key,
    required this.tipePesanan,
    required this.meja,
  });

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {

  String kategori = "Semua";

  final TextEditingController bayarController = TextEditingController();

  double kembalian = 0;

 
  String waktu = DateTime.now().toString();

 final supabase = Supabase.instance.client;

List<Map<String, dynamic>> produk = [];

Future<void> getProduk() async {
  final response = await supabase
      .from('products')
      .select()
      .order('id', ascending: true);

  setState(() {
    produk = response.map<Map<String, dynamic>>((p) {
      return {
        ...p,
        "qty": 0, 
        "stok": p["stok"] ?? 0,
      };
    }).toList();
  });
}

@override
void initState() {
  super.initState();
  getProduk();
}

Future<void> simpanTransaksi(double bayar) async  {
  final items = produk.where((p) => p["qty"] > 0).toList();

  if (items.isEmpty) return;

  final kode = "TRX${DateTime.now().millisecondsSinceEpoch}";



final userId = UserSession.userId;
if (userId == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("User belum login!")),
  );
  return;
}

final trx = await supabase.from('transactions').insert({
  "kode_transaksi": kode,
  "id_users": userId, // pakai user login custom
  "id_meja": int.tryParse(widget.meja),
  "total_harga": total,
  "uang_bayar": bayar,
  "uang_kembali": bayar - total,
}).select().single();

  int transaksiId = trx["id"];

  
  for (var item in items) {
    await supabase.from('transaksi_detail').insert({
      "id_transactions": transaksiId,
      "id_products": item["id"],
      "harga": item["harga"],
      "jumlah": item["qty"],
      "subtotal": item["qty"] * item["harga"],
    });

    
    await supabase.from('products').update({
      "stok": item["stok"]
    }).eq('id', item["id"]);
  }

  
}


  double get total {
  double t = 0;
  for (var p in produk) {
    t += (p["qty"] as int) * (p["harga"] as num);
  }
  return t;
}

  List get produkFilter {
    if (kategori == "Semua") return produk;
    return produk.where((p) => p["kategori"] == kategori).toList();
  }

  void resetKeranjang() {
    setState(() {
      for (var p in produk) {
        p["qty"] = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.red,
        centerTitle: true,
        iconTheme: const IconThemeData(
    color: Colors.white, 
  ),
        title: const Text("Kasir GeprekZone",style: TextStyle(color: Colors.white),),
      ),

      body: Column(
        children: [

         
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Tipe : ${widget.tipePesanan}"),
Text("Meja : ${widget.meja}"),
              ],
            ),
          ),

          
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                filterButton("Semua"),
                filterButton("Makanan"),
                filterButton("Minuman"),
              ],
            ),
          ),

          
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemCount: produkFilter.length,
              itemBuilder: (context, index) {

                var item = produkFilter[index];

                return Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Expanded(
                        child: item["image"] != null
    ? Image.network(
        item["image"],
        width: double.infinity,
        fit: BoxFit.cover,
      )
    : Container(
        color: Colors.grey[300],
        child: const Icon(Icons.fastfood),
      )
                      ),

                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              item["nama_produk"],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),

                           Text("Rp ${(item["harga"] as num).toDouble().toStringAsFixed(2)}"),

                           Text("Stok : ${item["stok"] ?? 0}"),

                            const SizedBox(height: 5),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red
                                ),
                              onPressed: () {
  setState(() {
    if ((item["stok"] ?? 0) > 0) {
      item["qty"]++;
      item["stok"]--;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Stok habis")),
      );
    }
  });
},
                                child: const Text("+ Keranjang",style: TextStyle(color: Colors.white),),
                              ),
                            )

                          ],
                        ),
                      )

                    ],
                  ),
                );
              },
            ),
          ),

          
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    const Text(
                      "Keranjang",
                      style: TextStyle(
                          fontSize:18,
                          fontWeight: FontWeight.bold),
                    ),

                    TextButton(
                        onPressed: (){
                          setState(() {
                            for (var p in produk) {
                              p["stok"] += p["qty"];
                              p["qty"] = 0;
                            }
                          });
                        },
                        child: const Text("Hapus Semua",style: TextStyle(color: Colors.red),)
                    )

                  ],
                ),

                const Divider(),

                ...produk.where((p) => p["qty"] > 0).map((p) {

                  double subtotal = p["qty"] * p["harga"];

                  return Column(
                    children: [

                      Row(
                        children: [

                          Expanded(
                            child: Text(
                              p["nama_produk"],
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600),
                            ),
                          ),

                          IconButton(
  icon: const Icon(Icons.remove),
  onPressed: () {
    setState(() {
      if (p["qty"] > 0) {
        p["qty"]--;
        p["stok"]++;
      }
    });
  },
),

Text("${p["qty"]}x"),

IconButton(
  icon: const Icon(Icons.add), // 🔥 tombol plus
  onPressed: () {
    setState(() {
      if ((p["stok"] ?? 0) > 0) {
        p["qty"]++;
        p["stok"]--;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Stok habis")),
        );
      }
    });
  },
),

const SizedBox(width:10),

Text("Rp ${subtotal.toStringAsFixed(2)}"),

                          IconButton(
                            icon: const Icon(Icons.delete,color: Colors.red),
                            onPressed: () {
                              setState(() {
                                p["stok"] += p["qty"];
                                p["qty"] = 0;
                              });
                            },
                          ),

                        ],
                      ),

                      const Divider()

                    ],
                  );

                }),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize:16),
                    ),
                    Text(
  "Rp ${total.toStringAsFixed(2)}",
  style: const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16),
),
                  ],
                ),

                const SizedBox(height:10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red
                    ),
                    onPressed: () {

                      if(total == 0){
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Keranjang masih kosong"),
                          ),
                        );
                        return;
                      }

                      showDialog(
                        context: context,
                        builder: (context) => dialogPembayaran(),
                      );
                    },
                    child: const Text("BAYAR",style: TextStyle(color: Colors.white),),
                  ),
                )

              ],
            ),
          )

        ],
      ),
    );
  }

  Widget filterButton(String nama) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: kategori == nama ? Colors.red : Colors.grey,
            foregroundColor: Colors.white,
        ),
        onPressed: () {
          setState(() {
            kategori = nama;
          });
        },
        child: Text(nama),
      ),
    );
  }

 Widget dialogPembayaran() {
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

        final totalController = TextEditingController(
          text: total.toStringAsFixed(2),
        );

        final kembaliController = TextEditingController(
          text: kembalian >= 0
              ? kembalian.toStringAsFixed(2)
              : "",
        );

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            /// TOTAL (READ ONLY)
            TextFormField(
              controller: totalController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Total",
                prefixText: "Rp ",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// NOMINAL BAYAR
            TextFormField(
              controller: bayarController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Nominal Bayar",
                prefixText: "Rp ",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                double bayar = double.tryParse(value) ?? 0;

                setStateDialog(() {
                  kembalian = bayar - total;

                  kembaliController.text =
                      kembalian >= 0
                          ? kembalian.toStringAsFixed(2)
                          : "";
                });
              },
            ),

            const SizedBox(height: 15),

            /// KEMBALIAN (READ ONLY & MUNCUL JIKA >= 0)
            TextFormField(
              controller: kembaliController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Kembalian",
                prefixText: "Rp ",
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
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text("Batal"),
      ),

      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
        ),
       onPressed: () async {
  double bayar = double.tryParse(bayarController.text) ?? 0;
  kembalian = bayar - total;

  if (bayar < total) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Uang tidak cukup"),
      ),
    );
    return;
  }

  /// 🔥 SIMPAN KE DATABASE DULU
  await simpanTransaksi(bayar);

  Navigator.pop(context);
  Navigator.pop(context);

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => StrukPage(
        produk: produk,
        total: total,
        bayar: bayar,
        kembali: kembalian,
        tipe: widget.tipePesanan,
        meja: widget.meja,
        kodeTransaksi: "TRX${DateTime.now().millisecondsSinceEpoch}",
        tanggal: DateTime.now().toString(),
      ),
    ),
  ).then((value) {
    if (value == true) {
      resetKeranjang();
    }
  });
},
        child: const Text("Selesai",
            style: TextStyle(color: Colors.white)),
      ),
    ],
  );
}

}