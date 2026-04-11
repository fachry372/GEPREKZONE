import 'package:flutter/material.dart';

class UserSession {
  static String? userId;
  static String? username;
  static String? role; 
  static String? nama;

 
  static void fromJson(Map<String, dynamic> json) {
    userId   = json['id'].toString(); 
    username = json['username'];
    role     = json['role'].toString().toLowerCase(); 
    nama     = json['nama'];
  }

  static void hapusSession() {
    userId = null;
    username = null;
    role = null;
    nama = null;
  }

  static bool isLoggedIn() => userId != null;

 static void cekAkses(BuildContext context, List<String> roleDiizinkan) {
    if (!isLoggedIn()) {
      _kirimKeLogin(context, "Silakan login terlebih dahulu");
      return;
    }

    if (!roleDiizinkan.contains(role)) {
      
      _kirimKeLogin(context, "Akses Ditolak: Role $role tidak diizinkan di sini");
    }
  }

static void _kirimKeLogin(BuildContext context, String pesan) {
  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(pesan)),
  );
}
}