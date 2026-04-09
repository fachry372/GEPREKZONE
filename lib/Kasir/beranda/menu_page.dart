import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> products = [];

  TextEditingController searchController = TextEditingController();
  String filterKategori = "Semua";

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final res = await supabase
        .from('products')
        .select()
        .order('id', ascending: true);

    setState(() {
      products = List<Map<String, dynamic>>.from(res);
    });
  }

  List<Map<String, dynamic>> getFilteredProducts() {
    return products.where((product) {
      bool cocokSearch = product["nama_produk"]
          .toLowerCase()
          .contains(searchController.text.toLowerCase());

      bool cocokKategori =
          filterKategori == "Semua" || product["kategori"] == filterKategori;

      return cocokSearch && cocokKategori;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    var filteredProducts = getFilteredProducts();

    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),

    appBar: AppBar(
  backgroundColor: Colors.red,
  centerTitle: true, 
  iconTheme: const IconThemeData(
    color: Colors.white, 
  ),
  title: const Text(
    "Daftar Menu",
    style: TextStyle(
      color: Colors.white, 
      fontWeight: FontWeight.bold,
    ),
  ),
),

      body: Column(
        children: [

        
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [

              
                TextField(
                  controller: searchController,
                  onChanged: (value) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: "Cari menu...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                /// FILTER
                DropdownButtonFormField<String>(
                  value: filterKategori,
                  items: const [
                    DropdownMenuItem(value: "Semua", child: Text("Semua")),
                    DropdownMenuItem(value: "Makanan", child: Text("Makanan")),
                    DropdownMenuItem(value: "Minuman", child: Text("Minuman")),
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(
                    child: Text(
                      "Data tidak ditemukan",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      var product = filteredProducts[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(10),

                          /// GAMBAR
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

                          /// TEXT
                          title: Text(
                            product["nama_produk"],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text("Rp ${product["harga"]}"),
                              Text("Stok: ${product["stok"]}"),

                              const SizedBox(height: 5),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  product["kategori"],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
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
        ],
      ),
    );
  }
}