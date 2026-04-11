import 'package:flutter/material.dart';
import 'package:geprekzone/Owner/log/logservice.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
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
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nama;
  late TextEditingController harga;
  late TextEditingController stok;

  String kategori = "Makanan";
  File? foto;
  String? oldImage;
  bool isLoading = false;

  final NumberFormat currencyFormatter = NumberFormat.decimalPattern('id_ID');

  bool get isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();

    nama = TextEditingController(
      text: isEdit ? widget.product!["nama_produk"] : "",
    );

    harga = TextEditingController(
      text: isEdit ? currencyFormatter.format(widget.product!["harga"]) : "",
    );

    stok = TextEditingController(
      text: isEdit ? widget.product!["stok"].toString() : "0",
    );
    kategori = isEdit ? widget.product!["kategori"] : "Makanan";
    oldImage = isEdit ? widget.product!["image"] : null;
  }

  void _onHargaChanged(String value) {
    if (value.isEmpty) return;

    String cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanValue.isEmpty) {
      harga.text = "";
      return;
    }

    String formatted = currencyFormatter.format(int.parse(cleanValue));

    harga.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  Future<File?> pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) return File(image.path);
    return null;
  }

  Future<String?> uploadImage(File file) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    await supabase.storage.from('product-images').upload(fileName, file);
    return supabase.storage.from('product-images').getPublicUrl(fileName);
  }

  InputDecoration inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    );
  }

  void simpan() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => isLoading = true);

  try {
    String? imageUrl;
    if (foto != null) imageUrl = await uploadImage(foto!);

    double hargaBaru = double.parse(harga.text.replaceAll('.', ''));
    int stokBaru = int.parse(stok.text);
    String namaBaru = nama.text;

    if (isEdit) {
  
      String namaLama = widget.product!["nama_produk"];
      double hargaLama = widget.product!["harga"].toDouble();
      int stokLama = widget.product!["stok"];

    
      List<String> perubahan = [];
      if (namaLama != namaBaru) perubahan.add("nama dari '$namaLama' ke '$namaBaru'");
      if (hargaLama != hargaBaru) perubahan.add("harga dari ${currencyFormatter.format(hargaLama)} ke ${currencyFormatter.format(hargaBaru)}");
      if (stokLama != stokBaru) perubahan.add("stok dari $stokLama ke $stokBaru");

   
      await supabase.rpc(
        'update_product',
        params: {
          'p_id': widget.product!["id"],
          'p_nama': namaBaru,
          'p_harga': hargaBaru,
          'p_kategori': kategori,
          'p_image': imageUrl ?? oldImage,
          'p_stok': stokBaru,
        },
      );

   
      if (perubahan.isNotEmpty) {
        await LogService.log("Mengubah menu '${namaLama}': ${perubahan.join(', ')}");
      }
    } else {
   
      await supabase.rpc(
        'insert_product',
        params: {
          'p_nama': namaBaru,
          'p_harga': hargaBaru,
          'p_kategori': kategori,
          'p_image': imageUrl,
          'p_stok': stokBaru,
        },
      );

      await LogService.log("Menambahkan menu baru: $namaBaru dengan stok $stokBaru");
    }

    if (mounted) Navigator.pop(context, true);
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan: $e"), backgroundColor: Colors.red),
      );
    }
  } finally {
    if (mounted) setState(() => isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEdit ? "Edit Menu" : "Tambah Menu",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () async {
                    File? image = await pickImage();
                    if (image != null) setState(() => foto = image);
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
                        ? Image.network(oldImage!, fit: BoxFit.cover)
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo),
                              SizedBox(height: 6),
                              Text("Pilih Foto"),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: nama,
                  decoration: inputStyle("Nama Produk"),
                  validator: (value) => (value == null || value.isEmpty)
                      ? "Nama tidak boleh kosong"
                      : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: harga,
                  keyboardType: TextInputType.number,
                  decoration: inputStyle("Harga").copyWith(prefixText: "Rp "),
                  onChanged: _onHargaChanged,
                  validator: (value) => (value == null || value.isEmpty)
                      ? "Harga tidak boleh kosong"
                      : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: stok,
                  keyboardType: TextInputType.number,
                  decoration: inputStyle("Stok"),
                  validator: (value) => (value == null || value.isEmpty)
                      ? "Stok tidak boleh kosong"
                      : null,
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: kategori,
                  items: const [
                    DropdownMenuItem(value: "Makanan", child: Text("Makanan")),
                    DropdownMenuItem(value: "Minuman", child: Text("Minuman")),
                  ],
                  onChanged: (value) => setState(() => kategori = value!),
                  decoration: inputStyle("Kategori"),
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
                        onPressed: isLoading ? null : simpan,
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
                            : Text(
                                isEdit ? "Update" : "Simpan",
                                style: const TextStyle(
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
          ),
        ),
      ),
    );
  }

}
