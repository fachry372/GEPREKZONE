import 'package:flutter/material.dart';
import 'package:geprekzone/Kasir/Transaksi/dialog_pembayaran.dart';
import 'package:intl/intl.dart';
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

final currencyFormatter = NumberFormat.currency(
  locale: 'id_ID',   
  symbol: 'Rp ',     
  decimalDigits: 0,   
);

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

      for (var p in produk) {
  p["controller"] = TextEditingController(text: p["qty"].toString());
}

  setState(() {
    produk = response.map<Map<String, dynamic>>((p) {
      return {
        ...p,
        "qty": 0, 
        "stok": p["stok"] ?? 0,
         "controller": TextEditingController(text: "0"),
      };
    }).toList();
  });
}


@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    UserSession.cekAkses(context, ['kasir']);
  });
  getProduk();
}

Future<void> simpanTransaksi(double bayar) async  {
  final items = produk.where((p) => p["qty"] > 0).toList();

  if (items.isEmpty) return;

  final kode = "TRX${DateTime.now().millisecondsSinceEpoch}";



final userId = UserSession.userId;
if (userId == null) {
  ScaffoldMessenger.of(context).clearSnackBars(); 
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("User belum login!")),
  );
  return;
}

final trx = await supabase.from('transactions').insert({
  "kode_transaksi": kode,
  "id_users": userId, 
  "id_meja": int.tryParse(widget.meja),
  "total_harga": total,
  "uang_bayar": bayar,
  "uang_kembali": bayar - total,
  "tipe_pesanan": widget.tipePesanan,
}).select().single();

final mejaId = int.tryParse(widget.meja);

if (mejaId != null) {
  await supabase
      .from('meja')
      .update({"status": "terisi"})
      .eq('id', mejaId);
}


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

  final currencyFormatter = NumberFormat.currency(
  locale: 'id_ID', 
  symbol: 'Rp ', 
  decimalDigits: 0, 
);

bool get isKeranjangValid {
  final itemsInCart = produk.where((p) => (p["qty"] ?? 0) > 0);
  if (itemsInCart.isEmpty) return false;

  for (var p in itemsInCart) {
    if ((p["isOverStock"] ?? false) == true) {
      return false; // disable tombol kalau ada yg melebihi stok
    }
  }

  return true;
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

                          Text(currencyFormatter.format(item["harga"])),

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
      item["controller"].text = item["qty"].toString();
    } else {
      ScaffoldMessenger.of(context).clearSnackBars(); 
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
                                  p["isOverStock"] = false; 
    p["controller"].text = "0";
                            }
                          });
                        },
                        child: const Text("Hapus Semua",style: TextStyle(color: Colors.red),)
                    )

                  ],
                ),

                const Divider(),

                ...produk.where((p) => p["qty"] > 0).map((p) {

  // pastikan setiap item punya controller
  p["controller"] ??= TextEditingController(text: p["qty"].toString());

  double subtotal = p["qty"] * p["harga"];

  return Column(
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              p["nama_produk"],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),

          Row(
            children: [
            
              IconButton(
                icon: const Icon(Icons.remove),
               onPressed: () {
  setState(() {
    if (p["qty"] > 0) {
      p["qty"]--;
      p["stok"]++;
      p["isOverStock"] = false;
      p["controller"].text = p["qty"].toString();
    }
  });
},
              ),

             
          SizedBox(
  width: 50,
  child: TextFormField(
    controller: p["controller"],
    keyboardType: TextInputType.number,
    textAlign: TextAlign.center,
    decoration: const InputDecoration(
      border: OutlineInputBorder(),
      isDense: true,
      contentPadding: EdgeInsets.symmetric(vertical: 8),
    ),
onChanged: (value) {
  if (value.isEmpty) return;

  int? inputQty = int.tryParse(value);
  if (inputQty == null) return;

  int maxQty = (p["stok"] ?? 0) + (p["qty"] ?? 0);

  setState(() {
   if (inputQty > maxQty) {
  p["qty"] = maxQty;
  p["stok"] = 0;
  p["isOverStock"] = false; 

  p["controller"].text = maxQty.toString();
  p["controller"].selection = TextSelection.fromPosition(
    TextPosition(offset: p["controller"].text.length),
  );

  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Maksimal stok: $maxQty")),
  );
}else {
      p["qty"] = inputQty;
      p["stok"] = maxQty - inputQty;
      p["isOverStock"] = false;
    }
  });
},
  ),
),

              
              IconButton(
                icon: const Icon(Icons.add),
              onPressed: () {
  setState(() {
    if ((p["stok"] ?? 0) > 0) {
      p["qty"]++;
      p["stok"]--;
      p["isOverStock"] = false;
      p["controller"].text = p["qty"].toString();
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Stok habis")),
      );
    }
  });
},
              ),
            ],
          ),

          const SizedBox(width: 10),
          Text(currencyFormatter.format(subtotal)),

          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              setState(() {
                p["stok"] += p["qty"];
                p["qty"] = 0;
                p["isOverStock"] = false;
                p["controller"].text = "0";
              });
            },
          ),
        ],
      ),
      const Divider(),
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
                    Text(currencyFormatter.format(total),
  style: const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16),
),
                  ],
                  
                ),

if (!isKeranjangValid)

                const SizedBox(height:10),

                SizedBox(
  width: double.infinity,
  child:ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: isKeranjangValid ? Colors.red : Colors.grey,
  ),
  onPressed: isKeranjangValid
      ? () {
          showDialog(
            context: context,
            builder: (context) => PembayaranDialog(
              total: total,
              produk: produk,
              tipePesanan: widget.tipePesanan,
              meja: widget.meja,
              onSimpan: simpanTransaksi,
            ),
          );
        }
      : null, 
  child: const Text("BAYAR", style: TextStyle(color: Colors.white)),
),
),

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

}