import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: KasirPage(tipePesanan: '', meja: '',),
    );
  }
}

class KasirPage extends StatefulWidget {
  final String tipePesanan;
  final String meja;

  const KasirPage({
    super.key,
    required this.tipePesanan,
    required this.meja,
  });

  @override
  State<KasirPage> createState() => _KasirPageState();
}

class _KasirPageState extends State<KasirPage> {

  String kategori = "Semua";

  final TextEditingController bayarController = TextEditingController();

  int kembalian = 0;

 
  String waktu = DateTime.now().toString();

  List produk = [
    {
      "nama": "Ayam Geprek",
      "harga": 15000,
      "kategori": "Makanan",
      "stok": 10,
      "gambar": "assets/ayam.jpg",
      "qty": 0
    },
    {
      "nama": "Nasi",
      "harga": 5000,
      "kategori": "Makanan",
      "stok": 20,
      "gambar": "assets/nasi.jpg",
      "qty": 0
    },
    {
      "nama": "Es Teh",
      "harga": 5000,
      "kategori": "Minuman",
      "stok": 15,
      "gambar": "assets/esteh.jpg",
      "qty": 0
    },
    {
      "nama": "Es Jeruk",
      "harga": 7000,
      "kategori": "Minuman",
      "stok": 8,
      "gambar": "assets/jeruk.jpg",
      "qty": 0
    },
  ];

  int get total {
    int t = 0;
    for (var p in produk) {
      t += (p["qty"] as int) * (p["harga"] as int);
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
        title: const Text("Kasir GeprekZone"),
      ),

      body: Column(
        children: [

          /// INFO TRANSAKSI
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

          /// FILTER
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

          /// PRODUK
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
                        child: Image.asset(
                          item["gambar"],
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              item["nama"],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),

                            Text("Rp ${item["harga"]}"),

                            Text("Stok : ${item["stok"]}"),

                            const SizedBox(height: 5),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red
                                ),
                                onPressed: () {

                                  setState(() {

                                    if (item["stok"] > 0) {
                                      item["qty"]++;
                                      item["stok"]--;
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Stok habis"),
                                        ),
                                      );
                                    }

                                  });

                                },
                                child: const Text("+ Keranjang"),
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

          /// KERANJANG
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
                        child: const Text("Clear")
                    )

                  ],
                ),

                const Divider(),

                ...produk.where((p) => p["qty"] > 0).map((p) {

                  int subtotal = p["qty"] * p["harga"];

                  return Column(
                    children: [

                      Row(
                        children: [

                          Expanded(
                            child: Text(
                              p["nama"],
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

                          const SizedBox(width:10),

                          Text("Rp $subtotal"),

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
                      "Rp $total",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize:16),
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
                    child: const Text("BAYAR"),
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
            backgroundColor: kategori == nama ? Colors.red : Colors.grey
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

      title: const Text("Pembayaran"),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total"),
              Text("Rp $total"),
            ],
          ),

          const SizedBox(height:15),

          TextField(
            controller: bayarController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                labelText: "Nominal Bayar",
                border: OutlineInputBorder()
            ),
            onChanged: (value) {

              int bayar = int.tryParse(value) ?? 0;

              setState(() {
                kembalian = bayar - total;
              });

            },
          ),

          const SizedBox(height:15),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Kembalian"),
              Text("Rp $kembalian"),
            ],
          )

        ],
      ),

      actions: [

        TextButton(
          onPressed: (){
            Navigator.pop(context);
          },
          child: const Text("Batal"),
        ),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red
          ),
          onPressed: () {

            int bayar = int.tryParse(bayarController.text) ?? 0;

            if(bayar < total){
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Uang tidak cukup"),
                ),
              );
              return;
            }

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
).then((value){
  if(value == true){
    resetKeranjang();
  }
});

          },
          child: const Text("Selesai"),
        )

      ],

    );
  }

}

class StrukPage extends StatelessWidget {

  final List produk;
  final int total;
  final int bayar;
  final int kembali;
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

  String rupiah(int angka) {
    return "Rp $angka";
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

            /// NAMA TOKO
            const Center(
              child: Text(
                "GEPREKZONE",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
            ),

            const Center(
              child: Text("Jl. Rumah Makan No.10"),
            ),

            const Center(
              child: Text("Telp : 08123456789"),
            ),

            const SizedBox(height: 10),

            const Center(
              child: Text(
                "STRUK PEMBELIAN",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            const Divider(),

            /// INFO TRANSAKSI
            Text("Kode Transaksi : $kodeTransaksi"),
            Text("Tanggal : $tanggal"),
            Text("Tipe Pesanan : $tipe"),
            Text("Meja : $meja"),

            const Divider(),

            /// HEADER ITEM
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Item"),
                Text("Subtotal"),
              ],
            ),

            const Divider(),

            /// LIST PRODUK
            ...items.map((p){

              int subtotal = p["qty"] * p["harga"];

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${p["nama"]} x${p["qty"]}"),
                  Text(rupiah(subtotal)),
                ],
              );

            }),

            const Divider(),

            /// TOTAL
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total",
                  style: TextStyle(
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  rupiah(total),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// BAYAR
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Bayar"),
                Text(rupiah(bayar)),
              ],
            ),

            /// KEMBALI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Kembali"),
                Text(rupiah(kembali)),
              ],
            ),

            const SizedBox(height: 20),

            const Center(
              child: Text("Terima Kasih 🙏"),
            ),

            const Center(
              child: Text("Selamat Menikmati"),
            ),

            const Spacer(),

            /// BUTTON DOWNLOAD PDF
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red
                ),
                onPressed: (){
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Download PDF (Demo)"),
                    ),
                  );
                },
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text("Download PDF"),
              ),
            ),

            const SizedBox(height:10),

            // /// BUTTON KEMBALI
            // SizedBox(
            //   width: double.infinity,
            //   child: OutlinedButton(
            //     onPressed: (){
            //       Navigator.pop(context,true);
            //     },
            //     child: const Text("Kembali"),
            //   ),
            // )

          ],
        ),
      ),

    );
  }
}