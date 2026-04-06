import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geprekzone/auth/session.dart';

class LogService {
  static final supabase = Supabase.instance.client;

  static Future<void> log(String activity) async {
    final userId = UserSession.userId;

    if (userId == null) return;

    try {
      await supabase.from('log').insert({
        "id_users": userId,
        "activity": activity,
      });
    } catch (e) {
      print("Log error: $e"); 
    }
  }
}