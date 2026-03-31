import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KelolaUserPage extends StatefulWidget {
  const KelolaUserPage({super.key});

  @override
  State<KelolaUserPage> createState() => _KelolaUserPageState();
}

class _KelolaUserPageState extends State<KelolaUserPage> {
  final supabase = Supabase.instance.client;

  String search = "";
  String filterStatus = "semua";
  String filterRole = "semua";

  List<Map<String, dynamic>> users = [];

  Future<void> getUsers() async {
    final response = await supabase
        .from('users')
        .select()
        .order('id', ascending: true);

    setState(() {
      users = List<Map<String, dynamic>>.from(response);
    });
  }

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  void formUser({int? index}) {
    bool isEdit = index != null;

    TextEditingController usernameController = TextEditingController(
      text: isEdit ? users[index]["username"] : "",
    );
    TextEditingController namaController = TextEditingController(
      text: isEdit ? users[index]["nama"] : "",
    );
    TextEditingController passwordController = TextEditingController();

    String role = isEdit ? users[index]["role"] : "kasir";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
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
                    isEdit ? "Edit User" : "Tambah User",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // INPUT USERNAME
                  SizedBox(
                    height: 60,
                    child: TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: "Username",
                        hintText: "Masukkan username",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        labelStyle: TextStyle(color: Colors.grey[600]),
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
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    height: 60,
                    child: TextField(
                      controller: namaController,
                      decoration: InputDecoration(
                        labelText: "Nama",
                        hintText: "Masukkan nama",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        labelStyle: TextStyle(color: Colors.grey[600]),
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
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    height: 60,
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        hintText: "Masukkan password",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        labelStyle: TextStyle(color: Colors.grey[600]),
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
                  ),
                  const SizedBox(height: 10),

                 
             SizedBox(
  height: 60,
  child: DropdownButtonFormField<String>(
    value: role,
    icon: const Icon(Icons.keyboard_arrow_down_rounded),
    items: ["admin", "kasir", "owner"].map((item) {
      return DropdownMenuItem<String>(
        value: item,
        child: Row(
          children: [
           
            const SizedBox(width: 10),
            Text(
              item.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }).toList(),
    onChanged: (value) {
      setModalState(() {
        role = value!;
      });
    },
    decoration: InputDecoration(
      labelText: "Role",
      hintText: "Pilih role",
      hintStyle: TextStyle(color: Colors.grey[400]),
      labelStyle: TextStyle(color: Colors.grey[600]),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 14,
      ),

      // 🔥 INI YANG BIKIN SAMA
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
    ),
    dropdownColor: Colors.white,
    borderRadius: BorderRadius.circular(12),
  ),
),
                  const SizedBox(height: 20),

                  // TOMBOL AKSI
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffe53935),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () async {
                            if (usernameController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Username & Email wajib diisi"),
                                ),
                              );
                              return;
                            }

                            if (!isEdit && passwordController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Password wajib diisi"),
                                ),
                              );
                              return;
                            }

                            try {
                              if (isEdit) {
                                await supabase.rpc(
                                  'update_user',
                                  params: {
                                    'p_id': users[index]['id'],
                                    'p_username': usernameController.text,
                                    'p_nama': namaController.text,
                                    'p_role': role,
                                    'p_password': passwordController.text,
                                  },
                                );
                              } else {
                                await supabase.rpc(
                                  'insert_user',
                                  params: {
                                    'p_username': usernameController.text,
                                    'p_password': passwordController.text,
                                    'p_nama': namaController.text,
                                    'p_role': role,
                                  },
                                );
                              }

                              if (mounted) Navigator.pop(context);
                              getUsers();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error: $e")),
                              );
                            }
                          },
                          child: Text(
                            isEdit ? "Update" : "Simpan",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: const BorderSide(color: Colors.transparent),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Batal",
                            style: TextStyle(fontSize: 16),
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
      },
    );
  }

  void toggleStatus(int index) async {
    await supabase.rpc(
      'toggle_user_status',
      params: {'p_id': users[index]['id']},
    );

    getUsers();
  }

  @override
  Widget build(BuildContext context) {
    var filteredUsers = users.where((u) {
      final cocokSearch = u["username"].toString().toLowerCase().contains(
        search,
      );
      final cocokStatus = filterStatus == "semua"
          ? true
          : u["status"] == filterStatus;
      return cocokSearch && cocokStatus;
    }).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          formUser();
        },
        backgroundColor: Colors.red,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Tambah User", style: TextStyle(color: Colors.white)),
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
                      "Kelola User",
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
                SizedBox(
  height: 60,
  child: TextField(
    onChanged: (value) {
      setState(() {
        search = value.toLowerCase();
      });
    },
    decoration: InputDecoration(
      
      hintText: "Masukkan username",

      
      floatingLabelBehavior: FloatingLabelBehavior.auto,

      prefixIcon: const Icon(Icons.search),

      hintStyle: TextStyle(color: Colors.grey[400]),
      labelStyle: TextStyle(color: Colors.grey[600]),

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
),
                const SizedBox(height: 10),
               Row(
  children: [
    // FILTER STATUS
    Expanded(
      child: SizedBox(
        height: 55,
        child: DropdownButtonFormField<String>(
          value: filterStatus,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: const [
            DropdownMenuItem(value: "semua", child: Text("Semua Status")),
            DropdownMenuItem(value: "aktif", child: Text("Aktif")),
            DropdownMenuItem(value: "nonaktif", child: Text("Nonaktif")),
          ],
          onChanged: (value) {
            setState(() {
              filterStatus = value!;
            });
          },
         decoration: InputDecoration(
  labelText: "Status",
  hintText: "Pilih Status",


  floatingLabelBehavior: FloatingLabelBehavior.auto,

  hintStyle: TextStyle(color: Colors.grey[400]),
  labelStyle: TextStyle(color: Colors.grey[600]),

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
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    const SizedBox(width: 10),

    
    Expanded(
      child: SizedBox(
        height: 55,
        child: DropdownButtonFormField<String>(
          value: filterRole,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: const [
            DropdownMenuItem(value: "semua", child: Text("Semua Role")),
            DropdownMenuItem(value: "admin", child: Text("Admin")),
            DropdownMenuItem(value: "kasir", child: Text("Kasir")),
            DropdownMenuItem(value: "owner", child: Text("Owner")),
          ],
          onChanged: (value) {
            setState(() {
              filterRole = value!;
            });
          },
         decoration: InputDecoration(
  labelText: "Role",
  hintText: "Pilih role",

  // 🔥 INI PENTING
  floatingLabelBehavior: FloatingLabelBehavior.auto,

  hintStyle: TextStyle(color: Colors.grey[400]),
  labelStyle: TextStyle(color: Colors.grey[600]),

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
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  ],
)
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                var data = filteredUsers[index];
                bool aktif = data["status"].toString() == "aktif";

                return Card(
                  color: const Color.fromARGB(255, 239, 218, 218),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),

                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔹 Username utama
                        Text(
                          data["username"],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 2),

                        // 🔹 Nama kecil (abu)
                        Text(
                          data["nama"] ?? data["username"],
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // 🔹 Badge Role
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
                            data["role"],
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
                            formUser(index: index);
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

                        const SizedBox(width: 25),

                        GestureDetector(
                          onTap: () {
                            toggleStatus(index);
                          },
                          child: Text(
                            aktif ? "Aktif" : "Nonaktif",
                            style: TextStyle(
                              color: aktif ? Colors.green : Colors.red,
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
