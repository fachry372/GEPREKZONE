import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      nomor.text = widget.meja!["nomor_meja"].toString();
      status = widget.meja!["status"];
    }
  }

  Future<void> simpan() async {
    setState(() => errorNomor = null);

    if (nomor.text.isEmpty) {
      setState(() => errorNomor = "Nomor meja wajib diisi");
      return;
    }

    final cekMeja = await supabase
        .from('meja')
        .select()
        .eq('nomor_meja', nomor.text);

    if (cekMeja.isNotEmpty) {
      if (!isEdit || cekMeja[0]["id"] != widget.meja!["id"]) {
        setState(() => errorNomor = "Nomor meja sudah ada!");
        return;
      }
    }

    if (isEdit) {
      await supabase
          .from('meja')
          .update({
            'nomor_meja': nomor.text,
            'status': status,
          })
          .eq('id', widget.meja!["id"]);
    } else {
      await supabase.from('meja').insert({
        'nomor_meja': nomor.text,
        'status': status,
      });
    }

    if (mounted) Navigator.pop(context, true);
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

          /// INPUT NOMOR
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

          /// STATUS
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

          /// BUTTON
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffe53935),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: simpan,
                  child: Text(
                    isEdit ? "Update" : "Simpan",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal",
                      style: TextStyle(fontSize: 18)),
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