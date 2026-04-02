import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class FormProduk extends StatefulWidget {
  final Map<String, dynamic>? product;

  const FormProduk({super.key, this.product});

  @override
  State<FormProduk> createState() => _FormProdukState();
}

class _FormProdukState extends State<FormProduk> {
  final supabase = Supabase.instance.client;
  final picker = ImagePicker();

  late TextEditingController nama;
  late TextEditingController harga;
  late TextEditingController stok;

  String kategori = "Makanan";
  File? foto;
  String? oldImage;

  bool get isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();

    nama = TextEditingController(
        text: isEdit ? widget.product!["nama_produk"] : "");

    harga = TextEditingController(
        text: isEdit ? widget.product!["harga"].toString() : "");

    stok = TextEditingController(
  text: isEdit ? widget.product!["stok"].toString() : "0",
);

    kategori = isEdit ? widget.product!["kategori"] : "Makanan";
    oldImage = isEdit ? widget.product!["image"] : null;
  }

  Future<File?> pickImage() async {
    final XFile? image =
        await picker.pickImage(source: ImageSource.gallery);

    if (image != null) return File(image.path);
    return null;
  }

  Future<String?> uploadImage(File file) async {
    final fileName =
        DateTime.now().millisecondsSinceEpoch.toString();

    await supabase.storage
        .from('product-images')
        .upload(fileName, file);

    return supabase.storage
        .from('product-images')
        .getPublicUrl(fileName);
  }

  InputDecoration inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  void simpan() async {
    String? imageUrl;

    if (foto != null) {
      imageUrl = await uploadImage(foto!);
    }

    if (isEdit) {
      await supabase.rpc('update_product', params: {
        'p_id': widget.product!["id"],
        'p_nama': nama.text,
        'p_harga': double.parse(harga.text),
        'p_kategori': kategori,
        'p_image': imageUrl ?? oldImage,
        'p_stok': int.parse(stok.text),
      });
    } else {
      await supabase.rpc('insert_product', params: {
        'p_nama': nama.text,
        'p_harga': double.parse(harga.text),
        'p_kategori': kategori,
        'p_image': imageUrl,
        'p_stok': int.parse(stok.text),
      });
    }

    Navigator.pop(context, true); // kirim sinyal refresh
  }

  @override
  Widget build(BuildContext context) {
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
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              GestureDetector(
                onTap: () async {
                  File? image = await pickImage();
                  if (image != null) {
                    setState(() {
                      foto = image;
                    });
                  }
                },
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: foto != null
                      ? Image.file(foto!, fit: BoxFit.cover)
                      : oldImage != null
                          ? Image.network(oldImage!,
                              fit: BoxFit.cover)
                          : const Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo),
                                SizedBox(height: 6),
                                Text("Pilih Foto")
                              ],
                            ),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: nama,
                decoration: inputStyle("Nama Produk"),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: harga,
                keyboardType: TextInputType.number,
                decoration: inputStyle("Harga"),
              ),

              const SizedBox(height: 12),

              

TextField(
  controller: stok,
  keyboardType: TextInputType.number,
  decoration: inputStyle("Stok"),
),

const SizedBox(height: 12),

              DropdownButtonFormField(
                value: kategori,
                items: const [
                  DropdownMenuItem(
                      value: "Makanan", child: Text("Makanan")),
                  DropdownMenuItem(
                      value: "Minuman", child: Text("Minuman")),
                ],
                onChanged: (value) {
                  kategori = value.toString();
                },
                decoration: inputStyle("Kategori"),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: simpan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: Text(isEdit ? "Update" : "Simpan"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
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
}