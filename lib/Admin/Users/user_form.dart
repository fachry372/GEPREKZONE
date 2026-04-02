import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserForm extends StatefulWidget {
  final Map<String, dynamic>? user;
  final Function onSuccess;

  const UserForm({
    super.key,
    this.user,
    required this.onSuccess,
  });

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final supabase = Supabase.instance.client;

  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool obscurePassword = true;

  late TextEditingController usernameController;
  late TextEditingController namaController;
  late TextEditingController passwordController;

  String role = "kasir";
  String? usernameExistError;

  bool get isEdit => widget.user != null;

  @override
  void initState() {
    super.initState();

    usernameController =
        TextEditingController(text: widget.user?["username"] ?? "");
    namaController =
        TextEditingController(text: widget.user?["nama"] ?? "");
    passwordController = TextEditingController();

    if (isEdit) {
      role = widget.user!["role"];
    }
  }

  Future<bool> isUsernameExist(String username) async {
  final response = await supabase
      .from('users')
      .select('id')
      .eq('username', username)
      .maybeSingle();


  if (isEdit && username == widget.user!["username"]) {
    return false;
  }

  return response != null;
}

 Future<void> submit() async {
  setState(() {
    usernameExistError = null;
  });

  if (!_formKey.currentState!.validate()) return;

  setState(() => isLoading = true);

  // 🔥 cek username ke database
  bool exist = await isUsernameExist(usernameController.text);

  if (exist) {
    setState(() {
      isLoading = false;
      usernameExistError = "Username sudah digunakan";
    });

    _formKey.currentState!.validate(); // trigger ulang validator
    return;
  }

  try {
    if (isEdit) {
      await supabase.rpc('update_user', params: {
        'p_id': widget.user!['id'],
        'p_username': usernameController.text,
        'p_nama': namaController.text,
        'p_role': role,
        'p_password': passwordController.text,
      });
    } else {
      await supabase.rpc('insert_user', params: {
        'p_username': usernameController.text,
        'p_password': passwordController.text,
        'p_nama': namaController.text,
        'p_role': role,
      });
    }

    Navigator.pop(context);
    widget.onSuccess();
  } catch (e) {
    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Gagal: $e")),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 25,
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isEdit ? "Edit User" : "Tambah User",
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

         
            SizedBox(
              height: 70,
              child: TextFormField(
                controller: usernameController,
                validator: (value) {
  if (value == null || value.isEmpty) {
    return "Username wajib diisi";
  }
  if (value.length > 20) {
    return "Username maksimal 20 karakter";
  }
  if (usernameExistError != null) {
    return usernameExistError;
  }
  return null;
},
                decoration: InputDecoration(
                  labelText: "Username",
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // NAMA
            SizedBox(
              height: 70,
              child: TextFormField(
                controller: namaController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Nama wajib diisi";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: "Nama",
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // PASSWORD
            SizedBox(
              height: 70,
              child: TextFormField(
                controller: passwordController,
                obscureText: obscurePassword,
                validator: (value) {
                  if (!isEdit && (value == null || value.isEmpty)) {
                    return "Password wajib diisi";
                  }
                  if (value != null && value.isNotEmpty && value.length < 6) {
                    return "Minimal 6 karakter";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: isEdit
                      ? "Password (opsional)"
                      : "Password",
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),

                  // 👁️ toggle password
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ROLE
            SizedBox(
              height: 60,
              child: DropdownButtonFormField<String>(
                value: role,
                items: ["admin", "kasir", "owner"].map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    role = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Role",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            
           Row(
  children: [
    Expanded(
      child: ElevatedButton(
        onPressed: isLoading ? null : submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xffff3d00), // merah/orange
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // 🔥 full rounded
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
                isEdit ? "Simpan" : "Simpan",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: ElevatedButton(
        onPressed: isLoading ? null : () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xffe0c7c7), // abu pink soft
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // 🔥 full rounded
          ),
          elevation: 0,
        ),
        child: const Text(
          "Batal",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ),
  ],
),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}