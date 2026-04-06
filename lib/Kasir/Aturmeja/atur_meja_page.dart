import 'package:flutter/material.dart';
import 'package:geprekzone/Kasir/Transaksi/Transaksi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class AturMejaPage extends StatefulWidget {

  final String tipePesanan;

  const AturMejaPage({
    super.key,
    required this.tipePesanan,
  });

  @override
  State<AturMejaPage> createState() => _PilihAturMejaPageState();
}

class _PilihAturMejaPageState extends State<AturMejaPage> {

   final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> meja = [];
  bool isLoading = true;

  Future<void> getMeja() async {
    final response = await supabase
        .from('meja')
        .select()
        .order('id', ascending: true);

    setState(() {
      meja = List<Map<String, dynamic>>.from(response);
      isLoading = false;
    });
  }

  Future<void> updateStatusMeja(int id, String statusSekarang) async {
  String statusBaru = statusSekarang == "terisi" ? "kosong" : "terisi";

  await supabase
      .from('meja')
      .update({"status": statusBaru})
      .eq('id', id);

  getMeja(); 
}

  @override
  void initState() {
    super.initState();
    getMeja();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.red,
        centerTitle: true,
        iconTheme: const IconThemeData(
    color: Colors.white, 
  ),
        title: const Text("Pilih Meja",style: TextStyle(color: Colors.white),),
      ),

    body: isLoading
    ? const Center(child: CircularProgressIndicator())
    : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const SizedBox(height: 10,),

       Padding(
  padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      
      const Text(
        "Kelola Status Meja",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 4),

    
      Text(
        "Ketuk meja untuk mengubah statusnya menjadi kosong atau terisi.",
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
        ),
      ),

    ],
  ),
),

        
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
              ),
              itemCount: meja.length,
              itemBuilder: (context, index) {

          var item = meja[index];
          bool terisi = item["status"] == "terisi";

          return InkWell(

           onTap: () {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            /// HANDLE
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 15),

            /// TITLE
            Text(
              "Ubah Status Meja",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            /// INFO
            Text(
              "Meja ${item["nomor_meja"]} akan diubah menjadi ${terisi ? "Kosong" : "Terisi"}",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),

            const SizedBox(height: 20),

            /// BUTTON
            Row(
              children: [

                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Batal"),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () async {
                      await updateStatusMeja(
                          item["id"], item["status"]);

                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Ya, Ubah",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),

          ],
        ),
      );
    },
  );
},

            child: Container(
              decoration: BoxDecoration(
                color: terisi ? Colors.red.shade400 : Colors.green.shade400,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 5)
                ],
              ),

              child: Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [

    const Icon(
      Icons.table_restaurant_rounded,
      color: Colors.white,
      size: 40,
    ),

    const SizedBox(height: 5),

    Text(
      "Meja ${item["nomor_meja"]}",
      style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.white
      ),
    ),

    Text(
      terisi ? "Terisi" : "Kosong",
      style: const TextStyle(color: Colors.white70),
    ),

  ],
)
            ),
          );
        },
      ),
          )
        ]
    )
    
    );
    
  }
}