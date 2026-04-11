import 'package:flutter/material.dart';


class DetailLogSheet extends StatelessWidget {
  final Map log;

  const DetailLogSheet({super.key, required this.log});

  @override
  Widget build(BuildContext context) {

DateTime createdAt = DateTime.parse(log['created_at'].toString()).toLocal();

String tanggalSaja = "${createdAt.day.toString().padLeft(2, '0')}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.year}";
String waktuSaja = "${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')} ";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const Text(
            "Detail Log Aktivitas",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 30),
          
          _buildDetailRow("Username", log['username']),
          _buildDetailRow("Role", log['role']),
          _buildDetailRow("Aktivitas", log['activity']),
      
          _buildDetailRow("Tanggal", tanggalSaja),
          _buildDetailRow("Waktu", waktuSaja),
          
          const SizedBox(height: 20),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffe53935),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Tutup", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
  
  String displayValue = (value == null) ? "-" : value.toString();

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 2),
        Text(
          displayValue, 
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)
        ),
      ],
    ),
  );
}
}