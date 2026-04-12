import 'package:flutter/material.dart';
import 'package:geprekzone/Owner/log/logservice.dart';
import 'package:geprekzone/auth/session.dart';
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
        .order('nomor_meja', ascending: true);

    setState(() {
      meja = List<Map<String, dynamic>>.from(response);
      isLoading = false;
    });
  }

  Future<void> updateStatusMeja(int id, String statusSekarang,String nomorMeja) async {
  String statusBaru = statusSekarang == "terisi" ? "kosong" : "terisi";
try {
 
    await supabase
        .from('meja')
        .update({"status": statusBaru})
        .eq('id', id);

 
    await LogService.log(
      "Mengubah status Meja $nomorMeja dari '$statusSekarang' menjadi '$statusBaru'."
    );

    getMeja(); 
  } catch (e) {
    
    await LogService.log("GAGAL mengubah status Meja $nomorMeja: $e");
  }
}

void tampilkanPesan(String nomor, String status) {
  if (!mounted) return;
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("Status meja $nomor berhasil diubah menjadi $status"),
      backgroundColor: Colors.green,
    
    ),
  );
}

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    UserSession.cekAkses(context, ['kasir']);
  });
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
        title: const Text("Atur Meja",style: TextStyle(color: Colors.white),),
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
    backgroundColor: Colors.transparent, 
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),

         
            const Text(
              "Ubah Status Meja?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            
            const SizedBox(height: 8),

           
            Text(
              "Apakah Anda yakin ingin mengubah status Meja ${item["nomor_meja"]} menjadi ${terisi ? "Kosong" : "Terisi"}?",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 235, 212, 214), 
                      side: BorderSide.none,      
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text("Batal", style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                 
onPressed: () async {
  String nomorMeja = item["nomor_meja"].toString();
  String statusLama = item["status"]; 
  String statusBaruIndo = terisi ? "Kosong" : "Terisi";

  Navigator.pop(context); 


  await updateStatusMeja(item["id"], statusLama, nomorMeja);
  
  tampilkanPesan(nomorMeja, statusBaruIndo);
},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Ya, Ubah",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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