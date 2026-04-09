import 'package:flutter/material.dart';

class DetailLogPage extends StatelessWidget {
  final Map log;

  const DetailLogPage({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Detail Log",style: TextStyle(color: Colors.white),),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xffe53935),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Username: ${log['username']}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),

            Text("Role: ${log['role']}"),
            const SizedBox(height: 10),

            Text("Aktivitas: ${log['activity']}"),
            const SizedBox(height: 10),

            Text("Tanggal: ${log['created_at']}"),
          ],
        ),
      ),
    );
  }
}