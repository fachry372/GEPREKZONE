import 'package:flutter/material.dart';
import 'package:geprekzone/Admin/Menu/form_menu.dart';
import 'package:geprekzone/Admin/admin_drawer.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class KelolaMenuPage extends StatefulWidget {
  const KelolaMenuPage({super.key});

  @override
  State<KelolaMenuPage> createState() => _KelolaMenuPageState();
}

class _KelolaMenuPageState extends State<KelolaMenuPage> {
  final ImagePicker picker = ImagePicker();

  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> products = [];

  Future<void> getProducts() async {
    final response = await supabase
        .from('products')
        .select()
        .order('id', ascending: true);

    setState(() {
      products = List<Map<String, dynamic>>.from(response);
    });
  }

  @override
  void initState() {
    super.initState();
    getProducts();
  }

  Future<String?> uploadImage(File file) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();

    await supabase.storage.from('product-images').upload(fileName, file);

    final imageUrl = supabase.storage
        .from('product-images')
        .getPublicUrl(fileName);

    return imageUrl;
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

  Future<File?> pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      return File(image.path);
    }

    return null;
  }

  void formMenu({Map<String, dynamic>? product}) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => FormProduk(product: product),
    );

    if (result == true) {
      getProducts();
    }
  }

  void hapusMenu(int id) async {
    await supabase.rpc('delete_product', params: {'p_id': id});

    getProducts();
  }

  @override
  Widget build(BuildContext context) {
    var filteredProducts = getFilteredProducts();

    return Scaffold(
      drawer: const AdminDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => formMenu(),
        backgroundColor: Colors.red,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Tambah Menu", style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(10, 40, 10, 10),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xffe53935), Color(0xffb71c1c)],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ),
                ),
                const Text(
                  "Kelola Menu",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

         
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                /// SEARCH
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

                /// FILTER (SEJAJAR)
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

          /// LIST MENU
          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(
                    child: Text(
                      "Data tidak ditemukan",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      var product = filteredProducts[index];

                      return Card(
                        color: const Color.fromARGB(255, 239, 218, 218),
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

                          /// TEXT
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
                                "Rp ${product["harga"]}",
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

                              /// BADGE
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

                          /// ACTION
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  formMenu(product: product);
                                },
                                child: const Text(
                                  "Edit",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              GestureDetector(
                                onTap: () {
                                  hapusMenu(product["id"]);
                                },
                                child: const Text(
                                  "Hapus",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
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
