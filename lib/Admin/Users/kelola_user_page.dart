import 'package:flutter/material.dart';
import 'package:geprekzone/Admin/Users/user_form.dart';
import 'package:geprekzone/Admin/admin_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

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

  String? usernameError;
String? namaError;
String? passwordError;

  List<Map<String, dynamic>> users = [];

 void showNotif({
  required String message,
  required bool isSuccess,
}) {
  AwesomeDialog(
    context: context,
    dialogType: isSuccess ? DialogType.success : DialogType.error,
    animType: AnimType.scale,
    title: isSuccess ? "Berhasil" : "Gagal",
    desc: message,
    btnOkOnPress: () {},
  ).show();
} 

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

void formTambahUser() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (context) {
      return UserForm(
        onSuccess: () {
          showNotif(
            message: "User berhasil ditambahkan",
            isSuccess: true,
          );
          getUsers();
        },
      );
    },
  );
}

void formEditUser(int index) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (context) {
      return UserForm(
        user: users[index],
        onSuccess: () {
          showNotif(
            message: "User berhasil diupdate",
            isSuccess: true,
          );
          getUsers();
        },
      );
    },
  );
}
 void toggleStatus(int index) {
  bool aktif = users[index]["status"] == "aktif";

  AwesomeDialog(
    context: context,
    dialogType: DialogType.warning,
    animType: AnimType.bottomSlide,
    title: aktif ? "Nonaktifkan User?" : "Aktifkan User?",
    desc: "Apakah kamu yakin ingin mengubah status user ini?",
    btnCancelOnPress: () {},
    btnOkOnPress: () async {
      await supabase.rpc('toggle_user_status', params: {
        'p_id': users[index]['id'],
      });

      showNotif(
        message: aktif
            ? "User berhasil dinonaktifkan"
            : "User berhasil diaktifkan",
        isSuccess: true,
      );

      getUsers();
    },
  ).show();
}

  @override
  Widget build(BuildContext context) {
  var filteredUsers = users.where((u) {
  final cocokSearch = u["username"]
      .toString()
      .toLowerCase()
      .contains(search);

  final cocokStatus = filterStatus == "semua"
      ? true
      : u["status"] == filterStatus;

  final cocokRole = filterRole == "semua"
      ? true
      : u["role"] == filterRole;

  return cocokSearch && cocokStatus && cocokRole;
}).toList();

    return Scaffold(
       drawer: const AdminDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          formTambahUser();
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
                            DropdownMenuItem(
                              value: "semua",
                              child: Text("Semua Status"),
                            ),
                            DropdownMenuItem(
                              value: "aktif",
                              child: Text("Aktif"),
                            ),
                            DropdownMenuItem(
                              value: "nonaktif",
                              child: Text("Nonaktif"),
                            ),
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
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                              ),
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
                            DropdownMenuItem(
                              value: "semua",
                              child: Text("Semua Role"),
                            ),
                            DropdownMenuItem(
                              value: "admin",
                              child: Text("Admin"),
                            ),
                            DropdownMenuItem(
                              value: "kasir",
                              child: Text("Kasir"),
                            ),
                            DropdownMenuItem(
                              value: "owner",
                              child: Text("Owner"),
                            ),
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
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
  child: filteredUsers.isEmpty
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
                            formEditUser(index);
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
