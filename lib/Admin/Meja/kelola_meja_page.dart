import 'package:flutter/material.dart';
import 'package:geprekzone/Admin/Meja/form_meja.dart';
import 'package:geprekzone/Admin/admin_drawer.dart';
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
  String? errorNomor;

  List<Map<String, dynamic>> meja = [];

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

  void formMeja({Map<String, dynamic>? data}) async {
  final result = await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (_) => FormMeja(meja: data),
  );

  if (result == true) {
    getMeja();
  }
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
                        backgroundColor:Color.fromARGB(255, 239, 218, 218),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        "Hapus",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
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
      },
    );

    if (konfirmasi == true) {
      await supabase.from('meja').delete().eq('id', meja[index]["id"]);

      getMeja();
    }
  }

  @override
  Widget build(BuildContext context) {
    var filteredMeja = meja.where((m) {
      final cocokSearch = m["nomor_meja"].toString().toLowerCase().contains(
        search,
      );

      final cocokStatus = filterStatus == "semua"
          ? true
          : m["status"] == filterStatus;

      return cocokSearch && cocokStatus;
    }).toList();

    return Scaffold(
       drawer: const AdminDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          formMeja();
        },

        backgroundColor: Colors.red,

        icon: const Icon(Icons.add, color: Colors.white),

        label: Text("Tambah Meja", style: TextStyle(color: Colors.white)),
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
                  child:  Builder(
  builder: (context) => IconButton(
    icon: const Icon(Icons.menu, color: Colors.white),
    onPressed: () {
      Scaffold.of(context).openDrawer();
    },
  ),
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
                    fillColor: Colors.white,
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

                const SizedBox(height: 10),

                /// FILTER STATUS
                DropdownButtonFormField(
                  value: filterStatus,
                  items: const [
                    DropdownMenuItem(
                      value: "semua",
                      child: Text("Semua Status"),
                    ),
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
  child: filteredMeja.isEmpty
      ? const Center(
          child: Text(
            "Data tidak ditemukan",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        )
      : ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: filteredMeja.length,
          itemBuilder: (context, index) {
            var data = filteredMeja[index];
            bool terisi = data["status"] == "terisi";

            return Card(
              color: const Color.fromARGB(255, 239, 218, 218),
              margin: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: terisi ? Colors.red : Colors.green,
                  child: const Icon(
                    Icons.table_restaurant,
                    color: Colors.white,
                  ),
                ),

              
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Meja ${data["nomor_meja"]}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                     decoration: BoxDecoration(
  color: terisi ? Colors.red[300] : Colors.green[400],
  borderRadius: BorderRadius.circular(8),
),
                      child: Text(
                        data["status"],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        formMeja(data: data);
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
                        hapusMeja(index);
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
)
        ]
      ),
    );
    
            
            
    
  }
}
