import 'package:flutter/material.dart';
import 'package:geprekzone/Admin/Meja/form_meja.dart';
import 'package:geprekzone/Admin/admin_drawer.dart';
import 'package:geprekzone/Owner/log/logservice.dart';
import 'package:geprekzone/auth/session.dart';
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
        .order('id', ascending: false);

    setState(() {
      meja = List<Map<String, dynamic>>.from(response);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    UserSession.cekAkses(context, ['admin']);
  });
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data == null
                  ? "Meja berhasil ditambahkan"
                  : "Meja berhasil diperbarui",
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void hapusMeja(int index) async {
    var dataMeja = meja[index];

    bool? konfirmasi = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const Text(
                "Hapus Meja?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Apakah Anda yakin ingin menghapus Meja ${dataMeja["nomor_meja"]}?",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          235,
                          212,
                          214,
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "Batal",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "Hapus",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );

    if (konfirmasi == true) {
      if (dataMeja["status"] == "terisi") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Meja yang sedang terisi tidak dapat dihapus!"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        await supabase.from('meja').delete().eq('id', dataMeja["id"]);
        await LogService.log(
        "Menghapus meja nomor ${dataMeja["nomor_meja"]}"
      );

        if (mounted) {
          getMeja();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Meja berhasil dihapus"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Gagal menghapus: $e")));
        }
      }
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
                  child: Builder(
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
              ],
            ),
          ),

          Expanded(
            child: filteredMeja.isEmpty
                ? const Center(
                    child: Text(
                      "Data tidak ditemukan",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(
                      top: 0,
                      bottom: 80,
                      left: 0,
                      right: 0,
                    ),

                    itemCount: filteredMeja.length,
                    itemBuilder: (context, index) {
                      var data = filteredMeja[index];
                      bool terisi = data["status"] == "terisi";

                      return Card(
                        color: Colors.white,
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
                                  color: terisi
                                      ? Colors.red[300]
                                      : Colors.green[400],
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
          ),
        ],
      ),
    );
  }
}
