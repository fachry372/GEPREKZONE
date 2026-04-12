import 'package:flutter/material.dart';
import 'package:geprekzone/auth/session.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Transaksi.dart';

class PilihMejaPage extends StatefulWidget {

  final String tipePesanan;

  const PilihMejaPage({
    super.key,
    required this.tipePesanan,
  });

  @override
  State<PilihMejaPage> createState() => _PilihMejaPageState();
}

class _PilihMejaPageState extends State<PilihMejaPage> {

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
        title: const Text("Pilih Meja",style: TextStyle(color: Colors.white),),
      ),

     body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Pilih Meja Pelanggan",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Meja berwarna merah sedang digunakan. Pilih meja warna hijau untuk melanjutkan transaksi.",
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
                        onTap: terisi
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TransaksiPage(
                                      tipePesanan: widget.tipePesanan,
                                      meja: item["nomor_meja"].toString(),
                                    ),
                                  ),
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
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                terisi ? "Terisi" : "Kosong",
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            
          
        
      
    );
  }
}