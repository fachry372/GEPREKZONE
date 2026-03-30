import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KelolaUserPage extends StatefulWidget {
  const KelolaUserPage({super.key});

  @override
  State<KelolaUserPage> createState() => _KelolaUserPageState();
}

class _KelolaUserPageState extends State<KelolaUserPage> {
  final supabase = Supabase.instance.client;
  List users = [];
  TextEditingController searchController = TextEditingController();

  String filterRole = "Semua";
  String filterStatus = "Semua";

  // Warna Utama Sesuai Gambar
  final Color primaryRed = const Color(0xFFD3421C); // Merah Bata
  final Color cardBg = const Color(0xFFF2DEDE);    // Pink Muda
  final Color roleLabelBg = const Color(0xFFE59285); // Pink Gelap untuk Role

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  /// ================= GET DATA =================
  Future<void> getUsers() async {
    try {
      final data = await supabase.from('users').select().order('id');
      setState(() {
        users = data;
      });
    } catch (e) {
      debugPrint("Error fetching users: $e");
    }
  }

  /// ================= FILTER LOGIC =================
  List getFilteredUsers() {
    return users.where((user) {
      bool cocokSearch = (user["nama"] ?? "")
          .toLowerCase()
          .contains(searchController.text.toLowerCase());

      bool cocokRole = filterRole == "Semua" || user["role"] == filterRole;

      bool cocokStatus = filterStatus == "Semua" ||
          (filterStatus == "Aktif" && user["status"] == "aktif") ||
          (filterStatus == "Nonaktif" && user["status"] == "nonaktif");

      return cocokSearch && cocokRole && cocokStatus;
    }).toList();
  }

  /// ================= TOGGLE STATUS =================
  Future<void> toggleStatus(Map user) async {
    String newStatus = user["status"] == "aktif" ? "nonaktif" : "aktif";
    await supabase
        .from('users')
        .update({"status": newStatus})
        .eq('id', user["id"]);
    getUsers();
  }

  /// ================= FORM CREATE / UPDATE =================
  void formUser({Map? user}) {
    bool isEdit = user != null;
    TextEditingController nama = TextEditingController(text: isEdit ? user["nama"] : "");
    TextEditingController username = TextEditingController(text: isEdit ? user["username"] : "");
    TextEditingController password = TextEditingController();
    String role = isEdit ? user["role"] : "Kasir";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEdit ? "Edit User" : "Tambah User",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(controller: nama, decoration: inputDecor("Nama Full")),
              const SizedBox(height: 12),
              TextField(controller: username, decoration: inputDecor("Username")),
              const SizedBox(height: 12),
              TextField(
                controller: password,
                obscureText: true,
                decoration: inputDecor(isEdit ? "Password (Kosongkan jika tidak ubah)" : "Password"),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField(
                value: role,
                items: const [
                  DropdownMenuItem(value: "Admin", child: Text("Admin")),
                  DropdownMenuItem(value: "Kasir", child: Text("Kasir")),
                ],
                onChanged: (v) => role = v.toString(),
                decoration: inputDecor("Pilih Role"),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryRed,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
               onPressed: () async {
  final payload = {
    "nama": nama.text,
    "username": username.text,
    "role": role,
  };

  // HASH PASSWORD
  if (password.text.isNotEmpty) {
    final hashed = await supabase.rpc('hash_password', params: {
      'p_password': password.text,
    });

    payload["password"] = hashed;
  }

  if (isEdit) {
    await supabase
        .from('users')
        .update(payload)
        .eq('id', user["id"]);
  } else {
    payload["status"] = "aktif";

    await supabase
        .from('users')
        .insert(payload);
  }

  if (mounted) Navigator.pop(context);
  getUsers();
},
                child: Text(isEdit ? "Update Data" : "Simpan User", style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  InputDecoration inputDecor(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    );
  }

  @override
  Widget build(BuildContext context) {
    var data = getFilteredUsers();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryRed,
        elevation: 0,
        title: const Text("Kelola Users", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => formUser(),
        backgroundColor: primaryRed,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Tambah User", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      body: Column(
        children: [
          // SEARCH SECTION
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: "Cari users",
                prefixIcon: const Icon(Icons.search, color: Colors.black),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // FILTER SECTION
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: _buildFilterDropdown("Semua Role", filterRole, ["Semua", "Admin", "Kasir"], (v) {
                  setState(() => filterRole = v!);
                })),
                const SizedBox(width: 12),
                Expanded(child: _buildFilterDropdown("Semua Status", filterStatus, ["Semua", "Aktif", "Nonaktif"], (v) {
                  setState(() => filterStatus = v!);
                })),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // LIST SECTION
          Expanded(
            child: data.isEmpty 
              ? const Center(child: Text("Tidak ada data user"))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: data.length,
                  itemBuilder: (context, i) {
                    var user = data[i];
                    bool isAktif = user["status"] == "aktif";

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person, color: primaryRed, size: 35),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user["nama"] ?? "-", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                Text(user["username"] ?? "-", style: TextStyle(color: Colors.grey.shade700)),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: roleLabelBg,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(user["role"] ?? "Kasir", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                                )
                              ],
                            ),
                          ),
                         Row(
  mainAxisSize: MainAxisSize.min,
  children: [

    GestureDetector(
      onTap: () => formUser(user: user),
      child: const Text(
        "Edit",
        style: TextStyle(
          color: Color(0xFF00BCD4),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
    
    const SizedBox(width: 10),

    GestureDetector(
      onTap: () => toggleStatus(user),
      child: Text(
        isAktif ? "Aktif" : "Nonaktif",
        style: TextStyle(
          color: isAktif ? Colors.green : Colors.orangeAccent,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
  ],)
                        ],
                      ),
                    );
                  },
                ),
          )
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String hint, String value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e == "Semua" ? hint : e))).toList(),
      onChanged: onChanged,
    );
  }
}