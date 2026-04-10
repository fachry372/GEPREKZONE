import 'package:flutter/material.dart';
import 'package:geprekzone/Owner/log/logservice.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FormMeja extends StatefulWidget {
  final Map<String, dynamic>? meja;

  const FormMeja({super.key, this.meja});

  @override
  State<FormMeja> createState() => _FormMejaState();
}

class _FormMejaState extends State<FormMeja> {
  final supabase = Supabase.instance.client;

  TextEditingController nomor = TextEditingController();
  String status = "kosong";

  String? errorNomor;

  bool get isEdit => widget.meja != null;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      nomor.text = widget.meja!["nomor_meja"].toString();
      status = widget.meja!["status"];
    }
  }

 Future<void> simpan() async {
  
  if (isLoading) return; 

  setState(() {
    errorNomor = null;
    isLoading = true; 
  });

  try {
    if (nomor.text.isEmpty) {
      setState(() {
        errorNomor = "Nomor meja wajib diisi";
        isLoading = false;
      });
      return;
    }

  
    final cekMeja = await supabase
        .from('meja')
        .select()
        .eq('nomor_meja', nomor.text);

    if (cekMeja.isNotEmpty) {
      if (!isEdit || cekMeja[0]["id"] != widget.meja!["id"]) {
        setState(() {
          errorNomor = "Nomor meja sudah ada!";
          isLoading = false; 
        });
        return;
      }
    }

    if (isEdit) {
      await supabase.from('meja').update({
        'nomor_meja': nomor.text,
        'status': status,
      }).eq('id', widget.meja!["id"]);

      await LogService.log("Mengubah status meja ${nomor.text} menjadi $status");
    } else {
      await supabase.from('meja').insert({
        'nomor_meja': nomor.text,
        'status': status,
      });

      await LogService.log("Menambahkan meja baru dengan nomor ${nomor.text}");
    }

    if (mounted) Navigator.pop(context, true);
  } catch (e) {
   
    setState(() => isLoading = false);
    
  }
}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 25,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isEdit ? "Edit Meja" : "Tambah Meja",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 25),

     
          TextFormField(
            controller: nomor,
            decoration: InputDecoration(
              hintText: "Nomor Meja",
              errorText: errorNomor,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15, vertical: 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 15),

       
          DropdownButtonFormField(
            value: status,
            items: const [
              DropdownMenuItem(value: "kosong", child: Text("Kosong")),
              DropdownMenuItem(value: "terisi", child: Text("Terisi")),
            ],
            onChanged: (value) {
              setState(() {
                status = value.toString();
              });
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 25),

          
        /// BUTTONS SECTION
Row(
  children: [
    // Tombol Batal
    Expanded(
      child: ElevatedButton(
        // Tombol batal juga di-disable saat sedang loading
        onPressed: isLoading ? null : () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 235, 212, 214),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          "Batal",
          style: TextStyle(color: Colors.black87),
        ),
      ),
    ),
    const SizedBox(width: 12),
    // Tombol Simpan / Update
    Expanded(
      child: ElevatedButton(
        onPressed: isLoading ? null : simpan,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
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

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}