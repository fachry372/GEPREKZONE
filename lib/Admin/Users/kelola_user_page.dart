import 'package:flutter/material.dart';
import 'package:geprekzone/Admin/Users/user_form.dart';
import 'package:geprekzone/Admin/admin_drawer.dart';
import 'package:geprekzone/Owner/log/logservice.dart';
import 'package:geprekzone/auth/session.dart';
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

  String? usernameError;
String? namaError;
String? passwordError;

  List<Map<String, dynamic>> users = [];

 void showSnack(String message, {bool isSuccess = true}) {
  final messenger = ScaffoldMessenger.of(context);

  messenger.clearSnackBars(); 

  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isSuccess ? Colors.green : Colors.red,

    ),
  );
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
          showSnack("User berhasil ditambahkan");
          getUsers();
        },
      );
    },
  );
}

void formEditUser(int index) {
   final user = users[index];
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (context) {
      return UserForm(
        user: user,
  disableRole: user['id'] == UserSession.userId, 

        onSuccess: () {
          showSnack("User berhasil diupdate");
          getUsers();
        },
      );
    },
  );
}
 void toggleStatus(int index) {
  final user = users[index];


  if (user['id'] == UserSession.userId) {
    showSnack("Tidak bisa menonaktifkan akun yang sedang dipakai ", isSuccess: false);
    return;
  }

  bool aktif = users[index]["status"] == "aktif";

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              aktif ? "Nonaktifkan User?" : "Aktifkan User?",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text("Apakah kamu yakin ingin mengubah status user ini?"),

            const SizedBox(height: 20),

            Row(
              children: [
              
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 235, 212, 214), 
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

                  const SizedBox(width: 10),

                 Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);

                      await supabase.rpc('toggle_user_status', params: {
                        'p_id': users[index]['id'],
                      });

                      await LogService.log(
                        "${aktif ? 'Menonaktifkan' : 'Mengaktifkan'} user: ${users[index]['username']}",
                      );

                      getUsers();

                      showSnack(
                        aktif
                            ? "User berhasil dinonaktifkan"
                            : "User berhasil diaktifkan",
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Ya",
                      style: TextStyle(color: Colors.white),
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
                  color: Colors.white,
elevation: 3,
shadowColor: Colors.black26,
shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(12),
),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),

                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                 
                        Text(
                          data["username"],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 2),

                      
                        Text(
                          data["nama"] ?? data["username"],
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(height: 6),

                      
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

                       Opacity(
  opacity: data['id'] == UserSession.userId ? 0.5 : 1,
  child: GestureDetector(
    onTap: data['id'] == UserSession.userId
        ? null
        : () {
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
