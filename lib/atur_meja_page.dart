import 'package:flutter/material.dart';

class AturMejaPage extends StatefulWidget {
  const AturMejaPage({super.key});

  @override
  State<AturMejaPage> createState() => _AturMejaPageState();
}

class _AturMejaPageState extends State<AturMejaPage> {

  // true = terisi (merah)
  // false = kosong (hijau)
  List<bool> mejaStatus = [
    false, true, false,
    false, true, false,
    false, false, true
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text("Atur Meja"),
        backgroundColor: Colors.red,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: mejaStatus.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {

            bool terisi = mejaStatus[index];

            return GestureDetector(
              onTap: () {
                setState(() {
                  mejaStatus[index] = !mejaStatus[index];
                });
              },

              child: Container(
                decoration: BoxDecoration(
                  color: terisi ? Colors.red : Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    const Icon(
                      Icons.table_bar,
                      color: Colors.white,
                      size: 30,
                    ),

                    const SizedBox(height: 5),

                    Text(
                      "Meja ${index + 1}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      terisi ? "Terisi" : "Kosong",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),

                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}