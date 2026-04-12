import 'package:flutter/material.dart';
import 'package:geprekzone/auth/session.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final ImagePicker picker = ImagePicker();

  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> products = [];

  Future<void> getProducts() async {
    final response = await supabase
        .from('products')
        .select()
        .order('id', ascending: false);

    setState(() {
      products = List<Map<String, dynamic>>.from(response);
    });
  }

  @override
  void initState() {
    super.initState();
     WidgetsBinding.instance.addPostFrameCallback((_) {
    UserSession.cekAkses(context, ['kasir']);
  });
    getProducts();
  }

 

  TextEditingController searchController = TextEditingController();

  String filterKategori = "Semua";

  List<Map<String, dynamic>> getFilteredProducts() {
    return products.where((product) {
      bool cocokSearch = product["nama_produk"].toLowerCase().contains(
        searchController.text.toLowerCase(),
      );

      bool cocokKategori =
          filterKategori == "Semua" || product["kategori"] == filterKategori;

      return cocokSearch && cocokKategori;
    }).toList();
  }


String formatRupiah(num angka) {
  return NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(angka);
}


  @override
  Widget build(BuildContext context) {
    var filteredProducts = getFilteredProducts();

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Daftar Menu",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xffe53935), // Warna utama merah
        elevation: 0,
        // Tombol kembali manual
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Jika Anda ingin kembali ke halaman sebelumnya (Kasir Home)
            Navigator.pop(context); 
            
            // ATAU jika ingin eksplisit ke halaman tertentu (pastikan route sudah terdaftar):
            // Navigator.pushReplacementNamed(context, '/kasirhome');
          },
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xffe53935), Color(0xffb71c1c)],
            ),
          ),
        ),
      ),
     
      body: Column(
        children: [
          

         
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                
                SizedBox(
                  height: 60,
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: "Masukkan nama menu",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

               
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 55,
                        child: DropdownButtonFormField<String>(
                          value: filterKategori,
                          items: const [
                            DropdownMenuItem(
                              value: "Semua",
                              child: Text("Semua Kategori"),
                            ),
                            DropdownMenuItem(
                              value: "Makanan",
                              child: Text("Makanan"),
                            ),
                            DropdownMenuItem(
                              value: "Minuman",
                              child: Text("Minuman"),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              filterKategori = value!;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: "Kategori",
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

        
          Expanded(
          child: RefreshIndicator(
            onRefresh: getProducts, // Fungsi yang dipanggil saat ditarik
            color: Colors.red,
            child: filteredProducts.isEmpty
                ? ListView( // Gunakan ListView agar tetap bisa di-refresh meski kosong
                    children: const [
                      SizedBox(height: 100),
                      Center(child: Text("Data tidak ditemukan", style: TextStyle(color: Colors.grey))),
                    ],
                  )
                :ListView.builder(
                    padding: const EdgeInsets.only(top: 0, bottom: 80, left: 0, right: 0),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      var product = filteredProducts[index];

                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: product["image"] == null
                                ? Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.fastfood),
                                  )
                                : Image.network(
                                    product["image"],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                          ),

                        
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product["nama_produk"],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 0),
                              Text(
                                formatRupiah(product["harga"] ?? 0),
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 12,
                                ),
                              ),

                              const SizedBox(height: 0),

                              Text(
                                "Stok : ${product["stok"] ?? 0}",
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 6),

                         
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  product["kategori"],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),

                        
                       
                        ),
                      );
                    },
                  ),
          ),
          )
        ],
      
      ),
    );
  }
}


class KonfirmasiHapus extends StatelessWidget {
  final String namaProduk;
  final VoidCallback onConfirm;

  const KonfirmasiHapus({
    super.key,
    required this.namaProduk,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
        
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom:20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        
          const Text(
            "Hapus Menu?",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Apakah Anda yakin ingin menghapus '$namaProduk'? Tindakan ini tidak dapat dibatalkan.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                            255,
                            235,
                            212,
                            214,
                          ),
                    side: BorderSide.none,      
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text("Batal", style: TextStyle(color: Colors.black)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Hapus Sekarang",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

