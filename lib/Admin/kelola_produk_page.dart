import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class KelolaMenuPage extends StatefulWidget {
  const KelolaMenuPage({super.key});

  @override
  State<KelolaMenuPage> createState() => _KelolaMenuPageState();
}

class _KelolaMenuPageState extends State<KelolaMenuPage> {

  final ImagePicker picker = ImagePicker();

  /// DATA MENU DEMO
  List<Map<String, dynamic>> products = [];

  TextEditingController searchController = TextEditingController();

  String filterKategori = "Semua";

  /// FILTER
  List<Map<String,dynamic>> getFilteredProducts(){

    return products.where((product){

      bool cocokSearch = product["nama_produk"]
          .toLowerCase()
          .contains(searchController.text.toLowerCase());

      bool cocokKategori =
          filterKategori == "Semua" ||
          product["kategori"] == filterKategori;

      return cocokSearch && cocokKategori;

    }).toList();

  }

  /// PILIH FOTO DARI GALERI
  Future<File?> pickImage() async {

    final XFile? image =
    await picker.pickImage(source: ImageSource.gallery);

    if(image != null){
      return File(image.path);
    }

    return null;

  }

  /// FORM TAMBAH / EDIT
  void formMenu({int? index}) {

    bool isEdit = index != null;

    TextEditingController nama =
    TextEditingController(
        text: isEdit ? products[index]["nama_produk"] : "");

    TextEditingController harga =
    TextEditingController(
        text: isEdit ? products[index]["harga"].toString() : "");

    String kategori =
    isEdit ? products[index]["kategori"] : "Makanan";

    File? foto =
    isEdit ? products[index]["foto"] : null;

    showModalBottomSheet(

        context: context,
        isScrollControlled: true,

        builder: (context){

          return StatefulBuilder(

              builder: (context,setModalState){

                return Padding(

                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),

                  child: Container(

                    padding: const EdgeInsets.all(20),

                    child: SingleChildScrollView(

                      child: Column(
                        mainAxisSize: MainAxisSize.min,

                        children: [

                          Text(
                            isEdit ? "Edit Menu" : "Tambah Menu",
                            style: const TextStyle(
                                fontSize:20,
                                fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(height:20),

                          /// PREVIEW FOTO
                          GestureDetector(

                            onTap: () async {

                              File? image =
                              await pickImage();

                              if(image != null){

                                setModalState(() {

                                  foto = image;

                                });

                              }

                            },

                            child: Container(

                              height:120,
                              width:double.infinity,

                              decoration: BoxDecoration(

                                  borderRadius:
                                  BorderRadius.circular(10),

                                  border: Border.all(
                                      color: Colors.grey)

                              ),

                              child: foto == null

                                  ? const Column(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [

                                  Icon(Icons.add_a_photo),

                                  SizedBox(height:6),

                                  Text("Pilih Foto")

                                ],
                              )

                                  : ClipRRect(

                                borderRadius:
                                BorderRadius.circular(10),

                                child: Image.file(
                                  foto!,
                                  fit: BoxFit.cover,
                                ),

                              ),

                            ),

                          ),

                          const SizedBox(height:16),

                          TextField(
                            controller: nama,
                            decoration:
                            inputStyle("Nama Produk"),
                          ),

                          const SizedBox(height:12),

                          TextField(
                            controller: harga,
                            keyboardType:
                            TextInputType.number,
                            decoration:
                            inputStyle("Harga"),
                          ),

                          const SizedBox(height:12),

                          DropdownButtonFormField(

                            value: kategori,

                            items: const [

                              DropdownMenuItem(
                                  value:"Makanan",
                                  child: Text("Makanan")
                              ),

                              DropdownMenuItem(
                                  value:"Minuman",
                                  child: Text("Minuman")
                              ),

                            ],

                            onChanged: (value){

                              kategori = value.toString();

                            },

                            decoration:
                            inputStyle("Kategori"),

                          ),

                          const SizedBox(height:20),

                          Row(

                            children: [

                              Expanded(

                                child: ElevatedButton(

                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      padding: const EdgeInsets.symmetric(
                                          vertical:14)
                                  ),

                                  onPressed: (){

                                    setState(() {

                                      if(isEdit){

                                        products[index]["nama_produk"] =
                                            nama.text;

                                        products[index]["harga"] =
                                            int.parse(harga.text);

                                        products[index]["kategori"] =
                                            kategori;

                                        products[index]["foto"] =
                                            foto;

                                      }

                                      else{

                                        products.add({

                                          "id":
                                          products.length + 1,

                                          "nama_produk":
                                          nama.text,

                                          "harga":
                                          int.parse(harga.text),

                                          "kategori":
                                          kategori,

                                          "foto":
                                          foto

                                        });

                                      }

                                    });

                                    Navigator.pop(context);

                                  },

                                  child: Text(
                                      isEdit ? "Update" : "Simpan"
                                  ),

                                ),

                              ),

                              const SizedBox(width:10),

                              Expanded(

                                child: OutlinedButton(

                                  onPressed: (){
                                    Navigator.pop(context);
                                  },

                                  child: const Text("Batal"),

                                ),

                              )

                            ],

                          )

                        ],

                      ),

                    ),

                  ),

                );

              }

          );

        }

    );

  }

