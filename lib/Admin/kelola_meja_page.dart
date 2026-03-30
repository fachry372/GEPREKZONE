import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KelolaMejaPage extends StatefulWidget {
  const KelolaMejaPage({super.key});

  @override
  State<KelolaMejaPage> createState() => _KelolaMejaPageState();
}

class _KelolaMejaPageState extends State<KelolaMejaPage> {

final supabase = Supabase.instance.client;
String search = "";
String filterStatus = "semua";

List<Map<String,dynamic>> meja = [];

 Future<void> getMeja() async {
  final response = await supabase
      .from('meja')
      .select()
      .order('id', ascending: true);

  setState(() {
    meja = List<Map<String, dynamic>>.from(response);
  });
}

@override
void initState() {
  super.initState();
  getMeja();
}
  /// FORM TAMBAH / EDIT
  void formMeja({int? index}) {

    bool isEdit = index != null;

    TextEditingController nomor =
        TextEditingController(
            text: isEdit ? meja[index]["nomor_meja"] : "");

    String status =
        isEdit ? meja[index]["status"] : "kosong";

    showDialog(

      context: context,

      builder: (context){

        return AlertDialog(

          title: Text(
              isEdit ? "Edit Meja" : "Tambah Meja"
          ),

          content: Column(

            mainAxisSize: MainAxisSize.min,

            children: [

              TextField(
                controller: nomor,
                decoration: const InputDecoration(
                  labelText: "Nomor Meja",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height:15),

              DropdownButtonFormField(

                value: status,

                items: const [

                  DropdownMenuItem(
                      value:"kosong",
                      child: Text("Kosong")
                  ),

                  DropdownMenuItem(
                      value:"terisi",
                      child: Text("Terisi")
                  ),

                ],

                onChanged: (value){

                  status = value.toString();

                },

                decoration: const InputDecoration(
                  labelText: "Status",
                  border: OutlineInputBorder(),
                ),

              )

            ],

          ),

          actions: [

            TextButton(

              onPressed: (){
                Navigator.pop(context);
              },

              child: const Text("Batal"),

            ),

            ElevatedButton(

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),

            onPressed: () async {

  if (nomor.text.isEmpty) return;

  if (isEdit) {
    // UPDATE
    await supabase.from('meja').update({
      'nomor_meja': nomor.text,
      'status': status
    }).eq('id', meja[index]["id"]);
  } else {
    // INSERT
    await supabase.from('meja').insert({
      'nomor_meja': nomor.text,
      'status': status
    });
  }

  Navigator.pop(context);
  getMeja(); // refresh data
},

              child: Text(
                  isEdit ? "Update" : "Simpan"
              ),

            )

          ],

        );

      }

    );

  }

 void toggleStatus(int index) async {

  String newStatus =
      meja[index]["status"] == "kosong"
          ? "terisi"
          : "kosong";

  await supabase.from('meja').update({
    'status': newStatus
  }).eq('id', meja[index]["id"]);

  getMeja();
}


 void hapusMeja(int index) async {

  await supabase
      .from('meja')
      .delete()
      .eq('id', meja[index]["id"]);

  getMeja();
}

  @override
  Widget build(BuildContext context) {

     var filteredMeja = meja.where((m) {
    final cocokSearch = m["nomor_meja"]
        .toString()
        .toLowerCase()
        .contains(search);

    final cocokStatus = filterStatus == "semua"
        ? true
        : m["status"] == filterStatus;

    return cocokSearch && cocokStatus;
  }).toList();

    return Scaffold(

      floatingActionButton: FloatingActionButton.extended(

        onPressed: (){
          formMeja();
        },

        backgroundColor: Colors.red,

        icon: const Icon(Icons.add),

        label: const Text("Tambah Meja"),

      ),

      body: Column(

        children: [

      
Container(
  width: double.infinity,
  padding: const EdgeInsets.fromLTRB(10, 40, 10, 10),
  decoration: const BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Color(0xffe53935),
        Color(0xffb71c1c)
      ],
    ),
  ),
  child: Stack(
    alignment: Alignment.center,
    children: [

      /// BUTTON BACK
      Align(
        alignment: Alignment.centerLeft,
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
      ),

     
      const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          
          Text(
            "Kelola Meja",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),

    ],
  ),
),

Padding(
  padding: const EdgeInsets.all(12),
  child: Column(
    children: [

      /// SEARCH
      TextField(
        onChanged: (value) {
          setState(() {
            search = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: "Cari meja",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),

      const SizedBox(height: 10),

      /// FILTER STATUS
      DropdownButtonFormField(
        value: filterStatus,
        items: const [
          DropdownMenuItem(value: "semua", child: Text("Semua Status")),
          DropdownMenuItem(value: "kosong", child: Text("Kosong")),
          DropdownMenuItem(value: "terisi", child: Text("Terisi")),
        ],
        onChanged: (value) {
          setState(() {
            filterStatus = value.toString();
          });
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    ],
  ),
),


          /// LIST MEJA
          Expanded(
            

            child: ListView.builder(
               padding: EdgeInsets.zero,
           itemCount: filteredMeja.length,

              itemBuilder: (context,index){

                var data = filteredMeja[index];

                bool terisi =
                    data["status"] == "terisi";

                return Card(
                color: Color.fromARGB(0, 255, 124, 124),
                  margin: const EdgeInsets.symmetric(
                      horizontal:12,
                      vertical:6
                  ),

                  child: ListTile(

                    leading: CircleAvatar(

                      backgroundColor:
                      terisi
                          ? Colors.red
                          : Colors.green,

                      child: const Icon(
                        Icons.table_restaurant,
                        color: Colors.white,
                      ),

                    ),

                    title: Text(
                      "Meja ${data["nomor_meja"]}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold
                      ),
                    ),

                    subtitle: Text(
                        terisi
                            ? "Terisi"
                            : "Kosong"
                    ),

                    trailing: Row(

                      mainAxisSize: MainAxisSize.min,

                      children: [

                        IconButton(

                          icon: const Icon(Icons.sync),

                          onPressed: (){
                            toggleStatus(index);
                          },

                        ),

                        IconButton(

                          icon: const Icon(
                              Icons.edit,
                              color: Colors.blue
                          ),

                          onPressed: (){
                            formMeja(index:index);
                          },

                        ),

                        IconButton(

                          icon: const Icon(
                              Icons.delete,
                              color: Colors.red
                          ),

                          onPressed: (){
                            hapusMeja(index);
                          },

                        )

                      ],

                    ),

                  ),

                );

              },

            ),

          )

        ],

      ),

    );

  }

}