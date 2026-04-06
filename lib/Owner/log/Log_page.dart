import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> logs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getLogs();
  }

  Future<void> getLogs() async {
    final response = await supabase
        .from('log')
        .select()
        .order('created_at', ascending: false);

    setState(() {
      logs = List<Map<String, dynamic>>.from(response);
      isLoading = false;
    });
  }

  String formatDate(String date) {
    final d = DateTime.parse(date);
    return "${d.day}-${d.month}-${d.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      /// APPBAR
      appBar: AppBar(
        backgroundColor: const Color(0xffe53935),
        centerTitle: true,
        title: const Text(
          "Log Aktivitas",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [

                /// 🔥 FILTER TANGGAL
                Row(
                  children: [
                    Expanded(child: tombolTanggal("Tanggal Awal")),
                    const SizedBox(width: 10),
                    Expanded(child: tombolTanggal("Tanggal Akhir")),
                  ],
                ),

                const SizedBox(height: 15),

                /// 🔥 DROPDOWN ROLE
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: "Semua Role",
                      items: const [
                        DropdownMenuItem(
                          value: "Semua Role",
                          child: Text("Semua Role"),
                        ),
                      ],
                      onChanged: (value) {},
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                /// 🔥 LIST LOG
                ...logs.map((log) {
                  return itemLog(
                    log["activity"] ?? "-",
                    formatDate(log["created_at"]),
                  );
                }).toList(),
              ],
            ),
    );
  }

  /// 🔥 WIDGET TOMBOL TANGGAL
  Widget tombolTanggal(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xffe53935),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_month, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  /// 🔥 ITEM LOG (CARD)
  Widget itemLog(String activity, String tanggal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffd7c2c2), // mirip gambar
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [

          /// ICON
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xffe53935).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.security,
              color: Color(0xffe53935),
            ),
          ),

          const SizedBox(width: 12),

          /// TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  tanggal,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          /// ARROW
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}