  InputDecoration inputStyle(String label){

    return InputDecoration(

      labelText: label,

      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10)
      ),

    );

  }

  /// HAPUS MENU
  void hapusMenu(int index){

    setState(() {

      products.removeAt(index);

    });

  }

  @override
  Widget build(BuildContext context) {

    var filteredProducts = getFilteredProducts();

    return Scaffold(

      floatingActionButton: FloatingActionButton.extended(

        backgroundColor: Colors.red,

        icon: const Icon(Icons.add),

        label: const Text("Tambah Menu"),

        onPressed: () => formMenu(),

      ),

      body: Column(

        children: [

          /// HEADER
          Container(

            width: double.infinity,

            padding: const EdgeInsets.fromLTRB(20,40,20,20),

            decoration: const BoxDecoration(

              gradient: LinearGradient(

                colors: [
                  Color(0xffe53935),
                  Color(0xffb71c1c)
                ],

              ),

            ),

            child: const Row(

              children: [

                Icon(Icons.restaurant_menu,
                    color: Colors.white),

                SizedBox(width:10),

                Text(
                  "Kelola Menu",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize:20,
                      fontWeight: FontWeight.bold),
                )

              ],

            ),

          ),

          /// SEARCH
          Padding(

            padding: const EdgeInsets.all(12),

            child: TextField(

              controller: searchController,

              onChanged: (value){
                setState(() {});
              },

              decoration: InputDecoration(

                hintText: "Cari menu...",

                prefixIcon: const Icon(Icons.search),

                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)
                ),

              ),

            ),

          ),

          /// FILTER
          Padding(

            padding: const EdgeInsets.symmetric(horizontal:12),

            child: DropdownButtonFormField(

              value: filterKategori,

              items: const [

                DropdownMenuItem(
                    value:"Semua",
                    child: Text("Semua Kategori")
                ),

                DropdownMenuItem(
                    value:"Makanan",
                    child: Text("Makanan")
                ),

                DropdownMenuItem(
                    value:"Minuman",
                    child: Text("Minuman")
                ),

              ],

              onChanged: (value){

                setState(() {

                  filterKategori = value.toString();

                });

              },

              decoration: const InputDecoration(
                  labelText: "Kategori",
                  border: OutlineInputBorder()
              ),

            ),

          ),

          const SizedBox(height:10),

          /// LIST MENU
          Expanded(

            child: ListView.builder(

              padding: const EdgeInsets.all(12),

              itemCount: filteredProducts.length,

              itemBuilder: (context,index){

                var product = filteredProducts[index];

                return Card(

                  child: ListTile(

                    leading: product["foto"] == null

                        ? const Icon(Icons.fastfood)

                        : ClipRRect(

                      borderRadius:
                      BorderRadius.circular(8),

                      child: Image.file(
                        product["foto"],
                        width:60,
                        height:60,
                        fit: BoxFit.cover,
                      ),

                    ),

                    title: Text(product["nama_produk"]),

                    subtitle: Text(
                        "Rp ${product["harga"]} • ${product["kategori"]}"
                    ),

                    trailing: Wrap(

                      children: [

                        IconButton(

                          icon: const Icon(Icons.edit,
                              color: Colors.blue),

                          onPressed: (){
                            formMenu(
                                index:
                                products.indexOf(product));
                          },

                        ),

                        IconButton(

                          icon: const Icon(Icons.delete,
                              color: Colors.red),

                          onPressed: (){
                            hapusMenu(
                                products.indexOf(product));
                          },

                        )

                      ],

                    ),

                  ),

                );

              },

            ),

          )

        ],

      ),

    );

  }

}