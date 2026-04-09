import 'package:flutter/material.dart';
import 'package:geprekzone/Owner/log/detaillog_page.dart';
import 'package:geprekzone/Owner/owner_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  final supabase = Supabase.instance.client;

  String selectedRole = "Semua Role"; 
TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> logs = [];
  bool isLoading = true;

  DateTime? startDate;
DateTime? endDate;

Future<void> pilihTanggal(bool isStart) async {
  DateTime initial = DateTime.now();

  final picked = await showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: DateTime(2020),
    lastDate: DateTime(2100),
  );

  if (picked != null) {
    setState(() {
      if (isStart) {
        startDate = picked;
      } else {
        endDate = picked;
      }
    });

    getLogs(); 
  }
}

  @override
  void initState() {
    super.initState();
    getLogs();
  }

 Future<void> getLogs() async {
  setState(() {
    isLoading = true;
  });

  try {
    var query = supabase.from('log').select();

    
    if (startDate != null && endDate != null) {
      query = query
          .gte(
            'created_at',
            DateTime(startDate!.year, startDate!.month, startDate!.day)
                .toIso8601String(),
          )
          .lt(
            'created_at',
            DateTime(endDate!.year, endDate!.month, endDate!.day + 1)
                .toIso8601String(),
          );
    } else if (startDate != null) {
      query = query.gte(
        'created_at',
        DateTime(startDate!.year, startDate!.month, startDate!.day)
            .toIso8601String(),
      );
    } else if (endDate != null) {
      query = query.lt(
        'created_at',
        DateTime(endDate!.year, endDate!.month, endDate!.day + 1)
            .toIso8601String(),
      );
    }

   
    final response =
        await query.order('created_at', ascending: false);

    final users = await supabase
        .from('users')
        .select('id, username, role');

  
    final usersMap = {
      for (var u in users) u['id']: u
    };

    List<Map<String, dynamic>> merged =
        List<Map<String, dynamic>>.from(response).map((log) {
      final user = usersMap[log['id_users']];
      return {
        ...log,
        'username': user?['username'] ?? '-',
        'role': user?['role'] ?? '-',
      };
    }).toList();

  
    if (selectedRole != "Semua Role") {
  merged = merged.where((e) {
    final role = (e['role'] ?? '').toString().toLowerCase().trim();
    final selected = selectedRole.toLowerCase().trim();
    return role == selected;
  }).toList();
}

  
   if (searchController.text.isNotEmpty) {
  merged = merged.where((e) {
    final username =
        (e['username'] ?? '').toString().toLowerCase().trim();

    final keyword =
        searchController.text.toLowerCase().trim();

    return username.contains(keyword);
  }).toList();
}

    setState(() {
      logs = merged;
      isLoading = false;
    });
  } catch (e) {
    print("Error: $e");
    setState(() {
      isLoading = false;
    });
  }
}

  String formatDate(String date) {
    final d = DateTime.parse(date);
    return "${d.day}-${d.month}-${d.year}";
  }

  Future<void> refreshData() async {
  setState(() {
    startDate = null;
    endDate = null;

    selectedRole = "Semua Role";
    searchController.clear();    
  });


  

  await getLogs();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(

       drawer: const OwnerDrawer(),
      backgroundColor: Colors.grey[200],

      
      appBar: AppBar(
  backgroundColor: const Color(0xffe53935),
  centerTitle: true,
  title: const Text(
    "Log Aktivitas",
    style: TextStyle(color: Colors.white),
  ),
  iconTheme: const IconThemeData(color: Colors.white),
),
     body:
      RefreshIndicator(
        color: Colors.red,
        onRefresh: refreshData,
        child: Column(
          children: [
        
          
            Padding(
        padding: const EdgeInsets.all(16),
        child:Column(
  children: [
    Row(
      children: [
        Expanded(child: tombolTanggal("Tanggal Awal", true)),
        const SizedBox(width: 10),
        Expanded(child: tombolTanggal("Tanggal Akhir", false)),
      ],
    ),

    const SizedBox(height: 15),

    
    TextFormField(
      controller: searchController,
      decoration: InputDecoration(
        hintText: "Cari username...",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (value) {
        getLogs();
      },
    ),

    const SizedBox(height: 10),

    
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedRole,
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: "Semua Role", child: Text("Semua Role")),
            DropdownMenuItem(value: "admin", child: Text("Admin")),
            DropdownMenuItem(value: "kasir", child: Text("Kasir")),
          ],
          onChanged: (value) {
            setState(() {
              selectedRole = value!;
            });
            getLogs();
          },
        ),
      ),
    ),
  ],
)
            ),
        
           
            Expanded(
        
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.red,))
              : logs.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 150),
                        Center(
                          child: Text(
                            "Tidak ada data log",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        final log = logs[index];
                        return itemLog(
                          log["username"] ?? "-", 
                          log["activity"] ?? "-",
                          formatDate(log["created_at"]),
                          log,
                        );
                      },
                    ),
        ),
            
          ],
        ),
      )
    );
  }

 Widget tombolTanggal(String text, bool isStart) {
  DateTime? selected = isStart ? startDate : endDate;

  return InkWell(
    onTap: () => pilihTanggal(isStart),
    borderRadius: BorderRadius.circular(25),
    child: Container(
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
            selected == null
                ? text
                : "${selected.day}-${selected.month}-${selected.year}",
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    ),
  );
}

  
Widget itemLog(String username, String activity, String tanggal, Map log) {
  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailLogPage(log: log),
        ),
      );
    },
    borderRadius: BorderRadius.circular(12),
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xffe53935).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history,
              color: Color(0xffe53935),
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(username,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(activity),
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

          const Icon(Icons.chevron_right),
        ],
      ),
    ),
  );
}
}