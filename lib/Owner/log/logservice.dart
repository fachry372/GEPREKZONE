import 'package:geprekzone/auth/session.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class LogService {
  static final supabase = Supabase.instance.client;

  static Future<void> log(String aktivitas) async {
   
    if (UserSession.userId == null) {
      debugPrint("Gagal mencatat log: Session kosong (User belum login)");
      return;
    }

    try {
   
      String pesanLengkap = "[${UserSession.role?.toUpperCase()}] ${UserSession.nama}: $aktivitas";

      
      await supabase.from('log').insert({
        "id_users": UserSession.userId,
        "activity": pesanLengkap,
        
      });

      debugPrint("Log Berhasil: $pesanLengkap");
    } catch (e) {
      debugPrint("Error saat mencatat log: $e");
    }
  }
}