import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KelolaMejaPage extends StatefulWidget {
  const KelolaMejaPage({super.key});

  @override
  State<KelolaMejaPage> createState() => _KelolaMejaPageState();
}

class _KelolaMejaPageState extends State<KelolaMejaPage> {

final supabase = Supabase.instance.client;
String search = "";
String filterStatus = "semua";

List<Map<String,dynamic>> meja = [];

 Future<void> getMeja() async {
  final response = await supabase
      .from('meja')
      .select()
      .order('id', ascending: true);

  setState(() {
    meja = List<Map<String, dynamic>>.from(response);
  });
}

@override
void initState() {
  super.initState();
  getMeja();
}
  
  /// FORM TAMBAH / EDIT
  void formMeja({int? index}) {
    bool isEdit = index != null;

    TextEditingController nomor = TextEditingController(
        text: isEdit ? meja[index]["nomor_meja"].toString() : "");

    String status = isEdit ? meja[index]["status"] : "kosong";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Agar keyboard tidak menutupi input
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return StatefulBuilder( // Menggunakan StatefulBuilder agar dropdown bisa berubah saat diklik
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom, // Menyesuaikan keyboard
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
                  
                  // INPUT NOMOR MEJA
                  TextField(
                    controller: nomor,
                    decoration: InputDecoration(
                      hintText: "Nomor Meja",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // DROPDOWN STATUS
                  DropdownButtonFormField(
                    value: status,
                    items: const [
                      DropdownMenuItem(value: "kosong", child: Text("Kosong")),
                      DropdownMenuItem(value: "terisi", child: Text("Terisi")),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        status = value.toString();
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

               // TOMBOL AKSI
Row(
  children: [
    // Tombol Simpan / Update
    Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xffe53935),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: () async {
          if (nomor.text.isEmpty) return;
          if (isEdit) {
            await supabase.from('meja').update({
              'nomor_meja': nomor.text,
              'status': status
            }).eq('id', meja[index]["id"]);
          } else {
            await supabase.from('meja').insert({
              'nomor_meja': nomor.text,
              'status': status
            });
          }
          if (mounted) Navigator.pop(context);
          getMeja();
        },
        child: Text(
          isEdit ? "Update" : "Simpan",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    ),
    const SizedBox(width: 15),
    // Tombol Batal
    Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 15),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(color: Colors.transparent)
          ),
        ),
        onPressed: () => Navigator.pop(context),
        child: const Text(
          "Batal",
          style: TextStyle(fontSize: 18),
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
        );
      },
    );
  }
 void toggleStatus(int index) async {

  String newStatus =
      meja[index]["status"] == "kosong"
          ? "terisi"
          : "kosong";

  await supabase.from('meja').update({
    'status': newStatus
  }).eq('id', meja[index]["id"]);

  getMeja();
}


 void hapusMeja(int index) async {
  bool? konfirmasi = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (context) {
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
              "Hapus Meja",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              "Apakah Anda yakin ingin menghapus Meja ${meja[index]["nomor_meja"]}?",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(color: Colors.grey),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text(
                      "Batal",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffe53935),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text(
                      "Hapus",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    },
  );

  if (konfirmasi == true) {
    await supabase
        .from('meja')
        .delete()
        .eq('id', meja[index]["id"]);

    getMeja();
  }
}

  @override
  Widget build(BuildContext context) {

     var filteredMeja = meja.where((m) {
    final cocokSearch = m["nomor_meja"]
        .toString()
        .toLowerCase()
        .contains(search);

    final cocokStatus = filterStatus == "semua"
        ? true
        : m["status"] == filterStatus;

    return cocokSearch && cocokStatus;
  }).toList();

    return Scaffold(

      floatingActionButton: FloatingActionButton.extended(

        onPressed: (){
          formMeja();
        },

        backgroundColor: Colors.red,

        icon: const Icon(Icons.add,color: Colors.white,),

        label:  Text("Tambah Meja",style: TextStyle(color: Colors.white),),

      ),

      body: Column(

        children: [

      
Container(
  width: double.infinity,
  padding: const EdgeInsets.fromLTRB(10, 40, 10, 10),
  decoration: const BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Color(0xffe53935),
        Color(0xffb71c1c)
      ],
    ),
  ),
  child: Stack(
    alignment: Alignment.center,
    children: [

      /// BUTTON BACK
      Align(
        alignment: Alignment.centerLeft,
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
      ),

     
      const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          
          Text(
            "Kelola Meja",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),

    ],
  ),
),

Padding(
  padding: const EdgeInsets.all(12),
  child: Column(
    children: [

      /// SEARCH
      TextField(
        onChanged: (value) {
          setState(() {
            search = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: "Cari meja",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),

      const SizedBox(height: 10),

      /// FILTER STATUS
      DropdownButtonFormField(
        value: filterStatus,
        items: const [
          DropdownMenuItem(value: "semua", child: Text("Semua Status")),
          DropdownMenuItem(value: "kosong", child: Text("Kosong")),
          DropdownMenuItem(value: "terisi", child: Text("Terisi")),
        ],
        onChanged: (value) {
          setState(() {
            filterStatus = value.toString();
          });
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    ],
  ),
),


          /// LIST MEJA
          Expanded(
            

            child: ListView.builder(
               padding: EdgeInsets.zero,
           itemCount: filteredMeja.length,

              itemBuilder: (context,index){

                var data = filteredMeja[index];

                bool terisi =
                    data["status"] == "terisi";

                return Card(
                color: Color.fromARGB(255, 239, 218, 218),
                  margin: const EdgeInsets.symmetric(
                      horizontal:12,
                      vertical:6
                  ),

                  child: ListTile(

                    leading: CircleAvatar(

                      backgroundColor:
                      terisi
                          ? Colors.red
                          : Colors.green,

                      child: const Icon(
                        Icons.table_restaurant,
                        color: Colors.white,
                      ),

                    ),

                    title: Text(
                      "Meja ${data["nomor_meja"]}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold
                      ),
                    ),

                    subtitle: Text(
                        terisi
                            ? "Terisi"
                            : "Kosong"
                    ),

                    trailing: Row(

                      mainAxisSize: MainAxisSize.min,

                      children: [

                        IconButton(

                          icon: const Icon(Icons.sync),

                          onPressed: (){
                            toggleStatus(index);
                          },

                        ),

                        IconButton(

                          icon: const Icon(
                              Icons.edit,
                              color: Colors.blue
                          ),

                          onPressed: (){
                            formMeja(index:index);
                          },

                        ),

                        IconButton(

                          icon: const Icon(
                              Icons.delete,
                              color: Colors.red
                          ),

                          onPressed: (){
                            hapusMeja(index);
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